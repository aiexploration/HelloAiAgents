@R3 @wip
Feature: Groups and invites
  A parent creates a group, chooses which of their children are in it and gets an
  invite code to share with other families, by hand or by email (R3).
  Rankings only ever compare children inside the same group.
  Other families only ever see a child's nickname and year group (N3).

  Background:
    Given Sam has a parent account with email "sam@example.com" and children Aarav in Year 6 and Maya in Year 4
    And Priya has a parent account with email "priya@example.com" and children Zara in Year 6 and Ivy in Year 5
    And Leo has a parent account with email "leo@example.com" and a child Kai in Year 5

  @api @ui @decision
  Scenario Outline: Sam creates a group, chooses his children and gets an invite code
    Given Sam is signed in
    When Sam creates a group named "<name>" with <children>
    Then he sees the group "<name>" with the members <members>
    And he sees an invite code of 8 capital letters and digits, never 0, O, 1, I or L

    Examples:
      | name                                     | children       | members        |
      | Oakfield Friends                         | Aarav and Maya | Aarav and Maya |
      | Oakfield and Riverside Eleven Plus Group | only Aarav     | Aarav          |

  @api @ui @decision
  Scenario Outline: A group that breaks the rules is not created
    Given Sam is signed in
    And Sam has created the group "Oakfield Friends" with Aarav and Maya
    When Sam creates a group named "<name>" with <children>
    Then he sees the message "<message>"
    And Sam's only group is still "Oakfield Friends"

    Examples:
      | name                                      | children | message                                   |
      |                                           | Aarav    | Enter a group name                        |
      | Oakfield and Riverside Eleven Plus Groups | Aarav    | Group name must be 40 characters or fewer |
      | oakfield friends                          | Aarav    | You already have a group with that name   |
      | Maths Club                                | no child | Choose at least one child for the group   |

  Rule: Sharing the invite code

    Background:
      Given Sam has created the group "Oakfield Friends" with Aarav and Maya
      And the invite code for "Oakfield Friends" is "K7MP4QXT"
      And Sam is signed in

    @ui
    Scenario: Sam copies the invite code
      When Sam copies the invite code for "Oakfield Friends"
      Then the code "K7MP4QXT" is ready to paste
      And he sees the message "Invite code copied"

    @api @ui
    Scenario: Sam sends the invite code by email
      When Sam sends the invite code for "Oakfield Friends" to "priya@example.com"
      Then he sees the message "Invite sent to priya@example.com"
      And an invite email goes to "priya@example.com"
      And the email shows the group "Oakfield Friends", Sam as the inviter and the code "K7MP4QXT"

    @api @N3
    Scenario: The invite email never mentions any child
      When Sam sends the invite code for "Oakfield Friends" to "priya@example.com"
      Then the email contains only the group name, the inviter's name, the code and how to join
      And it does not mention Aarav, Maya or any year group

    @api @ui
    Scenario: Sam resends the invite code
      Given it is Tuesday 21 October 2026 at 19:10
      And Sam sent the invite code for "Oakfield Friends" to "priya@example.com" at 19:00
      When Sam resends the invite code for "Oakfield Friends" to "priya@example.com"
      Then a second invite email with the code "K7MP4QXT" goes to "priya@example.com"

    @api @decision
    Scenario: Invite emails to one address are limited to 3 a day
      Given it is Tuesday 21 October 2026 at 21:00
      And Sam has sent the invite code for "Oakfield Friends" to "priya@example.com" 3 times today
      When Sam resends the invite code for "Oakfield Friends" to "priya@example.com"
      Then he sees the message "You've already sent 3 invites to this address today. Try again tomorrow."
      And no invite email goes to "priya@example.com"

    @api @ui
    Scenario: An invite needs a real-looking email address
      When Sam sends the invite code for "Oakfield Friends" to "priya-at-example.com"
      Then he sees the message "Enter a valid email address"
      And no invite email is sent

    @api @ui @decision
    Scenario: A new invite code replaces the old one
      Given Zara from another family is in the group "Oakfield Friends" with Aarav
      When Sam makes a new invite code for "Oakfield Friends"
      Then he sees an invite code for "Oakfield Friends" that is not "K7MP4QXT"
      And joining with the code "K7MP4QXT" shows "This invite code has expired. Ask for a new one."
      And Zara is still in the group "Oakfield Friends"

  Rule: Joining a group with a code

    Background:
      Given Sam has created the group "Oakfield Friends" with Aarav and Maya
      And the invite code for "Oakfield Friends" is "K7MP4QXT"
      And Priya is signed in

    @api @ui
    Scenario: Priya joins with the code and chooses which children join
      When Priya joins a group with the code "K7MP4QXT" and chooses Zara
      Then she sees the message "Zara has joined Oakfield Friends"
      And the group "Oakfield Friends" lists Aarav, Maya and Zara
      And this week's "Oakfield Friends" ranking includes Aarav, Maya and Zara
      And Ivy is not in the group "Oakfield Friends"

    @api @ui
    Scenario: At least one child must be chosen to join
      When Priya joins a group with the code "K7MP4QXT" and chooses no child
      Then she sees the message "Choose at least one child to join the group"
      And the group "Oakfield Friends" lists only Aarav and Maya

    @api @ui
    Scenario: A wrong code joins nobody
      When Priya joins a group with the code "K7MP4QXZ" and chooses Zara
      Then she sees the message "That invite code isn't right. Check it and try again."
      And the group "Oakfield Friends" lists only Aarav and Maya

    @api @decision
    Scenario Outline: Codes ignore capitals, spaces and dashes
      When Priya joins a group with the code "<typed>" and chooses Zara
      Then she sees the message "Zara has joined Oakfield Friends"

      Examples:
        | typed     |
        | k7mp4qxt  |
        | K7MP 4QXT |
        | k7mp-4qxt |

    @api @decision
    Scenario Outline: An invite code lasts 14 days
      Given the code "K7MP4QXT" was made on Monday 2 November 2026 at 19:00
      And it is <when>
      When Priya joins a group with the code "K7MP4QXT" and chooses Zara
      Then she sees the message "<message>"

      Examples:
        | when                             | message                                          |
        | Monday 16 November 2026 at 18:59 | Zara has joined Oakfield Friends                 |
        | Monday 16 November 2026 at 19:00 | This invite code has expired. Ask for a new one. |

    @api @ui
    Scenario: Joining twice does no harm
      Given Zara has joined "Oakfield Friends"
      When Priya joins a group with the code "K7MP4QXT" and chooses Zara
      Then she sees the message "Zara is already in Oakfield Friends"
      And Zara appears once in the group "Oakfield Friends" and once in its ranking

    @api @decision
    Scenario: The same code works for many families
      Given Zara has joined "Oakfield Friends"
      When Leo joins a group with the code "K7MP4QXT" and chooses Kai
      Then the group "Oakfield Friends" lists Aarav, Maya, Zara and Kai

    @api @decision
    Scenario: A group holds at most 30 children
      Given "Oakfield Friends" already has 30 children
      When Priya joins a group with the code "K7MP4QXT" and chooses Zara
      Then she sees the message "Oakfield Friends is full. A group can have up to 30 children."
      And Zara is not in the group "Oakfield Friends"

    @api @decision
    Scenario: A family can be in more than one group
      Given Zara has joined "Oakfield Friends"
      And Leo has created the group "Riverside Readers" with invite code "R4VN8WHE"
      When Priya joins a group with the code "R4VN8WHE" and chooses Zara
      Then Zara is in both "Oakfield Friends" and "Riverside Readers"
      And this week's "Riverside Readers" ranking does not show Aarav or Maya

  Rule: Who can see and change a group

    Background:
      Given Sam has created the group "Oakfield Friends" with Aarav and Maya
      And Zara from another family is in the group "Oakfield Friends" with Aarav

    @api @ui @N3
    Scenario: Members see only nicknames and year groups
      Given Priya is signed in
      When Priya opens the group "Oakfield Friends"
      Then she sees the members Aarav in Year 6, Maya in Year 4 and Zara in Year 6
      And she sees no other parent's email and no other child's details

    @api @ui
    Scenario Outline: A parent outside the group cannot see it
      Given Leo is signed in
      When Leo tries to <action>
      Then he sees the message "Group not found"
      And no group's members or ranking are shown

      Examples:
        | action                                      |
        | open the group "Oakfield Friends"           |
        | open this week's "Oakfield Friends" ranking |
        | open a group that does not exist            |

    @api @R10
    Scenario: Rankings only compare children in the same group
      Given Kai is only in the group "Riverside Readers"
      And Kai has more points this week than any child in "Oakfield Friends"
      When Aarav opens this week's "Oakfield Friends" ranking
      Then Kai does not appear in it

    @api @ui @decision
    Scenario Outline: Only the group's creator can invite or change the code
      Given Priya is signed in
      When Priya tries to <action>
      Then she sees the message "Only the parent who created the group can do that"
      And no invite email is sent

      Examples:
        | action                                                           |
        | see the invite code for "Oakfield Friends"                       |
        | send the invite code for "Oakfield Friends" to "leo@example.com" |
        | make a new invite code for "Oakfield Friends"                    |

    @api @ui @decision
    Scenario: A parent can take their child out of a group
      Given Zara is 2nd in this week's "Oakfield Friends" ranking
      And Priya is signed in
      When Priya takes Zara out of "Oakfield Friends" and confirms
      Then the group "Oakfield Friends" lists only Aarav and Maya
      And Zara is in neither this week's nor the all-time "Oakfield Friends" ranking
      And Priya's dashboard still shows Zara's own tests and scores

    @api @ui @decision
    Scenario Outline: A child cannot create, invite or join
      Given Aarav has signed in on this device after Sam
      When Aarav tries to <action>
      Then he is asked for a parent's email and password
      And Sam's groups are unchanged

      Examples:
        | action                                                           |
        | create a group named "Aarav's Team"                              |
        | send the invite code for "Oakfield Friends" to "leo@example.com" |
        | join a group with the code "K7MP4QXT"                            |

    @api
    Scenario Outline: Groups need a parent session
      Given nobody is signed in
      When someone tries to <action>
      Then they are asked to sign in as a parent
      And Sam's groups are unchanged

      Examples:
        | action                                                           |
        | create a group named "Oakfield Friends"                          |
        | send the invite code for "Oakfield Friends" to "leo@example.com" |
        | join a group with the code "K7MP4QXT"                            |
