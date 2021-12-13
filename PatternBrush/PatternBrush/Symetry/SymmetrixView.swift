//
//  SymmetrixView.swift
//  Symmetrix
//
//  Created by Nigel Barber on 27/01/2020.
//  Copyright © 2020 Mindbrix. All rights reserved.
//

import UIKit
import CoreGraphics
import TSUtils

extension UIImage {
    
    
    func resized(to size: CGSize) -> UIImage {
         return UIGraphicsImageRenderer(size: size).image { _ in
             draw(in: CGRect(origin: .zero, size: size))
         }
     }
    
func remove(color: UIColor) -> UIImage? {
    
    let cgColor = color.cgColor
    let components = cgColor.components
    var r = components?[0] ?? 0.0
    var g = components?[1] ?? 0.0
    var b = components?[2] ?? 0.0
    
    r = r * 255.0
    g = g * 255.0
    b = b * 255.0
    
    let colorMasking: [CGFloat] = [r, r, g, g, b, b]
    
    let image = UIImage(data: self.jpegData(compressionQuality: 1.0)!)!
    let rawImageRef: CGImage = image.cgImage!
    
    UIGraphicsBeginImageContext(image.size);
    
    let maskedImageRef = rawImageRef.copy(maskingColorComponents: colorMasking)
    UIGraphicsGetCurrentContext()?.translateBy(x: 0.0,y: image.size.height)
    UIGraphicsGetCurrentContext()?.scaleBy(x: 1.0, y: -1.0)
    UIGraphicsGetCurrentContext()?.draw(maskedImageRef!, in: CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height))
    let result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result
}
}

class SymmetrixView: UIView {
    static let viewWasTouched = "viewWasTouched"
    lazy var bitmapCtx: CGContext? = {
        let width = Int(ceil(self.bounds.size.width * self.contentScaleFactor))
        let height = Int(ceil(self.bounds.size.height * self.contentScaleFactor))
        let RGB = CGColorSpaceCreateDeviceRGB()
        let BGRA = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: RGB, bitmapInfo: BGRA.rawValue) else { return nil }
        ctx.setLineCap(CGLineCap.round)
        ctx.setLineJoin(CGLineJoin.round)
        ctx.scaleBy(x: self.contentScaleFactor, y: self.contentScaleFactor)
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(self.bounds)
        return ctx
    }()
    var lastPoint = CGPoint.zero
    var lineWidth: CGFloat = 4.0
    var lineColor = UIColor.black
    var turns = 16
    
    func clear() {
        guard let ctx = bitmapCtx else { return }
        ctx.fill(self.bounds)
        setNeedsDisplay()
    }
    
    
    
    func getImage() -> UIImage? {
        
        guard let ctx = bitmapCtx, let image = ctx.makeImage() else { return nil }
//        let image1 =  UIImage(cgImage: image)
//        return image1
////        let jpeg = image1.jpegData(compressionQuality: 1)
////        let out = try! UIImage(data: jpeg!)!.resized(to: CGSize(width: 300,height: 300), with: CGImage.ResizeTechnique.coreGraphics)
        
        
        let ciImage = CIImage(cgImage: image)
        let filteredImage = ciImage.applyingFilter("CIColorInvert") .applyingFilter("CIMaskToAlpha").applyingFilter("CIColorInvert")
        
        
        let i =  UIImage(ciImage: filteredImage)
        let img = i.resized(to: CGSize(width: 300,height: 300))
        
        return img
    }
    func drawLine(startPoint: CGPoint, endPoint: CGPoint) {
        guard let ctx = bitmapCtx else { return }
        
        ctx.setLineWidth(lineWidth)
        ctx.setStrokeColor(lineColor.cgColor)
        
        let inset = ceil(lineWidth * 0.5)
        let centre = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
        for t in 0 ..< turns {
            let angle = CGFloat(t) / CGFloat(turns) * CGFloat(.pi * 2.0)
            let rotation = CGAffineTransform(rotationAngle: angle)
            
            var m = CGAffineTransform(translationX: centre.x, y: centre.y)
            m = rotation.concatenating(m)
            m = m.translatedBy(x: -centre.x, y: -centre.y)
            
            let start = startPoint.applying(m)
            let end = endPoint.applying(m)
            
            ctx.move(to: start)
            ctx.addLine(to: end)
            ctx.strokePath()
            
            let origin = CGPoint(x: min(start.x, end.x), y: min(start.y, end.y))
            let size = CGSize(width:abs(start.x - end.x), height:abs(start.y - end.y))
            
            let dirtyRect = CGRect(origin:origin, size:size).insetBy(dx: -inset, dy: -inset)
            setNeedsDisplay(dirtyRect)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(name: Notification.Name(SymmetrixView.viewWasTouched), object: nil)
        
        lastPoint = touches.first!.location(in: self)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        drawLine(startPoint: lastPoint, endPoint: point)
        lastPoint = point
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: self)
        drawLine(startPoint: lastPoint, endPoint: point)
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = bitmapCtx, let image = ctx.makeImage(), let viewCtx = UIGraphicsGetCurrentContext() else { return }
        viewCtx.setBlendMode(.copy)
        viewCtx.interpolationQuality = .none
        viewCtx.draw(image, in: rect, byTiling: false)
    }
}
