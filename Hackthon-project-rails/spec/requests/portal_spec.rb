require "rails_helper"

RSpec.describe "The applicant and organizer workflow", type: :request do
  let(:password) { "correct horse battery staple" }
  let(:invite) { "test-only-organizer-invitation-32-characters" }
  let(:answers) do
    { organization: "UC Berkeley", skills: "Ruby, teamwork, product design",
      motivation: "I want to learn from teammates and build useful tools for students.",
      experience: "I would build an app that helps students find project partners with shared interests.",
      availability: "Saturday 2–6 PM Pacific", portfolio_url: "https://example.com/project" }
  end

  def register(role: "hacker", email: "applicant@example.test", code: nil)
    post sign_up_path, params: { user: { name: "Portal Applicant", email: email, password: password, password_confirmation: password, role: role, invite_code: code } }
  end

  def sign_in(email)
    post sign_in_path, params: { email: email, password: password }
  end

  before { allow(ENV).to receive(:fetch).and_call_original; allow(ENV).to receive(:fetch).with("ORGANIZER_INVITE_CODE", "").and_return(invite) }

  it "renders a normal public homepage, with registration and sign-in" do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Create an account", "Sign in with email")
    expect(response.body).not_to include("Try the interactive demo")
  end

  it "requires sign-in and prevents applicant access to organizer pages" do
    get application_path
    expect(response).to redirect_to(sign_in_path)
    register
    get organizer_applications_path
    expect(response).to have_http_status(:forbidden)
  end

  it "requires an authentic CSRF token when protection is enabled" do
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    register
    expect(response).to have_http_status(:unprocessable_entity)
    expect(User.count).to eq(0)
    get sign_up_path
    token = Nokogiri::HTML(response.body).at_css('input[name="authenticity_token"]')['value']
    post sign_up_path, params: { authenticity_token: token, user: { name: "CSRF Applicant", email: "csrf@example.test", password: password, password_confirmation: password, role: "hacker" } }
    expect(response).to redirect_to(application_path)
    get "/application.css"
    expect(response).to have_http_status(:ok)
  ensure
    ActionController::Base.allow_forgery_protection = previous
  end

  it "persists drafts, submits, grades, and displays the decision without private notes" do
    register
    expect(response).to redirect_to(application_path)
    post application_path, params: { hack_application: answers.except(:experience), intent: "save" }
    application = User.find_by!(email: "applicant@example.test").hack_application
    expect(application).to be_draft
    get application_path
    expect(response.body).to include("Ruby, teamwork", "Save draft")
    patch application_path, params: { hack_application: answers.merge(lock_version: application.lock_version), intent: "submit" }
    expect(application.reload.status).to eq("submitted")
    delete sign_out_path
    register(role: "organizer", email: "reviewer@example.test", code: invite)
    expect(response).to redirect_to(organizer_applications_path)
    get organizer_applications_path
    expect(response.body).to include("applicant@example.test", "Submitted")
    get organizer_application_path(application)
    expect(response).to have_http_status(:ok)
    patch organizer_application_review_path(application), params: { review: { lock_version: application.lock_version, readiness: 4, impact: 5, collaboration: 4, notes: "Private thoughtful assessment", decision: "accepted" } }
    expect(application.reload.status).to eq("accepted")
    expect(application.review.total).to eq(13)
    delete sign_out_path
    sign_in("applicant@example.test")
    get application_path
    expect(response.body).to include("Accepted", "Submitted applications are read-only")
    expect(response.body).not_to include("Private thoughtful assessment")
    patch application_path, params: { hack_application: answers.merge(skills: "Changed"), intent: "save" }
    expect(application.reload.skills).to eq(answers[:skills])
  end

  it "gives mentors their own form and requires availability at submission" do
    register(role: "mentor")
    get application_path
    expect(response.body).to include("Mentor application", "A hacker is stuck", "available to mentor")
    post application_path, params: { hack_application: answers.merge(availability: ""), intent: "submit" }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(HackApplication.count).to eq(0)
    post application_path, params: { hack_application: answers, intent: "submit" }
    expect(HackApplication.last.status).to eq("submitted")
  end

  it "rejects an organizer role without the private invitation" do
    register(role: "organizer", code: "wrong")
    expect(response).to have_http_status(:unprocessable_entity)
    expect(User.count).to eq(0)
    register(role: "organizer", code: invite)
    expect(User.last).to be_organizer
  end

  it "hashes passwords, rejects duplicates and wrong credentials, and revokes logout sessions" do
    register
    user = User.last
    expect(user.password_digest).not_to eq(password)
    expect(user.authenticate(password)).to eq(user)
    expect(LoginSession.count).to eq(1)
    delete sign_out_path
    expect(LoginSession.count).to eq(0)
    get application_path
    expect(response).to redirect_to(sign_in_path)
    register(email: "APPLICANT@example.test")
    expect(response).to have_http_status(:unprocessable_entity)
    post sign_in_path, params: { email: user.email, password: "wrong" }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Email or password is incorrect")
    sign_in(user.email)
    expect(response).to redirect_to(application_path)
  end

  it "scopes each applicant's form to their own account" do
    register
    post application_path, params: { hack_application: answers, intent: "submit" }
    first = HackApplication.last
    delete sign_out_path
    register(email: "second@example.test")
    get application_path
    expect(response.body).not_to include(answers[:motivation])
    patch application_path, params: { hack_application: answers.merge(user_id: first.user_id), intent: "save" }
    expect(response).to have_http_status(:not_found)
    expect(first.reload.status).to eq("submitted")
  end

  it "protects newer drafts from stale browser tabs" do
    register
    post application_path, params: { hack_application: answers, intent: "save" }
    patch application_path, params: { hack_application: { skills: "A newer answer", lock_version: 0 }, intent: "save" }
    patch application_path, params: { hack_application: { skills: "A stale answer", lock_version: 0 }, intent: "save" }
    expect(HackApplication.last.skills).to eq("A newer answer")
  end

  it "rejects incomplete submissions and unsafe links" do
    register
    post application_path, params: { hack_application: { motivation: "short" }, intent: "submit" }
    expect(response).to have_http_status(:unprocessable_entity)
    post application_path, params: { hack_application: answers.merge(portfolio_url: "javascript:alert(1)"), intent: "submit" }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(HackApplication.count).to eq(0)
  end

  it "uses a persistent login attempt limit" do
    10.times { post sign_in_path, params: { email: "unknown@example.test", password: password } }
    post sign_in_path, params: { email: "unknown@example.test", password: password }
    expect(response).to have_http_status(:too_many_requests)
  end

  it "hides identifying fields from blind review HTML and protects review decisions" do
    register
    post application_path, params: { hack_application: answers, intent: "submit" }
    application = HackApplication.last
    delete sign_out_path
    register(role: "organizer", email: "reviewer@example.test", code: invite)
    get organizer_application_path(application, blind: "1")
    expect(response.body).not_to include("applicant@example.test", "UC Berkeley", "https://example.com/project")
    bad_review = { lock_version: 0, readiness: 8, impact: 5, collaboration: 4, decision: "accepted" }
    patch organizer_application_review_path(application), params: { review: bad_review }
    expect(application.reload.status).to eq("submitted")
    expect(Review.count).to eq(0)
    good_review = bad_review.merge(readiness: 4)
    patch organizer_application_review_path(application), params: { review: good_review }
    patch organizer_application_review_path(application), params: { review: good_review.merge(decision: "declined") }
    expect(application.reload.status).to eq("accepted")
  end
end
