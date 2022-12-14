//
//  XmlOutput.swift
//  MobileProfileExtract
//
//  Created by David Ansermot on 04.11.22.
//

import Cocoa

class XmlOutput: OutputGenerator {
    
    /// Build the decoded file output
    ///
    /// - Parameter profile: The decoded provisioning profile
    /// - Parameter originalFileURL: The url to the original file
    /// - Returns: `String`
    ///
    public func buildDecodedFile(with profile: ProvisioningProfile, originalFileURL: URL) -> String {
        
        // File header
        var output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        output = "\(output)<head>\n"
        output = "\(output)\t<generator>MobileProfileExtract</generator>\n"
        if let version  = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            output = "\(output)\t<version>\(version)</version>\n"
        }
        output = "\(output)\t<author>David Ansermot</author>\n"
        output = "\(output)\t<github>https://github.com/mArm-ch/mobile-provision-extract</github>\n"
        output = "\(output)\t<originalFile>\(originalFileURL.path)</originalFile>\n"
        output = "\(output)</head>\n"
        
        // File body
        output = "\(output)<profile>\n"
        output = "\(output)\t<appIdName>\(profile.appIdName)</appIdName>\n"
        output = "\(output)\t<applicationIdentifierPrefixs>\n"
        for prefix in profile.applicationIdentifierPrefixs {
            output = "\(output)\t\t<prefix>\(prefix)</prefix>\n"
        }
        output = "\(output)\t</applicationIdentifierPrefixs>\n"
        output = "\(output)\t<creationDate>\(profile.creationDate)</creationDate>\n"
        
        output = "\(output)\t<platforms>\n"
        for plateform in profile.platforms {
            output = "\(output)\t\t<platform>\(plateform)</platform>\n"
        }
        output = "\(output)\t</platforms>\n"
        
        output = "\(output)\t<developerCertificates>\n"
        for certificate in profile.developerCertificates {
            output = "\(output)\t\t<certificate>\(certificate.certificate?.commonName ?? "Unknown")</certificate>\n"
        }
        output = "\(output)\t</developerCertificates>\n"
        
        output = "\(output)\t<entitlements>\n"
        for entitlement in profile.entitlements {
            // TODO: Extract clean value
            let value = entitlement.value
            output = "\(output)\t\t<entitlement>\n"
            output = "\(output)\t\t\t<key>\(entitlement.key)</key>\n"
            output = "\(output)\t\t\t<value>\(value)</value>\n"
            output = "\(output)\t\t</entitlement>\n"
        }
        output = "\(output)\t</entitlements>\n"
        
        output = "\(output)\t<expirationDate>\(profile.expirationDate)</expirationDate>\n"
        output = "\(output)\t<name>\(profile.name)</name>\n"
        
        output = "\(output)\t<provisionedDevices>\n"
        if let devices = profile.provisionedDevices {
            for device in devices {
                output = "\(output)\t\t<device>\(device)</device>\n"
            }
        }
        output = "\(output)\t<provisionedDevices>\n"
        
        output = "\(output)\t<teamIdentifiers>\n"
        for identifier in profile.teamIdentifiers {
            output = "\(output)\t\t<identifier>\(identifier)</identifier>\n"
        }
        output = "\(output)\t</teamIdentifiers>\n"
        
        output = "\(output)\t<teamName>\(profile.teamName)</teamName>\n"
        output = "\(output)\t<timeToLive>\(profile.timeToLive)</timeToLive>\n"
        output = "\(output)\t<UUID>\(profile.uuid)</UUID>\n"
        output = "\(output)\t<version>\(profile.version)</version>\n"
        
        output = "\(output)</profile>\n"
        return output
    }
}
