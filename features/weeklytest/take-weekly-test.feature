@R6 @R7 @wip
Feature: Take the weekly test
  The weekly test opens on Monday at 07:00 UK time and is due by Sunday at 23:59.
  Once a child starts it, they have 25 minutes (R6). During the test they can flag a
  question for later, use a rough-work scratchpad, skip a question and go back (R7).

  Background:
    Given Sam's children are Aarav in Year 6 and Maya in Year 4
    And week 11 runs from Monday 9 November 2026
    And Sam has approved all 30 questions in Aarav's and Maya's week 11 drafts

  @api @ui
  Scenario Outline: The test is open from Monday 07:00 until the end of Sunday 23:59
    Given Aarav's week <week> test has 30 approved questions
    And it is <when>
    And Aarav has signed in on this device after Sam
    When Aarav opens his week <week> test
    Then he sees the message "<message>"

    Examples:
      | when                             | week | message                                             |
      | Monday 9 November 2026 at 06:59  | 11   | Your next test opens today at 7am                   |
      | Monday 9 November 2026 at 07:00  | 11   | Your week 11 test is ready. You'll have 25 minutes. |
      | Sunday 15 November 2026 at 23:59 | 11   | Your week 11 test is ready. You'll have 1 minute.   |
      | Monday 16 November 2026 at 00:00 | 11   | This test has closed                                |

    Examples: UK time across the clock change on Sunday 25 October 2026
      | when                            | week | message                                          |
      | Sunday 25 October 2026 at 23:59 | 8    | Your week 8 test is ready. You'll have 1 minute. |
      | Monday 26 October 2026 at 00:00 | 8    | This test has closed                             |

  Rule: The 25-minute timer starts when Aarav starts

    Background:
      Given it is Tuesday 10 November 2026 at 17:00
      And Aarav has signed in on this device after Sam

    @api @ui @decision
    Scenario: When time runs out, the answers so far are submitted
      Given Aarav started his week 11 test at 17:00 and has answered 22 questions
      When the time reaches 17:25
      Then he sees the message "Time's up! Your answers have been sent."
      And his 22 answers were submitted for marking at 17:25

    @api @ui @decision
    Scenario: Closing the app does not stop the timer, and he carries on where he left off
      Given Aarav started his week 11 test at 17:00, answered questions 1 to 10 and closed the app at 17:08
      And it is Tuesday 10 November 2026 at 17:15
      When Aarav opens his week 11 test
      Then he sees question 11 of 30
      And the timer shows 10 minutes left
      And his answers to questions 1 to 10 are kept

    @api @ui @decision
    Scenario: Coming back after the 25 minutes finds the test already submitted
      Given Aarav started his week 11 test at 17:00, answered questions 1 to 10 and closed the app at 17:08
      And it is Tuesday 10 November 2026 at 17:40
      When Aarav opens his week 11 test
      Then he sees the message "Time ran out, so your answers were sent."
      And his 10 answers were submitted for marking at 17:25

  Rule: The test closes at midnight on Sunday, even if time is left

    Background:
      Given it is Sunday 15 November 2026 at 23:40
      And Aarav has signed in on this device after Sam

    @api @ui @decision
    Scenario: A test started late on Sunday only gets the time until it closes
      When Aarav starts his week 11 test
      Then he sees the message "The test closes at midnight, so you have 20 minutes."
      And the timer shows 20 minutes left

    @api
    Scenario: The close cuts the timer short and later answers are refused
      Given Aarav started his week 11 test at 23:40 and has answered 12 questions
      And it is Monday 16 November 2026 at 00:05
      When Aarav tries to answer question 13
      Then he sees the message "This test has closed"
      And his 12 answers were submitted for marking at 00:00, with 5 of his 25 minutes unused

  Rule: Aarav can move around the test freely

    Background:
      Given it is Tuesday 10 November 2026 at 17:00
      And Aarav has signed in on this device after Sam
      And Aarav has started his week 11 test

    @api @ui
    Scenario: Aarav skips a question
      Given Aarav is on question 3
      When Aarav skips question 3
      Then he sees question 4 of 30
      And question 3 shows as unanswered

    @api @ui
    Scenario: Aarav goes back and changes an answer
      Given Aarav has answered questions 1 to 10 and chose "B" for question 2
      When Aarav changes his answer to question 2 to "D"
      Then his answer to question 2 is "D"
      And his answers to questions 1 and 3 to 10 are unchanged

    @ui
    Scenario: Aarav flags a question to come back to
      Given Aarav is on question 5
      When Aarav flags question 5 for later
      Then question 5 shows a flag in the list of questions
      And he can still answer question 5

    @ui
    Scenario: Aarav's rough work stays with its question
      Given Aarav has written rough work on the scratchpad for question 6
      When Aarav goes back to question 6 from question 7
      Then he sees his rough work for question 6
      And the scratchpad for question 7 is empty

    @api @N3 @decision
    Scenario: Rough work is never sent with the answers
      Given Aarav has written rough work on the scratchpad for questions 6 and 9
      When Aarav submits his week 11 test and confirms
      Then the submitted test contains his answers and no rough work
      And Sam cannot see Aarav's rough work

    @ui @N3 @decision
    Scenario: Rough work is cleared from the device once the test is submitted
      Given Aarav has written rough work on the scratchpad for question 6
      And Aarav has submitted his week 11 test
      When Aarav opens his week 11 test again
      Then no rough work for question 6 is shown or kept on this device

    @ui @N3
    Scenario: Maya does not see Aarav's rough work on a shared device
      Given Aarav has written rough work on the scratchpad for question 6 and closed the app
      And Maya has signed in on this device after Sam
      When Maya starts her week 11 test
      Then her scratchpad for question 6 is empty

    @ui @decision
    Scenario: The review screen lists unanswered and flagged questions
      Given Aarav has answered 28 questions, skipping questions 3 and 18
      And Aarav has flagged questions 5 and 12 for later
      When Aarav opens the review screen
      Then he sees "28 of 30 answered"
      And questions 3 and 18 are listed as unanswered
      And questions 5 and 12 are listed as flagged

    @ui @decision
    Scenario Outline: Aarav is asked to confirm before submitting
      Given Aarav has answered <answered> of the 30 questions
      When Aarav submits his week 11 test
      Then he is asked "<question>"
      And his answers are not yet submitted

      Examples:
        | answered | question                                                   |
        | 30       | Ready to submit? You can't change your answers after this. |
        | 28       | You have 2 unanswered questions. Submit anyway?            |

  Rule: Each child takes only their own test, once

    @api @ui @decision
    Scenario: Aarav cannot take the test a second time or change what he sent
      Given Aarav submitted his week 11 test with 28 answers on Tuesday 10 November 2026 at 17:20
      And it is Wednesday 11 November 2026 at 17:00
      And Aarav has signed in on this device after Sam
      When Aarav tries to change his answer to question 2
      Then he sees the message "You've done this week's test. Your next test opens Monday at 7am"
      And his 28 submitted answers are unchanged
      And he cannot start the test again

    @api @ui
    Scenario: Maya's test runs on its own after Aarav has finished
      Given it is Tuesday 10 November 2026 at 17:30
      And Aarav submitted his week 11 test at 17:20
      And Maya has signed in on this device after Sam
      When Maya starts her week 11 test
      Then she sees question 1 of 30, levelled to Year 4
      And the timer shows 25 minutes left

    @api @ui @decision
    Scenario Outline: Nobody else can open Aarav's test
      Given it is Tuesday 10 November 2026 at 17:00
      And Zara from another family is in the group "Oakfield Friends" with Aarav
      And <session>
      When <who> tries to open Aarav's week 11 test
      Then <who> sees the message "Test not found"
      And Aarav's week 11 test has not been started

      Examples:
        | who   | session                                     |
        | Maya  | Maya has signed in on this device after Sam |
        | Zara  | Zara has signed in on her family's device   |
        | Priya | Priya is signed in                          |

    @api @ui @decision
    Scenario: A parent cannot take a test for a child
      Given it is Tuesday 10 November 2026 at 17:00
      And Sam is signed in
      When Sam tries to start Aarav's week 11 test
      Then he sees the message "Only Aarav can take his test. Sign in as Aarav on this device."
      And Aarav's week 11 test has not been started

    @api
    Scenario: Taking a test needs a child to be signed in
      Given nobody is signed in
      When someone tries to start Aarav's week 11 test
      Then they are asked to sign in
      And Aarav's week 11 test has not been started
