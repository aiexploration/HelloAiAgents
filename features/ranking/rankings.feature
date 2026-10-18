@R10 @wip
Feature: Weekly and all-time rankings within a group
  Each group has a weekly ranking, which starts again at Monday 00:00 UK time, and an all-time
  ranking that adds up every week (R10). Only the top 3 are shown by rank, with nickname and points.
  Everyone else sees milestone tiers and their own position. Rankings only ever compare children in
  the same group, and children appear by nickname only (N3). Points come from the weekly test (R9,
  SCRUM-23). Weekly tiers: Gold from 300 points, Silver from 200, Bronze from 100, Starter below 100.
  All-time tiers: Gold from 2,500 points, Silver from 1,000, Bronze from 500, Starter below 500.
  Whether Year 4 children should see the ranking is an open question in the requirements.

  Background:
    Given Sam's children are Aarav in Year 6 and Maya in Year 4
    And Priya's children are Zara in Year 6 and Ivy in Year 5
    And Leo's only child is Kai in Year 5
    And week 11 runs from Monday 9 November 2026
    And Sam has created the group "Oakfield Friends" with Aarav and Maya
    And Priya has joined "Oakfield Friends" with Zara and Ivy
    And Omar, Noah and Ella from other families are in "Oakfield Friends"
    And Leo has created the group "Riverside Readers" with Kai
    And the children in "Oakfield Friends" have these points:
      | child | all-time before week 11 | week 11 |
      | Aarav | 1,250                   | 342     |
      | Zara  | 1,400                   | 310     |
      | Ivy   | 900                     | 290     |
      | Omar  | 1,100                   | 270     |
      | Maya  | 600                     | 186     |
      | Noah  | 300                     | 50      |
      | Ella  | 700                     | no test |

  Rule: Only the top 3 are shown by rank; everyone else sees tiers and their own position

    Background:
      Given it is Saturday 14 November 2026 at 10:00

    @api @ui
    Scenario: The top 3 are shown by rank with their nickname and points
      Given Omar has signed in on his family's device
      When Omar opens this week's "Oakfield Friends" ranking
      Then he sees the top 3: 1st Aarav with 342 points, 2nd Zara with 310 points and 3rd Ivy with 290 points

    @api @ui @decision
    Scenario: A child outside the top 3 sees their own position and tier, and only the tiers of others
      Given Omar has signed in on his family's device
      When Omar opens this week's "Oakfield Friends" ranking
      Then he sees "You're 4th this week with 270 points. Silver tier."
      And below the top 3 he sees Omar in Silver, Maya in Bronze and Noah in Starter
      And he does not see Maya's or Noah's points or positions

    @api @ui @decision
    Scenario Outline: Every child sees their own position and weekly tier
      Given <session>
      When <child> opens this week's "Oakfield Friends" ranking
      Then <child> sees "<message>"

      Examples:
        | child | session                                      | message                                             |
        | Aarav | Aarav has signed in on this device after Sam | You're 1st this week with 342 points. Gold tier.    |
        | Maya  | Maya has signed in on this device after Sam  | You're 5th this week with 186 points. Bronze tier.  |
        | Noah  | Noah has signed in on his family's device    | You're 6th this week with 50 points. Starter tier.  |
        | Ella  | Ella has signed in on her family's device    | Take your week 11 test to join this week's ranking. |

    @api @decision
    Scenario Outline: Weekly tiers start at 100, 200 and 300 points
      Given Noah has <points> points in week 11
      And Noah has signed in on his family's device
      When Noah opens this week's "Oakfield Friends" ranking
      Then he sees "<tier> tier"

      Examples:
        | points | tier    |
        | 0      | Starter |
        | 99     | Starter |
        | 100    | Bronze  |
        | 199    | Bronze  |
        | 200    | Silver  |
        | 299    | Silver  |
        | 300    | Gold    |

    @api @ui @decision
    Scenario: A child with no test this week is listed as not taken yet, without a position
      Given Omar has signed in on his family's device
      When Omar opens this week's "Oakfield Friends" ranking
      Then he sees Ella under "Not taken yet"
      And Ella has no position in this week's "Oakfield Friends" ranking

    @api @ui @decision
    Scenario: A parent sees the top 3 and the position and tier of each of their own children
      Given Sam is signed in
      When Sam opens this week's "Oakfield Friends" ranking
      Then he sees the top 3: 1st Aarav with 342 points, 2nd Zara with 310 points and 3rd Ivy with 290 points
      And he sees "Maya: 5th this week with 186 points. Bronze tier."
      And he does not see Omar's or Noah's points or positions

    @api @ui @decision
    Scenario: Maya in Year 4 sees the group ranking like everyone else
      Given Maya has signed in on this device after Sam
      When Maya opens this week's "Oakfield Friends" ranking
      Then she sees the top 3: 1st Aarav with 342 points, 2nd Zara with 310 points and 3rd Ivy with 290 points
      And she sees "You're 5th this week with 186 points. Bronze tier."

    @api @ui @N3 @decision
    Scenario: The ranking shows children only by nickname
      Given Sam is signed in
      When Sam opens this week's "Oakfield Friends" ranking
      Then each child is shown only by nickname
      And no surname, school, photo, year group, parent's name or email is shown

  Rule: Children with the same points share a place

    Background:
      Given it is Saturday 14 November 2026 at 10:00
      And Maya has signed in on this device after Sam

    @api @ui @decision
    Scenario Outline: Tied children share a place, in nickname order, and the next place is skipped
      Given <change>
      When Maya opens this week's "Oakfield Friends" ranking
      Then she sees the top 3: <top 3>
      And she sees "You're 5th this week with 186 points. Bronze tier."

      Examples:
        | change                                       | top 3                                                                                            |
        | Ivy and Omar also have 310 points in week 11 | 1st Aarav with 342 points, then joint 2nd Ivy, Omar and Zara with 310 points                     |
        | Omar also has 290 points in week 11          | 1st Aarav with 342 points, 2nd Zara with 310 points, then joint 3rd Ivy and Omar with 290 points |

  Rule: The weekly ranking starts again at Monday 00:00 UK time

    @api @ui
    Scenario Outline: This week's ranking changes over at midnight on Sunday, UK time
      Given it is <when>
      And Aarav has signed in on this device after Sam
      When Aarav opens this week's "Oakfield Friends" ranking
      Then he sees the week <week> ranking

      Examples:
        | when                             | week |
        | Sunday 15 November 2026 at 23:59 | 11   |
        | Monday 16 November 2026 at 00:00 | 12   |

      Examples: During British Summer Time, midnight UK time is 23:00 the evening before in UTC
        | when                            | week |
        | Sunday 18 October 2026 at 23:59 | 7    |
        | Monday 19 October 2026 at 00:00 | 8    |

    @api @ui
    Scenario: A new week's ranking starts with nobody on points
      Given it is Monday 16 November 2026 at 08:00
      And Aarav has signed in on this device after Sam
      When Aarav opens this week's "Oakfield Friends" ranking
      Then he sees every child in "Oakfield Friends" under "Not taken yet"
      And he sees "Take your week 12 test to join this week's ranking."

    @api @decision
    Scenario: Points from a test sent at the Sunday-midnight close stay in the week that closed
      Given Maya's week 11 test was sent when the test closed on Monday 16 November 2026 at 00:00, with 30 of 30 answered
      And it earned her 186 points
      And it is Monday 16 November 2026 at 08:00
      And Maya has signed in on this device after Sam
      When Maya opens last week's "Oakfield Friends" ranking
      Then she sees "You were 5th in week 11 with 186 points. Bronze tier."
      And Maya has no points in this week's "Oakfield Friends" ranking

  Rule: The all-time ranking adds up every week and never resets

    @api @ui
    Scenario: The all-time top 3 includes this week's points
      Given it is Saturday 14 November 2026 at 10:00
      And Maya has signed in on this device after Sam
      When Maya opens the all-time "Oakfield Friends" ranking
      Then she sees the top 3: 1st Zara with 1,710 points, 2nd Aarav with 1,592 points and 3rd Omar with 1,370 points
      And she sees "You're 5th all-time with 786 points. Bronze tier."

    @api @ui @decision
    Scenario Outline: A week without a test keeps a child's all-time points, and the reset does not touch them
      Given it is <when>
      And <session>
      When <child> opens the all-time "Oakfield Friends" ranking
      Then <child> sees "<message>"

      Examples:
        | when                               | child | session                                   | message                                             |
        | Saturday 14 November 2026 at 10:00 | Ella  | Ella has signed in on her family's device | You're 6th all-time with 700 points. Bronze tier.   |
        | Saturday 14 November 2026 at 10:00 | Noah  | Noah has signed in on his family's device | You're 7th all-time with 350 points. Starter tier.  |
        | Monday 16 November 2026 at 00:00   | Ivy   | Ivy has signed in on her family's device  | You're 4th all-time with 1,190 points. Silver tier. |

  Rule: A ranking only ever compares children in the same group

    Background:
      Given it is Saturday 14 November 2026 at 10:00
      And Kai has 400 points in week 11
      And Zara is in both "Oakfield Friends" and "Riverside Readers"

    @api @ui
    Scenario: Children in another group never appear, even with more points
      Given Aarav has signed in on this device after Sam
      When Aarav opens this week's "Oakfield Friends" ranking
      Then he sees the top 3: 1st Aarav with 342 points, 2nd Zara with 310 points and 3rd Ivy with 290 points
      And Kai does not appear in it

    @api @decision
    Scenario: A child in two groups counts in each, with the same points
      Given Zara has signed in on her family's device
      When Zara opens this week's "Riverside Readers" ranking
      Then she sees the top 3: 1st Kai with 400 points and 2nd Zara with 310 points
      And Aarav, Maya, Ivy, Omar, Noah and Ella do not appear in it

  Rule: Only the group's children and their parents can see its ranking

    Background:
      Given it is Saturday 14 November 2026 at 10:00

    @api @ui
    Scenario Outline: Children in the group and their parents can see its ranking
      Given <session>
      When <who> opens this week's "Oakfield Friends" ranking
      Then <who> sees the top 3: 1st Aarav with 342 points, 2nd Zara with 310 points and 3rd Ivy with 290 points

      Examples:
        | who   | session                                      |
        | Aarav | Aarav has signed in on this device after Sam |
        | Zara  | Zara has signed in on her family's device    |
        | Sam   | Sam is signed in                             |
        | Priya | Priya is signed in                           |

    @api @ui
    Scenario Outline: Anyone outside the group is told it does not exist
      Given <session>
      When <who> tries to open <ranking> "Oakfield Friends" ranking
      Then <who> sees the message "Group not found"
      And <who> does not see any child's nickname, points or tier

      Examples:
        | who | session                                  | ranking      |
        | Leo | Leo is signed in                         | this week's  |
        | Leo | Leo is signed in                         | the all-time |
        | Kai | Kai has signed in on his family's device | this week's  |
        | Kai | Kai has signed in on his family's device | the all-time |

    @api
    Scenario: Seeing a ranking needs someone to be signed in
      Given nobody is signed in
      When someone tries to open this week's "Oakfield Friends" ranking
      Then they are asked to sign in
