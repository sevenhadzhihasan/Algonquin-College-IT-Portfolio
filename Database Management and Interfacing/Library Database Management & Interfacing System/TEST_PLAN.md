# Milestone #1 Test Plan - Library Database Project
**Student Network ID:** hadz0024

| Test ID | Test Purpose | Test Data | Expected Result | Actual Result |
| :--- | :--- | :--- | :--- | :--- |
| **TP-01** | Verify initial interface visualization | Application launch | Displays options 1-5 and Q option layout cleanly. | PASS |
| **TP-02** | Validate lowercase quit input string | Input: `q` | Bypasses loops and exits with zero error tracebacks. | PASS |
| **TP-03** | Validate uppercase quit input string | Input: `Q` | Normalizes character to lowercase and exits cleanly. | PASS |
| **TP-04** | Trap invalid navigation index numbers | Input: `7` | Blocks entry; requests menu options 1-5 or Q. | PASS |
| **TP-05** | Trap text strings inside menu choices | Input: `show` | Catches entry safely and prompts for valid option. | PASS |
| **TP-06** | Verify branch option 1 execution flow | Input: `1` | Prints "Displaying all books" and "Querying books". | PASS |
| **TP-07** | Verify branch option 2 execution flow | Input: `2` | Prints "Displaying all members" and "Querying members". | PASS |
| **TP-08** | Block missing parameters on lookup loops | Input: `3` then `[Enter]` | Output: "Input field cannot be left blank." | PASS |
| **TP-09** | Verify branch option 3 execution flow | Input: `3` then `6131222345` | Processes string safely and displays query stubs. | PASS |
| **TP-10** | Verify option 4 empty string enforcement | Input: `4` then `[Enter]` | Traps field and demands a non-empty string. | PASS |
| **TP-11** | Confirm option 4 compound data tracking | Input: `4` then `613123` then `1` | Collects parameters sequentially and loads stub data. | PASS |
| **TP-12** | Confirm option 5 update execution flow | Input: `5` then `101` | Triggers "Updating loan return" routine placeholder. | PASS |
