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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([NSPasteboard.PasteboardType.fileNameType(forPathExtension: ".mobileprovision")])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        fileTypeOk = checkExtension(drag: sender)
        return []
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return fileTypeOk ? .copy : []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let _ = sender.draggedFileURL else {
            return false
        }
        return true
    }
    
    fileprivate func checkExtension(drag: NSDraggingInfo) -> Bool {
        guard let fileExtension = drag.draggedFileURL?.pathExtension?.lowercased() else {
            return false
        }
        return acceptedExtensions.contains(fileExtension)
    }
}

extension NSDraggingInfo {
    var draggedFileURL: NSURL? {
        let filenames = self.draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [String]
        let path = filenames?.first
        
        return path.map(NSURL.init)
    }
}
