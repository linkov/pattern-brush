//
//  Vertex.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/14/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import simd

/** Data structure that goes directly to the shader functions. Do not change the order of the variables without
 also changing the order int he Shader.metal file. */
struct Vertex: Codable {
    
    // MARK: Variables (IMPORTANT: DO NOT change the order of these variables)
    
    var position: SIMD2<Float>
    
    var point_size: Float
    
    var color: SIMD4<Float>
    
    var rotation: Float
    
    
    
    // MARK: Initialization
    
    init(position: CGPoint, size: CGFloat = 10.0, color: UIColor, rotation: CGFloat) {
        let x = Float(position.x)
        let y = Float(position.y)
        let rgba = color.rgba
        let toFloat = [rgba.red, rgba.green, rgba.blue, rgba.alpha].map { a -> Float in
            return Float(a)
        }
        
        self.position = SIMD2<Float>(x: x, y: y)
        self.point_size = Float(size)
        self.color = SIMD4<Float>(x: toFloat[0], y: toFloat[1], z: toFloat[2], w: toFloat[3])
        self.rotation = Float(rotation)
    }
    
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        var container = try? decoder.unkeyedContainer()
        
        let data = try container?.decodeIfPresent(Data.self) ?? Data()
        let decString = (String(data: data, encoding: .utf8) ?? "0,0,0,1*10*0,0,0,1*0").split(separator: "*")
        let posString = decString[0]
        let sizeString = decString[1]
        let colString = decString[2]
        let rotString = decString[3]
        
        let posArr = posString.split(separator: ",")
        let colArr = colString.split(separator: ",")
        
        self.position = SIMD2<Float>(x: Float(posArr[0]) ?? 0.0, y: Float(posArr[1]) ?? 0.0)
        self.point_size = (sizeString as NSString).floatValue
        self.color = SIMD4<Float>(x: Float(colArr[0]) ?? 0.0, y: Float(colArr[1]) ?? 0.0, z: Float(colArr[2]) ?? 0.0, w: Float(colArr[3]) ?? 0.0)
        self.rotation = (rotString as NSString).floatValue
    }
    
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        let posString = "\(position.x),\(position.y)"
        let sizeString = "\(point_size)"
        let colString = "\(color.x),\(color.y),\(color.z),\(color.w)"
        let rotString = "\(rotation)"
        
        let encodeString = "\(posString)*\(sizeString)*\(colString)*\(rotString)"
        let data = encodeString.data(using: .utf8)
        try container.encode(data)
    }
    
    
    
    
}
