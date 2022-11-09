//
//  PlistOutput.swift
//  MobileProfileExtract
//
//  Created by David Ansermot on 04.11.22.
//
//  Ref : https://wiki.cmdreporter.com/support/solutions/articles/12000060393-full-example-plist
//

import Cocoa

class PlistOutput: OutputGenerator {
    
    /// Build the decoded file output
    ///
    /// - Parameter profile: The decoded provisioning profile
    /// - Parameter originalFileURL: The url to the original file
    /// - Returns: `String`
    ///
    public func buildDecodedFile(with profile: ProvisioningProfile, originalFileURL: URL) -> String {
        var output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        output = "\(output)<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
        output = "\(output)<plist version=\"1.0\">\n"
        output = "\(output)<dict>\n"
        
        // Header
        //
        output = "\(output)\t<key>header</key>\n"
        output = "\(output)\t<dict>\n"
        output = "\(output)\t\t<key>generator</key>\n"
        output = "\(output)\t\t<string>MobileProfileExtract</string>\n"
        
        if let version  = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            output = "\(output)\t\t<key>version</key>\n"
            output = "\(output)\t\t<string>\(version)</string>\n"
        }
        
        output = "\(output)\t\t<key>author</key>\n"
        output = "\(output)\t\t<string>David Ansermot</string>\n"
        
        output = "\(output)\t\t<key>github</key>\n"
        output = "\(output)\t\t<string>https://github.com/mArm-ch/mobile-provision-extract</string>\n"
        
        output = "\(output)\t\t<key>originalFile</key>\n"
        output = "\(output)\t\t<string>\(originalFileURL.path)</string>\n"
        
        output = "\(output)\t</dict>\n"
        
        
        // Body
        //
        output = "\(output)\t<key>profile</key>\n"
        output = "\(output)\t<dict>\n"
        
        output = "\(output)\t\t<key>appIdName</key>\n"
        output = "\(output)\t\t<string>\(profile.appIdName)</string>\n"
        
        output = "\(output)\t\t<key>applicationIdentifierPrefixes</key>\n"
        output = "\(output)\t\t<array>\n"
        for prefix in profile.applicationIdentifierPrefixs {
            output = "\(output)\t\t\t<string>\(prefix)</string>\n"
        }
        output = "\(output)\t\t</array>\n"
        
        output = "\(output)\t\t<key>creationDate</key>\n"
        output = "\(output)\t\t<string>\(profile.creationDate)</string>\n"
        
        output = "\(output)\t\t<key>platforms</key>\n"
        output = "\(output)\t\t<array>\n"
        for plateform in profile.platforms {
            output = "\(output)\t\t\t<string>\(plateform)</string>\n"
        }
        output = "\(output)\t\t</array>\n"
        
        output = "\(output)\t\t<key>developerCertificates</key>\n"
        output = "\(output)\t\t<array>\n"
        for certificate in profile.developerCertificates {
            output = "\(output)\t\t\t<string>\(certificate.certificate?.commonName ?? "Unknown")</string>\n"
        }
        output = "\(output)\t\t</array>\n"
        
        output = "\(output)\t\t<key>entitlements</key>\n"
        output = "\(output)\t\t<array>\n"
        for entitlement in profile.entitlements {
            let value = entitlement.value
            output = "\(output)\t\t\t<dict>\n"
            output = "\(output)\t\t\t\t<key>key</key>\n"
            output = "\(output)\t\t\t\t<string>\(entitlement.key)</string>\n"
            output = "\(output)\t\t\t\t<key>value</key>\n"
            output = "\(output)\t\t\t\t<string>\(value)</string>\n"
            output = "\(output)\t\t\t</dict>\n"
        }
        output = "\(output)\t\t</array>\n"
        
        output = "\(output)\t\t<key>expirationDate</key>\n"
        output = "\(output)\t\t<string>\(profile.expirationDate)</string>\n"
        
        output = "\(output)\t\t<key>name</key>\n"
        output = "\(output)\t\t<string>\(profile.name)</string>\n"
        
        output = "\(output)\t\t<key>provisionedDevices</key>\n"
        output = "\(output)\t\t<array>\n"
        if let devices = profile.provisionedDevices {
            for device in devices {
                output = "\(output)\t\t\t<string>\(device)</string>\n"
            }
        }
        output = "\(output)\t\t</array>\n"
        
        output = "\(output)\t\t<key>teamIdentifiers</key>\n"
        output = "\(output)\t\t<array>\n"
        for identifier in profile.teamIdentifiers {
            output = "\(output)\t\t\t<string>\(identifier)</string>\n"
        }
        output = "\(output)\t\t</array>\n"
        
        output = "\(output)\t\t<key>teamName</key>\n"
        output = "\(output)\t\t<string>\(profile.teamName)</string>\n"
        
        output = "\(output)\t\t<key>timeToLive</key>\n"
        output = "\(output)\t\t<string>\(profile.timeToLive)</string>\n"
        
        output = "\(output)\t\t<key>UUID</key>\n"
        output = "\(output)\t\t<string>\(profile.uuid)</string>\n"
        
        output = "\(output)\t\t<key>version</key>\n"
        output = "\(output)\t\t<string>\(profile.version)</string>\n"
        
        output = "\(output)\t</dict>\n"

        output = "\(output)</dict>\n"
        
        output = "\(output)</plist>\n"
        return output
    }
}
