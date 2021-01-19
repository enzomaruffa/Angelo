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
        
        let height = imageHeight
        let width = imageWidth
        let numComponents = 4
        let numBytes = height * width * numComponents
        
        var pixelData = [UInt8]()
        
        for i in 0..<imageHeight {
            for j in 0..<imageWidth {
                let tileID = tileIndexMatrix[i][j]
                let color = colorMap[tileID]
                
                pixelData.append(UInt8(color!.components![0] * 255))
                pixelData.append(UInt8(color!.components![1] * 255))
                pixelData.append(UInt8(color!.components![2] * 255))
                pixelData.append(UInt8(color!.alpha * 255))
            }
        }
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        
        let rgbData = CFDataCreate(nil, pixelData, numBytes)!
        let provider = CGDataProvider(data: rgbData)!
        
        let image = CGImage(width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bitsPerPixel: 8 * numComponents,
                                  bytesPerRow: width * numComponents,
                                  space: colorspace,
                                  bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                  provider: provider,
                                  decode: nil,
                                  shouldInterpolate: true,
                                  intent: CGColorRenderingIntent.defaultIntent)!
        
        return image
    }
    
    // TODO: Add returns for not only a final image, but a color matrix and only the rgb values
}
