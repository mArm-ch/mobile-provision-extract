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
        if let mobileProvision = NSPasteboard.PasteboardType.fileNameType(forPathExtension: "mobileprovision") {
            registerForDraggedTypes([mobileProvision])
        }
        self.isMouseDragging = false
        
        // Mouse tracking
        self.isMouseOverTheView = false
    }
    
    
    
    
    // -------------------------------------------------------------------------
    // MARK: - Dragging logic
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.fileTypeOk = checkExtension(drag: sender)
        self.isMouseDragging = true
        return []
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.isMouseDragging = true
        return self.fileTypeOk ? .copy : .generic
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.isMouseDragging = false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let _ = sender.draggedFileURL else {
            return false
        }
        return true
    }
    
    fileprivate func checkExtension(drag: NSDraggingInfo) -> Bool {
        NSLog("File url : \(drag.draggedFileURL)")
        guard let fileExtension = drag.draggedFileURL?.pathExtension?.lowercased() else {
            return false
        }
        return acceptedExtensions.contains(fileExtension)
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
        if self.isMouseDragging && self.isMouseOverTheView {
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
    var draggedFileURL: NSURL? {
        let filenames = draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [String]
        let path = filenames?.first
        
        return path.map(NSURL.init)
    }
}
