// MIT License
//
// Copyright (c) 2022 David Ansermot
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
    private let backgroundActiveColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
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
            if let backgroundColor = backgroundColor { self.layer?.backgroundColor = backgroundColor.cgColor }
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
        
        let outputType = self.askForOutputType(forFile: fileURL)
        
        if !self.decodeCMSfile(fileURL, output: outputType) {
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
    
    fileprivate func askForOutputType(forFile: URL) -> OutputGeneratorType {
        
        let alert = NSAlert();
        alert.messageText = "Extraction format"
        alert.informativeText = "Please, choose the format of the output file."
        
        alert.addButton(withTitle: "Text")
        alert.addButton(withTitle: "XML")
        alert.addButton(withTitle: "Plist")
        
        let response = alert.runModal()
        
        switch response {
        case .alertFirstButtonReturn:   return .Text
        case .alertSecondButtonReturn:  return .Xml
        case .alertThirdButtonReturn:   return .Plist
        default:                        return .Text
        }
    }
    
    /// Decode the mobile provisioning profile
    ///
    /// - Important: `@discardableResult`, `fileprivate`
    ///
    /// - Parameter fileToDecode: The URL to the file to decode
    /// - Returns: `Bool`
    ///
    @discardableResult
    fileprivate func decodeCMSfile(_ fileToDecode: URL, output: OutputGeneratorType) -> Bool {
        do {
            let profileData = try Data(contentsOf: fileToDecode)
            let profile = try ProvisioningProfile.parse(from: profileData)
            let tempPath = self.tempPathFor(file: fileToDecode, output: output)
            
            if let tempPathURL = URL(string: "file://\(tempPath)") {
                var fileContents = output.generator().buildDecodedFile(with: profile,
                                                                       originalFileURL: fileToDecode)
                
                // Try to open the file in TextEdit
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
    fileprivate func tempPathFor(file: URL, output: OutputGeneratorType) -> String {
        let directory = NSTemporaryDirectory()
        let path = file.path.components(separatedBy: "/")
        
        if let filename = path.last {
            let parts = filename.components(separatedBy: ".")
            return "\(directory)\(parts.first ?? Date().formatted())-decoded.\(output.rawValue)"
        }
        return ""
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
            self.backgroundColor = self.backgroundInactiveColor
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
