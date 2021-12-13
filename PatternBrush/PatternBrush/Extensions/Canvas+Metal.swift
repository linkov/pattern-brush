//
//  Canvas+Metal.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/18/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit


/* Returns the library to use for this project. */
internal func getLibrary(device: MTLDevice?) -> MTLLibrary? {
    let framework = Bundle(for: Canvas.self)
    guard let resource = framework.path(forResource: "default", ofType: "metallib") else {
        return nil
    }
    return try? device?.makeLibrary(filepath: resource)
}

/** Builds a render pipeline. */
internal func buildRenderPipeline(device: MTLDevice?, vertProg: MTLFunction?, fragProg: MTLFunction?) -> MTLRenderPipelineState? {
    // Make a descriptor for the pipeline.
    let descriptor = MTLRenderPipelineDescriptor()
    descriptor.vertexFunction = vertProg
    descriptor.fragmentFunction = fragProg
    descriptor.colorAttachments[0].pixelFormat = CANVAS_PIXEL_FORMAT
    descriptor.colorAttachments[0].isBlendingEnabled = true
    descriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperation.add
    descriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperation.add
    descriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactor.sourceAlpha
    descriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactor.one
    descriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
    descriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
    
    let state = try! device?.makeRenderPipelineState(descriptor: descriptor)
    return state
}


/** Builds a sample descriptor for the fragment function. */
internal func buildSampleState(device: MTLDevice?) -> MTLSamplerState? {
    let sd = MTLSamplerDescriptor()
    sd.magFilter = .linear
    sd.minFilter = .nearest
    sd.mipFilter = .linear
    sd.rAddressMode = .clampToZero
    sd.sAddressMode = .clampToZero
    sd.tAddressMode = .clampToZero
    guard let sampleState = device?.makeSamplerState(descriptor: sd) else {
        return nil
    }
    return sampleState
}


/** Builds a depth stencil descriptor for the canvas. */
internal func buildDepthStencilState(device: MTLDevice?) -> MTLDepthStencilState? {
    let depthStencilDesc = MTLDepthStencilDescriptor()
    depthStencilDesc.depthCompareFunction = .always
    depthStencilDesc.isDepthWriteEnabled = false
    
    guard let state = device?.makeDepthStencilState(descriptor: depthStencilDesc) else {
        return nil
    }
    return state
}


/** Creates an empty texture. */
internal func makeEmptyTexture(device: MTLDevice?, width: CGFloat, height: CGFloat, format: MTLPixelFormat = .bgra8Unorm) -> MTLTexture? {
    guard width * height > 0 else { return nil }
    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
        pixelFormat: format,
        width: width >= 8192 ? 8192 : Int(width),
        height: height >= 8192 ? 8192 : Int(height),
        mipmapped: false
    )
    textureDescriptor.usage = [.renderTarget, .shaderRead]
    return device?.makeTexture(descriptor: textureDescriptor)
}
