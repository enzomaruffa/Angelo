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
    
    @IBOutlet weak var templateImageView: UIImageView!
    
    @IBOutlet weak var result1: UIImageView!
    @IBOutlet weak var result2: UIImageView!
    @IBOutlet weak var result3: UIImageView!
    @IBOutlet weak var result4: UIImageView!
    @IBOutlet weak var result5: UIImageView!
    @IBOutlet weak var result6: UIImageView!
    
    var resultImageViews: [UIImageView] {
        [result1, result2, result3, result4, result5, result6]
    }
    
    let imageName = "process-example"
    let tileSize = (3, 3)
    
    var inputs: (rules: WFCTilesAdjacencyRules, frequency: WFCTilesFrequencyRules, tilesColorMap: [Int: CGColor])!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for imageView in resultImageViews {
            imageView.layer.magnificationFilter = kCAFilterNearest
        }
        templateImageView.layer.magnificationFilter = kCAFilterNearest
        
        let uiImage = UIImage(named: "process-example")
        templateImageView.image = uiImage
        
        // Do any additional setup after loading the view, typically from a nib.
        if let image = UIImage(named: "process-example")?.cgImage {
            let processor = WFCTilesPreProcessor()
            inputs = try! processor.preprocess(image: image, tileSize: tileSize)
        }
    }
    
    @IBAction func generateTapped(_ sender: Any) {
        
        let image = templateImageView.image
        
        let xScale = (image?.size.width)! / templateImageView.frame.width
        let yScale = (image?.size.height)! / templateImageView.frame.height
        
        for imageView in resultImageViews {
            let imageViewXSize = imageView.frame.width * xScale
            let imageViewYSize = imageView.frame.height * yScale
            
            
            guard let image = createImage(withSize: (Int(imageViewXSize), Int(imageViewYSize))) else {
                continue
            }
            
            imageView.image = UIImage(cgImage: image)
        }
        
    }
    
    func createImage(withSize size: (Int, Int)) -> CGImage? {
        
        let solver = WFCTilesSolver()
        
        let maxRuns = 3
        var currentRuns = 0
        
        var matrix: [[Int]]?
        
        while currentRuns < maxRuns {
            do {
                currentRuns += 1
                matrix = try solver.solve(rules: inputs.rules, frequency: inputs.frequency, outputSize: size)
                break
            } catch {
                print(error)
            }
        }
        
        guard let imageMatrix = matrix else { return nil }
        
        let postprocessor = WFCTilesPostProcessor()
        let image = postprocessor.postprocess(tileIndexMatrix: imageMatrix, colorMap: inputs.tilesColorMap)
        
        return image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

