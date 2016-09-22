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
        let url = NSBundle.mainBundle().URLForResource("lect15", withExtension: "pdf")
        let pdf = PDFDocument(URL: url)
        //let pages: Int = pdf.pageCount()
        //let text: String = pdf.string()
        //let page1 = pdf.pageAtIndex(0)
        ourPDF.setDocument(pdf)
        //print("\(ourPDF.document) pages: \(pages)")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

