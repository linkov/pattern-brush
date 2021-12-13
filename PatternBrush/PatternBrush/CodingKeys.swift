//
//  CodingKeys.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/28/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit


internal enum LayerCodingKeys: CodingKey {
    case elements
    case isLocked
    case isHidden
}

internal enum ElementCodingKeys: CodingKey {
    case vertices
    case brushName
    case start
    case isFreeHand
}

internal enum ToolCodingKeys: CodingKey {
    case name
}

internal enum CanvasCodingKeys: CodingKey {
    case canvasLayers
    case force
    case registeredTextures
    case registeredBrushes
    case currentBrush
    case maximumForce
    case stylusOnly
    case canvasColor
    case currentLayer
}
