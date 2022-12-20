//
//  main.swift
//  FuncCalc
//
//  Created by Peter Kvasnikov on 27.11.2022.
//

import Foundation

struct Stack<T> {
    private var elements: [T] = []
    
    func isEmpty() -> Bool {
        return elements.isEmpty
    }
    
    mutating func push(newElement: T) {
        return elements.append(newElement)
    }
    
    mutating func pop() {
        elements.removeLast()
    }
    
    func getLast() -> T? {
        return self.isEmpty() ? nil : elements.last
    }
}

enum OperatorType{
    case add
    case subtract
    case divide
    case multiply
    case exponent
    case openBracket // originally, there were no brackets, because they're not operators, but then I realized, that it'll be on stack and it'll be cool to use a stack of type "Operator" :)
}

enum OperatorPrecedence: Int {
    case high = 3
    case meduim = 2
    case low = 1
    case zero = 0
}

enum OperatorAssociativity {
    case left
    case right
    case none
}

struct Operator {
    private let type: OperatorType
    private let precedence: OperatorPrecedence
    private let associativity: OperatorAssociativity
    private let originalToken: String
    
    init(token: String) {
        switch token { // break isn't necessary in Swift switch-case
        case "*":
            self.originalToken = "*"
            self.type = .multiply
            self.precedence = .meduim
            self.associativity = .left
        case "/":
            self.originalToken = "/"
            self.type = .divide
            self.precedence = .meduim
            self.associativity = .left
        case "+":
            self.originalToken = "+"
            self.type = .add
            self.precedence = .low
            self.associativity = .left
        case "-":
            self.originalToken = "-"
            self.type = .subtract
            self.precedence = .low
            self.associativity = .left
        case "^":
            self.originalToken = "^"
            self.type = .exponent
            self.precedence = .high
            self.associativity = .right
        case "(":
            self.originalToken = "^"
            self.type = .openBracket
            self.precedence = .zero
            self.associativity = .none
        default:
            print("Unknown operator")
            exit(1)
        }
    }
    
    func getType() -> OperatorType {
        return self.type
    }
    
    func getPrecedence() -> OperatorPrecedence {
        return self.precedence
    }
    
    func getAssociativity() -> OperatorAssociativity {
        return self.associativity
    }
    
    func getOriginalToken() -> String {
        return self.originalToken
    }
}

struct ExpressionInfo {
    var symbol: String
    var expression: String
}
// Example of Dict
// f(x) = 5.5*x+4^2
// key = f
// value = ExpressionInfo("x", ExpressionInfo)
// So f(x) will overwrite f(y) inside dictionary and that's good, because when we calculate the function value, we don't use any symbol, only function name: `f(10)`
// but when we define functions via previosly defined functions, e.g. `f1(x) = f(x) + 4`, f(x) and f(y), we'll check for symbol and everything we'll be fine
var funcDict: Dictionary<String, ExpressionInfo> = [:]

print(">", terminator: "")

