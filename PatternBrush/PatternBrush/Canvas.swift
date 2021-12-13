//
//  Canvas.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/7/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit

internal let CANVAS_PIXEL_FORMAT: MTLPixelFormat = .bgra8Unorm

/** A Metal-accelerated canvas for drawing and painting. */
public class Canvas: MTKView, MTKViewDelegate, Codable {
    
    // MARK: Variables

    // ---> Internal
    
    internal var commandQueue: MTLCommandQueue!
    internal var textureLoader: MTKTextureLoader!
    internal var sampleState: MTLSamplerState!
        
    internal var canvasLayers: [Layer]
    internal var currentPath: Element!
    internal var undoRedoManager: UndoRedoManager
    
    internal var force: CGFloat
    internal var registeredTextures: [String : MTLTexture]
    internal var registeredBrushes: [String : Brush]
    
    
    
    // ---> Public
    
    /** The brush that determines the styling of the next curve drawn on the canvas. */
    public var currentBrush: Brush!
    
    /** The tool that is currently used to add objects to the canvas. */
    public internal(set) var currentTool: Tool!
    
    /** Whether or not the canvas should respond to force as a way to draw curves. */
    public var forceEnabled: Bool
    
    /** The maximum force allowed on the canvas. */
    public var maximumForce: CGFloat {
        didSet {
            self.maximumForce = CGFloat(simd_clamp(Float(self.maximumForce), 0.0, 1.0))
        }
    }
    
    /** Only allow styluses such as the Apple Pencil to be used for drawing. */
    public var stylusOnly: Bool
    
    /** The index of the current layer. */
    public internal(set) var currentLayer: Int
    
    /** The delegate for the CanvasEvents protocol. */
    public var canvasDelegate: CanvasEvents?
    
    
    
    
    // --> Static/Computed
    
    /** A very basic pencil tool for freehand drawing. */
    lazy internal var pencilTool: Pencil = {
        return Pencil()
    }()
    
    /** A basic tool for creating perfect rectangles. */
    lazy internal var rectangleTool: Rectangle = {
        return Rectangle()
    }()
    
    /** A basic line tool for drawing straight lines. */
    lazy internal var lineTool: Line = {
        return Line()
    }()
    
    /** A basic circle tool for drawing straight lines. */
    lazy internal var ellipseTool: Ellipse = {
        return Ellipse()
    }()
    
    /** A simple eraser. */
    lazy internal var eraserTool: Eraser = {
        return Eraser()
    }()
    
    
    // ---> Overrides
    
    public override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override var backgroundColor: UIColor? {
        didSet {
            self.clearColor = (self.backgroundColor ?? UIColor.white).metalClearColor
        }
    }
    
    
    
    
    // MARK: Initialization
    
    public init(frame: CGRect = CGRect.zero) {
        
        self.forceEnabled = true
        self.stylusOnly = false
        self.force = 1.0
        self.maximumForce = 1.0
        self.canvasLayers = []
        self.currentLayer = -1
        self.registeredTextures = [:]
        self.registeredBrushes = [:]
        self.undoRedoManager = UndoRedoManager()
        
        // Configure the metal view.
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        
        self.colorPixelFormat = CANVAS_PIXEL_FORMAT
        self.framebufferOnly = false
        self.delegate = self
        self.isOpaque = true
        self.isPaused = true
        self.enableSetNeedsDisplay = true
        (self.layer as? CAMetalLayer)?.isOpaque = true
        
        self.textureLoader = MTKTextureLoader(device: device!)
        self.commandQueue = device?.makeCommandQueue()
        self.sampleState = buildSampleState(device: device)
        self.currentBrush = Brush(name: "defaultBrush", config: [
            BrushOption.Size: 10.0,
            BrushOption.Color: UIColor.black
        ])
        self.currentTool = self.pencilTool // Default tool
        self.currentPath = Element([], brushName: "defaultBrush") // Used for drawing temporary paths
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try? decoder.container(keyedBy: CanvasCodingKeys.self)
        
        canvasLayers = try container?.decodeIfPresent([Layer].self, forKey: .canvasLayers) ?? []
        force = try container?.decodeIfPresent(CGFloat.self, forKey: .force) ?? 1.0
        maximumForce = try container?.decodeIfPresent(CGFloat.self, forKey: .maximumForce) ?? 1.0
        
        let codedTextures = try container?.decodeIfPresent([String: Data?].self, forKey: .registeredTextures) ?? [:]
        registeredTextures = textureDataToDictionary(loader: textureLoader, dictionary: codedTextures)
        
        registeredBrushes = try container?.decodeIfPresent([String : Brush].self, forKey: .registeredBrushes) ?? [:]
        stylusOnly = try container?.decodeIfPresent(Bool.self, forKey: .stylusOnly) ?? false
    }
    
