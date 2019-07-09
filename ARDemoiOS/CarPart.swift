//
//  CarPart.swift
//  ARDemoiOS
//
//  Created by Mishra, Neeraj Kumar (US - Bengaluru) on 05/07/19.
//  Copyright © 2019 Mishra, Neeraj Kumar (US - Bengaluru). All rights reserved.
//

import Foundation
import ARKit

/// Categorizing Part depending on the type
enum PartType {
    case glass
    case body
    case rim
    case notKnown
}

/// Creating obj
class CarPart {
    var item: SCNNode!
    var type: PartType!
    
    class func getNodeObj(item: SCNNode) -> CarPart {
        let part = CarPart()
        if let name = item.name {
            switch name {
                
            case "Plate_08_003",
                 "door_lf_ok_001",
                 "Plate_08_001",
                 "Group_004",
                 "Group_002",
                 "Group_001",
                 "door_rf_ok_001",
                 "door_lr_ok_001",
                 "door_rr_ok_001",
                 "boot_ok_001",
                 "bonnet_ok_001",
                 "":
                part.item = item
                part.type = .body
            case "3D_Object__32_001","3D_Object__32_003","3D_Object__32_005","3D_Object__32_007":
                part.item = item
                part.type = .rim
            case "fara_lf_001","fara_lf_003","steklo_001","windscre01_001":
                part.item = item
                part.type = .glass
                
            case "WITHOUT_PE_001", "DONT_EDIT_001":
                print(item)
                
            default:
                part.item = item
                part.type = .notKnown
            }
        }
       return part
    }
}
