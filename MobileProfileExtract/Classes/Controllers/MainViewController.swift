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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extractionLabel.isEditable = false
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.view.window?.title = "MobileProvision Extract"
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

