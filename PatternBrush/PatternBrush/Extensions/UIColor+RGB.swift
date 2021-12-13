//
//  UIColor+RGB.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/12/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit
import Metal

public extension UIColor {
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var metalClearColor: MTLClearColor {
        let rgba = self.rgba
        return MTLClearColor(red: Double(rgba.red), green: Double(rgba.green), blue: Double(rgba.blue), alpha: Double(rgba.alpha))
    }
    
    static func fromSIMD4(simd: SIMD4<Float>) -> UIColor {
        return UIColor(red: CGFloat(simd.x), green: CGFloat(simd.y), blue: CGFloat(simd.z), alpha: CGFloat(simd.w))
    }
    
    func toSIMD4() -> SIMD4<Float> {
        let rgba = self.rgba
        return SIMD4<Float>(x: Float(rgba.red), y: Float(rgba.green), z: Float(rgba.blue), w: Float(rgba.alpha))
    }
    
}

public extension MTLClearColor {
    
    var uiColor: UIColor {
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
}
