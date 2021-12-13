//
//  ViewController.swift
//  PatternBrush
//
//  Created by Alex ALX on 12.12.21.
//

import UIKit
import TSLog
import Metal


public extension UIDevice {
    static func isSimulator() -> Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }
}

extension ViewController: CanvasEvents {
    
    func isDrawing(element: Element, on canvas: Canvas) {
        
    }
    
    func stoppedDrawing(element: Element, on canvas: Canvas) {
        
    }
    
    func didChangeBrush(to brush: Brush) {
        TSLog.sI.log(.debug, "---> Changed Brush: \(brush.name)")
    }
    
    func didChangeTool(to tool: CanvasTool) {
        TSLog.sI.log(.debug, "---> Changed Tool: \(tool)")
    }
    
    func didUndo(on canvas: Canvas) {
        
    }
    
    func didRedo(on canvas: Canvas) {
        
    }
    
    func didClear(canvas: Canvas) {
        
    }
    
    func didClear(layer at: Int, on canvas: Canvas) {
            
    }
    
    func didAddLayer(at index: Int, to canvas: Canvas) {
            
    }
    
    func didRemoveLayer(at index: Int, from canvas: Canvas) {
            
    }
    
    func didMoveLayer(from startIndex: Int, to destIndex: Int, on canvas: Canvas) {
            
    }
    
    func didSwitchLayer(from oldLayer: Int, to newLayer: Int, on canvas: Canvas) {
            
    }
    
}

class ViewController: UIViewController {
   
    @IBOutlet weak var currentBrushImageView: UIImageView!
    
    let colors: [UIColor] = [.black, .green, .red, .blue, .purple, .orange, .brown, .cyan]
    lazy var tools: [CanvasTool] = [
        CanvasTool.pencil,
        CanvasTool.rectangle,
        CanvasTool.line,
        CanvasTool.ellipse,
        CanvasTool.eraser
    ]
    var currentBrush: Int = 0

    @IBOutlet weak var dynamicCanvas: Canvas!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDynamicCanvas()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveImage), name: Notification.Name(rawValue: "SymetryDidProvideImage"), object: nil)

    }
    
    func configureDynamicCanvas() {
        dynamicCanvas.backgroundColor = .white
        dynamicCanvas.forceEnabled = true//UIDevice.isSimulator() ? false : true
        dynamicCanvas.stylusOnly = true//UIDevice.isSimulator() ? false : true
        dynamicCanvas.currentBrush.size = 20
        dynamicCanvas.maximumForce = 1.0
        dynamicCanvas.addLayer(at: 0)
        dynamicCanvas.currentBrush.color = colors[0]
        dynamicCanvas.canvasDelegate = self
        
//        // Load some textures.
//        if let img = UIImage(named: "Smudge.png") {
//            dynamicCanvas.addTexture(img, forName: "paintTexture")
//            print("Added the paint texture!")
//        }
//        if let img = UIImage(named: "Splash.png") {
//            dynamicCanvas.addTexture(img, forName: "splashTexture")
//            print("Added the splash texture!")
//        }
//
//        // Load a brush.
//        let basicPaint: Brush = Brush(name: "basicPaintBrush", config: [
//            BrushOption.Size: CGFloat(20),
//            BrushOption.Color: UIColor.black,
//            BrushOption.TextureName: "paintTexture"
//        ])
//        let shapeBrush: Brush = Brush(name: "shapeBrush", config: [
//            BrushOption.Size: CGFloat(50),
//            BrushOption.Color: UIColor.black.withAlphaComponent(0.2),
//            BrushOption.TextureName: "splashTexture"
//        ])
//        dynamicCanvas.addBrush(basicPaint)
//        dynamicCanvas.addBrush(shapeBrush)
//        print("Added brushes!")
//
//        // Set the current brush.
//        dynamicCanvas.changeBrush(to: "basicPaintBrush")
       // currentBrushImageView.image = UIImage(named: "Smudge.png")
        currentBrushImageView.layer.borderWidth = 2
        currentBrushImageView.layer.borderColor = UIColor.blue.cgColor
        currentBrushImageView.layer.cornerRadius = 8
        
        // Gestures.
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoom))
        dynamicCanvas.addGestureRecognizer(pinch)
    }

    
    //MARK: - Actions

    @objc func didReceiveImage(_ imageNotification: NSNotification) {
        
        
        dynamicCanvas.clear()
        dynamicCanvas.registeredTextures.removeAll()
        dynamicCanvas.registeredBrushes.removeAll()
        
        let image = imageNotification.object as! UIImage
        dynamicCanvas.addTexture(image, forName: "splashTexture")
        // Load a brush.
        let basicPaint: Brush = Brush(name: "shapeBrush", config: [
            BrushOption.Size: CGFloat(1500),
            BrushOption.Color: UIColor.black,
            BrushOption.TextureName: "splashTexture"
        ])
        dynamicCanvas.addBrush(basicPaint)
        dynamicCanvas.changeBrush(to: "shapeBrush")
        currentBrushImageView.image = image
    }
    
    @objc func zoom(gesture: UIPinchGestureRecognizer) {
        let anchor = CGPoint(x: view.frame.width / dynamicCanvas.frame.width, y: view.frame.height / dynamicCanvas.frame.height)

        let initialScale = self.dynamicCanvas.contentScaleFactor
        let totalScale = min(max(gesture.scale * initialScale, 0.125), 8)
        let scaling = totalScale/initialScale

        var transform = CGAffineTransform(translationX: anchor.x, y: anchor.y)
        transform = transform.scaledBy(x: scaling, y: scaling)
        transform = transform.translatedBy(x: -anchor.x, y: -anchor.y)

        self.dynamicCanvas.transform = self.dynamicCanvas.transform.concatenating(transform)
        gesture.scale = 1
    }
    
    @IBAction func toolMenuItemDidTap(_ sender: UISegmentedControl) {
        
        dynamicCanvas.changeTool(to: tools[sender.selectedSegmentIndex])
    }
    
    @IBAction func brushMenuItemDidTap(_ sender: UISegmentedControl) {
        self.currentBrush = sender.selectedSegmentIndex
        if self.currentBrush == 0 {
            dynamicCanvas.changeBrush(to: "basicPaintBrush")
        } else if currentBrush == 1 {
            dynamicCanvas.changeBrush(to: "shapeBrush")
        }
    }
    

}

