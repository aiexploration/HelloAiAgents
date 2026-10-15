@R4 @R5 @wip
Feature: Approve the weekly questions
  Each week Prepwise drafts a 30-question test for every child: 15 Maths and 15 English,
  levelled to their year group (R4). The questions are drafted by AI, and a parent must
  approve every one before the child can see the test. Flagged questions block release (R5).

  Background:
    Given Sam has a parent account with email "sam@example.com"
    And Sam's children are Aarav in Year 6 and Maya in Year 4

  @api @ui @decision
  Scenario Outline: The drafts are ready at 09:00 on the Saturday before release
    Given it is <when>
    And Sam is signed in
    When Sam opens the questions to approve
    Then he sees the message "<message>"

    Examples:
      | when                              | message                                                  |
      | Saturday 7 November 2026 at 08:59 | Next week's questions will be ready on Saturday at 9am   |
      | Saturday 7 November 2026 at 09:00 | Aarav's and Maya's week 11 questions are ready to review |

  @api @decision
  Scenario Outline: Each child's draft has 15 Maths and 15 English questions at their level
    Given Aarav's and Maya's week 11 drafts are ready
    And Sam is signed in
    When Sam opens <child>'s week 11 draft
    Then it has 30 questions: 15 Maths and 15 English
    And every question is levelled to Year <year>
    And every question has 4 or 5 answer options with exactly one correct answer
    And none of its questions is also in <other>'s draft

    Examples:
      | child | year | other |
      | Aarav | 6    | Maya  |
      | Maya  | 4    | Aarav |

  @api @N3
  Scenario: Drafting questions never uses a child's personal details
    When Aarav's week 11 draft is prepared
    Then the details sent to the AI service are only his year group, exam styles and topics to cover
    And they do not include his nickname, his PIN or any parent's name or email
    And no question in the draft mentions Aarav, Maya or Sam

  Rule: Sam reviews each question in Aarav's draft

    Background:
      Given it is Saturday 7 November 2026 at 10:00
      And Aarav's week 11 draft is ready with none of its 30 questions approved
      And Sam is signed in

    @api @ui
    Scenario: Sam approves a question
      When Sam approves question 4 of Aarav's week 11 draft
      Then question 4 shows as approved
      And 29 questions still need approval

    @api @ui @decision
    Scenario: Sam edits a question's wording and answer, which approves it
      When Sam changes question 4's wording to "What is 3/4 of 48?" and its correct answer to "36"
      Then question 4 shows the new wording with "36" as the correct answer
      And question 4 shows as approved

    @api @ui @decision
    Scenario: Sam swaps a question for another on the same topic
      Given question 7 is on the topic "Fractions"
      When Sam swaps question 7
      Then question 7 is a different question on the topic "Fractions"
      And the new question 7 needs approval

    @api @ui @decision
    Scenario: Sam asks for a question to be drafted again
      Given question 12 is on the topic "Ratio"
      When Sam regenerates question 12 with the note "Make it easier"
      Then question 12 is a newly drafted question on the topic "Ratio"
      And the new question 12 needs approval

    @api @ui
    Scenario: Sam flags a question with a reason
      When Sam flags question 9 with the reason "Two answers could be right"
      Then question 9 shows as flagged with the reason "Two answers could be right"
      And Aarav's week 11 test cannot be released

    @api @ui @decision
    Scenario: A flag needs a reason
      When Sam flags question 9 without a reason
      Then he sees the message "Say what is wrong with this question"
      And question 9 is not flagged

    @api @ui
    Scenario: Swapping a flagged question clears the flag
      Given Sam has flagged question 9 with the reason "Two answers could be right"
      When Sam swaps question 9
      Then question 9 is no longer flagged
      And the new question 9 needs approval

    @api @ui
    Scenario: Approving all the rest skips flagged questions
      Given Sam has approved questions 1 to 5 and flagged question 9
      When Sam approves all remaining questions
      Then questions 1 to 8 and 10 to 30 show as approved
      And question 9 is still flagged

    @api @ui
    Scenario: Approving the last question makes the test ready
      Given Sam has approved every question except question 30
      When Sam approves question 30 of Aarav's week 11 draft
      Then he sees the message "Aarav's week 11 test will open on Monday at 7am"

    @api @ui
    Scenario Outline: Flagged or unapproved questions block release
      Given Sam has approved every question except <blocking>
      When Sam opens Aarav's week 11 draft
      Then he sees the message "<message>"
      And questions <listed> are listed as blocking release

      Examples:
        | blocking                                      | message                          | listed   |
        | question 9, which he flagged                  | 1 question is blocking release   | 9        |
        | questions 9 and 21                            | 2 questions are blocking release | 9 and 21 |
        | question 9, which he flagged, and question 21 | 2 questions are blocking release | 9 and 21 |

    @api @ui @decision
    Scenario Outline: An edited question must still have exactly one correct answer
      When Sam edits question 4 so that <change>
      Then he sees the message "<message>"
      And question 4 is unchanged

      Examples:
        | change                         | message                                |
        | its wording is empty           | Enter the question                     |
        | it has 3 answer options        | A question needs 4 or 5 answer options |
        | it has 6 answer options        | A question needs 4 or 5 answer options |
        | two options are the same       | Each answer option must be different   |
        | no option is marked correct    | Mark one answer as correct             |
        | two options are marked correct | Only one answer can be correct         |

  Rule: Only an approved test reaches the child

    @api @ui @decision
    Scenario: A draft not fully approved by Monday 07:00 is not released, and does not hold up Maya
      Given Sam has approved 29 of the 30 questions in Aarav's week 11 draft
      And it is Monday 9 November 2026 at 07:00
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 test
      Then he sees the message "Your test isn't ready yet"
      And Sam is told "Aarav's week 11 test is waiting for 1 question to be approved"
      And Maya's week 11 test, which Sam fully approved, opens as usual

    @api @decision
    Scenario: A late approval opens the test straight away, with the usual deadline
      Given Sam has approved 29 of the 30 questions in Aarav's week 11 draft
      And it is Monday 9 November 2026 at 18:00
      When Sam approves the last question
      Then Aarav's week 11 test opens straight away
      And it is still due on Sunday 15 November 2026 at 23:59

    @api @ui
    Scenario: A child never sees draft questions
      Given it is Saturday 7 November 2026 at 10:00
      And Aarav's week 11 draft is ready with none of its 30 questions approved
      And Aarav has signed in on this device after Sam
      When Aarav opens his weekly test
      Then he sees the message "Your next test opens Monday at 7am"
      And no week 11 question is shown

    @api @ui
    Scenario Outline: A child cannot review or approve questions
      Given Aarav's week 11 draft is ready with none of its 30 questions approved
      And Aarav has signed in on this device after Sam
      When Aarav tries to <action>
      Then he is asked for a parent's email and password
      And Aarav's week 11 draft is unchanged

      Examples:
        | action                                     |
        | open his week 11 draft                     |
        | approve all questions in his week 11 draft |
        | open Maya's week 11 draft                  |

    @api @ui
    Scenario Outline: Another family's child's draft is treated like a child that does not exist
      Given Priya has a parent account with email "priya@example.com"
      And Zara from another family is in the group "Oakfield Friends" with Aarav
      And Priya is signed in
      When Priya tries to <action>
      Then she sees the message "Child not found"
      And Aarav's week 11 draft is unchanged

      Examples:
        | action                                      |
        | open Aarav's week 11 draft                  |
        | approve question 4 of Aarav's week 11 draft |
        | flag question 9 of Aarav's week 11 draft    |

    @api
    Scenario: Approving questions needs a parent session
      Given nobody is signed in
      When someone tries to approve question 4 of Aarav's week 11 draft
      Then they are asked to sign in as a parent
      And Aarav's week 11 draft is unchanged
