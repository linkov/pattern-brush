//
//  Canvas+Layers.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/18/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit

/** Extension that handles managing canvas layers. */
public extension Canvas {
    
    /** Returns whether or not the user is currently on a valid layer. */
    internal func isOnValidLayer() -> Bool {
        guard canvasLayers.count > 0 else { return false }
        guard currentLayer >= 0 && currentLayer < canvasLayers.count else { return false }
        if canvasLayers[currentLayer].isLocked == true { return false }
        return true
    }
    
    
    /** Switches to a different drawing layer. */
    func switchLayer(to index: Int) {
        guard index >= 0 && index < canvasLayers.count else { return }
        
        let old = self.currentLayer
        self.currentLayer = index
        canvasDelegate?.didSwitchLayer(from: old, to: index, on: self)
    }
    
    
    /** Adds a layer to the canvas. */
    func addLayer(at index: Int) {
        // Adding a layer does not require a rebuild of the buffer
        // because that will happen when the user draws again.
        let newLayer = Layer()
        if self.canvasLayers.count == 0 {
            self.canvasLayers.append(newLayer)
            self.currentLayer = 0
            self.canvasDelegate?.didAddLayer(at: 0, to: self)
            return
        }
        
        self.canvasLayers.insert(newLayer, at: index)
        rebuildBuffer()
        self.canvasDelegate?.didAddLayer(at: index, to: self)
    }
    
    
    /** Deletes a layer from the canvas. */
    func removeLayer(at index: Int) {
        guard index >= 0 && index <= self.canvasLayers.count else { return }
        
        // Remove the canvas layer.
        self.canvasLayers.remove(at: index)
        if self.currentLayer >= self.canvasLayers.count {
            self.currentLayer = self.canvasLayers.count - 1
        }
        
        // Rebuild the buffer.
        rebuildBuffer()
        setNeedsDisplay()
        
        self.canvasDelegate?.didRemoveLayer(at: index, from: self)
    }
    
    
    /** Moves the layer at the specified index to a different position on the canvas. */
    func moveLayer(from startIndex: Int, to destIndex: Int) {
        guard startIndex >= 0 && startIndex < self.canvasLayers.count else { return }
        guard destIndex >= 0 && destIndex < self.canvasLayers.count else { return }
        
        let moveLayer = canvasLayers[startIndex]
        canvasLayers.remove(at: startIndex)
        canvasLayers.insert(moveLayer, at: destIndex)
        
        rebuildBuffer()
        setNeedsDisplay()
        
        self.canvasDelegate?.didMoveLayer(from: startIndex, to: destIndex, on: self)
    }
    
    
    /** Locks a particular layer so that no actions can be taken on it. */
    func lock(layer at: Int) {
        guard at >= 0 && at < canvasLayers.count else { return }
        canvasLayers[at].isLocked = true
    }
    
    
    /** Unlocks a particular layer so that you can interact with it again. */
    func unlock(layer at: Int) {
        guard at >= 0 && at < canvasLayers.count else { return }
        canvasLayers[at].isLocked = false
    }
    
    
    /** Hides a particular layer so that it cannot be seen. */
    func hide(layer at: Int) {
        guard at >= 0 && at < canvasLayers.count else { return }
        canvasLayers[at].isHidden = true
        rebuildBuffer()
        setNeedsDisplay()
    }
    
    
    /** Shows a layer that has been hidden so that it can be visible on the canvas */
    func show(layer at: Int) {
        guard at >= 0 && at < canvasLayers.count else { return }
        canvasLayers[at].isHidden = false
        rebuildBuffer()
        setNeedsDisplay()
    }
    
    
    /** Returns the layer at the given index. */
    func getLayer(at index: Int) -> Layer? {
        guard index >= 0 && index < canvasLayers.count else { return nil }
        return canvasLayers[index]
    }
    
}
