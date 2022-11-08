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
        
        output = "\(output)\n"
        output = "\(output)\n* Original file : \n* \(originalFileURL.path)"
        output = "\(output)\n*"
        if let version  = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            output = "\(output)\n*\n* Generated with 'MobileProfileExtract \(version)' by David Ansermot"
            output = "\(output)\n* Github : https://github.com/mArm-ch/mobile-provision-extract"
            output = "\(output)\n*"
            
        }
        output = "\(output)\n* ----------------------------------------------------------- *"
        
        output = "\(output)\n\nAppIDName: \(profile.appIdName)"
        output = "\(output)\n\nApplicationIdentifierPrefixs :\n"
        for prefix in profile.applicationIdentifierPrefixs {
            output = "\(output)- \(prefix)\n"
        }
        
        output = "\(output)\n\nCreationDate: \(profile.creationDate)"
        
        output = "\(output)\n\nPlatforms:\n"
        for plateform in profile.platforms {
            output = "\(output)- \(plateform)\n"
        }
        
        output = "\(output)\nDeveloperCertificates:\n"
        for certificate in profile.developerCertificates {
            output = "\(output)- \(certificate.certificate?.commonName ?? "Unknown")\n"
        }
        
        output = "\(output)\nEntitlements:\n"
        for entitlement in profile.entitlements {
            // TODO: Extract clean value
            let value = entitlement.value
            output = "\(output)- \(entitlement.key) => \(value)\n"
        }
        
        output = "\(output)\n\nExpirationDate: \(profile.expirationDate)"
        output = "\(output)\n\nName: \(profile.name)"
        
        output = "\(output)\n\nProvisionedDevices:"
        if let devices = profile.provisionedDevices {
            output = "\(output)\n"
            for device in devices {
                output = "\(output)- \(device)\n"
            }
        } else {
            output = "\(output) None\n"
        }
        
        output = "\(output)\nTeamIdentifiers:\n"
        for identifier in profile.teamIdentifiers {
            output = "\(output)- \(identifier)\n"
        }
        
        
        output = "\(output)\n\nTeamName: \(profile.teamName)"
        output = "\(output)\n\nTimeToLive: \(profile.timeToLive)"
        output = "\(output)\n\nUUID: \(profile.uuid)"
        output = "\(output)\n\nVersion: \(profile.version)"
        
        output = "\(output)</dict>"
        return output
    }
}
