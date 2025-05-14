# Core Functionalities
* An internal list with the Tokens is stored
* Parses a space-separated infix expression
* Handles implicit multiplication like `2(3)` by inserting a `*`
* Handles operator replacement logic (e.g., replacing a `+` if another operator follows immediately).
* Uses the Reverse Polish Notation and evaluates the expression using a stack-based method
