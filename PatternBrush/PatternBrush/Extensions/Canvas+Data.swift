//
//  Canvas+Data.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/31/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit

extension Canvas {
    
    /** Exports the canvas as a UIImage. */
    public func export(size s: CGSize? = nil) -> UIImage? {
        guard let drawable = currentDrawable else { return nil }
        
        let size = s ?? CGSize(width: drawable.texture.width, height: drawable.texture.height)
        guard let img = makeImage(for: drawable.texture, size: size) else { return nil };
        return UIImage(cgImage: img)
    }
    
    /** Exports the canvas, all of its layers, brush data, etc. into codable data. */
    public func exportCanvas() -> Data? {
        do {
            let data: Data = try JSONEncoder().encode(self)
            return data
        } catch {
            return nil
        }
    }
    
    /** Returns all of the layers. */
    public func exportLayers() -> [Layer] {
        return canvasLayers
    }
    
    /** Exports just the drawings from each layer. */
    public func exportLayerDrawings() -> [[Element]] {
        let ret = canvasLayers.map { $0.elements }
        return ret
    }
    
    /** Exports just the drawing data from a given element. */
    public func exportDrawings(from index: Int) -> [Element] {
        guard index >= 0 && index < canvasLayers.count else { return [] }
        return canvasLayers[index].elements
    }
    
    /** Sets the canvas layers to the input and repaints the screen. */
    public func load(layers: [Layer]) {
        canvasLayers = layers
        currentLayer = layers.count > 0 ? 0 : -1
        setNeedsDisplay()
    }
    
    /** Loads the drawings from each layer. */
    public func load(layerElements: [[Element]]) {
        for i in 0..<canvasLayers.count {
            let copy = layerElements[i].map { $0.copy() }
            canvasLayers[i].elements = copy
        }
        setNeedsDisplay()
    }
    
    /** Loads canvas elements onto a particular layer. */
    public func load(elements: [Element], onto layer: Int) {
        guard layer >= 0 && layer < canvasLayers.count else { return }
        
        let copy = elements.map { $0.copy() }
        canvasLayers[layer].elements = copy
        setNeedsDisplay()
    }
    
}
