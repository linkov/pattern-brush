//
//  Element+Shapes.swift
//  Canvas2
//
//  Created by Adeola Uthman on 2/5/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit


extension Element {
    
    /** Returns an array of vertices that map to a rectangle (two triangles). */
    func endRectangle(start: CGPoint, end: CGPoint, brush: Brush) -> [Vertex] {
        let size = brush.size
        let color = brush.color
        let rotation = CGFloat(-1)
        
        // Compute the rectangle from the starting point to the end point.
        // Remember that the end coordinates can be behind the start.
        var corner1 = start
        var corner2 = start
        
        // Condition 1: Going from bottom left to top right.
        if start.x < end.x && start.y < end.y {
            let xDist = end.x - start.x
            let yDist = end.y - start.y
            corner2.x += xDist
            corner1.y += yDist
        }
        // Condition 2: Top left to bottom right.
        else if start.x < end.x && start.y > end.y {
            let xDist = end.x - start.x
            let yDist = start.y - end.y
            corner2.x += xDist
            corner1.y -= yDist
        }
        // Condition 3: Top right to bottom left.
        else if start.x > end.x && start.y > end.y {
            let xDist = start.x - end.x
            let yDist = start.y - end.y
            corner2.x -= xDist
            corner1.y -= yDist
        }
        // Condition 4: Bottom right to top left.
        else if start.x > end.x && start.y < end.y {
            let xDist = start.x - end.x
            let yDist = end.y - start.y
            corner2.x -= xDist
            corner1.y += yDist
        }
        
        // Apply the corners to the vertices array to form two triangles,
        // which will come together to form one rectangle on the screen.
        return [
            Vertex(position: end, size: size, color: color, rotation: rotation),
            Vertex(position: corner2, size: size, color: color, rotation: rotation),
            Vertex(position: start, size: size, color: color, rotation: rotation),

            Vertex(position: start, size: size, color: color, rotation: rotation),
            Vertex(position: end, size: size, color: color, rotation: rotation),
            Vertex(position: corner1, size: size, color: color, rotation: rotation)
        ]
    }
    
    
    /** Returns an array of vertices that map to a straight line. */
    func endLine(start: CGPoint, end: CGPoint, brush: Brush) -> [Vertex] {
        let size = brush.size
        let color = brush.color
        let rotation = CGFloat(-1)
        
        // TODO: Maybe just use distance to the end point to compute the line coordinates.
        let perpendicular = start.perpendicular(other: end).normalize()
        var A: CGPoint = start
        var B: CGPoint = end
        var C: CGPoint = end
        var D: CGPoint = start
        
        // Based on the rotation, compute the four corners of the quad.
        // Condition 1: Bottom left to top right.
        if start.x < end.x && start.y < end.y {
            A.x -= (perpendicular * size).x
            A.y += (perpendicular * size).x
            
            B.x -= (perpendicular * size).x
            B.y += (perpendicular * size).x
            
            C.x += (perpendicular * size).x
            C.y -= (perpendicular * size).x
            
            D.x += (perpendicular * size).x
            D.y -= (perpendicular * size).x
        }
        // Condition 2: Top left to bottom right.
        else if start.x < end.x && start.y > end.y {
            A.x += (perpendicular * size).x
            A.y += (perpendicular * size).x
            
            B.x += (perpendicular * size).x
            B.y += (perpendicular * size).x
            
            C.x -= (perpendicular * size).x
            C.y -= (perpendicular * size).x
            
            D.x -= (perpendicular * size).x
            D.y -= (perpendicular * size).x
        }
        // Condition 3: Top right to bottom left.
        else if start.x > end.x && start.y > end.y {
            A.x += (perpendicular * size).x
            A.y -= (perpendicular * size).x
            
            B.x += (perpendicular * size).x
            B.y -= (perpendicular * size).x
            
            C.x -= (perpendicular * size).x
            C.y += (perpendicular * size).x
            
            D.x -= (perpendicular * size).x
            D.y += (perpendicular * size).x
        }
        // Condition 4: Bottom right to top left.
        else if start.x > end.x && start.y < end.y {
            A.x -= (perpendicular * size).x
            A.y -= (perpendicular * size).x
            
            B.x -= (perpendicular * size).x
            B.y -= (perpendicular * size).x
            
            C.x += (perpendicular * size).x
            C.y += (perpendicular * size).x
            
            D.x += (perpendicular * size).x
            D.y += (perpendicular * size).x
        }
        
        // Set the vertices of the line quad.
        return [
            // Triangle 1
            Vertex(position: A, size: size, color: color, rotation: rotation),
            Vertex(position: B, size: size, color: color, rotation: rotation),
            Vertex(position: C, size: size, color: color, rotation: rotation),

            // Triangle 2
            Vertex(position: A, size: size, color: color, rotation: rotation),
            Vertex(position: C, size: size, color: color, rotation: rotation),
            Vertex(position: D, size: size, color: color, rotation: rotation),
        ]
    }
    
    
    /** Returns an array of vertices that map to an ellipse. */
    func endEllipse(start: CGPoint, end: CGPoint, brush: Brush) -> [Vertex] {
        let size = brush.size
        let color = brush.color
        let rotation = CGFloat(-1)
        
        var verts: [Vertex] = [
            Vertex(position: self.start, color: color, rotation: rotation)
        ]
                
        /** Creates points around a circle. It's just a formula for degrees to radians. */
        func rads(forDegree d: Int) -> CGFloat {
            // 7 turns out to be the magic number here :)
            return (7 * CGFloat.pi * CGFloat(d)) / 180
        }
        
        // Keep track of the texture position for each vertex in the circle.
        let poses: [(x: Float, y: Float)] = [
            (0, 0),
            (0.5, -0.5),
            (0.5, 0),
            (0, 0),
            (-0.5, -0.5),
            (-0.5, 0)
        ]
        var pose: Int = 0
        
        // Create vertices for the circle.
        for i in 0..<720 {
            // Add the previous point so that the triangle can reconnect to
            // the start point.
            if i > 0 && verts.count > 0 && i % 2 == 0 {
                let last = verts[i - 1]
                verts.append(last)
            }
            
            // Calculate the point at the distance around the circle.
            let _x = cos(rads(forDegree: i)) * abs(end.x - self.start.x)
            let _y = sin(rads(forDegree: i)) * abs(end.y - self.start.y)
            let pos: CGPoint = CGPoint(x: self.start.x + _x, y: self.start.y + _y)
            let vert: Vertex = Vertex(position: pos, size: size, color: color, rotation: rotation)
            verts.append(vert)
            
            // Update the pose.
            pose = (pose == poses.count - 1) ? 0 : pose + 1
        }
        
        return verts
    }
    
}
