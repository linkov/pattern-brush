//
//  UITouch+Metal.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/12/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit
import Metal
import MetalKit

public extension UITouch {
    
    /** Returns the location of this touch in a view that is based on the Metal coordinate system. */
    func metalLocation(in view: Canvas) -> CGPoint {
        let loc = self.preciseLocation(in: view)
        
        let viewportWidthHalf = view.bounds.width / 2
        let viewportHeightHalf = view.bounds.height / 2
        
        let norm: CGPoint = CGPoint(
            x: CGFloat(loc.x / viewportWidthHalf) - 1,
            y: 1 - CGFloat(loc.y / viewportHeightHalf)
        )
        return norm
    }
    
    
    
}
