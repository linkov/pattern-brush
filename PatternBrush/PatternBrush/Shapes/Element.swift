//
//  Element.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/19/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit


/** An element is a manager for a group of quads on a layer of the canvas. */
public class Element: Codable {
    
    // MARK: Variables
    
    // --> Internal
    
    internal var buffer: MTLBuffer?
    internal var vertices: [Vertex]
    
    internal var brushName: String
    internal var start: CGPoint
    internal var isFreeHand: Bool
    
    
    
    // --> Public
    
    /** Returns the number of vertices that make up this element. */
    public var length: Int {
        return vertices.count
    }
    
    
    
    // MARK: Initialization
    
    init(_ verts: [Vertex], brushName: String) {
        self.vertices = verts
        self.brushName = brushName
        self.isFreeHand = true
        self.start = CGPoint()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: ElementCodingKeys.self)
        
        self.vertices = try container?.decodeIfPresent([Vertex].self, forKey: .vertices) ?? []
        self.brushName = try container?.decodeIfPresent(String.self, forKey: .brushName) ?? "defaultBrush"
        self.isFreeHand = try container?.decodeIfPresent(Bool.self, forKey: .isFreeHand) ?? true
        self.start = CGPoint()
    }
    
    
    public func copy() -> Element {
        let e = Element(self.vertices, brushName: self.brushName)
        e.isFreeHand = self.isFreeHand
        return e
    }
    
    
    
    // MARK: Functions
    
    /** Starts a new path using this element. */
    internal func startPath(point: CGPoint, canvas: Canvas, isFreeHand: Bool = true) {
        self.brushName = canvas.currentBrush.name
        guard let brush = canvas.getBrush(
            withName: self.brushName,
            with: [
                // TODO: Brush size is not working
                BrushOption.Size: canvas.currentBrush.size,
                BrushOption.Color: canvas.currentBrush.color,
                BrushOption.TextureName: canvas.currentBrush.textureName,
                BrushOption.IsEraser: canvas.currentBrush.isEraser,
            ]
        ) else { return }
        
        // Configure the element.
        self.start = point
        self.isFreeHand = isFreeHand
        
        // Add the first vertex.
        let vert = Vertex(
            position: point,
            size: 0,
            color: brush.color,
            rotation: 0
        )
        self.vertices = [vert]
        BezierGenerator.startPath(with: point)
    }
    
    /** Finishes this element so that no more quads can be added to it without starting an
     entirely new element (i.e. lifting the stylus and drawing a new curve). */
    internal func closePath() {
        vertices = []
        BezierGenerator.closePath()
    }
    
    /** Ends the last quad that exists on this element. */
    internal func endPencil(at point: CGPoint, canvas: Canvas) {
        guard let brush = canvas.getBrush(
            withName: self.brushName,
            with: [
                // TODO: Brush size is not working
                BrushOption.Size: canvas.currentBrush.size,
                BrushOption.Color: canvas.currentBrush.color,
                BrushOption.TextureName: canvas.currentBrush.textureName,
                BrushOption.IsEraser: canvas.currentBrush.isEraser,
            ]
        ) else { return }
        
        // Generate the vertices to the next point.
        let prevPoint = vertices.count > 0 ?
            CGPoint(x: CGFloat(vertices.last!.position.x), y: CGFloat(vertices.last!.position.y)) : self.start
        let verts = BezierGenerator.add(point: point).map {
            Vertex(
                position: $0,
                size: brush.size * canvas.force,
                color: brush.color,
                rotation: point.angel(to: prevPoint)
            )
        }
        vertices.append(contentsOf: verts)
    }
    
    /**Ends the curve as a particular tool.  */
    internal func end(at point: CGPoint, canvas: Canvas, as tool: CanvasTool) {
        guard let brush = canvas.getBrush(
            withName: self.brushName,
            with: [
                BrushOption.Size: canvas.currentBrush.size,
                BrushOption.Color: canvas.currentBrush.color,
                BrushOption.TextureName: canvas.currentBrush.textureName,
                BrushOption.IsEraser: canvas.currentBrush.isEraser,
            ]
        ) else { return }

        // End and display the quad as the current tool where you currently drag.
        switch tool {
            case .rectangle:
                let verts = endRectangle(start: self.start, end: point, brush: brush)
                self.vertices = verts
                break
            case .line:
                let verts = endLine(start: self.start, end: point, brush: brush)
                self.vertices = verts
                break
            case .ellipse:
                let verts = endEllipse(start: self.start, end: point, brush: brush)
                self.vertices = verts
                break
            default:
                let verts = endRectangle(start: self.start, end: point, brush: brush)
                self.vertices = verts
                break
        }
    }
    
    
    // MARK: Rendering
    
    /** Rebuilds the buffer. */
    internal func rebuildBuffer(canvas: Canvas) {
        if vertices.count > 0 {
            buffer = canvas.device!.makeBuffer(
                bytes: vertices,
                length: length * MemoryLayout<Vertex>.stride,
                options: .cpuCacheModeWriteCombined
            )
        } else {
            buffer = nil
        }
    }
    
    /** Renders the element to the screen. */
    internal func render(canvas: Canvas, buffer: MTLCommandBuffer, encoder: MTLRenderCommandEncoder) {
        guard vertices.count > 0 else { return }
        guard let vBuff = self.buffer else { return }
        guard let brush = canvas.getBrush(withName: self.brushName) else { return }
        
        // Set the properties on the encoder for this element and the brush it uses specifically.
        encoder.setRenderPipelineState(brush.pipeline)
        encoder.setVertexBuffer(vBuff, offset: 0, index: 0)
        
        if let texName = brush.textureName, let txr = canvas.getTexture(withName: texName) {
            encoder.setFragmentTexture(txr, index: 0)
        }
        encoder.setFragmentSamplerState(canvas.sampleState, index: 0)
        
        // Draw primitives.
        encoder.drawPrimitives(type: isFreeHand == true ? .point : .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
    
    
    // MARK: Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ElementCodingKeys.self)
        
        try container.encode(vertices, forKey: .vertices)
        try container.encode(brushName, forKey: .brushName)
        try container.encode(isFreeHand, forKey: .isFreeHand)
    }
    
}
