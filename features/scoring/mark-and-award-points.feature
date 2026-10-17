@R8 @R9 @wip
Feature: Mark the weekly test and award points
  A weekly test is marked as soon as it is sent: by the child, when the 25 minutes run out, or when
  the test closes at midnight on Sunday. Results show the score out of 30, the points, the time taken,
  the Maths and English split and the mistakes to review (R8). Points (R9, to be tuned later): 10 per
  correct answer; a correct "Challenging" question earns 3 more on top of its 10; 50 for completing on
  time; 20 for beating your previous best score. On time means the child submitted it themselves, with
  every question answered, before the 25 minutes ran out and before the close. Equalling your previous
  best does not beat it. The group ranking is covered separately (R10, SCRUM-24).

  Background:
    Given Sam's children are Aarav in Year 6 and Maya in Year 4
    And week 11 runs from Monday 9 November 2026
    And Sam has approved all 30 questions in Aarav's and Maya's week 11 drafts

  Rule: The test is marked as soon as it is sent

    Scenario Outline: Results are ready straight after the test is sent, however it was sent
      Given Aarav started his week 11 test on <started>
      And Aarav's week 11 test was sent <how> on <sent at>, with <answered> of 30 answered
      And it is <sent at>
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees his score out of 30, his points and his mistakes to review
      And he sees "Time taken: <time taken>"

      @api @ui
      Examples: Sent by Aarav or when his time ran out
        | started                           | how               | sent at                           | answered | time taken |
        | Tuesday 10 November 2026 at 17:00 | by Aarav          | Tuesday 10 November 2026 at 17:20 | 30       | 20 minutes |
        | Tuesday 10 November 2026 at 17:00 | when time ran out | Tuesday 10 November 2026 at 17:25 | 22       | 25 minutes |

      @api
      Examples: Sent when the test closed at midnight on Sunday
        | started                          | how                  | sent at                          | answered | time taken |
        | Sunday 15 November 2026 at 23:40 | when the test closed | Monday 16 November 2026 at 00:00 | 12       | 20 minutes |

    @api @ui @decision
    Scenario: Results are not shown while the test is still in progress
      Given it is Tuesday 10 November 2026 at 17:10
      And Aarav started his week 11 test on Tuesday 10 November 2026 at 17:00 and has answered 8 questions
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees the message "Finish your test to see your results. You have 15 minutes left."
      And no score, points or mistakes are shown

    @api @ui
    Scenario: Results show the score and the Maths and English split
      Given Aarav's week 11 test was sent by Aarav on Tuesday 10 November 2026 at 17:20, with 30 of 30 answered
      And 26 of his answers were right, 14 in Maths and 12 in English
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees "26 out of 30"
      And he sees "Maths 14 out of 15" and "English 12 out of 15"

    @api @ui @decision
    Scenario: Wrong and unanswered questions are listed as mistakes to review
      Given Aarav's week 11 test was sent by Aarav on Tuesday 10 November 2026 at 17:20, with 28 of 30 answered
      And he skipped questions 3 and 18 and got questions 7 and 21 wrong
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees "26 out of 30"
      And his mistakes to review are questions 3, 7, 18 and 21, with 3 and 18 shown as unanswered
      And each mistake shows the question and his answer, without the correct answer

    @api @N3 @decision
    Scenario: Marking does not use the AI service
      Given Aarav's week 11 test was sent by Aarav on Tuesday 10 November 2026 at 17:20, with 30 of 30 answered
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then no request is made to the AI service while his test is marked
      And his results contain no other child's answers or scores

  Rule: Points are 10 per correct answer, 3 more per correct Challenging question, 50 on time and 20 for a new best

    Background:
      Given it is Tuesday 10 November 2026 at 17:30

    @api @ui @decision
    Scenario Outline: Worked examples of the points for one test
      Given Aarav's best score before week 11 is <best before>
      And Aarav's week 11 test was sent <how> on Tuesday 10 November 2026 at <at>, with <answered> of 30 answered
      And <correct> of his answers were right, <challenging> of them on Challenging questions
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees "<correct> out of 30"
      And he sees "<total> points": <for correct> for correct answers, <challenge> Challenging bonus, <on time> on-time bonus and <best> best-score bonus

      Examples: Completed on time
        | best before  | how      | at    | answered | correct | challenging | for correct | challenge | on time | best | total |
        | 24 out of 30 | by Aarav | 17:20 | 30       | 26      | 4           | 260         | 12        | 50      | 20   | 342   |
        | none         | by Aarav | 17:20 | 30       | 26      | 0           | 260         | 0         | 50      | 0    | 310   |
        | 25 out of 30 | by Aarav | 17:20 | 30       | 25      | 3           | 250         | 9         | 50      | 0    | 309   |
        | none         | by Aarav | 17:20 | 30       | 0       | 0           | 0           | 0         | 50      | 0    | 50    |

      Examples: Not completed on time, so no on-time bonus
        | best before  | how               | at    | answered | correct | challenging | for correct | challenge | on time | best | total |
        | 24 out of 30 | by Aarav          | 17:20 | 28       | 27      | 5           | 270         | 15        | 0       | 20   | 305   |
        | 20 out of 30 | when time ran out | 17:25 | 22       | 18      | 2           | 180         | 6         | 0       | 0    | 186   |
        | 26 out of 30 | when time ran out | 17:25 | 30       | 10      | 1           | 100         | 3         | 0       | 0    | 103   |
        | 12 out of 30 | when time ran out | 17:25 | 0        | 0       | 0           | 0           | 0         | 0       | 0    | 0     |

    @api @decision
    Scenario: The best-score bonus compares scores, not points
      Given Aarav's best score before week 11 is 24 out of 30, from week 10, when he earned 330 points
      And Aarav's week 11 test was sent when time ran out on Tuesday 10 November 2026 at 17:25, with 30 of 30 answered
      And 25 of his answers were right, 0 of them on Challenging questions
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees "270 points": 250 for correct answers, 0 Challenging bonus, 0 on-time bonus and 20 best-score bonus

    @api @decision
    Scenario: The best score belongs to each child
      Given Maya's best score before week 11 is 29 out of 30
      And Aarav's best score before week 11 is 20 out of 30
      And Aarav's week 11 test was sent by Aarav on Tuesday 10 November 2026 at 17:20, with 30 of 30 answered
      And 22 of his answers were right, 0 of them on Challenging questions
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees "290 points": 220 for correct answers, 0 Challenging bonus, 50 on-time bonus and 20 best-score bonus

    @api @decision
    Scenario: The previous best is the best of all earlier weeks, not just last week
      Given Aarav scored 24 out of 30 in week 8 and 20 out of 30 in week 10
      And Aarav's week 11 test was sent by Aarav on Tuesday 10 November 2026 at 17:20, with 30 of 30 answered
      And 22 of his answers were right, 0 of them on Challenging questions
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees "270 points": 220 for correct answers, 0 Challenging bonus, 50 on-time bonus and 0 best-score bonus

    @api @decision
    Scenario: Wrong and unanswered answers never take points away
      Given Maya had 600 all-time points before week 11
      And Maya's week 11 test was sent when time ran out on Tuesday 10 November 2026 at 17:25, with 10 of 30 answered
      And 0 of her answers were right, 0 of them on Challenging questions
      And Maya has signed in on this device after Sam
      When Maya opens her week 11 results
      Then she sees "0 points": 0 for correct answers, 0 Challenging bonus, 0 on-time bonus and 0 best-score bonus
      And Maya's all-time points are 600

  Rule: Points are awarded once and stay with the child

    Background:
      Given it is Wednesday 11 November 2026 at 17:00
      And Aarav had 1,250 all-time points before week 11
      And Aarav's week 11 test was sent by Aarav on Tuesday 10 November 2026 at 17:20, with 30 of 30 answered
      And it earned him 342 points

    @api @ui
    Scenario: Opening the results again shows the same points
      Given Aarav opened his week 11 results on Tuesday 10 November 2026 at 17:20 and saw "342 points"
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees "342 points"

    @api @decision
    Scenario: A submission that arrives twice earns its points once
      When Aarav's week 11 submission arrives a second time after a poor connection
      Then Aarav's week 11 points are still 342
      And Aarav's all-time points are 1,592

    @api @decision
    Scenario: A child's points are never counted for their brother or sister
      Given Maya had 600 all-time points before week 11
      And Maya's week 11 test was sent by Maya on Tuesday 10 November 2026 at 17:50, with 30 of 30 answered
      And it earned her 186 points
      And Maya has signed in on this device after Sam
      When Maya opens her week 11 results
      Then Aarav's all-time points are 1,592 and Maya's are 786

  Rule: A week without a test earns nothing, and late answers earn nothing

    @api @ui
    Scenario: A week not taken shows that no test was taken
      Given Aarav did not start his week 11 test
      And it is Monday 16 November 2026 at 07:00
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees the message "No test taken in week 11"
      And he sees "0 points": 0 for correct answers, 0 Challenging bonus, 0 on-time bonus and 0 best-score bonus

    @api
    Scenario: Answers refused after the close earn nothing
      Given Aarav's best score before week 11 is 26 out of 30
      And Aarav started his week 11 test on Sunday 15 November 2026 at 23:40 and has answered 12 questions
      And 10 of his answers are right, 1 of them on a Challenging question
      And it is Monday 16 November 2026 at 00:05
      And Aarav has signed in on this device after Sam
      When Aarav tries to answer question 13
      Then his week 11 points are worked out from the 12 answers sent at 00:00 only: 103 points, made of 100 for correct answers, 3 Challenging bonus, 0 on-time bonus and 0 best-score bonus

  Rule: Only the child and their own parent can see the results

    Background:
      Given it is Tuesday 10 November 2026 at 17:30
      And Aarav's week 11 test was sent by Aarav on Tuesday 10 November 2026 at 17:20, with 30 of 30 answered
      And 26 of his answers were right, 4 of them on Challenging questions
      And Zara from another family is in the group "Oakfield Friends" with Aarav
      And Priya is Zara's parent

    @api @ui
    Scenario: Sam sees Aarav's results
      Given Sam is signed in
      When Sam opens Aarav's week 11 results
      Then he sees "26 out of 30", Aarav's points, the time taken and the mistakes to review

    @api @ui @decision
    Scenario Outline: Nobody else can open Aarav's results
      Given <session>
      When <who> tries to open Aarav's week 11 results
      Then <who> sees the message "Results not found"
      And <who> does not see Aarav's score, points, time taken or mistakes

      Examples:
        | who   | session                                     |
        | Maya  | Maya has signed in on this device after Sam |
        | Zara  | Zara has signed in on her family's device   |
        | Priya | Priya is signed in                          |

    @api
    Scenario: Seeing results needs someone to be signed in
      Given nobody is signed in
      When someone tries to open Aarav's week 11 results
      Then they are asked to sign in
