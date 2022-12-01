//
//  main.swift
//  FuncCalc
//
//  Created by Peter Kvasnikov on 27.11.2022.
//

import Foundation

//enum Token {
//    case add
//    case subtract
//    case multiply
//    case divide
//    case power
//    case number
//    case rightParenthesis
//    case leftParenthesis
//    case OTHER
//}

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
    // Example: f1(x) = 2*x^2 +0.5x - 6/(3 + 9)
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
            
            currentToken = ""
            currentIndex += 1
        }
    } else {
        print("Please enter a valid string!")
    }
    
    print(">", terminator: "")
}
