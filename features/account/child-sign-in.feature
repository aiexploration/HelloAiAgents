@R1 @wip
Feature: Child sign-in with a PIN
  Children sign in by picking their profile and entering a 4-digit PIN,
  only on a device where their parent has signed in before.
  Children have no email or password (N3).

  Background:
    Given Sam has a parent account with children Aarav in Year 6 and Maya in Year 4
    And Aarav's PIN is "4821" and Maya's PIN is "1357"

  @api @ui
  Scenario: Aarav signs in with his PIN
    Given Sam has signed in on this device before
    When Aarav picks his profile and enters PIN "4821"
    Then he sees his home screen greeting him as Aarav

  @ui @N3
  Scenario: The profile picker only shows this family's children
    Given Sam has signed in on this device before
    And Zara from another family is in the group "Oakfield Friends" with Aarav
    When the child sign-in screen opens
    Then it shows the profiles Aarav and Maya
    And it does not show Zara

  @api @ui
  Scenario: A wrong PIN does not sign the child in
    Given Sam has signed in on this device before
    When Maya picks her profile and enters PIN "1111"
    Then she sees the message "That PIN isn't right. Try again."
    And she is not signed in

  @api
  Scenario: A child's PIN only works for their own profile
    Given Sam has signed in on this device before
    When Maya picks her profile and enters Aarav's PIN "4821"
    Then she is not signed in

  @api @ui
  Scenario: Child sign-in is not offered on a device no parent has used
    Given no parent has signed in on this device
    When the child sign-in screen opens
    Then it asks for a parent to sign in first
    And no child profiles are shown

  @api
  Scenario: Repeated wrong PINs pause that child's sign-in and tell the parent
    Given Sam has signed in on this device before
    And it is Tuesday 21 October 2026 at 17:00
    And Maya has entered a wrong PIN 5 times in a row
    When Maya picks her profile and enters PIN "1357"
    Then she sees the message "Too many tries. Ask a grown-up or wait 15 minutes."
    And she is not signed in
    And Sam's dashboard shows that Maya's sign-in was paused at 17:00

  @api
  Scenario: Pausing one child does not affect the other
    Given Sam has signed in on this device before
    And Maya's sign-in is paused after 5 wrong PINs
    When Aarav picks his profile and enters PIN "4821"
    Then he sees his home screen greeting him as Aarav

  @api @ui
  Scenario: A child cannot open parent pages
    Given Aarav is signed in on this device
    When he tries to open the parent dashboard
    Then he is asked for a parent's email and password
    And the parent dashboard is not shown

  @api @ui
  Scenario: Signing out returns to the profile picker
    Given Aarav is signed in on this device
    When Aarav signs out
    Then he sees the child sign-in screen with Aarav and Maya
