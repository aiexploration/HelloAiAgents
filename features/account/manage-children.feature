@R2 @wip
Feature: Manage children
  Parents add, change and remove their own children. A child is only a nickname,
  a year group from 4 to 7, one or more exam styles and a 4-digit PIN (N3).

  Background:
    Given Sam is signed in as a parent
    And Sam's children are Aarav in Year 6 and Maya in Year 4
    And Aarav's PIN is "4821" and Maya's PIN is "1357"

  @api @ui
  Scenario Outline: Sam adds a child in any year group from 4 to 7
    When Sam adds a child with nickname "Kiran", Year <year>, exam styles GL and CEM and PIN "3961" entered twice
    Then the dashboard shows Aarav, Maya and Kiran in Year <year>
    And the child sign-in screen on this device shows Aarav, Maya and Kiran
    And Kiran can sign in with PIN "3961"

    Examples:
      | year |
      | 5    |
      | 4    |
      | 7    |

  @api @ui @N3
  Scenario: Adding a child asks only for what Prepwise needs
    When Sam starts adding a child
    Then he is asked only for a nickname, year group, exam styles and a PIN
    And he is not asked for an email, surname, school, photo or date of birth

  @api @ui
  Scenario Outline: Details that break the rules are refused
    When Sam adds a child with nickname "<nickname>", Year <year>, exam style GL and PIN "<pin>" entered twice
    Then he sees the message "<message>"
    And Sam's children are still only Aarav and Maya

    Examples: Year group must be 4 to 7
      | nickname | year | pin  | message                            |
      | Kiran    | 3    | 3961 | Year group must be between 4 and 7 |
      | Kiran    | 8    | 3961 | Year group must be between 4 and 7 |

    @N3 @decision
    Examples: Nickname must be short, unique in the family and free of contact details
      | nickname               | year | pin  | message                                     |
      |                        | 5    | 3961 | Enter a nickname                            |
      | Alexandra-Christabelle | 5    | 3961 | Nickname must be 20 characters or fewer     |
      | aarav                  | 5    | 3961 | You already have a child with that nickname |
      | kiran@example.com      | 5    | 3961 | Nickname can't contain numbers or @         |
      | Kiran5                 | 5    | 3961 | Nickname can't contain numbers or @         |

    Examples: PIN must be exactly 4 digits
      | nickname | year | pin   | message                      |
      | Kiran    | 5    | 123   | PIN must be exactly 4 digits |
      | Kiran    | 5    | 12345 | PIN must be exactly 4 digits |
      | Kiran    | 5    | 12a4  | PIN must be exactly 4 digits |

    @decision
    Examples: Very easy PINs are refused
      | nickname | year | pin  | message                              |
      | Kiran    | 5    | 0000 | Choose a PIN that is harder to guess |
      | Kiran    | 5    | 7777 | Choose a PIN that is harder to guess |
      | Kiran    | 5    | 1234 | Choose a PIN that is harder to guess |
      | Kiran    | 5    | 9876 | Choose a PIN that is harder to guess |

  @api @ui
  Scenario: The two PIN entries must match
    When Sam adds a child with nickname "Kiran", Year 5, exam style GL, PIN "3961" and confirmation "3916"
    Then he sees the message "The two PINs don't match"
    And Sam's children are still only Aarav and Maya

  @api @ui @decision
  Scenario: At least one exam style must be chosen
    When Sam adds a child with nickname "Kiran", Year 5, no exam style and PIN "3961" entered twice
    Then he sees the message "Choose at least one exam style: GL, CEM or ISEB"
    And Sam's children are still only Aarav and Maya

  @api @decision
  Scenario: A family can have at most 6 children
    Given Sam already has 6 children
    When Sam adds a child with nickname "Kiran", Year 5, exam style GL and PIN "3961" entered twice
    Then he sees the message "You can add up to 6 children"
    And Kiran is not added

  @api
  Scenario: Changing year group and exam style applies from the next weekly test
    Given Aarav has a week 8 test in progress
    When Sam moves Aarav to Year 7 and changes his exam styles to ISEB only
    Then Aarav's next weekly draft is levelled to Year 7 in ISEB style
    And Aarav's week 8 test in progress is unchanged

  @api @ui
  Scenario: Renaming a child shows the new nickname everywhere
    Given Maya is in the group "Oakfield Friends"
    When Sam renames Maya to "Mimi"
    Then the child sign-in screen on this device shows Aarav and Mimi
    And the "Oakfield Friends" ranking shows Mimi instead of Maya

  @api @ui
  Scenario: Resetting a PIN replaces the old one
    When Sam resets Maya's PIN to "8642"
    Then Maya cannot sign in with PIN "1357"
    And Maya can sign in with PIN "8642"

  @api @decision
  Scenario: Resetting a PIN lifts the wrong-PIN pause
    Given Maya's sign-in is paused after 5 wrong PINs
    When Sam resets Maya's PIN to "8642"
    Then Maya can sign in with PIN "8642" straight away
    And Sam's dashboard no longer shows Maya's sign-in as paused

  @api @ui @N3
  Scenario: A PIN is never shown back
    When Sam opens Maya's details
    Then he sees her nickname, year group and exam styles
    And he is offered to reset her PIN
    And Maya's PIN is not shown

  @ui
  Scenario: Cancelling a removal keeps the child
    Given Sam has chosen to remove Maya and is asked to confirm
    When Sam cancels
    Then the dashboard still shows Aarav and Maya

  @api @ui
  Scenario: A removed child disappears from every list
    Given Maya is in the group "Oakfield Friends"
    When Sam removes Maya and confirms
    Then the dashboard shows only Aarav
    And the child sign-in screen on this device shows only Aarav
    And the "Oakfield Friends" rankings no longer show Maya

  @api @ui
  Scenario: A removed child can no longer sign in
    Given Maya is signed in on another device
    When Sam removes Maya and confirms
    Then Maya cannot sign in with PIN "1357"
    And the other device returns to the child sign-in screen

  @api @N3 @decision
  Scenario: Removing a child deletes their data
    Given Maya has completed 3 weekly tests and earned points in "Oakfield Friends"
    When Sam removes Maya and confirms
    Then Maya's tests, answers and points are deleted, not just hidden
    And the "Oakfield Friends" all-time ranking no longer counts Maya's points

  @api @ui
  Scenario Outline: Another family's child looks the same as one that does not exist
    Given Priya is another parent whose child Zara is in "Oakfield Friends" with Aarav
    When Sam tries to <action>
    Then he sees the message "Child not found", the same as for a child that does not exist
    And Zara's details are unchanged

    Examples:
      | action                   |
      | view Zara's details      |
      | change Zara's year group |
      | remove Zara              |

  @api @ui
  Scenario Outline: A child cannot manage children
    Given Sam has signed out and Aarav is signed in on this device
    When Aarav tries to <action>
    Then he is asked for a parent's email and password
    And Sam's children are unchanged

    Examples:
      | action                   |
      | add a child              |
      | change Maya's year group |
      | remove Maya              |

  @api
  Scenario: Managing children needs a parent session
    Given Sam has signed out and nobody is signed in
    When someone opens the page for managing children
    Then they are asked to sign in as a parent
