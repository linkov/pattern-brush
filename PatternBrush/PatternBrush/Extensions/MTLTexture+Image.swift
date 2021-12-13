//
//  MTLTexture+Image.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/18/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import UIKit


/** Converts a dictionary of textures to be codable. */
internal func dictionaryToCodable(dictionary: [String : MTLTexture?]) -> [String : Data?] {
    var ret: [String : Data?] = [:]
    for (key, val) in dictionary {
        ret[key] = val?.toData()
    }
    return ret
}

/** Converts a dictionary of texture data to MTLTextures. */
internal func textureDataToDictionary(loader: MTKTextureLoader, dictionary: [String : Data?]) -> [String : MTLTexture] {
    var ret: [String : MTLTexture] = [:]
    for (key, val) in dictionary {
        if val == nil { continue }
        let txr = try! loader.newTexture(data: val!, options: [
            MTKTextureLoader.Option.SRGB : false,
            MTKTextureLoader.Option.allocateMipmaps: false,
            MTKTextureLoader.Option.generateMipmaps: false,
        ])
        ret[key] = txr
    }
    return ret
}

/** Loads a texture from data. */
func textureFromData(loader: MTKTextureLoader, data: Data) -> MTLTexture {
    let txr = try! loader.newTexture(data: data, options: [
        MTKTextureLoader.Option.SRGB : false,
        MTKTextureLoader.Option.allocateMipmaps: false,
        MTKTextureLoader.Option.generateMipmaps: false,
    ])
    return txr
}


public extension MTLTexture {
    
    /** Returns a CIImage from this texture. */
    func toCIImage() -> CIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let image = CIImage(mtlTexture: self, options: [.colorSpace: colorSpace])
        return image
    }
    
    
    /** Returns a CGImage from a texture. */
    func toCGImage(size: CGSize? = nil) -> CGImage? {
        guard let ciimage = toCIImage() else { return nil }
        let context = CIContext()
        let rect = CGRect(origin: .zero, size: size ?? ciimage.extent.size)
        return context.createCGImage(ciimage, from: rect)
    }
    
    
    /** Returns a UIImage from this textrue. */
    func toUIImage(size: CGSize? = nil) -> UIImage? {
        guard let cgimage = toCGImage(size: size) else { return nil }
        return UIImage(cgImage: cgimage)
    }
    
    
    /** Returns the image as data from this texture. */
    func toData() -> Data? {
        guard let image = toUIImage() else { return nil }
        return image.pngData()
    }
    
    
    func toBytes() -> UnsafeMutableRawPointer? {
        let rowBytes = self.width * 4
        let ptr = malloc(self.width * self.height * 4)
        
        let region = MTLRegionMake2D(0, 0, self.width, self.height)
        self.getBytes(ptr!, bytesPerRow: rowBytes, from: region, mipmapLevel: 0)
        
        return ptr
    }
    
    
    func toCGImage2() -> CGImage? {
        guard let ptr = toBytes() else { return nil }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawInfo: UInt32 = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: rawInfo)
        
        let textureSize = self.width * self.height * 4
        let rowBytes = self.width * 4
        
        guard let prov = CGDataProvider(dataInfo: nil, data: ptr, size: textureSize, releaseData: { (p, urp, i) in
        }) else { return nil }
        let cgImage = CGImage(width: self.width, height: self.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: rowBytes, space: colorSpace, bitmapInfo: bitmapInfo, provider: prov, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        return cgImage
    }
    
    
}
