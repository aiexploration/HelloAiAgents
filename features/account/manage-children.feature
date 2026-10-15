@R2 @wip
Feature: Manage children
  Parents add, change and remove their own children. Each child has a nickname,
  a year group from 4 to 7, one or more exam styles and a 4-digit PIN (R2).
  Nothing else about a child is asked for or kept (N3).

  Background:
    Given Sam is signed in
    And Sam's children are Aarav in Year 6 and Maya in Year 4
    And Aarav's PIN is "4821" and Maya's PIN is "1357"

  @api @ui @decision
  Scenario Outline: Sam adds a child
    When Sam adds a child with nickname "<nickname>", Year <year>, exam styles GL and CEM and PIN "3961" entered twice
    Then the dashboard shows Aarav, Maya and <nickname>, with <nickname> in Year <year>
    And the child sign-in screen on this device shows the profiles Aarav, Maya and <nickname>
    And <nickname> can sign in with PIN "3961"

    Examples:
      | nickname             | year |
      | Kiran                | 4    |
      | Kiran                | 5    |
      | Kiran                | 6    |
      | Kiran                | 7    |
      | Christabelleannabell | 5    |

  @ui @N3
  Scenario: Adding a child asks only for what Prepwise needs
    When Sam starts adding a child
    Then he is asked only for a nickname, year group, exam styles and a PIN
    And he is not asked for an email, surname, school, photo or date of birth

  @api @N3
  Scenario: Extra details sent for a child are not kept
    When Sam adds Kiran in Year 5 with exam style GL and PIN "3961" and also sends a surname and an email
    Then Kiran is saved with only a nickname, year group, exam styles and PIN
    And no surname or email is stored for Kiran

  Scenario Outline: Details that break the rules are refused when adding a child
    When Sam adds a child with nickname "<nickname>", Year <year>, exam styles <styles> and PIN "<pin>" entered twice
    Then he sees the message "<message>"
    And Sam's children are still only Aarav and Maya

    @api
    Examples: Year group must be 4 to 7
      | nickname | year | styles | pin  | message                            |
      | Kiran    | 3    | GL     | 3961 | Year group must be between 4 and 7 |
      | Kiran    | 8    | GL     | 3961 | Year group must be between 4 and 7 |

    @api @ui @N3 @decision
    Examples: Nickname must be short, unique in the family and free of contact details
      | nickname              | year | styles | pin  | message                                     |
      |                       | 5    | GL     | 3961 | Enter a nickname                            |
      | Christabelleannabella | 5    | GL     | 3961 | Nickname must be 20 characters or fewer     |
      | aarav                 | 5    | GL     | 3961 | You already have a child with that nickname |
      | kiran@example.com     | 5    | GL     | 3961 | Nickname can't contain numbers or @         |
      | Kiran5                | 5    | GL     | 3961 | Nickname can't contain numbers or @         |

    @api @ui
    Examples: PIN must be exactly 4 digits
      | nickname | year | styles | pin   | message                      |
      | Kiran    | 5    | GL     | 123   | PIN must be exactly 4 digits |
      | Kiran    | 5    | GL     | 12345 | PIN must be exactly 4 digits |

    @api
    Examples: PIN must be digits only
      | nickname | year | styles | pin  | message                      |
      | Kiran    | 5    | GL     | 12a4 | PIN must be exactly 4 digits |

    @api @ui @decision
    Examples: Very easy PINs are refused
      | nickname | year | styles | pin  | message                              |
      | Kiran    | 5    | GL     | 0000 | Choose a PIN that is harder to guess |
      | Kiran    | 5    | GL     | 7777 | Choose a PIN that is harder to guess |
      | Kiran    | 5    | GL     | 1234 | Choose a PIN that is harder to guess |
      | Kiran    | 5    | GL     | 9876 | Choose a PIN that is harder to guess |

    @api @ui @decision
    Examples: At least one exam style must be chosen
      | nickname | year | styles | pin  | message                                         |
      | Kiran    | 5    | none   | 3961 | Choose at least one exam style: GL, CEM or ISEB |

  @api @ui
  Scenario: The two PIN entries must match
    When Sam adds a child with nickname "Kiran", Year 5, exam styles GL, PIN "3961" and confirmation "3916"
    Then he sees the message "The two PINs don't match"
    And Sam's children are still only Aarav and Maya

  @api @decision
  Scenario: A family can have at most 6 children
    Given Sam has added 4 more children, so he has 6
    When Sam adds a child with nickname "Kiran", Year 5, exam styles GL and PIN "3961" entered twice
    Then he sees the message "You can add up to 6 children"
    And Sam still has 6 children

  @api @R4 @decision
  Scenario: Changing year group and exam style applies from the next weekly test
    Given it is Wednesday 22 October 2026 at 18:00
    And Aarav has a week 8 test in progress
    When Sam changes Aarav to Year 7 with ISEB as his only exam style
    Then Aarav's week 9 draft is levelled to Year 7 in ISEB style
    And Aarav's week 8 test in progress is unchanged

  @api @ui
  Scenario: Renaming a child shows the new nickname everywhere
    Given Maya is 2nd in this week's "Oakfield Friends" ranking
    When Sam renames Maya to "Mimi"
    Then the child sign-in screen on this device shows the profiles Aarav and Mimi
    And this week's "Oakfield Friends" ranking shows Mimi 2nd instead of Maya

  Scenario Outline: Changes that break the rules are refused
    When Sam changes Maya's <field> to "<value>"
    Then he sees the message "<message>"
    And Maya's details are unchanged

    @api @ui
    Examples:
      | field      | value | message                                     |
      | nickname   | Aarav | You already have a child with that nickname |
      | year group | 8     | Year group must be between 4 and 7          |

    @api @ui @decision
    Examples:
      | field       | value | message                                         |
      | PIN         | 0000  | Choose a PIN that is harder to guess            |
      | exam styles | none  | Choose at least one exam style: GL, CEM or ISEB |

  @api @ui
  Scenario: Resetting a PIN replaces the old one
    When Sam resets Maya's PIN to "8642" entered twice
    Then Maya cannot sign in with PIN "1357"
    And Maya can sign in with PIN "8642"

  @api @decision
  Scenario: Resetting a PIN lifts the wrong-PIN pause
    Given it is Tuesday 21 October 2026 at 17:02
    And Maya's sign-in was paused at 17:00 after 5 wrong PINs
    When Sam resets Maya's PIN to "8642" entered twice
    Then Maya can sign in with PIN "8642"
    And Sam's dashboard no longer shows Maya's sign-in as paused

  @api @ui @N3
  Scenario: A PIN is never shown back
    When Sam opens Maya's details
    Then he sees her nickname, year group and exam styles
    And he can choose to reset her PIN
    And Maya's PIN is not shown

  @ui
  Scenario: Cancelling a removal keeps the child
    Given Sam has chosen to remove Maya and is asked to confirm
    When Sam cancels
    Then the dashboard still shows Aarav and Maya

  @api @ui
  Scenario: A removed child disappears from every list
    Given Maya is 2nd in this week's "Oakfield Friends" ranking
    When Sam removes Maya and confirms
    Then the dashboard shows only Aarav
    And the child sign-in screen on this device shows only the profile Aarav
    And Maya is in neither this week's nor the all-time "Oakfield Friends" ranking

  @api @ui
  Scenario: A removed child can no longer sign in
    Given Maya is signed in on another device
    When Sam removes Maya and confirms
    Then Maya cannot sign in with PIN "1357"
    And Maya's session on the other device has ended

  @api @N3 @decision
  Scenario: Removing a child deletes their data
    Given Maya has completed 3 weekly tests and earned points in "Oakfield Friends"
    And Maya has an unapproved week 9 draft
    When Sam removes Maya and confirms
    Then Maya's tests, answers, points and draft are deleted, not just hidden
    And the all-time "Oakfield Friends" ranking no longer counts Maya's points

  @api @ui
  Scenario Outline: Another family's child is treated like a child that does not exist
    Given Zara from another family is in the group "Oakfield Friends" with Aarav
    When Sam tries to <action>
    Then he sees the message "Child not found"
    And no child's details are changed

    Examples:
      | action                                         |
      | view Zara's details                            |
      | change Zara's year group                       |
      | remove Zara                                    |
      | view the details of a child who does not exist |

  @api @ui @decision
  Scenario Outline: A child cannot manage children
    Given Aarav has signed in on this device after Sam
    When Aarav tries to <action>
    Then he is asked for a parent's email and password
    And Sam's children are unchanged

    Examples:
      | action                   |
      | add a child              |
      | change Maya's year group |
      | remove Maya              |

  @api
  Scenario Outline: Managing children needs a parent session
    Given nobody is signed in
    When someone tries to <action>
    Then they are asked to sign in as a parent
    And Sam's children are unchanged

    Examples:
      | action                   |
      | add a child              |
      | change Maya's year group |
      | remove Maya              |
