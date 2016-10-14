//
//  AppDelegate.swift
//  progA2
//
//  Created by Ashley Midgley on 9/22/16.
//  Copyright © 2016 Ashley Midgley. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    //Outlets for menu items
    
    //File
    @IBOutlet weak var openMenuItem: NSMenuItem!
    @IBOutlet weak var aboutMenuItem: NSMenuItem!
    
    //Navigation
    @IBOutlet weak var prevDocMenuItem: NSMenuItem!
    @IBOutlet weak var nextDocMenuItem: NSMenuItem!
    @IBOutlet weak var prevPageMenuItem: NSMenuItem!
    @IBOutlet weak var nextPageMenuItem: NSMenuItem!
    
    //Tools
    @IBOutlet weak var zoomInMenuItem: NSMenuItem!
    @IBOutlet weak var zoomOutMenuItem: NSMenuItem!
    @IBOutlet weak var zoomToFitMenuItem: NSMenuItem!
    @IBOutlet weak var addBookmarkMenuItem: NSMenuItem!
    
    var viewerWindows = [PDFViewerWindowController]()
   
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        newPDFViewerWindow(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func newPDFViewerWindow(sender: AnyObject) {
        let pdfViewerWindow = PDFViewerWindowController()
        viewerWindows.append(pdfViewerWindow)
        pdfViewerWindow.showWindow(self)
    }
}