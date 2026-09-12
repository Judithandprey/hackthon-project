Feature: Apply to a hackathon
  As an applicant
  I want to save an application and return to it
  So that I can submit when I am ready

  Scenario: A hacker saves a draft and submits it
    Given I have registered as a hacker
    When I fill out my application
    And I press "Save draft"
    Then I should see "Draft saved"
    When I press "Submit application"
    Then I should see "Application submitted"
    And I should see "Submitted applications are read-only"

  Scenario: A mentor receives a different application form
    Given I have registered as a mentor
    Then I should see "Mentor application"
    And I should see "A hacker is stuck. How would you help them?"
    And I should see "When are you available to mentor?"

  Scenario: Returning applicants can sign in with email and password
    Given I have registered as a hacker
    When I press "Sign out"
    And I sign in with my email and password
    Then I should see "Hacker application"
