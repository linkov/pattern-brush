//
//  Eraser.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/17/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit


/** A tool for erasing pixels from the canvas. */
public struct Eraser: Tool {
    
    // MARK: Variables
    
    public var name: String
    
    
    
    // MARK: Initialization
    
    public init() {
        self.name = "eraser"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: ToolCodingKeys.self)
        name = try container?.decodeIfPresent(String.self, forKey: .name) ?? "eraser"
    }
    
    
    // MARK: Functions
    
    public func beginTouch(canvas: Canvas, _ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard canvas.isOnValidLayer() else { return false }
        
        // Get the force from the user input.
        canvas.setForce(value: firstTouch.force)
        return true
    }
    
    public func moveTouch(canvas: Canvas, _ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard canvas.currentPath != nil else { return false }
        guard canvas.isOnValidLayer() else { return false }
        if canvas.canvasLayers[canvas.currentLayer].isLocked == true { return false }
        
        // All touches for apple pencil.
        guard let coalesced = event?.coalescedTouches(for: firstTouch) else { return false }
        
        guard let t = coalesced.first else { return false }
        let point = t.metalLocation(in: canvas)
        
        // Get the force from the user input.
        canvas.setForce(value: firstTouch.force)
        
        // Go through the vertices on the layer and have them "erased."
        canvas.canvasLayers[canvas.currentLayer].eraseVertices(canvas: canvas, point: point)
        canvas.rebuildBuffer()
        return true
    }
    
    public func endTouch(canvas: Canvas, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard canvas.isOnValidLayer() else { return false }
        
        // Clear the current drawing curve.
        canvas.rebuildBuffer()
        canvas.currentPath?.closePath()
        return true
    }
    
    public func cancelTouch(canvas: Canvas, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard canvas.isOnValidLayer() else { return false }
        
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
