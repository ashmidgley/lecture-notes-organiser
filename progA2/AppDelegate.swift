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
    @IBOutlet weak var currentPageNoLabel: NSTextField!
    @IBOutlet weak var goToPageNoField: NSSearchField!
    var pages = 1
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func choosePDF(sender: NSButton) {
        //NSWorkspace.sharedWorkspace().selectFile(nil, inFileViewerRootedAtPath: "/Home")
        let fileChooser = NSOpenPanel();
        fileChooser.title = "Choose a .pdf file";
        fileChooser.showsResizeIndicator = true;
        fileChooser.showsHiddenFiles = false;
        fileChooser.canChooseDirectories = false;
        fileChooser.canCreateDirectories = true;
        fileChooser.allowsMultipleSelection = false;
        fileChooser.allowedFileTypes = ["pdf"];
        
        if(fileChooser.runModal() == NSModalResponseOK) {
            let result = fileChooser.URL
            if(result != nil){
                //let path = result!.path!
                
                let pdf = PDFDocument(URL: result)
                ourPDF.setDocument(pdf)
                pages = pdf.pageCount()
                
                let timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
                timer.fire()
            }
        }else{
            //User clicked on "Cancel"
            return
        }
    }

    @IBAction func nextPage(sender: NSButton) {
        if(ourPDF.canGoToNextPage()){
            ourPDF.goToNextPage(self)
        }
    }
    
    @IBAction func previousPage(sender: NSButton) {
        if(ourPDF.canGoToPreviousPage()){
            ourPDF.goToPreviousPage(self)
        }
    }
    
    @IBAction func zoomIn(sender: NSButton) {
        if(ourPDF.canZoomIn()){
            ourPDF.zoomIn(self)
        }
    }
    
    @IBAction func zoomOut(sender: NSButton) {
        if(ourPDF.canZoomOut()){
            ourPDF.zoomOut(self)
        }
    }
    
    @IBAction func zoomToFit(sender: NSButton) {
        if ourPDF.scaleFactor() > 1.0 {
            while ourPDF.scaleFactor() > 1.0 {
                ourPDF.zoomOut(self)
            }
        }else if ourPDF.scaleFactor() < 1.0 {
            while ourPDF.scaleFactor() < 1.0 {
                ourPDF.zoomIn(self)
            }
        }
    }
    
    @IBAction func choosePage(sender: NSSearchField) {
        let pageNo = Int(goToPageNoField.stringValue)
        if pageNo != nil && pageNo <= pages{
            ourPDF.goToPage(ourPDF.document().pageAtIndex(pageNo!-1))
        }
    }
    
    func updateLabel(){
        currentPageNoLabel.stringValue = "Page \(ourPDF.document().indexForPage(ourPDF.currentPage())+1) of \(pages)"
    }
}

