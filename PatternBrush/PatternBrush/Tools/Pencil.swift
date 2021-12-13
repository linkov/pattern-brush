//
//  Pencil.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/16/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit

/** A basic pencil tool, which allows for freehand drawing on the canvas. */
public struct Pencil: Tool {
    
    // MARK: Variables
    
    public var name: String
    
    
    
    // MARK: Initialization
    
    public init() {
        self.name = "pencil"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: ToolCodingKeys.self)
        name = try container?.decodeIfPresent(String.self, forKey: .name) ?? "pencil"
    }
    
    
    
    // MARK: Functions
    
    public func beginTouch(canvas: Canvas, _ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard canvas.isOnValidLayer() else { return false }
        let point = firstTouch.metalLocation(in: canvas)
        
        // Get the force from the user input.
        canvas.setForce(value: firstTouch.force)
        
        // Start a new quad when a touch is down.
        canvas.currentPath.startPath(point: point, canvas: canvas)
        return true
    }
    
    public func moveTouch(canvas: Canvas, _ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard canvas.currentPath != nil else { return false }
        guard canvas.isOnValidLayer() else { return false }
        
        // All important touches for apple pencil.
        guard let coalesced = event?.coalescedTouches(for: firstTouch) else { return false }
        guard let pred = event?.predictedTouches(for: firstTouch) else { return false }
        
        // Get the force from the user input.
        canvas.setForce(value: firstTouch.force)
        
        // NOTE: Run the following code for all of the touches.
        var total = [UITouch]()
        total.append(contentsOf: touches)
        total.append(contentsOf: coalesced)
        total.append(contentsOf: pred)
        total.sort { (t1, t2) -> Bool in
            let p1 = t1.metalLocation(in: canvas)
            let p2 = t2.metalLocation(in: canvas)
            return p1 < p2
        }
        
        for touch in total {
            let point = touch.metalLocation(in: canvas)
            canvas.currentPath!.endPencil(at: point, canvas: canvas)
        }
        return true
    }
    
    public func endTouch(canvas: Canvas, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard canvas.isOnValidLayer() else { return false }
        
        if let first = touches.first {
            let p = first.metalLocation(in: canvas)
            canvas.currentPath!.endPencil(at: p, canvas: canvas)
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
            canvas.currentPath!.endPencil(at: p, canvas: canvas)
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
