//
//  Line.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/16/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit


/** A tool that draws a straight line from the initial touch point to the end touch point. */
public struct Line: Tool {
    
    // MARK: Variables
    
    public var name: String
    
    
    
    // MARK: Initialization
    
    public init() {
        self.name = "line"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: ToolCodingKeys.self)
        name = try container?.decodeIfPresent(String.self, forKey: .name) ?? "line"
    }
    
    
    // MARK: Functions
    
    public func beginTouch(canvas: Canvas, _ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard canvas.isOnValidLayer() else { return false }
        let point = firstTouch.metalLocation(in: canvas)

        // When drawing a line, you only need one quad to work with.
//        let quad = Quad(start: point)
        canvas.currentPath.startPath(point: point, canvas: canvas, isFreeHand: false)
        return true
    }
    
    public func moveTouch(canvas: Canvas, _ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard canvas.currentPath != nil else { return false }
        guard canvas.isOnValidLayer() else { return false }
        
        let point = firstTouch.metalLocation(in: canvas)
        canvas.currentPath.end(at: point, canvas: canvas, as: .line)
        return true
    }
    
    public func endTouch(canvas: Canvas, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard canvas.isOnValidLayer() else { return false }
        
        if let first = touches.first {
            let p = first.metalLocation(in: canvas)
            canvas.currentPath!.end(at: p, canvas: canvas, as: .line)
        }
        
        // Clear the current drawing curve.
        canvas.rebuildBuffer()
        canvas.currentPath?.closePath()
        return true
    }
    
    public func cancelTouch(canvas: Canvas, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard canvas.isOnValidLayer() else { return false }
        
        if let first = touches.first {
            let p = first.metalLocation(in: canvas)
            canvas.currentPath!.end(at: p, canvas: canvas, as: .line)
        }
        
        // Clear the current drawing curve.
        canvas.rebuildBuffer()
        canvas.currentPath?.closePath()
        return true
    }
    
    // MARK: Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ToolCodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
    
}
