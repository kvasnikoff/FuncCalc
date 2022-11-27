//
//  main.swift
//  FuncCalc
//
//  Created by Peter Kvasnikov on 27.11.2022.
//

import Foundation

var funcDict: Dictionary<String, String> = [:]

print(">", terminator: "")

while var line: String = readLine() {
    
    //    get rid of all spaces
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
    let expressionPattern: Regex = /^([a-zA-Z]+[0-9a-zA-Z_]*[(][a-z][)])[=]([0-9a-zA-Z\+\-\*\/\^\.\(\)]+)$/
    
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
        var expressionOfFunc: String = String(group.2)
        
        for (key, value) in funcDict {
            expressionOfFunc = expressionOfFunc.replacingOccurrences(of: key, with: value)
        }
        
        funcDict[nameOfFunc] = expressionOfFunc
        print(funcDict)
    } else if let group = try calculationPattern.wholeMatch(in: line) {
        let nameOfFunc: String = String(group.1)
        let value: String = String(group.2)
        print(nameOfFunc, value)
    } else {
        print("Please enter a valid string")
    }
    
    print(">", terminator: "")
}
