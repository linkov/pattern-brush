//
//  Canvas+Touch.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/12/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public extension Canvas {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Check for stylus only touches.
        if self.stylusOnly == true {
            if touch.type != .pencil && touch.type != .stylus {
                return
            }
        }
        
        // Let the current tool handle manipulating point and quad/vertex data.
        if self.currentTool.beginTouch(canvas: self, touch, touches, with: event) {
            self.canvasDelegate?.isDrawing(element: currentPath, on: self)
            setNeedsDisplay()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Check for stylus only touches.
        if self.stylusOnly == true {
            if touch.type != .pencil && touch.type != .stylus {
                return
            }
        }
        
        // Allow the current tool to handle movement across the screen.
        if self.currentTool.moveTouch(canvas: self, touch, touches, with: event) {
            self.canvasDelegate?.isDrawing(element: currentPath, on: self)
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Check for stylus only touches.
        if self.stylusOnly == true {
            if touch.type != .pencil && touch.type != .stylus {
                return
            }
        }
        
        if self.currentTool.endTouch(canvas: self, touches, with: event) {
            self.canvasDelegate?.stoppedDrawing(element: currentPath, on: self)
            setNeedsDisplay()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Check for stylus only touches.
        if self.stylusOnly == true {
            if touch.type != .pencil && touch.type != .stylus {
                return
            }
        }
        
        if self.currentTool.cancelTouch(canvas: self, touches, with: event) {
            self.canvasDelegate?.stoppedDrawing(element: currentPath, on: self)
            setNeedsDisplay()
        }
    }
}
