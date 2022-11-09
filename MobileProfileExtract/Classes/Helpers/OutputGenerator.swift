//
//  OutputGenerator.swift
//  MobileProfileExtract
//
//  Created by David Ansermot on 04.11.22.
//

import Foundation

enum OutputGeneratorType: String, CaseIterable {
    case Text = "txt"
    case Xml = "xml"
    case Plist = "plist"
    
    func generator() -> OutputGenerator {
        switch self {
        case .Text:     return TextOutput()
        case .Xml:      return XmlOutput()
        case .Plist:    return PlistOutput()
        }
    }
}

protocol OutputGenerator {
    func buildDecodedFile(with profile: ProvisioningProfile, originalFileURL: URL) -> String
}
