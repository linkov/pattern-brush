//
//  Tool.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/16/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit

/** The different tools that can be used on the canvas. */
public enum CanvasTool {
    case pencil
    case rectangle
    case line
    case ellipse
    case eraser
}

/** A protocol for defining a tool, which determines how to manipulate the vertex/quad data on the canvas. */
public protocol Tool: Codable {
    
    // MARK: Variables
    
    var name: String { get set }
    
    
    // MARK: Initialization
    
    init()
    
    init(from decoder: Decoder) throws
    
    
    
    // MARK: Functions
    
    /** Called when this tool first hits the canvas. */
    func beginTouch(canvas: Canvas, _ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool
    
    /** Called when this tool starts to move. */
    func moveTouch(canvas: Canvas, _ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool
    
    /** Called when this tool is no longer touching the canvas. */
    func endTouch(canvas: Canvas, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool
    
    /** Called when this tool stops touching the canvas w/o help from the user. */
    func cancelTouch(canvas: Canvas, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool
    
    
    // MARK: Codable
    
    func encode(to encoder: Encoder) throws
    
}
