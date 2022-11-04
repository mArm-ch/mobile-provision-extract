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
}

protocol OutputGenerator {
    static func buildDecodedFile(with profile: ProvisioningProfile, originalFileURL: URL) -> String
}
