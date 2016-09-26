//
//  AppDelegate.swift
//  progA2
//
//  Created by Ashley Midgley on 9/22/16.
//  Copyright © 2016 Ashley Midgley. All rights reserved.
//

import Cocoa
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var ourPDF: PDFView!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let url = NSBundle.mainBundle().URLForResource("myPDF", withExtension: "pdf")
        //let pages: Int = pdf.pageCount()
        //let text: String = pdf.string()
        //let page1 = pdf.pageAtIndex(0)
        let pdf = PDFDocument(URL: url)
        ourPDF.setDocument(pdf)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func choosePDF(sender: NSButton) {
        NSWorkspace.sharedWorkspace().selectFile(nil, inFileViewerRootedAtPath: "/Home")
        //NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs(files)
        
    }

}

