//
//  DragView.swift
//  MobileProfileExtract
//
//  Created by David Ansermot on 12.10.22.
//

import Cocoa

class DragView: NSView {
    
    private var fileTypeOk: Bool = false
    private var acceptedExtensions: [String] = ["mobileprovision"]
    
    private let backgroundActiveColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
    
    private var isMouseDragging = false {
        didSet { self.updateBackgroundColor() }
    }
    private var isMouseOverTheView = false {
        didSet { self.updateBackgroundColor() }
    }
    private var backgroundColor: NSColor? {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    private lazy var area: NSTrackingArea = makeTrackingArea()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // Drag & Drop
        registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
        self.isMouseDragging = false
        
        // Mouse tracking
        self.isMouseOverTheView = false
    }
    
    
    
    
    // -------------------------------------------------------------------------
    // MARK: - Dragging logic
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.fileTypeOk = checkExtension(drag: sender)
        self.isMouseDragging = true
        return self.fileTypeOk ? .copy : NSDragOperation()
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.isMouseDragging = true
        return self.fileTypeOk ? .copy : NSDragOperation()
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.isMouseDragging = false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let fileURL = sender.draggedFileURL else {
            return false
        }
        
        NSLog("Dragged file : \(fileURL)")
        
        self.decodeCMSfile(fileURL)
        
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
    
    fileprivate func decodeCMSfile(_ fileToDecode: URL) {
        do {
            let profileData = try! Data(contentsOf: fileToDecode)
            let profile = try! ProvisioningProfile.parse(from: profileData)
            
            let tempPath = self.tempPathFor(file: fileToDecode)
            
            Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [
                "-a",
                "TextEdit",
                tempPath
            ])
        }
    }
    
    fileprivate func tempPathFor(file: URL) -> String {
        let directory = NSTemporaryDirectory()
        let path = file.path.components(separatedBy: "/")
        
        if let filename = path.last {
            let parts = filename.components(separatedBy: ".")
            return "\(directory)\(parts.first ?? Date().formatted())-decoded.txt"
        }
        
        return ""
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Mouse management
    
    public override func updateTrackingAreas() {
        removeTrackingArea(self.area)
        self.area = makeTrackingArea()
        addTrackingArea(self.area)
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.isMouseOverTheView = true
    }
    
    override func mouseExited(with event: NSEvent) {
        self.isMouseOverTheView = false
    }
    
    private func makeTrackingArea() -> NSTrackingArea {
        return NSTrackingArea(rect: bounds,
                              options: [.mouseEnteredAndExited, .activeInKeyWindow],
                              owner: self,
                              userInfo: nil)
    }
    
    private func updateBackgroundColor() {
        if self.isMouseDragging && self.isMouseOverTheView && self.fileTypeOk {
            self.backgroundColor = self.backgroundActiveColor
        } else {
            self.backgroundColor = nil
        }
    }
    
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
