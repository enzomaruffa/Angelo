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
    
    var i = 0
    let images = ["test", "test3", "process-example", "process-example-rep"]
    let tileSize = (3, 3)
    
    var inputs: (rules: WFCTilesAdjacencyRules, frequency: WFCTilesFrequencyRules, tilesColorMap: [Int: CGColor])!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for imageView in resultImageViews {
            imageView.layer.magnificationFilter = kCAFilterNearest
        }
        templateImageView.layer.magnificationFilter = kCAFilterNearest
        
        let name = images[i]
        setImage(named: name)
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
    
    @IBAction func nextImage(_ sender: Any) {
        i += 1
        if i >= images.count {
            i = 0
        }
        
        setImage(named: images[i])
    }
    
    func setImage(named: String) {
        let uiImage = UIImage(named: named)
        templateImageView.image = uiImage
        
        // Do any additional setup after loading the view, typically from a nib.
        if let image = UIImage(named: named)?.cgImage {
            let processor = WFCTilesPreProcessor()
            inputs = try! processor.preprocess(image: image, tileSize: tileSize)
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

