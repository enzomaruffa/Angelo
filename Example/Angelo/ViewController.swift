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
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false //You need to call this property so the image is added to your view
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView) //This add it the view controller without constraints
        makeConstraints()
        
        // Do any additional setup after loading the view, typically from a nib.
        if let image = UIImage(named: "process-example")?.cgImage {
            let processor = WFCTilesPreProcessor()
            let (adjacency, frequency, colorMap) = try! processor.preprocess(image: image, tileSize: (3, 3))
            
            let solver = WFCTilesSolver()
            
            var runs = 1
            var currentRuns = 0
            
            var matrix: [[Int]]?
            
            while currentRuns < runs {
                do {
                    print("Doing run \(currentRuns)...")
                    currentRuns += 1
                    matrix = try solver.solve(rules: adjacency, frequency: frequency, outputSize: (120, 120))
                    print(" Finished!")
                    break
                } catch {
                    print(" Error \(error)")
                }
            }
            
            guard let imageMatrix = matrix else { return }
            
            let postprocessor = WFCTilesPostProcessor()
            let image = postprocessor.postprocess(tileIndexMatrix: imageMatrix, colorMap: colorMap)
            imageView.image = UIImage(cgImage: image)
        }
    }
    
    func makeConstraints() {
        imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

