//
//  Layer.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/18/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit


/** A layer on the canvas. */
public struct Layer: Codable {
    
    // MARK: Variables
    
    internal var elements: [Element]
    
    internal var isLocked: Bool
    
    internal var isHidden: Bool
    
    
    
    
    
    // MARK: Initialization
    
    init() {
        self.elements = []
        self.isLocked = false
        self.isHidden = false
    }
    
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: LayerCodingKeys.self)
        
        self.elements = try container?.decodeIfPresent([Element].self, forKey: .elements) ?? []
        self.isLocked = try container?.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
        self.isHidden = try container?.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
    }
    
    
    
    // MARK: Functions
    
    /** Makes sure that this layer understands that a new element was added on it. */
    internal mutating func add(element: Element) {
        self.elements.append(element)
    }
    
    /** Removes an element from this layer. */
    internal mutating func remove(at: Int) {
        guard at >= 0 && at < elements.count else { return }
        elements.remove(at: at)
    }
    
    /** Erases points from this layer by making them transparent. */
    internal mutating func eraseVertices(canvas: Canvas, point: CGPoint) {
        let a = canvas.currentBrush.size * canvas.force
        let size = (((a / 100) * 4) / 2) / 50
        
        for var i in 0..<elements.count {
            // If it is a shape (circle, rectangle, line) just
            // remove the whole thing, don't bother removing vertices.
            if elements[i].isFreeHand == false {
                if i >= 0 && i < elements.count {
                    elements.remove(at: i)
                    i -= 1
                    continue
                }
            }
            
            // If it's free hand, just remove specific vertices.
            elements[i].vertices.removeAll { vert -> Bool in
                CGPoint.inRange(
                    x: vert.position.x,
                    y: vert.position.y,
                    a: Float(point.x),
                    b: Float(point.y),
                    size: Float(size)
                )
            }
            elements[i].rebuildBuffer(canvas: canvas)
        }
    }
    
    
    // MARK: Rendering
    
    internal func render(canvas: Canvas, index: Int, buffer: MTLCommandBuffer, encoder: MTLRenderCommandEncoder) {
        // Render each element on this layer.
        for element in elements {
            if element.buffer == nil { element.rebuildBuffer(canvas: canvas) }
            element.render(canvas: canvas, buffer: buffer, encoder: encoder)
        }
    }
    
    
    // MARK: Decoding
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LayerCodingKeys.self)
        
        try container.encode(elements, forKey: .elements)
        try container.encode(isLocked, forKey: .isLocked)
        try container.encode(isHidden, forKey: .isHidden)
    }
    
}
