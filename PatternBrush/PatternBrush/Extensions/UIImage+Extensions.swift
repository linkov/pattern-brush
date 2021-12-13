//
//  UIImage+Extensions.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/18/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit
import Accelerate

public extension UIImage {
    
    /** Returns the color information at a certain pixel. */
    subscript(_ point: CGPoint) -> UIColor? {
        guard let pixelData = self.cgImage?.dataProvider?.data else { return nil }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = Int((size.width * point.y + point.x) * 4.0 * scale * scale)
        let i = Array(0 ... 3).map { CGFloat(data[pixelInfo + $0]) / CGFloat(255) }
        return UIColor(red: i[0], green: i[1], blue: i[2], alpha: i[3])
    }
    
}

/** Helper function for making an image. */
internal func swizzleBGRA8toRGBA8(_ bytes: UnsafeMutableRawPointer, width: Int, height: Int) {
    var sourceBuffer = vImage_Buffer(data: bytes,
                                     height: vImagePixelCount(height),
                                     width: vImagePixelCount(width),
                                     rowBytes: width * 4)
    var destBuffer = vImage_Buffer(data: bytes,
                                   height: vImagePixelCount(height),
                                   width: vImagePixelCount(width),
                                   rowBytes: width * 4)
    var swizzleMask: [UInt8] = [ 2, 1, 0, 3 ] // BGRA -> RGBA
    vImagePermuteChannels_ARGB8888(&sourceBuffer, &destBuffer, &swizzleMask, vImage_Flags(kvImageNoFlags))
}

/** Makes a new image from a texture. */
internal func makeImage(for texture: MTLTexture, size: CGSize?) -> CGImage? {
    assert(texture.pixelFormat == .bgra8Unorm)

    let width = size != nil ? Int(size!.width) : texture.width
    let height = size != nil ? Int(size!.height) : texture.height
    let pixelByteCount = 4 * MemoryLayout<UInt8>.size
    let imageBytesPerRow = width * pixelByteCount
    let imageByteCount = imageBytesPerRow * height
    let imageBytes = UnsafeMutableRawPointer.allocate(byteCount: imageByteCount, alignment: pixelByteCount)
    defer { imageBytes.deallocate() }

    texture.getBytes(imageBytes,
                     bytesPerRow: imageBytesPerRow,
                     from: MTLRegionMake2D(0, 0, width, height),
                     mipmapLevel: 0)
    swizzleBGRA8toRGBA8(imageBytes, width: width, height: height)

    guard let colorSpace = CGColorSpace(name: CGColorSpace.linearSRGB) else { return nil }
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    guard let bitmapContext = CGContext(data: nil,
                                        width: width,
                                        height: height,
                                        bitsPerComponent: 8,
                                        bytesPerRow: imageBytesPerRow,
                                        space: colorSpace,
                                        bitmapInfo: bitmapInfo) else { return nil }
    bitmapContext.data?.copyMemory(from: imageBytes, byteCount: imageByteCount)
    let image = bitmapContext.makeImage()
    return image
}
