//
//  DragView.swift
//  MobileProfileExtract
//
//  Created by David Ansermot on 12.10.22.
//

import Cocoa

/// Represent a view that supports drag & drop
///
class DragView: NSView {
    
    /// Tells if the dragged file type is accepted
    private var fileTypeOk: Bool = false
    /// List of accepted file extentions
    private var acceptedExtensions: [String] = ["mobileprovision"]
    
    /// The background color when drag&drop is active on the view
    private let backgroundActiveColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
    /// The background color when drag&drop is not active on the view
    private let backgroundInactiveColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
    
    /// Flag to know if mouse is dragging a file
    private var isMouseDragging = false {
        didSet { self.updateBackgroundColor() }
    }
    /// Flag to know if mouse is hover the drag&drop view
    private var isMouseOverTheView = false {
        didSet { self.updateBackgroundColor() }
    }
    /// The current background
    private var backgroundColor: NSColor? {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    /// The mouse tracking area
    private lazy var area: NSTrackingArea = makeTrackingArea()
    
    
    
    // -------------------------------------------------------------------------
    // MARK: - View lifecycle
    
    /// Required initialiser
    ///
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.backgroundColor = backgroundInactiveColor
        
        // Drag & Drop
        registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
        self.isMouseDragging = false
        
        // Mouse tracking
        self.isMouseOverTheView = false
    }
    
    
    
    // -------------------------------------------------------------------------
    // MARK: - Dragging logic
    
    /// Dragging begun, check for filetype
    ///
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.fileTypeOk = checkExtension(drag: sender)
        self.isMouseDragging = true
        return self.fileTypeOk ? .copy : NSDragOperation()
    }
    
    /// Dragging updated, check also filetype
    ///
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.isMouseDragging = true
        return self.fileTypeOk ? .copy : NSDragOperation()
    }
    
    /// Dragging ended
    ///
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.isMouseDragging = false
    }
    
    /// Performe the decode operation
    ///
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let fileURL = sender.draggedFileURL else { return false }
        if !self.decodeCMSfile(fileURL) {
            // TODO: Display error alert
        }
        return true
    }
    
    /// Check if the extension is allowed
    ///
    /// - Important: `fileprivate`
    ///
    /// - Parameter drag: The dragging infos
    /// - Returns: `Bool`
    ///
    fileprivate func checkExtension(drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = board[0] as? String else {
            return false
        }
        let suffix = URL(fileURLWithPath: path).pathExtension
        for ext in self.acceptedExtensions {
            if ext.lowercased() == suffix {
                return true
            }
        }
        return false
    }
    
    
    
    // -------------------------------------------------------------------------
    // MARK: - Data extraction related
    
    /// Decode the mobile provisioning profile
    ///
    /// - Important: `@discardableResult`, `fileprivate`
    ///
    /// - Parameter fileToDecode: The URL to the file to decode
    /// - Returns: `Bool`
    ///
    @discardableResult
    fileprivate func decodeCMSfile(_ fileToDecode: URL) -> Bool {
        do {
            let profileData = try Data(contentsOf: fileToDecode)
            let profile = try ProvisioningProfile.parse(from: profileData)
            let tempPath = self.tempPathFor(file: fileToDecode)
            
            if let tempPathURL = URL(string: "file://\(tempPath)") {
                let fileContents = self.buildDecodedFile(with: profile)
                do {
                    try fileContents.write(to: tempPathURL, atomically: true, encoding: .utf8)
                    Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [
                        "-a",
                        "TextEdit",
                        tempPath
                    ])
                    return true
                } catch {
                    print(error.localizedDescription)
                    // TODO: Display error alert
                }
            } else {
                // TODO: Display error message
            }
        } catch {
            // TODO: Display error alert
        }
        return false
    }
    
    /// Returns the temporary path for a file to decode
    ///
    /// - Important: `fileprivate`
    ///
    /// - Parameter file: The URL to the file to generate the temp path
    /// - Returns: `String`
    ///
    fileprivate func tempPathFor(file: URL) -> String {
        let directory = NSTemporaryDirectory()
        let path = file.path.components(separatedBy: "/")
        
        if let filename = path.last {
            let parts = filename.components(separatedBy: ".")
            return "\(directory)\(parts.first ?? Date().formatted())-decoded.txt"
        }
        return ""
    }
    
    /// Build the decoded file output
    ///
    /// - Important: `fileprivate`
    ///
    /// - Parameter profile: The decoded provisioning profile
    /// - Returns: `String`
    ///
    fileprivate func buildDecodedFile(with profile: ProvisioningProfile) -> String {
        var output = "AppIDName: \(profile.appIdName)"
        output = "\(output)\n\nApplicationIdentifierPrefixs :\n\(profile.applicationIdentifierPrefixs)"
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
        return output
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Mouse management
    
    /// Update the tracking of the mouse
    ///
    public override func updateTrackingAreas() {
        removeTrackingArea(self.area)
        self.area = makeTrackingArea()
        addTrackingArea(self.area)
    }
    
    /// Mouse entered zone, update flag
    ///
    override func mouseEntered(with event: NSEvent) {
        self.isMouseOverTheView = true
    }
    
    /// Mouse leaved zone, update flag
    ///
    override func mouseExited(with event: NSEvent) {
        self.isMouseOverTheView = false
    }
    
    /// Gets the correct tracking area
    ///
    /// - Important: `private`
    ///
    private func makeTrackingArea() -> NSTrackingArea {
        return NSTrackingArea(rect: bounds,
                              options: [.mouseEnteredAndExited, .activeInKeyWindow],
                              owner: self,
                              userInfo: nil)
    }
    
    /// Update the background color
    ///
    /// - Important: `private`
    ///
    private func updateBackgroundColor() {
        if self.isMouseDragging && self.isMouseOverTheView && self.fileTypeOk {
            self.backgroundColor = self.backgroundActiveColor
        } else {
            self.backgroundColor = nil
        }
    }
    
    /// Draw the view
    ///
    open override func draw(_ dirtyRect: NSRect) {
        if let backgroundColor = backgroundColor {
            backgroundColor.setFill()
            dirtyRect.fill()
        } else {
            super.draw(dirtyRect)
        }
        
        self.layer?.cornerRadius = 8.0
        self.layer?.borderWidth = 1.0
        self.layer?.borderColor = NSColor.darkGray.cgColor
    }
}


extension NSDraggingInfo {
    var draggedFileURL: URL? {
        guard let board = self.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = board[0] as? String else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }
}
