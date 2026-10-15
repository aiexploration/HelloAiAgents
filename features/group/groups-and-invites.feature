@R3 @wip
Feature: Groups and invites
  A parent creates a group of their children and shares its invite code with other
  families, by hand or by email (R3). Members see only nicknames and year groups (N3).

  Background:
    Given Sam has a parent account with email "sam@example.com"
    And Sam's children are Aarav in Year 6 and Maya in Year 4
    And Priya has a parent account with email "priya@example.com"
    And Priya's children are Zara in Year 6 and Ivy in Year 5
    And Leo has a parent account with email "leo@example.com"
    And Leo's only child is Kai in Year 5

  @api @ui @decision
  Scenario Outline: Sam creates a group, chooses his children and gets an invite code
    Given Sam is signed in
    When Sam creates a group named <name> with <children>
    Then he sees the group <name> with the members <children>
    And he sees an invite code of 8 capital letters and digits, never 0, O, 1, I or L

    Examples:
      | name                                       | children       |
      | "Oakfield Friends"                         | Aarav and Maya |
      | "Oakfield and Riverside Eleven Plus Group" | Aarav          |

  @api @ui @decision
  Scenario Outline: A group that breaks the rules is not created
    Given Sam is signed in
    And Sam has created the group "Oakfield Friends" with Aarav and Maya
    When Sam creates a group named <name> with <children>
    Then he sees the message "<message>"
    And Sam's only group is still "Oakfield Friends"

    Examples:
      | name                                        | children | message                                      |
      | ""                                          | Aarav    | Enter a group name                           |
      | "   "                                       | Aarav    | Enter a group name                           |
      | "Oakfield and Riverside Eleven Plus Groups" | Aarav    | Group name must be 40 characters or fewer    |
      | "oakfield friends"                          | Aarav    | You already have a group with that name      |
      | "sam@example.com"                           | Aarav    | Group name can't contain @ or a phone number |
      | "07700900123"                               | Aarav    | Group name can't contain @ or a phone number |
      | "Maths Club"                                | no child | Choose at least one child for the group      |

  @api @ui
  Scenario: Sam adds another of his children later
    Given Sam has created the group "Oakfield Friends" with Aarav
    And Sam is signed in
    When Sam adds Maya to "Oakfield Friends"
    Then the group "Oakfield Friends" lists Aarav and Maya
    And this week's "Oakfield Friends" ranking includes Maya

  Rule: Only the creator shares the invite code

    Background:
      Given Sam has created the group "Oakfield Friends" with Aarav and Maya
      And the invite code for "Oakfield Friends" is "K7MP4QXT"
      And Sam is signed in

    @ui
    Scenario: Sam copies the invite code
      When Sam copies the invite code for "Oakfield Friends"
      Then the code "K7MP4QXT" is ready to paste
      And he sees the message "Invite code copied"

    @api @ui @N3
    Scenario Outline: Sam sends the invite code by email, never mentioning any child
      When Sam sends the invite code for "Oakfield Friends" to "<email>"
      Then he sees the message "Invite sent to <email>"
      And an invite email goes to "<email>"
      And the email contains only the group name, Sam's name, the code "K7MP4QXT" and a link to sign in and enter the code
      And it does not mention Aarav, Maya or any year group
      And it does not contain Sam's email address

      Examples: An address with a Prepwise account
        | email             |
        | priya@example.com |

      @decision
      Examples: The reply never reveals whether an address has an account
        | email              |
        | nobody@example.com |

    @api @ui
    Scenario: Sam resends the invite code
      Given it is Tuesday 21 October 2026 at 19:10
      And Sam has sent the invite code for "Oakfield Friends" to "priya@example.com" at 19:00
      When Sam resends the invite code for "Oakfield Friends" to "priya@example.com"
      Then a second invite email with the code "K7MP4QXT" goes to "priya@example.com"

    @api @decision
    Scenario Outline: Sam can email one group's code to one address at most 3 times a UK day
      Given Sam has sent the invite code for "Oakfield Friends" to "priya@example.com" 3 times on Tuesday 21 October 2026
      And it is <when>
      When Sam resends the invite code for "Oakfield Friends" to "priya@example.com"
      Then he sees the message "<message>"

      Examples:
        | when                               | message                                                                  |
        | Tuesday 21 October 2026 at 23:59   | You've already sent 3 invites to this address today. Try again tomorrow. |
        | Wednesday 22 October 2026 at 00:00 | Invite sent to priya@example.com                                         |

    @api @decision
    Scenario: A parent can send at most 20 invite emails a UK day
      Given it is Tuesday 21 October 2026 at 20:00
      And Sam has sent 20 invite emails today to different addresses
      When Sam sends the invite code for "Oakfield Friends" to "leo@example.com"
      Then he sees the message "You can send up to 20 invites a day. Try again tomorrow."
      And no invite email is sent

    @api @ui @decision
    Scenario: A new invite code replaces the old one
      Given Zara from another family is in the group "Oakfield Friends" with Aarav
      When Sam makes a new invite code for "Oakfield Friends"
      Then he sees an invite code for "Oakfield Friends" that is not "K7MP4QXT"
      And Zara is still in the group "Oakfield Friends"

  Rule: A valid code lets a family join

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
    Scenario: Two children join at once
      When Priya joins a group with the code "K7MP4QXT" and chooses Zara and Ivy
      Then she sees the message "Zara and Ivy joined Oakfield Friends"
      And the group "Oakfield Friends" lists Aarav, Maya, Zara and Ivy

    @api @ui
    Scenario: Priya adds another child to a group she is already in
      Given Zara from another family is in the group "Oakfield Friends" with Aarav
      When Priya joins a group with the code "K7MP4QXT" and chooses Ivy
      Then she sees the message "Ivy has joined Oakfield Friends"
      And the group "Oakfield Friends" lists Aarav, Maya, Zara and Ivy

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
    Scenario: Repeated wrong codes pause joining for 15 minutes
      Given it is Tuesday 21 October 2026 at 19:10
      And Priya has entered 5 wrong invite codes since 19:00
      When Priya joins a group with the code "K7MP4QXT" and chooses Zara
      Then she sees the message "Too many tries. Try again in 15 minutes."
      And the group "Oakfield Friends" lists only Aarav and Maya

    @api @decision
    Scenario Outline: Codes ignore capitals, spaces and dashes
      When Priya joins a group with the code "<typed>" and chooses Zara
      Then she sees the message "Zara has joined Oakfield Friends"

      Examples:
        | typed     |
        | K7MP 4QXT |
        | k7mp-4qxt |

    @api @decision
    Scenario Outline: An invite code lasts 14 days
      Given the invite code "K7MP4QXT" was made on Monday 2 November 2026 at 19:00
      And it is <when>
      When Priya joins a group with the code "K7MP4QXT" and chooses Zara
      Then she sees the message "<message>"

      Examples:
        | when                             | message                                          |
        | Monday 16 November 2026 at 18:59 | Zara has joined Oakfield Friends                 |
        | Monday 16 November 2026 at 19:00 | This invite code has expired. Ask for a new one. |

    @api @decision
    Scenario: A replaced code no longer works
      Given Sam has made a new invite code for "Oakfield Friends"
      When Priya joins a group with the code "K7MP4QXT" and chooses Zara
      Then she sees the message "This invite code has expired. Ask for a new one."
      And the group "Oakfield Friends" lists only Aarav and Maya

    @api @ui
    Scenario: Joining twice does no harm
      Given Zara from another family is in the group "Oakfield Friends" with Aarav
      When Priya joins a group with the code "K7MP4QXT" and chooses Zara
      Then she sees the message "Zara is already in Oakfield Friends"
      And Zara appears once in the group "Oakfield Friends" and once in its ranking

    @api @decision
    Scenario: The same code works for many families
      Given Zara from another family is in the group "Oakfield Friends" with Aarav
      And Leo is signed in
      When Leo joins a group with the code "K7MP4QXT" and chooses Kai
      Then the group "Oakfield Friends" lists Aarav, Maya, Zara and Kai

    @api @decision
    Scenario Outline: A group holds at most 30 children, and a family joins all or nothing
      Given "Oakfield Friends" already has <before> children
      When Priya joins a group with the code "K7MP4QXT" and chooses <children>
      Then she sees the message "<message>"
      And "Oakfield Friends" has <after> children

      Examples:
        | before | children     | message                                                       | after |
        | 29     | Zara         | Zara has joined Oakfield Friends                              | 30    |
        | 30     | Zara         | Oakfield Friends is full. A group can have up to 30 children. | 30    |
        | 29     | Zara and Ivy | Oakfield Friends has room for 1 more child. Choose fewer.     | 29    |

    @api @decision
    Scenario: A family can be in more than one group
      Given Zara from another family is in the group "Oakfield Friends" with Aarav
      And Leo has created the group "Riverside Readers" with Kai
      And the invite code for "Riverside Readers" is "R4VN8WHE"
      When Priya joins a group with the code "R4VN8WHE" and chooses Zara
      Then Zara is in both "Oakfield Friends" and "Riverside Readers"
      And this week's "Riverside Readers" ranking does not show Aarav or Maya

  Rule: Only members see a group

    Background:
      Given Sam has created the group "Oakfield Friends" with Aarav and Maya
      And the invite code for "Oakfield Friends" is "K7MP4QXT"
      And Zara from another family is in the group "Oakfield Friends" with Aarav

    @api @ui @N3
    Scenario: Members see only nicknames and year groups
      Given Priya is signed in
      When Priya opens the group "Oakfield Friends"
      Then she sees the members Aarav in Year 6, Maya in Year 4 and Zara in Year 6
      And she does not see any parent's name or email, or any child's exam styles

    @api @ui
    Scenario Outline: A parent outside the group is told it does not exist
      Given Leo is signed in
      When Leo tries to <action>
      Then he sees the message "Group not found"
      And the group "Oakfield Friends" lists only Aarav, Maya and Zara
      And no invite email is sent

      Examples:
        | action                                                             |
        | open the group "Oakfield Friends"                                  |
        | open this week's "Oakfield Friends" ranking                        |
        | send the invite code for "Oakfield Friends" to "priya@example.com" |
        | make a new invite code for "Oakfield Friends"                      |
        | take Aarav out of "Oakfield Friends"                               |
        | open a group that does not exist                                   |

    @api @R10
    Scenario: Rankings only compare children in the same group
      Given Leo has created the group "Riverside Readers" with Kai
      And Kai has more points this week than any child in "Oakfield Friends"
      And Aarav has signed in on this device after Sam
      When Aarav opens this week's "Oakfield Friends" ranking
      Then Kai does not appear in it

    @api @ui @decision
    Scenario Outline: Only the group's creator can see, send or change the code
      Given Priya is signed in
      When Priya tries to <action>
      Then she sees the message "Only the parent who created the group can do that"
      And the invite code is not shown to her
      And the invite code for "Oakfield Friends" is still "K7MP4QXT"
      And no invite email is sent

      Examples:
        | action                                                           |
        | see the invite code for "Oakfield Friends"                       |
        | send the invite code for "Oakfield Friends" to "leo@example.com" |
        | make a new invite code for "Oakfield Friends"                    |

    @api @N3
    Scenario Outline: A parent cannot use another family's child
      Given Priya is signed in
      When Priya tries to <action>
      Then she sees the message "Child not found"
      And the group "Oakfield Friends" lists only Aarav, Maya and Zara
      And Priya has no group of her own

      Examples:
        | action                                                 |
        | join a group with the code "K7MP4QXT" and choose Aarav |
        | create a group named "Zara's Club" with Aarav          |
        | take Aarav out of "Oakfield Friends"                   |

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
      And no invite email is sent

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
      And no invite email is sent

      Examples:
        | action                                                           |
        | create a group named "Oakfield Friends"                          |
        | send the invite code for "Oakfield Friends" to "leo@example.com" |
        | join a group with the code "K7MP4QXT"                            |
