Given("I have registered as a {word}") do |role|
  visit sign_up_path
  fill_in "Full name", with: "Test Applicant"
  fill_in "Email address", with: "cucumber@example.test"
  select(role == "mentor" ? "Mentor — help others build" : "Hacker — build with a team", from: "I'm joining as a")
  fill_in "user_password", with: "correct horse battery staple"
  fill_in "Confirm password", with: "correct horse battery staple"
  click_button "Create account"
end

When("I fill out my application") do
  fill_in "School or organization", with: "UC Berkeley"
  fill_in "What skills do you bring or want to learn?", with: "Ruby, web apps and teamwork"
  fill_in "Why do you want to join?", with: "I want to build something useful for students and learn with teammates."
  fill_in "Tell us about an idea or a project you care about.", with: "I would build an app that helps students find partners for creative projects."
end

When("I press {string}") { |label| click_button label }
Then("I should see {string}") { |text| expect(page).to have_content(text) }
When("I sign in with my email and password") do
  visit sign_in_path
  fill_in "Email address", with: "cucumber@example.test"
  fill_in "Password", with: "correct horse battery staple"
  click_button "Sign in"
end
