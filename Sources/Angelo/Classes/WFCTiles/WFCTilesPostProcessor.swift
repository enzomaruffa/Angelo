//
//  WFCTilesPostProcessor.swift
//  Angelo
//
//  Created by Enzo Maruffa Moreira on 30/12/20.
//

import Foundation

public class WFCTilesPostProcessor {
    public init() { }
    
    public func postprocess(tileIndexMatrix: [[Int]], colorMap: [Int: CGColor]) -> CGImage {
        
        let imageHeight = tileIndexMatrix.count
        let imageWidth = tileIndexMatrix[0].count
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            .union(CGBitmapInfo.byteOrder32Little)
        
        let context = CGContext(data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        let bitmapData = context!.data!.bindMemory(to: UInt32.self, capacity: imageWidth * imageHeight)
        
        for i in 0..<imageHeight {
            for j in 0..<imageWidth {
                let tileID = tileIndexMatrix[i][j]
                let color = colorMap[tileID]
                
                print("Setting \(color) to (\(i), \(j)")
                
                var colorAsUInt : UInt32 = 0

                colorAsUInt += UInt32(color!.components![0] * 8) << 3
                colorAsUInt += UInt32(color!.components![1] * 8) << 2
                colorAsUInt += UInt32(color!.components![2] * 8) << 1
                colorAsUInt += UInt32(color!.alpha * 8)
                
                print(" Color as UInt32: \(colorAsUInt)")

                bitmapData[imageHeight * i + j] = colorAsUInt
            }
        }
        
        return context!.makeImage()!
    }
}
