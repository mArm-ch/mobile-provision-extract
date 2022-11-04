//
//  OutputGenerator.swift
//  MobileProfileExtract
//
//  Created by David Ansermot on 04.11.22.
//

import Foundation

protocol OutputGenerator {
    static func buildDecodedFile(with profile: ProvisioningProfile, originalFileURL: URL) -> String
}
