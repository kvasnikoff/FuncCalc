# FuncCalc

**Term Project**

**Uni:** `MIREA – Russian Technological University`

**Field of study:** `Applied Mathematics and Informatics, Master's Degree`

**Subject:** `Functional Programming`

## Requirements

### Non-functional requirements

* Programming Language: `Swift`
* Use some fuctional programing patterns: `closures`, `pure finctions`, `higher-order functions` (i.e. map, filter, reduce), `etc.`

### Functional requirements

#### Defining functions with numbers and simple arithmetic operations (+, -, *, /, ^) in infix notation

```
>f1(x) = x^2
f1(x) = x^2

>f2(x) = 3*x
f2(x) = 3*x
```

#### Defining functions via previosly defined functions

```
>f1(x) = x^2
f1(x) = x^2

>f2(x) = 3*x
f2(x) = 3*x

>f3(x) = f1(x) + f2(x)
f3(x) = x^2 + 3*x
```

#### Calculation of the function value

```
>f3(x) = x^2 + 3*x
f3(x) = x^2 + 3*x

>f3(10)
f3(10) = 130
```

#### Taking symbolic derivative

```
>f3(x) = x^2 + 3*x
f3(x) = x^2 + 3*x

>f3’
f3’(x) = 2x + 3
```


## Tasks to accomplish functional requirements
- [x] Get rid of all spaces inside entered string
- [x] Write regular expressions to indentify command type (expression `f1(x) = x^2`, calculation `f3(10)` or invalid)
- [x] Parse expression-commands via regex and save results to Dictionary, where key is a name of a function (e.g. `f`) and value is struct containing symbol (e.g. `x`) and mathematical expression (e.g. `x^2 + 3*x`). So f(x) will overwrite f(y) and that's good, because when we calculate the function value, we don't use any symbol, only function name: `f(10)`
- [x] Transform functions defined by previosly defined functions into original representation (e.g. `f1(x) + f2(x)` -> `x^2 + 3*x`)
- [x] Study [Shunting_yard algorithm](https://en.wikipedia.org/wiki/Shunting_yard_algorithm) to translate `Infix notation` to `Reverse Polish Notation`
- [x] Implement Stack data structure
- [x] Check for parentheses balance
- [x] Detect numbers with many digits and decimal point as single token
- [x] Replace symbol of function (e.g. 'x' in 'f(x)') with number while function value calculation (e.g. 'f(10)') before using [Shunting_yard algorithm](https://en.wikipedia.org/wiki/Shunting_yard_algorithm)
- [ ] Implement token detection
- [ ] Implement [Shunting_yard algorithm](https://en.wikipedia.org/wiki/Shunting_yard_algorithm)
- [ ] Implement Reverse Polish Notation Calculation
- [ ] Do research into sumbolic derivation techniques in Swift
- [ ] Implement sumbolic derivation
- [ ] Refactor and check for the ability to add more functional patterns

