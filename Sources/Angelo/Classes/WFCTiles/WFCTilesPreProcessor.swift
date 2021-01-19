//
//  WFCTilesPreProcessor.swift
//  Angelo
//
//  Created by Enzo Maruffa Moreira on 30/12/20.
//

import CoreGraphics

public class WFCTilesPreProcessor {
    public init() { }
    
    public func preprocess(image: CGImage, tileSize: (Int, Int)) throws -> (rules: WFCTilesAdjacencyRules, frequency: WFCTilesFrequencyRules, tilesColorMap: [Int: CGColor]) {
        
        guard let dataProvider = image.dataProvider else {
            throw WFCErrors.InvalidDataProviderForImage
        }
        
        let width = image.width
        let height = image.height
        
        // Transform the matrix into colors
        var colors = [CGColor]()
        
        let elementCount = image.width * image.height * 4
        
        let pixelData = dataProvider.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        for i in 0..<elementCount/4 {
            let dataOffset = i * 4
            let red = (data + dataOffset).pointee
            let green = (data + dataOffset + 1).pointee
            let blue = (data + dataOffset + 2).pointee
            let alpha = (data + dataOffset + 3).pointee
            
            let color = CGColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha)/255)
            
            colors.append(color)
        }
        
        // Create tiles, adjacency rules
        var tiles = [[CGColor]]()
        
        // Frequency stuff
        let frequencyRules = WFCTilesFrequencyRules()
        var uniqueTiles: [[CGColor]: Int] = [:]
        var nextID = 0
        
        for i in 0..<height {
            for j in 0..<width {
                
                var tile = [CGColor]()
                
                for iOffset in 0..<tileSize.0 {
                    for jOffset in 0..<tileSize.1 {
                        let finalIndex = ((i + iOffset) % height * width) + ((j + jOffset) % width)
                        tile.append(colors[finalIndex])
                    }
                }
                
                tiles.append(tile)
                
                if let tileID = uniqueTiles[tile] {
                    // Add to the frequency rules
                    frequencyRules.addOccurence(elementID: tileID)
                } else {
                    // Add to the unique dict
                    uniqueTiles[tile] = nextID
                    
                    // Add to the frequency rules
                    frequencyRules.addOccurence(elementID: nextID)
                    
                    // Adds the ID for the next one
                    nextID += 1
                }
            }
        }
        
        // Generates adjacency rules
        let adjacencyRules = WFCTilesAdjacencyRules()
        
        var i = 0
        
        for tile in tiles {
            for relatedTile in tiles {

                for direction in WFCTilesDirection.allCases {
                    
                    i += 1
                    
                    var iOffset = 0
                    var jOffset = 0
                    
                    switch direction {
                    case .up:
                        // Compare tile pixels 4, 5, 6, 7, 8, 9 with relatedTile pixels 1, 2, 3, 4, 5, 6. If equal, add rule
                        iOffset = 1
                    case .left:
                        // Compare tile pixels 1, 2, 4, 5, 7, 8 with relatedTile pixels 2, 3, 5, 6, 8, 9. If equal, add rule
                        jOffset = 1
                    case .right:
                        // Compare tile pixels 2, 3, 5, 6, 8, 9 with relatedTile pixels 1, 2, 4, 5, 7, 8. If equal, add rule
                        jOffset = -1
                    case .down:
                        // Compare tile pixels 1, 2, 3, 4, 5, 6 with relatedTile pixels 4, 5, 6, 7, 8, 9. If equal, add rule
                        iOffset = -1
                    }
                    
                    var willAddRule = true
                    
                    // Compares tiles
                    for i in 0..<tileSize.0 {
                        for j in 0..<tileSize.1 {
                            let finalI = i + iOffset
                            let finalJ = j + jOffset
                            
                            if finalI >= tileSize.0 || finalI < 0
                                || finalJ >= tileSize.1 || finalJ < 0 {
                                continue
                            }
                            
                            let finalTileIndex = i * tileSize.0 + j
                            let finalRelatedTileIndex = finalI * tileSize.0 + finalJ
                            
                            if tile[finalTileIndex] != relatedTile[finalRelatedTileIndex] {
                                willAddRule = false
                                break
                            }
                        }
                    }
                    
                    if willAddRule {
                        adjacencyRules.addRule(aID: uniqueTiles[relatedTile]!, canAppearRelativeToB: uniqueTiles[tile]!, inDirection: direction)
                    }
                }
            }
        }
        
        // Builds the color map for each tile
        var colorMap = [Int: CGColor]()
        
        for tile in tiles {
            let id = uniqueTiles[tile]!
            let color = tile[0]
            
            colorMap[id] = color
        }
        
        return (rules: adjacencyRules, frequency: frequencyRules, tilesColorMap: colorMap)
    }
}
