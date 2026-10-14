@R1 @wip
Feature: Parent sign-in
  Parents sign in with their email and password to manage their children,
  approve the weekly questions and see progress.

  Background:
    Given Sam has a parent account with email "sam@example.com" and a password he chose
    And Sam's children are Aarav in Year 6 and Maya in Year 4

  @api @ui
  Scenario: Sam signs in with the right email and password
    When Sam signs in with email "sam@example.com" and his password
    Then he sees the parent dashboard
    And the dashboard shows Aarav and Maya

  @api
  Scenario: The email address is not case-sensitive
    When Sam signs in with email "Sam@Example.com" and his password
    Then he sees the parent dashboard

  @api @ui
  Scenario Outline: Wrong details do not reveal which part was wrong
    When someone signs in with email "<email>" and password "<password>"
    Then they see the message "Email or password is incorrect"
    And they are not signed in

    Examples:
      | email              | password         |
      | sam@example.com    | not-his-password |
      | nobody@example.com | any-password     |

  @api
  Scenario: Repeated wrong passwords pause sign-in for that account
    Given it is Tuesday 21 October 2026 at 19:00
    And someone has entered a wrong password for "sam@example.com" 5 times in the last 15 minutes
    When Sam signs in with email "sam@example.com" and his password
    Then he sees the message "Too many attempts. Try again in 15 minutes."
    And he is not signed in

  @api
  Scenario: Sign-in works again after the pause
    Given it is Tuesday 21 October 2026 at 19:00
    And sign-in for "sam@example.com" was paused at 18:40 after 5 wrong passwords
    When Sam signs in with email "sam@example.com" and his password
    Then he sees the parent dashboard

  @api @ui
  Scenario: Signing out ends the parent session
    Given Sam is signed in
    When Sam signs out
    Then he sees the welcome screen
    And opening the parent dashboard asks him to sign in

  @api
  Scenario: Parent pages need a parent session
    Given nobody is signed in
    When someone opens the parent dashboard
    Then they are asked to sign in as a parent