    public required init(coder: NSCoder) {
        self.forceEnabled = true
        self.stylusOnly = false
        self.force = 1.0
        self.maximumForce = 1.0
        self.canvasLayers = []
        self.currentLayer = -1
        self.registeredTextures = [:]
        self.registeredBrushes = [:]
        self.undoRedoManager = UndoRedoManager()
        
        // Configure the metal view.
        super.init(coder: coder)
        
        self.device = MTLCreateSystemDefaultDevice()
//        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        self.colorPixelFormat = CANVAS_PIXEL_FORMAT
        self.framebufferOnly = false
        self.delegate = self
        self.isOpaque = true
        self.isPaused = true
        self.enableSetNeedsDisplay = true
        (self.layer as? CAMetalLayer)?.isOpaque = true
        
        self.textureLoader = MTKTextureLoader(device: device!)
        self.commandQueue = device?.makeCommandQueue()
        self.sampleState = buildSampleState(device: device)
        self.currentBrush = Brush(name: "defaultBrush", config: [
            BrushOption.Size: 10.0,
            BrushOption.Color: UIColor.black
        ])
        self.currentTool = self.pencilTool // Default tool
        self.currentPath = Element([], brushName: "defaultBrush") // Used for drawing temporary paths
       

    }
    
    
    
    
    // MARK: Functions
    
    // ---> Public
    
    /** Registers a new brush that can be used on this canvas. */
    public func addBrush(_ brush: Brush) {
        let cpy = brush.copy()
        cpy.setupPipeline(canvas: self)
        self.registeredBrushes[brush.name] = cpy
    }
    
    /** Returns the brush with the specified name. */
    public func getBrush(withName name: String, with configuration: [BrushOption : Any?]? = nil) -> Brush? {
        guard var brush = self.registeredBrushes[name] else { return nil }
        if let config = configuration { brush = brush.load(from: config) }
        
        return brush
    }
    
    /** Tells the canvas to start using a different brush to draw with, based on the registered name. */
    public func changeBrush(to name: String, with configuration: [BrushOption : Any?]? = nil) {
        guard let brush = self.getBrush(withName: name, with: configuration) else { return }
        
        self.currentBrush = brush
        self.canvasDelegate?.didChangeBrush(to: brush)
    }
    
    /** Tells the canvas to keep track of another texture, which can be used later on for different brush strokes. */
    public func addTexture(_ image: UIImage, forName name: String) {
        guard let cg = image.cgImage else { return }
        let texture = try! self.textureLoader.newTexture(cgImage: cg, options: [
            MTKTextureLoader.Option.SRGB : false,
            MTKTextureLoader.Option.textureStorageMode: MTLStorageMode.shared.rawValue
        ])
        self.registeredTextures[name] = texture
    }
    
    /** Returns the texture that has been registered on the canvas using a particular name. */
    public func getTexture(withName name: String) -> MTLTexture? {
        guard let texture = self.registeredTextures[name] else { return nil }
        return texture
    }
    
    /** Changes the tool being used on the canvas. */
    public func changeTool(to tool: CanvasTool) {
        switch tool {
        case CanvasTool.pencil:
            self.currentTool = self.pencilTool
            break
        case CanvasTool.rectangle:
            self.currentTool = self.rectangleTool
            break
        case CanvasTool.line:
            self.currentTool = self.lineTool
            break
        case CanvasTool.ellipse:
            self.currentTool = self.ellipseTool
            break
        case CanvasTool.eraser:
            self.currentTool = self.eraserTool
            break
        }
        canvasDelegate?.didChangeTool(to: tool)
    }
    
    /** Allows the user to add custom undo/redo actions to their app. */
    public func addUndoRedo(onUndo: @escaping () -> Any?, onRedo: @escaping () -> Any?) {
        undoRedoManager.add(onUndo: onUndo, onRedo: onRedo)
    }
    
