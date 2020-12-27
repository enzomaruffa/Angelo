//
//  ViewController.swift
//  Angelo
//
//  Created by Enzo Maruffa on 12/27/2020.
//  Copyright (c) 2020 Enzo Maruffa. All rights reserved.
//

import UIKit
import Angelo

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        // Creating our system
        let system = LSystem()
        system.add(rule: LSystemRule(input: "a", outputs: ["a", "b"]))
        system.add(rule: LSystemRule(input: "b", output: "a"))

        system.add(transition: LSystemParametersTransition(input: "a", output: "a", transition: { (_) -> ([String : Any]) in
            return ["origin": "a"]
        }))
        
        system.add(transition: LSystemParametersTransition(input: "b", output: "a", transition: { (_) -> ([String : Any]) in
            return ["origin": "b"]
        }))
        
        let output = system.produceOutput(input: "a", iterations: 5)
        
        print(output.string) // A string of the elements's string representation
        print(output.stringWithParameters)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

