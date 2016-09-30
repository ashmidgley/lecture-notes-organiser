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
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    
    @IBOutlet weak var headerLabel: NSTextField!
    @IBOutlet weak var currentDocLabel: NSTextField!
    
    @IBOutlet weak var currentPageNoLabel: NSTextField!
    @IBOutlet weak var goToPageNoField: NSTextField!
    
    @IBOutlet weak var prevDocButton: NSButton!
    @IBOutlet weak var nextDocButton: NSButton!

    @IBOutlet weak var textSearchField: NSSearchField!
    
    var pages = 0
    var docs = [NSURL]()
    var docIndex = 0
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        prevDocButton.hidden = true
        nextDocButton.hidden = true
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
        fileChooser.allowsMultipleSelection = true;
        fileChooser.allowedFileTypes = ["pdf"];
        
        if(fileChooser.runModal() == NSModalResponseOK) {
            self.docs = fileChooser.URLs
            //let path = result!.path!
            titleLabel.hidden = true
            subtitleLabel.hidden = true
            setPDF(docs[0])
            headerLabel.stringValue = "Current Document:"
            if(docs.count > 1){
                prevDocButton.hidden = false
                nextDocButton.hidden = false
            }
        }else{
            //User clicked on "Cancel"
            return
        }
    }
    
    func setPDF(url: NSURL){
        let pdf = PDFDocument(URL: url)
        ourPDF.setDocument(pdf)
        pages = pdf.pageCount()
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateLabels"), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func updateLabels(){
        currentPageNoLabel.stringValue = "Page \(ourPDF.document().indexForPage(ourPDF.currentPage())+1) of \(pages)"
        let pathC = docs[docIndex].pathComponents!
        currentDocLabel.stringValue = "\(pathC[pathC.count-1])"
        
    }

    @IBAction func previousPage(sender: NSButton) {
        if(ourPDF.canGoToPreviousPage()){
            ourPDF.goToPreviousPage(self)
        }
    }
    
    @IBAction func nextPage(sender: NSButton) {
        if(ourPDF.canGoToNextPage()){
            ourPDF.goToNextPage(self)
        }
    }
    
    @IBAction func previousDocument(sender: NSButton) {
        if !docs.isEmpty {
            if(docIndex != 0){
                docIndex -= 1
                setPDF(docs[docIndex])
            }
        }
    }
    
    @IBAction func nextDocument(sender: NSButton) {
        if !docs.isEmpty {
            if(docIndex != docs.count-1){
                docIndex += 1
                setPDF(docs[docIndex])
            }
        }
    }
    
    @IBAction func zoomOut(sender: NSButton) {
        if(ourPDF.canZoomOut()){
            ourPDF.zoomOut(self)
        }
    }
    
    @IBAction func zoomIn(sender: NSButton) {
        if(ourPDF.canZoomIn()){
            ourPDF.zoomIn(self)
        }
    }
    
    @IBAction func zoomToFit(sender: NSButton) {
        ourPDF.setScaleFactor(CGFloat(1.0))
    }
    
    @IBAction func goToPage(sender: NSButton) {
        let pageNo = Int(goToPageNoField.stringValue)
        if pageNo != nil && pageNo <= pages{
            ourPDF.goToPage(ourPDF.document().pageAtIndex(pageNo!-1))
            goToPageNoField.stringValue.removeAll()
        }
    }
    
    @IBAction func textSearch(sender: NSSearchField) {
        if textSearchField.stringValue != "" {
            let results = ourPDF.document().findString(textSearchField.stringValue, withOptions: 0)
    
            if !results.isEmpty {
                ourPDF.goToSelection(results[0] as! PDFSelection)
                ourPDF.setHighlightedSelections(results)
            }
        }
    }
    
}

