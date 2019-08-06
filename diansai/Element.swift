//
//  Element.swift
//  diansai
//
//  Created by JiaCheng on 2019/8/2.
//  Copyright © 2019 JiaCheng. All rights reserved.
//

import Foundation

enum SysType: String {
    case system
    case custom
}

enum Charactistic: String {
    case read
    case write
    case readAndWrite
}

//class Element: NSObject, NSSecureCoding {
//    static var supportsSecureCoding: Bool {
//        return true
//    }
//
//    func encode(with coder: NSCoder) {
//        coder.encode(sysType, forKey: "sysType")
//        coder.encode(property, forKey: "property")
//        coder.encode(displayName, forKey: "displayName")
//        coder.encode(sendPrefix, forKey: "sendPrefix")
//        coder.encode(receivePrefix, forKey: "receivePrefix")
//    }
//
//    required convenience init?(coder: NSCoder) {
////        self.sysType = (coder.decodeObject(forKey: "sysType") as! SysType)
////        self.property = (coder.decodeObject(forKey: "property") as! Charactistic)
//        let displayName = (coder.decodeObject(forKey: "displayName"))
//        let sendPrefix = (coder.decodeObject(forKey: "sendPrefix") as? String)
//        let receivePrefix = (coder.decodeObject(forKey: "receivePrefix") as! String)
//
//        self.init(sysType: .system, property: .read, displayName: "displayName", sendPrefix: sendPrefix, receivePrefix: receivePrefix)
//    }
//
//    var sysType: SysType!
//    var property: Charactistic!
//    var displayName: String!
//    var sendPrefix: String?
//    var receivePrefix: String!
//
//    init(sysType: SysType, property: Charactistic, displayName: String, sendPrefix: String?, receivePrefix: String) {
//        self.sysType = sysType
//        self.property = property
//        self.displayName = displayName
//        self.sendPrefix = sendPrefix
//        self.receivePrefix = receivePrefix
//    }
//
//    func setting(sysType: SysType, property: Charactistic, displayName: String, sendPrefix: String?, receivePrefix: String) {
//        self.sysType = sysType
//        self.property = property
//        self.displayName = displayName
//        self.sendPrefix = sendPrefix
//        self.receivePrefix = receivePrefix
//    }
//}

struct Element {
    let sysType: SysType!
    let property: Charactistic!
    let displayName: String!
    let sendPrefix: String?
    let receivePrefix: String!
    
    var propertyListRepresentation : [String: String] {
        return ["sysType" : sysType.rawValue, "property" : property.rawValue, "displayName": displayName, "sendPrefix": sendPrefix ?? "", "receivePrefix": receivePrefix]
    }
    
    init(sysType: SysType?, property: Charactistic?, displayName: String?, sendPrefix: String?, receivePrefix: String?) {
        self.sysType = sysType
        self.property = property
        self.displayName = displayName
        self.sendPrefix = sendPrefix == "" ? nil : sendPrefix
        self.receivePrefix = receivePrefix
    }
}