    /** Undoes the last action on  the canvas. */
    public func undo() {
        let _ = undoRedoManager.performUndo()
        rebuildBuffer()
        canvasDelegate?.didUndo(on: self)
    }
    
    /** Redoes the last action on  the canvas. */
    public func redo() {
        let _ = undoRedoManager.performRedo()
        rebuildBuffer()
        canvasDelegate?.didRedo(on: self)
    }
    
    /** Clears the entire canvas. */
    public func clear() {
        for i in 0..<canvasLayers.count {
            canvasLayers[i].elements = []
        }
        rebuildBuffer()
        canvasDelegate?.didClear(canvas: self)
    }
    
    /** Clears the drawings on the specified layer. */
    public func clear(layer at: Int) {
        guard at >= 0 && at < canvasLayers.count else { return }
        
        canvasLayers[at].elements = []
        rebuildBuffer()
        canvasDelegate?.didClear(layer: at, on: self)
    }
    
    
    
    
    
    // ---> Internal
    
    /** Updates the force property of the canvas. */
    internal func setForce(value: CGFloat) {
        if self.forceEnabled == true {
            self.force = min(value, self.maximumForce)
        } else {
            // use simulated force
            var length = CGPoint(x: 1, y: 1).distance(to: .zero)
            length = min(length, 5000)
            length = max(100, length)
            self.force = sqrt(1000 / length)
        }
    }
    
    
    
    // ---> Rendering
    
    /** Ends the curve that is currently being drawn if there is one, then rebuilds the main buffer. */
    internal func rebuildBuffer() {
        // If you were in the process of drawing a curve and are on a valid
        // layer, add that finished element to the layer.
        if let copy = currentPath?.copy() {
            if isOnValidLayer() && copy.vertices.count > 0 {
                // Add the newly drawn element to the layer.
                copy.rebuildBuffer(canvas: self)
                canvasLayers[currentLayer].add(element: copy)
                
                // Add an undo action.
                undoRedoManager.clearRedos()
                undoRedoManager.add(onUndo: { () -> Any? in
                    let index = self.canvasLayers[self.currentLayer].elements.count - 1
                    self.canvasLayers[self.currentLayer].remove(at: index)
                    return nil
                }) { () -> Any? in
                    copy.rebuildBuffer(canvas: self)
                    self.canvasLayers[self.currentLayer].add(element: copy)
                    return nil
                }
            }
        }
        
        // Repaint the canvas.
        setNeedsDisplay()
    }
    
    /** Finish the current drawing path and add it to the canvas. Then repaint the view. Never needs to be called manually. */
    internal func repaint() {
        autoreleasepool {
            // Get a reference to a command buffer and render encoder.
            guard let rpd = currentRenderPassDescriptor else { return }
            guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
            guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) else { return }
            
            // Render each layer.
            for i in 0..<canvasLayers.count {
                let layer = canvasLayers[i]
                if layer.isHidden == true { continue }
                layer.render(canvas: self, index: i, buffer: commandBuffer, encoder: encoder)
                

                if i == currentLayer {
                    if let cp = currentPath {
                        if cp.vertices.count > 0 && canvasLayers[currentLayer].isLocked == false {
                            cp.rebuildBuffer(canvas: self)
                            cp.render(canvas: self, buffer: commandBuffer, encoder: encoder)
                        }
                    }
                }
            }

            // Finishing main encoding and present drawable.
            encoder.endEncoding()
            if let drawable = currentDrawable {
                commandBuffer.present(drawable)
            }
            commandBuffer.commit()
        }
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public func draw(in view: MTKView) {
        repaint()
    }
    
    
    // MARK: Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CanvasCodingKeys.self)
        
        try container.encode(canvasLayers, forKey: .canvasLayers)
        try container.encode(force, forKey: .force)
        
        let codableTextures = dictionaryToCodable(dictionary: registeredTextures)
        try container.encode(codableTextures, forKey: .registeredTextures)
        try container.encode(registeredBrushes, forKey: .registeredBrushes)
        try container.encode(currentBrush, forKey: .currentBrush)
        try container.encode(maximumForce, forKey: .maximumForce)
        try container.encode(stylusOnly, forKey: .stylusOnly)
        try container.encode(currentLayer, forKey: .currentLayer)
    }
    
    
    
} // End of class.
