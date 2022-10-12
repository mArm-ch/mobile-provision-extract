//
//  MainViewController.swift
//  MobileProfileExtract
//
//  Created by David Ansermot on 12.10.22.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet var extractionImageView: NSImageView!
    @IBOutlet var extractionLabel: NSTextField!
    @IBOutlet var extractionView: DragView!
    
    /// View has been loaded
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extractionLabel.isEditable = false
        // Do any additional setup after loading the view.
    }
    
    /// View will appear
    ///
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.view.window?.title = "MobileProvision Extract"
    }
    
    /// The represented object in the view
    ///
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

