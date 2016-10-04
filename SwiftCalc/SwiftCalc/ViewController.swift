//
//  ViewController.swift
//  SwiftCalc
//
//  Created by Zach Zeleznick on 9/20/16.
//  Copyright © 2016 zzeleznick. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: Width and Height of Screen for Layout
    var w: CGFloat!
    var h: CGFloat!
    

    // IMPORTANT: Do NOT modify the name or class of resultLabel.
    //            We will be using the result label to run autograded tests.
    // MARK: The label to display our calculations
    var resultLabel = UILabel()
    
    // TODO: This looks like a good place to add some data structures.
    //       One data structure is initialized below for reference.
    var currArg = ""
    var prevTotalVal = ""
    var decimal = false
    var prevOp : operators = operators.empty
    
    enum operators : String{
        case clear = "C"
        case sign = "+/-"
        case percent = "%"
        
        case divide = "/"
        case multiply = "*"
        case subtract = "-"
        case add = "+"
        case equal = "="
        
        case zero = "0"
        case dot = "."
        
        case empty
    }
    
    let margin = 1e-10

    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        w = view.bounds.size.width
        h = view.bounds.size.height
        navigationItem.title = "Calculator"
        // IMPORTANT: Do NOT modify the accessibilityValue of resultLabel.
        //            We will be using the result label to run autograded tests.
        resultLabel.accessibilityValue = "resultLabel"
        makeButtons()
        // Do any additional setup here.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCurrArg(_ content: String) {
        guard currArg.characters.count < 7 else { return }
        if (content == operators.zero.rawValue) {
            guard currArg != operators.zero.rawValue else { return }
        }
        if (content == operators.dot.rawValue) {
            guard !decimal else { return }
            if (currArg == "") {
                currArg += "0"
            }
            decimal = true
        }
        currArg += content
        
    }
    
    func clearArgs() {
        currArg = ""
        prevTotalVal = ""
        prevOp = operators.empty
        decimal = false
        resultLabel.text = "0"
    }
    
    func flipSign() {
        guard Double(currArg) != nil else {
            guard Double(prevTotalVal) != nil else { return }
            if (prevTotalVal.characters.count >= 7) {
                return
            }
            prevTotalVal = flipSignHelper(input: prevTotalVal)
            updateResultLabel(prevTotalVal)
            return
        }
        if (currArg.characters.count >= 7) {
            return
        }
        currArg = flipSignHelper(input: currArg)
        updateResultLabel(currArg)
    }
    
    func flipSignHelper(input: String) -> String {
        let tempConv = Double(input)
        var ret : String = ""
        if (floor(tempConv!) == tempConv) || (round(tempConv!) == tempConv) {
            ret = String(0 - Int(input)!)
        } else {
            ret = String(0 - Double(input)!)
        }
        return ret
    }
    
    func applyOperation(operation: operators) {
        guard Double(currArg) != nil else {
            updateResultLabel(prevTotalVal)
            prevOp = operation
            return
        }
        guard Double(prevTotalVal) != nil else {
            prevTotalVal = currArg
            currArg = ""
            decimal = false
            updateResultLabel(prevTotalVal)
            prevOp = operation
            return
        }
        let tempTot = Double(prevTotalVal)
        let tempCur = Double(currArg)
        let newTot = calculate(a: tempTot!, b: tempCur!, operation: prevOp)
        let flooredTot = floor(newTot)
        let ceilTot = round(newTot)
        if (newTot >= flooredTot - margin && newTot <= flooredTot + margin) {
        //if (newTot == flooredTot) {
            prevTotalVal = (abs(flooredTot) > 1e7 || abs(flooredTot) < 1e-4)
                ? flooredTot.scientificStyle : String(Int(flooredTot))
            decimal = false
        //} else if (newTot == ceilTot) {
        } else if(newTot >= ceilTot - margin && newTot <= ceilTot + margin) {
            prevTotalVal = (abs(ceilTot) > 1e7 || abs(ceilTot) < 1e-4)
                ? ceilTot.scientificStyle : String(Int(ceilTot))
            decimal = false
        } else {
            prevTotalVal = (abs(newTot) > 1e7 || abs(newTot) < 1e-4)
                ? newTot.scientificStyle : String(newTot)
            decimal = true
        }
        prevOp = operation
        if (prevOp == operators.equal) {
            currArg = prevTotalVal
            prevTotalVal = ""
            updateResultLabel(currArg)
        } else {
            currArg = ""
            decimal = false
            updateResultLabel(prevTotalVal)
        }
        
    }
    
    // TODO: Ensure that resultLabel gets updated.
    //       Modify this one or create your own.
    func updateResultLabel(_ content: String) {
        if (content.characters.count > 7) {
            resultLabel.text = content.substring(to: content.index(content.startIndex, offsetBy: 7))
        } else {
            resultLabel.text = content
        }
    }
    
    // TODO: A calculate method with no parameters, scary!
    //       Modify this one or create your own.
    func calculate(a: Double, b:Double, operation: operators) -> Double {
        var result : Double = 0.0
        switch operation{
            
        case operators.divide:
            result = a / b
        case operators.multiply:
            result = a * b
        case operators.subtract:
            result = a - b
        case operators.add:
            result = a + b

        default: ()
        }
        return result
    }
    
    // REQUIRED: The responder to a number button being pressed.
    func numberPressed(_ sender: CustomButton) {
        guard Int(sender.content) != nil else { return }
        updateCurrArg(sender.content)
        updateResultLabel(currArg)
    }
    
    // REQUIRED: The responder to an operator button being pressed.
    func operatorPressed(_ sender: CustomButton) {
        guard Int(sender.content) == nil else { return }
        let arg = sender.content
        switch arg{
        case operators.clear.rawValue:
            clearArgs()
        case operators.sign.rawValue:
            flipSign()
        case operators.percent.rawValue:
            ()
            
        case operators.divide.rawValue:
            applyOperation(operation: operators.divide)
        case operators.multiply.rawValue:
            applyOperation(operation: operators.multiply)
        case operators.subtract.rawValue:
            applyOperation(operation: operators.subtract)
        case operators.add.rawValue:
            applyOperation(operation: operators.add)
        case operators.equal.rawValue:
            applyOperation(operation: operators.equal)
        default: ()
        }
    }
    
    // REQUIRED: The responder to a number or operator button being pressed.
    func buttonPressed(_ sender: CustomButton) {
        guard (sender.content == operators.zero.rawValue || sender.content == operators.dot.rawValue) else { return }
        let arg = sender.content
        switch arg{
        case operators.zero.rawValue:
            updateCurrArg(arg)
            updateResultLabel(currArg)
        case operators.dot.rawValue:
            updateCurrArg(arg)
            updateResultLabel(currArg)
        default: ()
        }
    }
    
    // IMPORTANT: Do NOT change any of the code below.
    //            We will be using these buttons to run autograded tests.
    
    func makeButtons() {
        // MARK: Adds buttons
        let digits = (1..<10).map({
            return String($0)
        })
        let operators = ["/", "*", "-", "+", "="]
        let others = ["C", "+/-", "%"]
        let special = ["0", "."]
        
        let displayContainer = UIView()
        view.addUIElement(displayContainer, frame: CGRect(x: 0, y: 0, width: w, height: 160)) { element in
            guard let container = element as? UIView else { return }
            container.backgroundColor = UIColor.black
        }
        displayContainer.addUIElement(resultLabel, text: "0", frame: CGRect(x: 70, y: 70, width: w-70, height: 90)) {
            element in
            guard let label = element as? UILabel else { return }
            label.textColor = UIColor.white
            label.font = UIFont(name: label.font.fontName, size: 60)
            label.textAlignment = NSTextAlignment.right
        }
        
        let calcContainer = UIView()
        view.addUIElement(calcContainer, frame: CGRect(x: 0, y: 160, width: w, height: h-160)) { element in
            guard let container = element as? UIView else { return }
            container.backgroundColor = UIColor.black
        }

        let margin: CGFloat = 1.0
        let buttonWidth: CGFloat = w / 4.0
        let buttonHeight: CGFloat = 100.0
        
        // MARK: Top Row
        for (i, el) in others.enumerated() {
            let x = (CGFloat(i%3) + 1.0) * margin + (CGFloat(i%3) * buttonWidth)
            let y = (CGFloat(i/3) + 1.0) * margin + (CGFloat(i/3) * buttonHeight)
            calcContainer.addUIElement(CustomButton(content: el), text: el,
            frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)) { element in
                guard let button = element as? UIButton else { return }
                button.addTarget(self, action: #selector(operatorPressed), for: .touchUpInside)
            }
        }
        // MARK: Second Row 3x3
        for (i, digit) in digits.enumerated() {
            let x = (CGFloat(i%3) + 1.0) * margin + (CGFloat(i%3) * buttonWidth)
            let y = (CGFloat(i/3) + 1.0) * margin + (CGFloat(i/3) * buttonHeight)
            calcContainer.addUIElement(CustomButton(content: digit), text: digit,
            frame: CGRect(x: x, y: y+101.0, width: buttonWidth, height: buttonHeight)) { element in
                guard let button = element as? UIButton else { return }
                button.addTarget(self, action: #selector(numberPressed), for: .touchUpInside)
            }
        }
        // MARK: Vertical Column of Operators
        for (i, el) in operators.enumerated() {
            let x = (CGFloat(3) + 1.0) * margin + (CGFloat(3) * buttonWidth)
            let y = (CGFloat(i) + 1.0) * margin + (CGFloat(i) * buttonHeight)
            calcContainer.addUIElement(CustomButton(content: el), text: el,
            frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)) { element in
                guard let button = element as? UIButton else { return }
                button.backgroundColor = UIColor.orange
                button.setTitleColor(UIColor.white, for: .normal)
                button.addTarget(self, action: #selector(operatorPressed), for: .touchUpInside)
            }
        }
        // MARK: Last Row for big 0 and .
        for (i, el) in special.enumerated() {
            let myWidth = buttonWidth * (CGFloat((i+1)%2) + 1.0) + margin * (CGFloat((i+1)%2))
            let x = (CGFloat(2*i) + 1.0) * margin + buttonWidth * (CGFloat(i*2))
            calcContainer.addUIElement(CustomButton(content: el), text: el,
            frame: CGRect(x: x, y: 405, width: myWidth, height: buttonHeight)) { element in
                guard let button = element as? UIButton else { return }
                button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            }
        }
    }

}