while var line: String = readLine() {
    
    // get rid of all spaces
    //    line = line.replacingOccurrences(of: " ", with: "") // non functional way
    line = line.filter {$0 != " "} // functional way
    
    // Name: expressionPattern
    // Example: f1(x) = 2*x^2 +0.5*x - 6/(3 + 9)
    // Description:
    // ^ - begining of expression
    // [a-zA-Z]+ - any character (function name can't start with digit)
    // [0-9a-zA-Z_]* - sequens of characers and digits (0 or more) – continuation of name
    // [(][a-z][)] - name of function's argument inside parentheses ()
    // [=] - equials sigh
    // [0-9a-zA-Z\+\-\*\/\^\.\(\)]+ - any characters, digits (with point), and arithmetic operations (+, -, *, /, ^) – one or more
    // $ – ending of expression
    let expressionPattern: Regex = /^([a-zA-Z]+[0-9a-zA-Z_]*)[(]([a-z])[)][=]([0-9a-zA-Z\+\-\*\/\^\.\(\)]+)$/
    
    // Name: calculationPattern
    // Example: f1(10)
    // Description:
    // ^ - begining of expression
    // [a-zA-Z]+ - any character (function name can't start with digit)
    // [0-9a-zA-Z_]* - sequens of characers and digits (0 or more) – continuation of name
    // [(]([0-9]+[0-9\.]*)[)] - one or more digits (with point) inside parentheses ()
    let  calculationPattern = /^([a-zA-Z]+[0-9a-zA-Z_]*)[(]([0-9]+[0-9\.]*)[)]$/
    
    if let group = try expressionPattern.wholeMatch(in: line) {
        let nameOfFunc: String = String(group.1)
        let symbol: String = String(group.2)
        var expressionOfFunc: String = String(group.3)
        
        if !expressionOfFunc.reduce ([Character](), { stack, symbol in // we're here to show how smart we are :)
            if symbol == "(" {
                return stack + [symbol] // stack.append(symbol) doesn't work, because "stack" is immutable in reduce
            } else if symbol == ")" && stack.last == "(" {
                return stack.dropLast()
            } else if symbol == ")" { // if two previous statements are false -> expression is invalid, so add symbol to the stack and it will be not empty at the end
                return stack + [symbol]
            } else {
                return stack
            }
        }).isEmpty {
            print("Please enter a string with correct parentheses balance!")
        } else {
            for (key, value) in funcDict {
                expressionOfFunc = expressionOfFunc.replacingOccurrences(of: key + "(" + value.symbol + ")", with: value.expression)
            }
            
            funcDict[nameOfFunc] = ExpressionInfo(symbol: symbol, expression: expressionOfFunc)
            print("\(nameOfFunc)(\(symbol))=\(expressionOfFunc)")
        }
        
    } else if let group = try calculationPattern.wholeMatch(in: line) {
        let nameOfFunc: String = String(group.1)
        let value: String = String(group.2)
        //print(nameOfFunc, value)
        
        
        guard let expressionOfFunc = funcDict[nameOfFunc]?.expression else {
            print("Please enter a valid function name!")
            continue
        }
        
        let symbolsArray = expressionOfFunc.map { String($0) == funcDict[nameOfFunc]?.symbol ?  String(value) : String($0) } // convert to Array of Strings and replace symbol with value
        
        var postfixQueue: [String] = []
        var stack: Stack<Operator> = Stack()
        
        // var currentToken: Token = .OTHER
        
        var currentToken: String = ""
        
        var currentIndex: Int = 0
        
        while currentIndex < symbolsArray.count {
            currentToken += symbolsArray[currentIndex]
            while currentIndex < symbolsArray.count - 1 && (Double(symbolsArray[currentIndex]) != nil || symbolsArray[currentIndex] == ".") && (Double(symbolsArray[currentIndex + 1]) != nil || symbolsArray[currentIndex + 1] == "."){ // swift checks conditions in order, so it never goes to `index + 1` if `currentIndex < symbolsArray.count - 1`
                
                currentIndex += 1
                currentToken += symbolsArray[currentIndex]
            }
            
            print(currentToken)
            
            // shunting yard algorithm to convert from infix to postfix
            //            1. For all the input tokens:
            //                1. Read the next token
            //                2. If token is an operator (x)
            //                    1. While there is an operator (y) at the top of the operators stack and either (x) is left-associative and its precedence is less or equal to that of (y), or (x) is right-associative and its precedence is less than (y)
            //                        1. Pop (y) from the stack
            //                        2. Add (y) output buffer
            //                    2. Push (x) on the stack
            //                3. Else if token is left parenthesis, then push it on the stack
            //                4. Else if token is a right parenthesis
            //                    1. Until the top token (from the stack) is left parenthesis, pop from the stack to the output buffer
            //                    2. Also pop the left parenthesis but don’t include it in the output buffer
            //                5. Else add token to output buffer
            //            2. Pop any remaining operator tokens from the stack to the output
            
            let operatorsArray: [String] = ["*", "/", "+", "-", "^"] // to not write multiple ||
            if operatorsArray.contains(currentToken) {
                let op: Operator = Operator(token: currentToken)
                while (!stack.isEmpty() && stack.getLast()!.getPrecedence().rawValue >= op.getPrecedence().rawValue && op.getAssociativity() == OperatorAssociativity.left) || (!stack.isEmpty() && stack.getLast()!.getPrecedence().rawValue > op.getPrecedence().rawValue && op.getAssociativity() == OperatorAssociativity.right) {
                    
                    postfixQueue.append(stack.getLast()!.getOriginalToken())
                    stack.pop()
                }
                stack.push(newElement: op)
            } else if currentToken == "(" {
                stack.push(newElement: Operator(token: currentToken))
            } else if currentToken == ")" {
                while(stack.getLast()?.getType() != OperatorType.openBracket) {
                    postfixQueue.append(stack.getLast()!.getOriginalToken())
                    stack.pop()
                }
                stack.pop() // popping "(" from stack
            } else {
                postfixQueue.append(currentToken)
            }

            currentToken = ""
            currentIndex += 1
        }
        while !stack.isEmpty() {
            postfixQueue.append(stack.getLast()!.getOriginalToken())
            stack.pop()
        }
        print(postfixQueue)
    } else {
        print("Please enter a valid string!")
    }
    
    print(">", terminator: "")
}
