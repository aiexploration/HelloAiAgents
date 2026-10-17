@R4 @R5 @wip
Feature: Approve the weekly questions
  Each week Prepwise drafts a 30-question test for every child: 15 Maths and 15 English,
  levelled to their year group (R4). Extra questions on weak topics come later (R12, SCRUM-43).
  The questions are drafted by AI, and a parent must approve every one before the child
  can see the test. Flagged questions block release (R5).

  Background:
    Given Sam has a parent account with email "sam@example.com"
    And Sam's children are Aarav in Year 6 and Maya in Year 4
    And week 11 runs from Monday 9 November 2026

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

  @api @N3 @N7
  Scenario: Drafting questions never uses a child's personal details
    Given Aarav's week 11 draft is ready
    And Sam has regenerated question 12 choosing "Make it easier"
    When the requests sent to the AI service for Aarav's week 11 draft are checked
    Then they contain only his year group, exam styles, topics to cover and the regenerate choice Sam picked
    And they do not include his nickname, his PIN or any parent's name or email
    And no question in the draft mentions Aarav, Maya or Sam

  @api @R2 @decision
  Scenario: Changing year group after the draft is ready applies from the next week
    Given Aarav's week 11 draft is ready
    And Sam is signed in
    When Sam changes Aarav to Year 7
    Then Aarav's week 11 draft is still levelled to Year 6
    And Aarav's week 12 draft will be levelled to Year 7

  Rule: Sam reviews each question in Aarav's draft

    Background:
      Given it is Saturday 7 November 2026 at 10:00
      And Aarav's week 11 draft is ready with none of its 30 questions approved
      And Sam is signed in

    @api @ui @decision
    Scenario: Sam edits a question's wording and answer, which approves it
      When Sam changes question 4's wording to "What is 3/4 of 48?" and its correct answer to "36"
      Then question 4 shows the new wording with "36" as the correct answer
      And question 4 shows as approved

    @api @ui @decision
    Scenario: Swapping uses a spare question that was already drafted
      Given question 7 is on the topic "Fractions"
      When Sam swaps question 7
      Then question 7 is a spare question on the topic "Fractions" from Aarav's week 11 draft
      And no new request is sent to the AI service
      And the new question 7 is not already in Aarav's or Maya's draft
      And the new question 7 needs approval

    @api @ui @N3 @decision
    Scenario Outline: Regenerating drafts one new question with the choice Sam picked
      Given question 12 is on the topic "Ratio"
      When Sam regenerates question 12 choosing "<choice>"
      Then one request is sent to the AI service for a new question on "Ratio" with "<choice>"
      And the new question 12 is not already in Aarav's or Maya's draft
      And the new question 12 needs approval

      Examples:
        | choice          |
        | Make it easier  |
        | Make it harder  |
        | Fix the wording |

    @ui @N3 @decision
    Scenario: Regenerating offers fixed choices, not a free-text note
      When Sam chooses to regenerate question 12
      Then he can pick only "Make it easier", "Make it harder" or "Fix the wording"
      And there is no box to type a note

    @api @ui @decision
    Scenario: A flag needs a reason
      When Sam flags question 9 without a reason
      Then he sees the message "Say what is wrong with this question"
      And question 9 is not flagged

    @api @ui
    Scenario Outline: Fixing a flagged question clears the flag
      Given Sam has flagged question 9 with the reason "Two answers could be right"
      When Sam <fixes> question 9
      Then question 9 is no longer flagged
      And question 9 <state>

      Examples:
        | fixes                                       | state             |
        | swaps                                       | needs approval    |
        | regenerates, choosing "Fix the wording" for | needs approval    |
        | edits the wording of                        | shows as approved |

    @api @ui @decision
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
    Scenario Outline: An edited question must follow the question rules
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
      Given Sam has approved all 30 questions in Maya's week 11 draft
      And Sam has approved 29 of the 30 questions in Aarav's week 11 draft
      And it is Monday 9 November 2026 at 07:00
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 test
      Then he sees the message "Your test isn't ready yet"
      And Sam's dashboard shows "Aarav's week 11 test is waiting for 1 question to be approved"
      And Maya's week 11 test is open

    @api @decision
    Scenario: A late approval opens the test straight away, with the usual deadline
      Given Sam has approved 29 of the 30 questions in Aarav's week 11 draft
      And it is Monday 9 November 2026 at 18:00
      When Sam approves the last question
      Then Aarav's week 11 test opens straight away
      And it is still due on Sunday 15 November 2026 at 23:59

    @api @ui @decision
    Scenario: Flagging a question, even after approving everything, blocks release
      Given Sam has approved all 30 questions in Aarav's week 11 draft
      And it is Sunday 8 November 2026 at 20:00
      When Sam flags question 9 with the reason "Two answers could be right"
      Then question 9 shows as flagged with the reason "Two answers could be right"
      And he sees the message "1 question is blocking release"
      And Aarav's week 11 test will not open on Monday at 7am while question 9 is flagged

    @api @decision
    Scenario Outline: Once the test has opened, its questions cannot be changed
      Given Aarav's week 11 test opened on Monday 9 November 2026 at 07:00
      And Sam is signed in
      When Sam tries to <action> question 7 of Aarav's week 11 test
      Then he sees the message "This test has opened, so its questions can't be changed"
      And Aarav's week 11 test is unchanged

      Examples:
        | action     |
        | edit       |
        | swap       |
        | regenerate |
        | flag       |

    @api @ui
    Scenario: Aarav gets Sam's edits, never the questions Sam swapped out
      Given Sam changed question 4's wording to "What is 3/4 of 48?" and swapped question 7
      And Sam has approved all 30 questions in Aarav's week 11 draft
      And it is Monday 9 November 2026 at 07:00
      And Aarav has signed in on this device after Sam
      When Aarav goes through his week 11 test
      Then question 4 reads "What is 3/4 of 48?"
      And the question Sam swapped out of question 7 never appears

    @api @ui
    Scenario: A child never sees draft questions
      Given it is Saturday 7 November 2026 at 10:00
      And Aarav has done his week 10 test
      And Aarav's week 11 draft is ready with none of its 30 questions approved
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 test
      Then he sees the message "Your next test opens Monday at 7am"
      And no week 11 question is shown

    @api @ui
    Scenario Outline: Another family's child's draft is treated like a child that does not exist
      Given Priya has a parent account with email "priya@example.com"
      And Zara from another family is in the group "Oakfield Friends" with Aarav
      And Priya is signed in
      When Priya tries to <action> of Aarav's week 11 draft
      Then she sees the message "Child not found"
      And Aarav's week 11 draft is unchanged

      Examples:
        | action                 |
        | open question 4        |
        | edit question 4        |
        | regenerate question 12 |
        | flag question 9        |

    @api @ui
    Scenario Outline: Reviewing questions needs a parent session
      Given Aarav's week 11 draft is ready with none of its 30 questions approved
      And <session>
      When <who> tries to <action> of <whose> week 11 draft
      Then <outcome>
      And Aarav's and Maya's week 11 drafts are unchanged

      Examples:
        | session                                      | who     | action                 | whose   | outcome                                       |
        | Aarav has signed in on this device after Sam | Aarav   | open question 4        | his     | he is asked for a parent's email and password |
        | Aarav has signed in on this device after Sam | Aarav   | approve all questions  | his     | he is asked for a parent's email and password |
        | Aarav has signed in on this device after Sam | Aarav   | open question 4        | Maya's  | he is asked for a parent's email and password |
        | nobody is signed in                          | someone | open question 4        | Aarav's | they are asked to sign in as a parent         |
        | nobody is signed in                          | someone | edit question 4        | Aarav's | they are asked to sign in as a parent         |
        | nobody is signed in                          | someone | regenerate question 12 | Aarav's | they are asked to sign in as a parent         |
