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
    var prevDoc = 0
    var loaded = false
    var newDoc = false
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    
    @IBOutlet weak var docComboBox: NSComboBox!
    
    @IBOutlet weak var displaySelectedButton: NSPopUpButton!
    @IBOutlet weak var thumbnailView: PDFThumbnailView!
    
    @IBOutlet weak var notesField: NSTextField!
    var notes = [String: String]()
    
    var bookmarks = [Bookmark]()
    @IBOutlet weak var bookmarksOptions: NSComboBox!
    
    @IBOutlet weak var currentPageNoLabel: NSTextField!
    @IBOutlet weak var goToPageNoField: NSTextField!
    
    @IBOutlet weak var prevDocButton: NSButton!
    @IBOutlet weak var nextDocButton: NSButton!

    @IBOutlet weak var textSearchField: NSSearchField!
    @IBOutlet weak var casesLabel: NSTextField!
    @IBOutlet weak var searchCasesStepper: NSStepper!
    var currStepperVal = 0
    var results = [AnyObject]()
    let highlightBackColor = NSColor(red: 1, green: 1, blue: 0, alpha: 1)
    let highlightMainColor = NSColor(red: 1, green: 0.65, blue: 0, alpha: 1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        thumbnailView.setPDFView(ourPDF)
        prevDocButton.hidden = true
        nextDocButton.hidden = true
        searchCasesStepper.hidden = true
        notesField.hidden = true
        docComboBox.hidden = true
        docComboBox.editable = false
        bookmarksOptions.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateDocument), name: PDFViewDocumentChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePageNumber), name: PDFViewPageChangedNotification, object: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func updatePageNumber() {
        if !newDoc {
            //notes field
            notes["\(docs[docIndex].lastPathComponent!) Page \(currPage)"] = notesField.stringValue
            let note = notes["\(docs[docIndex].lastPathComponent!) Page \(ourPDF.document().indexForPage(ourPDF.currentPage())+1)"]
            if  note != nil && note != "" {
                notesField.stringValue = note!
            }else{
                notesField.stringValue = ""
            }
            notesField.updateLayer()
            
            //page elements
            self.currPage = ourPDF.document().indexForPage(ourPDF.currentPage())+1
            currentPageNoLabel.stringValue = "Page \(self.currPage) of \(self.pages)"
        }
    }
    
    func updateDocument(){
        //notes view
        notes["\(docs[prevDoc].lastPathComponent!) Page \(currPage)"] = notesField.stringValue
        
        let note = notes["\(docs[docIndex].lastPathComponent!) Page 1"]
        if  note != nil && note != "" {
            notesField.stringValue = note!
        }else{
            notesField.stringValue = ""
        }
        notesField.updateLayer()
        
        prevDoc = docIndex
        self.currPage = 1
        newDoc = false
        docComboBox.stringValue = docs[docIndex].lastPathComponent!
        self.pages = ourPDF.document().pageCount()
        currentPageNoLabel.stringValue = "Page \(ourPDF.document().indexForPage(ourPDF.currentPage())+1) of \(self.pages)"
    }
    
    @IBAction func choosePDF(sender: AnyObject) {
        let fileChooser = NSOpenPanel();
        fileChooser.title = "Choose a .pdf file";
        fileChooser.showsResizeIndicator = true;
        fileChooser.showsHiddenFiles = false;
        fileChooser.canChooseDirectories = false;
        fileChooser.canCreateDirectories = true;
        fileChooser.allowsMultipleSelection = true;
        fileChooser.allowedFileTypes = ["pdf"];
        
        if(fileChooser.runModal() == NSModalResponseOK) {
            //remove previous documents navigation if there is any available
            if docComboBox.numberOfItems > 0 {
                docComboBox.removeAllItems()
                docs = [NSURL]()
            }
            
            self.docs = fileChooser.URLs
            self.loaded = true
            titleLabel.hidden = true
            subtitleLabel.hidden = true
            
            
            //update bookmarks
            if bookmarks.count > 0 {
                bookmarks.removeAll()
                bookmarksOptions.removeAllItems()
                bookmarksOptions.hidden = true
                bookmarksOptions.updateLayer()
            }

            //unarchive saved notes
            if let savedNotes = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().resourcePath!+"/notesSave") as? [String: String] {
                print("loaded")
                notes = savedNotes
            }
            
            //set initial notes value
            let note = notes["\(docs[0].lastPathComponent!) Page 1"]
            if  note != nil && note != "" {
                notesField.stringValue = note!
            }else{
                notesField.stringValue = ""
            }
            notesField.updateLayer()
            
            //allow navigation buttons if more than one document
            if(docs.count > 1){
                prevDocButton.hidden = false
                nextDocButton.hidden = false
            }else{
                prevDocButton.hidden = true
                nextDocButton.hidden = true
            }
            
            //add document selection to header combo box
            for url in docs {
                docComboBox.addItemWithObjectValue(url.lastPathComponent!)
            }
            docComboBox.stringValue = docs[0].lastPathComponent!
            docComboBox.hidden = false
            
            //set the pdfview to display the initial document
            setPDF(docs[0])
        }else{
            //User clicked on "Cancel"
            return
        }
    }
    
    func setPDF(url: NSURL){
        ourPDF.setDocument(PDFDocument(URL: url))
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
                newDoc = true
                setPDF(docs[docIndex])
            }
        }
    }
    
    @IBAction func nextDocument(sender: AnyObject) {
        if !docs.isEmpty {
            if(docIndex != docs.count-1){
                docIndex += 1
                newDoc = true
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
    
    @IBAction func saveNotes(sender: AnyObject) {
        NSKeyedArchiver.archiveRootObject(notes, toFile: NSBundle.mainBundle().resourcePath!+"/notesSave")
    }
    
    @IBAction func discardNotes(sender: AnyObject) {
        notesField.stringValue = ""
        notes = [String: String]()
        notesField.updateLayer()
    }
    
    @IBAction func addBookmark(sender: AnyObject) {
        if loaded {
            let newBookmark = Bookmark(docIndex: self.docIndex, pageNo: self.currPage-1)
            if !(containsBookmark(bookmarks, new: newBookmark)) {
                bookmarks.append(newBookmark)
                let bItem = "\(docs[newBookmark.doc].lastPathComponent!) - Page \(newBookmark.page+1)"
                bookmarksOptions.addItemWithObjectValue(bItem)
                bookmarksOptions.stringValue = "Select a bookmark..."
                bookmarksOptions.updateLayer()
                
                bookmarksOptions.hidden = false
                bookmarksOptions.stringValue = "Select a bookmark..."
                
            }
        }
    }
    
    func containsBookmark(bookmarks: [Bookmark], new: Bookmark) -> Bool{
        for b in bookmarks{
            if b.bookmarkStr == new.bookmarkStr {
                return true
            }
        }
        return false
    }
    
    @IBAction func bookmarkSelected(sender: AnyObject) {
        if loaded {
            let bookmark = bookmarks[bookmarksOptions.indexOfSelectedItem]
            setPDF(docs[bookmark.doc])
            ourPDF.goToPage(ourPDF.document().pageAtIndex(bookmark.page))
            docComboBox.stringValue = docs[bookmark.doc].lastPathComponent!
            bookmarksOptions.stringValue = "Select a bookmark..."
        }
    }
    
    @IBAction func textSearch(sender: NSSearchField) {
        if loaded {
            if textSearchField.stringValue != "" {
                self.results = ourPDF.document().findString(textSearchField.stringValue, withOptions: 1)
                if !results.isEmpty {
                    casesLabel.hidden = false
                    searchCasesStepper.hidden = false
                    results[0].setColor(highlightMainColor)
                    if results.count > 1 {
                        for i in 1..<results.count {
                            results[i].setColor(highlightBackColor)
                        }
                    }
                    ourPDF.setHighlightedSelections(results)
                    ourPDF.goToSelection(results[0] as! PDFSelection)
                    casesLabel.stringValue = "Case \(currStepperVal+1) of \(results.count)"
                }
            }else{
                searchCasesStepper.hidden = true
                casesLabel.stringValue.removeAll()
                ourPDF.setHighlightedSelections(nil)
                currStepperVal = 0
            }
        }
    }
    
    @IBAction func changeSearchCase(sender: NSStepper) {
        let stepVal = searchCasesStepper.intValue
        let cStepVal = Int32(currStepperVal)
        let rCount = Int32(results.count-1)
        if stepVal < cStepVal && currStepperVal != 0{
            //moving downwards
            currStepperVal -= 1
        }else if stepVal > cStepVal && currStepperVal < results.count-1{
            //moving upwards
            currStepperVal += 1
        }else if stepVal >= rCount {
            searchCasesStepper.intValue = rCount
        }
        if results.count > 1 {
            for i in 0..<results.count {
                if i == currStepperVal {
                    results[i].setColor(highlightMainColor)
                }else{
                    results[i].setColor(highlightBackColor)
                }
            }
        }
        ourPDF.goToSelection(results[currStepperVal] as! PDFSelection)
        ourPDF.setHighlightedSelections(results)
        casesLabel.stringValue = "Case \(currStepperVal+1) of \(results.count)"
    }
    
    @IBAction func displayOptionSelected(sender: NSPopUpButton) {
        let curr = displaySelectedButton.selectedItem?.title
        if curr == "Thumbnail" {
            thumbnailView.hidden = false
            notesField.hidden = true
        }else{
            thumbnailView.hidden = true
            notesField.hidden = false
        }
    }
    
    @IBAction func docSelected(sender: NSComboBox) {
        if loaded {
            newDoc = true
            setPDF(docs[sender.indexOfSelectedItem])
            docIndex = sender.indexOfSelectedItem
            docComboBox.stringValue = docs[sender.indexOfSelectedItem].lastPathComponent!
        }
    }
    
    @IBAction func aboutProgram(sender: AnyObject) {
        let about = NSAlert()
        about.messageText = "About the program"
        about.informativeText = "This Lecture notes organiser was created by Ash Midgley for a COSC346 - Object Oriented programming project.\n\nThe application is designed to open and manipulate PDF documents in a user friendly manner.\n\nNo programmers were harmed in the production of this PDF viewer."
        about.alertStyle = NSAlertStyle.InformationalAlertStyle
        about.addButtonWithTitle("Close")
        
        if about.runModal() == NSAlertFirstButtonReturn {
            return
        }
    }
}