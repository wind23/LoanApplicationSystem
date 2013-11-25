Feature: Application Page

  As an administrator,
  I want an application form for users,
  so that they can apply for loan.

Background:

  Given I am on the home page

Scenario: show all the applications to adminstrator
  When I fill in "user_username" with "test_user1"
  And I fill in "user_password" with "pass"
  And I press "登录"
  And I follow "填写报销申请"
  Then I should be on the reimbursement application page of "test_user1"
  When I fill in "app_details" with "abcdef"
  And I fill in "app_amount" with "100"
  And I press "提交"
  Then I should see "abcdef"

Scenario: when the amount is invalid
  When I fill in "user_username" with "test_user1"
  And I fill in "user_password" with "pass"
  And I press "登录"
  And I follow "填写报销申请"
  Then I should be on the reimbursement application page of "test_user1"
  When I fill in "app_details" with "abcdef"
  And I fill in "app_amount" with "100u"
  And I press "提交"
  Then I should see "Invalid amount!"

Scenario: details should not be empty
  When I fill in "user_username" with "test_user1"
  And I fill in "user_password" with "pass"
  And I press "登录"
  When I follow "填写报销申请"
  Then I should be on the reimbursement application page of "test_user1"
  And I press "提交"
  Then I should see "Details should not be empty!"

Scenario: can not visit invalid page
  When I fill in "user_username" with "test_user1"
  And I fill in "user_password" with "pass"
  And I press "登录"
  When I go to the wait for verify page for test_user1
  Then I should be on the application page for "test_user1"
  And I should see "No permission"

Scenario: details can be removed
  When I fill in "user_username" with "test_user1"
  And I fill in "user_password" with "pass"
  And I press "登录"
  And I follow the first "撤销"
  Then I should not see "test004"

Scenario: details removed by invalid user
  When I fill in "user_username" with "test_user2"
  And I fill in "user_password" with "pass"
  And I press "登录"
  And I go to the delete page for 1344556800
  Then I should see "No permission"

Scenario: should not be added if login timed out
  When I go to the reimbursement application page of "test_user1"
  Then I should be on the Chinese home page
  And I should see "Login timed out!"
