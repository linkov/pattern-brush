//
//  Bezier.swift
//  Canvas2
//
//  Created by Adeola Uthman on 2/4/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit


/** A class used for generating bezier curves. */
internal class BezierGenerator {
    
    // MARK: Variables
    
    private static var points: [CGPoint] = []
    
    private static var step: Int = 0
    
    
    
    // MARK: Initialization
       
    
    
    // MARK: Functions
    
    /** Starts the path with a new point. */
    static func startPath(with point: CGPoint) {
        BezierGenerator.step = 0
        BezierGenerator.points.removeAll()
        BezierGenerator.points.append(point)
    }
    
    /** Adds additional points onto the path between the last point and the current point. */
    static func add(point: CGPoint) -> [CGPoint] {
        guard point != BezierGenerator.points.last else { return [] }
        BezierGenerator.points.append(point)
        
        guard BezierGenerator.points.count >= 3 else { return [] }
        BezierGenerator.step += 1
        
        let result = BezierGenerator.intermediatePoints()
        return result
    }
    
    /** Closes the bezier path so that it can start again when you draw a new curve. */
    static func closePath() {
        BezierGenerator.step = 0
        BezierGenerator.points.removeAll()
    }
    
    
    
    // MARK: Other
    
    /** Generates intermediate points between a set of points. */
    private static func intermediatePoints() -> [CGPoint] {
        var begin: CGPoint = .zero
        var control: CGPoint = .zero
        let end = CGPoint.middle(
            p1: BezierGenerator.points[BezierGenerator.step],
            p2: BezierGenerator.points[BezierGenerator.step + 1]
        )
        var vertices: [CGPoint] = []
        
        if BezierGenerator.step == 1 {
            begin = BezierGenerator.points[0]
            let middle1 = CGPoint.middle(
                p1: BezierGenerator.points[0],
                p2: BezierGenerator.points[1]
            )
            control = CGPoint.middle(p1: middle1, p2: BezierGenerator.points[1])
        } else {
            begin = CGPoint.middle(
                p1: BezierGenerator.points[BezierGenerator.step - 1],
                p2: BezierGenerator.points[step]
            )
            control = BezierGenerator.points[BezierGenerator.step]
        }
        
        let dis = begin.distance(to: end)
        let segements = max(Int(dis / 5), 2)
        for i in 0 ..< segements {
            let t = CGFloat(i) / CGFloat(segements)
            let x = pow(1 - t, 2) * begin.x + 2.0 * (1 - t) * t * control.x + t * t * end.x
            let y = pow(1 - t, 2) * begin.y + 2.0 * (1 - t) * t * control.y + t * t * end.y
            vertices.append(CGPoint(x: x, y: y))
        }
        vertices.append(end)
        return vertices
    }
}
