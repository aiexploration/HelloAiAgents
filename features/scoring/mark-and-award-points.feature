@R8 @R9 @wip
Feature: Mark the weekly test and award points
  A weekly test is marked as soon as it is submitted: by the child, when the 25 minutes run
  out, or when the test closes at midnight on Sunday. The results show the score out of 30,
  the points earned, the time taken, the Maths and English split and the mistakes to review (R8).
  Points are 10 for each correct answer, +3 for each correct "Challenging" question, +50 for
  completing on time and +20 for beating your previous best score (R9, to be tuned later).
  The group ranking is covered separately (R10, SCRUM-24).

  Background:
    Given Sam's children are Aarav in Year 6 and Maya in Year 4
    And week 11 runs from Monday 9 November 2026
    And Sam has approved all 30 questions in Aarav's and Maya's week 11 drafts

  Rule: The test is marked as soon as it is submitted

    @api @ui
    Scenario Outline: Results are ready straight after the test is submitted, however it was sent
      Given <sent>
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results on <opened>
      Then he sees his score out of 30, his points and his mistakes to review
      And he sees "Time taken: <time taken>"

      Examples:
        | sent                                                                                          | opened                            | time taken |
        | Aarav started his week 11 test on Tuesday 10 November 2026 at 17:00 and submitted it at 17:20 | Tuesday 10 November 2026 at 17:20 | 20 minutes |
        | Aarav started his week 11 test on Tuesday 10 November 2026 at 17:00 and time ran out at 17:25 | Tuesday 10 November 2026 at 17:25 | 25 minutes |
        | Aarav started his week 11 test on Sunday 15 November 2026 at 23:40 and it closed at 00:00     | Monday 16 November 2026 at 00:00  | 20 minutes |

    @api @ui
    Scenario: Results show the score and the Maths and English split
      Given Aarav submitted his week 11 test on Tuesday 10 November 2026 at 17:20 with 26 correct answers
      And 14 of his correct answers were Maths and 12 were English
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees "26 out of 30"
      And he sees "Maths 14 out of 15" and "English 12 out of 15"

    @api @ui @decision
    Scenario: Wrong and unanswered questions are listed as mistakes to review
      Given Aarav submitted his week 11 test with 28 answers, skipping questions 3 and 18
      And his answers to questions 7 and 21 were wrong and all his other answers were right
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees "26 out of 30"
      And his mistakes to review are questions 3, 7, 18 and 21, with 3 and 18 shown as unanswered
      And each mistake shows the question and his answer, but not yet the correct answer

    @api @N3 @decision
    Scenario: Marking happens inside Prepwise and uses only the nickname
      Given Aarav submitted his week 11 test on Tuesday 10 November 2026 at 17:20
      When Aarav's week 11 test is marked
      Then his answers are not sent to the AI service or any other service outside Prepwise
      And his results name him only as Aarav in Year 6

  Rule: Points are worked out from the answers, the Challenging questions, the timing and the previous best

    @api @decision
    Scenario Outline: Worked examples of the points for one test
      Given Aarav's best score before week 11 is <best before>
      And Aarav's week 11 test was <sent>
      And he got <correct> answers right, <challenging> of them on Challenging questions
      When Aarav's week 11 test is marked
      Then his score is <correct> out of 30
      And he earns <total> points: <for correct> for correct answers, <challenge> Challenging bonus, <on time> on-time bonus and <best> best-score bonus

      Examples: Completed on time
        | best before  | sent                                    | correct | challenging | for correct | challenge | on time | best | total |
        | 24 out of 30 | submitted by Aarav with all 30 answered | 26      | 4           | 260         | 12        | 50      | 20   | 342   |
        | no score yet | submitted by Aarav with all 30 answered | 26      | 0           | 260         | 0         | 50      | 0    | 310   |
        | 25 out of 30 | submitted by Aarav with all 30 answered | 25      | 3           | 250         | 9         | 50      | 0    | 309   |
        | no score yet | submitted by Aarav with all 30 answered | 0       | 0           | 0           | 0         | 50      | 0    | 50    |

      Examples: Not completed on time, so no on-time bonus
        | best before  | sent                                       | correct | challenging | for correct | challenge | on time | best | total |
        | 24 out of 30 | submitted by Aarav with 28 answered        | 27      | 5           | 270         | 15        | 0       | 20   | 305   |
        | 20 out of 30 | sent when time ran out with 22 answered    | 18      | 2           | 180         | 6         | 0       | 0    | 186   |
        | 26 out of 30 | sent when the test closed with 12 answered | 10      | 1           | 100         | 3         | 0       | 0    | 103   |
        | 12 out of 30 | sent when time ran out with 0 answered     | 0       | 0           | 0           | 0         | 0       | 0    | 0     |

    @api @decision
    Scenario: The best-score bonus compares scores, not points
      Given Aarav's best score before week 11 is 24 out of 30, from week 10, when he earned 330 points
      And Aarav's week 11 test was sent when time ran out with 30 answered
      And he got 25 answers right, none of them on Challenging questions
      When Aarav's week 11 test is marked
      Then he earns 270 points: 250 for correct answers and 20 best-score bonus

    @api @decision
    Scenario: The best score belongs to each child
      Given Maya's best score before week 11 is 29 out of 30
      And Aarav's best score before week 11 is 20 out of 30
      And Aarav's week 11 test was submitted by Aarav with all 30 answered
      And he got 22 answers right, none of them on Challenging questions
      When Aarav's week 11 test is marked
      Then he earns 290 points: 220 for correct answers, 50 on-time bonus and 20 best-score bonus

    @api @decision
    Scenario: The previous best is the best of all earlier weeks, not just last week
      Given Aarav scored 24 out of 30 in week 8 and 20 out of 30 in week 10
      And Aarav's week 11 test was submitted by Aarav with all 30 answered
      And he got 22 answers right, none of them on Challenging questions
      When Aarav's week 11 test is marked
      Then he earns 270 points: 220 for correct answers and 50 on-time bonus

  Rule: Points are awarded once, stay with the child and never go down

    Background:
      Given it is Wednesday 11 November 2026 at 17:00
      And Aarav earned 342 points for his week 11 test on Tuesday 10 November 2026
      And Aarav had 1,250 points in total before week 11

    @api @ui
    Scenario: Opening the results again does not change the points
      Given Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results again
      Then he sees "342 points"
      And his total is 1,592 points

    @api @decision
    Scenario: Marking the same test again does not award the points twice
      When Aarav's week 11 test is marked again
      Then he still has 342 points for week 11
      And his total is still 1,592 points

    @api
    Scenario: A child's points are never counted for their brother or sister
      Given Maya had 600 points in total before week 11
      And Maya earned 186 points for her week 11 test on Tuesday 10 November 2026
      When Sam opens his dashboard
      Then he sees Aarav has 1,592 points in total and Maya has 786 points in total

    @api
    Scenario: Wrong and unanswered answers never take points away
      Given Maya had 600 points in total before week 11
      And Maya's week 11 test was sent when time ran out with 10 answered
      And she got 0 answers right
      When Maya's week 11 test is marked
      Then she earns 0 points for week 11
      And her total is still 600 points

  Rule: A week without a test earns nothing, and late answers earn nothing

    @api @ui
    Scenario: A week not taken shows that no test was taken
      Given Aarav did not start his week 11 test
      And it is Monday 16 November 2026 at 07:00
      And Aarav has signed in on this device after Sam
      When Aarav opens his week 11 results
      Then he sees the message "No test taken in week 11"
      And he earned 0 points for week 11

    @api
    Scenario: Answers refused after the close earn nothing
      Given Aarav started his week 11 test on Sunday 15 November 2026 at 23:40 and has answered 12 questions
      And it is Monday 16 November 2026 at 00:05
      When Aarav tries to answer question 13
      Then he sees the message "This test has closed"
      And his week 11 results count only the 12 answers sent at 00:00

  Rule: Only the child and their own parent can see the results

    Background:
      Given it is Tuesday 10 November 2026 at 17:30
      And Aarav submitted his week 11 test at 17:20 with 26 correct answers
      And Zara from another family is in the group "Oakfield Friends" with Aarav

    @api @ui
    Scenario: Sam sees Aarav's results
      Given Sam is signed in
      When Sam opens Aarav's week 11 results
      Then he sees "26 out of 30", the points, the time taken and the mistakes to review

    @api @ui @decision
    Scenario Outline: Nobody else can open Aarav's results
      Given <session>
      When <who> tries to open Aarav's week 11 results
      Then <who> sees the message "Results not found"
      And <who> does not see Aarav's score, time taken or mistakes

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
