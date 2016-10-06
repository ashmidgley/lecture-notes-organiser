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
    var currPage = 1
    var pages = 0
    var docs = [NSURL]()
    var docIndex = 0
    var loaded = false
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    
    @IBOutlet weak var headerLabel: NSTextField!
    @IBOutlet weak var currentDocLabel: NSTextField!
    
    @IBOutlet weak var displaySelectedButton: NSPopUpButton!
    @IBOutlet weak var thumbnailView: PDFThumbnailView!
    
    @IBOutlet weak var notesField: NSTextField!
    var notes = [String]()
    @IBOutlet weak var bookmarksView: NSScrollView!
    var bookmarks = [NSButton]()
    var bookmarkStr = [[String]]()
    
    @IBOutlet weak var currentPageNoLabel: NSTextField!
    @IBOutlet weak var goToPageNoField: NSTextField!
    
    @IBOutlet weak var prevDocButton: NSButton!
    @IBOutlet weak var nextDocButton: NSButton!

    @IBOutlet weak var textSearchField: NSSearchField!
    @IBOutlet weak var casesLabel: NSTextField!
    @IBOutlet weak var searchCasesStepper: NSStepper!
    var currStepperVal = 0
    var results = [AnyObject]()
    let highlightColor = NSColor(red: 1, green: 1, blue: 0, alpha: 1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        thumbnailView.setPDFView(ourPDF)
        prevDocButton.hidden = true
        nextDocButton.hidden = true
        searchCasesStepper.hidden = true
        notesField.hidden = true
        bookmarksView.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePageNumber), name: PDFViewPageChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateDocument), name: PDFViewDocumentChangedNotification, object: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func updatePageNumber() {
        //notes field
        if currPage != ourPDF.document().indexForPage(ourPDF.currentPage())+1 && !notes.isEmpty{
            notes[currPage-1] = notesField.stringValue
            notesField.stringValue = notes[ourPDF.document().indexForPage(ourPDF.currentPage())]
            notesField.updateLayer()
        }
        
        //page elements
        self.currPage = ourPDF.document().indexForPage(ourPDF.currentPage())+1
        currentPageNoLabel.stringValue = "Page \(self.currPage) of \(self.pages)"
    }
    
    func updateDocument(){
        let pathC = docs[docIndex].pathComponents!
        currentDocLabel.stringValue = "\(pathC[pathC.count-1])"
        self.pages = ourPDF.document().pageCount()
        self.currPage = 1
        currentPageNoLabel.stringValue = "Page \(self.currPage) of \(self.pages)"
        
        //print("Saving")
        //NSKeyedArchiver.archiveRootObject(notes, toFile: "savedNotes.bin")
        
        notes = [String](count: self.pages, repeatedValue: "")
        notesField.stringValue = ""
        notesField.updateLayer()
    }
    
    @IBAction func choosePDF(sender: AnyObject) {
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
            
            self.loaded = true
            titleLabel.hidden = true
            subtitleLabel.hidden = true
            
            //update bookmarks
            for b in bookmarks {
                b.removeFromSuperview()
            }
            bookmarks.removeAll()
            bookmarkStr.removeAll()
            bookmarksView.updateLayer()
            bookmarkStr = Array(count: docs.count, repeatedValue: Array(count: 1000, repeatedValue: ""))
            
            setPDF(docs[0])
            
            self.pages = ourPDF.document().pageCount()
            notes = [String](count: self.pages, repeatedValue: "")
            notesField.updateLayer()
            
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
    }

    @IBAction func previousPage(sender: AnyObject) {
        if(ourPDF.canGoToPreviousPage()){
            ourPDF.goToPreviousPage(self)
        }
    }
    
    @IBAction func nextPage(sender: AnyObject) {
        if(ourPDF.canGoToNextPage()){
            ourPDF.goToNextPage(self)
        }
    }
    
    @IBAction func previousDocument(sender: AnyObject) {
        if !docs.isEmpty {
            if(docIndex != 0){
                docIndex -= 1
                setPDF(docs[docIndex])
            }
        }
    }
    
    @IBAction func nextDocument(sender: AnyObject) {
        if !docs.isEmpty {
            if(docIndex != docs.count-1){
                docIndex += 1
                setPDF(docs[docIndex])
            }
        }
    }
    
    @IBAction func zoomOut(sender: AnyObject) {
        if(ourPDF.canZoomOut()){
            ourPDF.zoomOut(self)
        }
    }
    
    @IBAction func zoomIn(sender: AnyObject) {
        if(ourPDF.canZoomIn()){
            ourPDF.zoomIn(self)
        }
    }
    
    @IBAction func zoomToFit(sender: AnyObject) {
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
        if loaded {
            if textSearchField.stringValue != "" {
                self.results = ourPDF.document().findString(textSearchField.stringValue, withOptions: 1)
                if !results.isEmpty {
                    casesLabel.hidden = false
                    searchCasesStepper.hidden = false
                    for s in results {
                        s.setColor(highlightColor)
                    }
                    ourPDF.setHighlightedSelections(results)
                    ourPDF.goToSelection(results[0] as! PDFSelection)
                    casesLabel.stringValue = "Case \(currStepperVal+1) of \(results.count)"
                }
            }else{
                searchCasesStepper.hidden = true
                casesLabel.stringValue.removeAll()
                ourPDF.setHighlightedSelections(nil)
            }
        }
    }
    
    @IBAction func changeSearchCase(sender: NSStepper) {
        let stepVal = searchCasesStepper.intValue
        let cStepVal = Int32(currStepperVal)
        if stepVal < cStepVal && currStepperVal != 0{
            //moving backwards
            currStepperVal -= 1
            ourPDF.goToSelection(results[currStepperVal] as! PDFSelection)
        }else if stepVal > cStepVal && currStepperVal != results.count-1{
            //moving upwards
            currStepperVal += 1
            ourPDF.goToSelection(results[currStepperVal] as! PDFSelection)
        }
    }

    @IBAction func addBookmark(sender: AnyObject) {
        if loaded {
            let bookStr = "\(currentDocLabel.stringValue) - Page \(self.currPage)"
            if !bookmarkStr[docIndex].contains(bookStr) {
                let fieldRect = NSRect(x: 5, y: 15*(2*bookmarks.count), width: 150, height: 30)
                let bookmark = NSButton(frame: fieldRect)
                bookmark.title = bookStr
                bookmarkStr[docIndex][currPage-1] = bookStr
                bookmarks.append(bookmark)
                bookmark.action = #selector(self.jumpToPage)
            
                for b in bookmarks {
                    bookmarksView.addSubview(b)
                }
                bookmarksView.updateLayer()
            }
        }
    }

    func jumpToPage(sender: NSButton) {
        let bookmark = sender.title
        var docI = 0
        var pageNo = 0
        for r in 0..<bookmarkStr.count {
            for c in 0..<bookmarkStr[r].count {
                if bookmarkStr[r][c] == bookmark {
                    docI = r
                    pageNo = c
                    break
                }
            }
        }
        
        self.docIndex = docI
        self.currPage = pageNo
        setPDF(self.docs[docI])
        ourPDF.goToPage(ourPDF.document().pageAtIndex(pageNo))
    }
    
    @IBAction func displayOptionSelected(sender: NSPopUpButton) {
        let curr = displaySelectedButton.selectedItem?.title
        if curr == "Thumbnail" {
            thumbnailView.hidden = false
            bookmarksView.hidden = true
            notesField.hidden = true
        }else if curr == "Bookmarks" {
            thumbnailView.hidden = true
            bookmarksView.hidden = false
            notesField.hidden = true
        }else{
            thumbnailView.hidden = true
            bookmarksView.hidden = true
            notesField.hidden = false
        }
    }
    
    @IBAction func aboutProgram(sender: AnyObject) {
        let about = NSAlert()
        about.messageText = "About the program"
        about.informativeText = "This Lecture notes organiser was created by Ash Midgley.\n\nThe application is designed to open and manipulate PDF documents in a user friendly manner.\n"
        about.alertStyle = NSAlertStyle.InformationalAlertStyle
        about.addButtonWithTitle("Close")
        
        if about.runModal() == NSAlertFirstButtonReturn {
            return
        }
    }
    
    /*
    @IBAction func addAnnotation(sender: NSButton) {
        if loaded {
            let annotation = PDFAnnotationText()
            let rect = NSRect(x: 5, y: 5, width: 40, height: 40)
            annotation.setShouldDisplay(true)
            annotation.setBounds(rect)
            ourPDF.currentPage().addAnnotation(annotation)
        }
    }
    
    @IBAction func runHelp(sender: AnyObject) {
        let f1 = NSAlert()
        f1.messageText = "Help"
        f1.informativeText = "Welcome to help!\nWe will step through each tool that the user can use in the application."
        f1.alertStyle = NSAlertStyle.WarningAlertStyle
        f1.addButtonWithTitle("Done")
        f1.addButtonWithTitle("Close")
        
        if f1.runModal() == NSAlertFirstButtonReturn {
            //if done selected
        }
    }
 */
}