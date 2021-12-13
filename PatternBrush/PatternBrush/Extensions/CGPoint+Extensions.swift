//
//  CGPoint+Extensions.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/15/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint: Comparable {
    
    public static func < (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }
    
    static func middle(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    }
    
    func direction(to other: CGPoint) -> CGFloat {
        let dX = abs(other.x - self.x)
        let dY = abs(other.y - self.y)
        let t = atan(dY / dX)
        return t
    }
    
    func distance(to other: CGPoint) -> CGFloat {
        let p = pow(x - other.x, 2) + pow(y - other.y, 2)
        return sqrt(p)
    }
    
    static func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        let p = pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)
        return sqrt(p)
    }
    
    func angel(to other: CGPoint = .zero) -> CGFloat {
        let point = self - other
        if y == 0 {
            return x >= 0 ? 0 : CGFloat.pi
        }
        return -CGFloat(atan2f(Float(point.y), Float(point.x)))
    }
    
    private func norm() -> CGFloat {
        return sqrt(pow(x, 2) + pow(y, 2))
    }
    
    func normalize() -> CGPoint {
        let n = norm()
        let out = CGPoint(x: x / n, y: y / n)
        return out
    }
    
    func perpendicular(other: CGPoint) -> CGPoint {
        var diff = CGPoint(x: other.x - self.x, y: other.y - self.x)
        let length = hypot(diff.x, diff.y)
        diff.x /= length
        diff.y /= length
        let perp = CGPoint(x: -diff.y, y: diff.x)
        return perp
    }
    
    /** Checks if a vertex lies within the range of another vertex by the amount of the brush size. */
    static func inRange(x: Float, y: Float, a: Float, b: Float, size: Float) -> Bool {
        return (x >= a - size && x <= a + size) && (y >= b - size && y <= b + size)
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func -=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }
    
    static func +(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x + rhs, y: lhs.y + rhs)
    }
    
    static func -(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x - rhs, y: lhs.y - rhs)
    }
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
}
