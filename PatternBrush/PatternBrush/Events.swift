//
//  Events.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/22/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit
import Metal
import MetalKit

/** A set of methods that get called at different points throughout the lifecycle of the canvas. */
public protocol CanvasEvents {
    
    /** Called while the user is currently drawing on the canvas. */
    func isDrawing(element: Element, on canvas: Canvas)
    
    /** Called when the user stops drawing on the canvas. */
    func stoppedDrawing(element: Element, on canvas: Canvas)
    
    /** Called whenever you change a brush. */
    func didChangeBrush(to brush: Brush)
    
    /** Called when you change the tool. */
    func didChangeTool(to tool: CanvasTool)
    
    /** Called when an action has been undone. */
    func didUndo(on canvas: Canvas)
    
    /** Called when an action is  redone. */
    func didRedo(on canvas: Canvas)
    
    /** Called when the canvas is cleared. */
    func didClear(canvas: Canvas)
    
    /** Called when a single layer is cleared. */
    func didClear(layer at: Int, on canvas: Canvas)
    
    /** Called whenever a new layer is added to the canvas. */
    func didAddLayer(at index: Int, to canvas: Canvas)
    
    /** Called whenever a  layer is removed from the canvas. */
    func didRemoveLayer(at index: Int, from canvas: Canvas)
    
    /** Called whenever a layer is moved. */
    func didMoveLayer(from startIndex: Int, to destIndex: Int, on canvas: Canvas)
    
    /** Called whenever you switch to a different layer. */
    func didSwitchLayer(from oldLayer: Int, to newLayer: Int, on canvas: Canvas)
}
