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
class AppDelegate: NSObject, NSApplicationDelegate, PDFViewerModelDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var ourPDF: PDFView!
    
    //Header elements
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var docComboBox: NSComboBox!
    @IBOutlet weak var prevDocButton: NSButton!
    @IBOutlet weak var nextDocButton: NSButton!
    
    //Left panel elements
    @IBOutlet weak var displaySelectedButton: NSPopUpButton!
    @IBOutlet weak var thumbnailView: PDFThumbnailView!
    @IBOutlet weak var notesField: NSTextField!
    
    //Toolbar elements
    @IBOutlet weak var bookmarksOptions: NSComboBox!
    
    //Footer elements
    @IBOutlet weak var currentPageNoLabel: NSTextField!
    @IBOutlet weak var goToPageNoField: NSTextField!
    @IBOutlet weak var textSearchField: NSSearchField!
    @IBOutlet weak var casesLabel: NSTextField!
    @IBOutlet weak var searchCasesStepper: NSStepper!
    
    //PDF viewer state is now an instance of the model
    var pdfViewer: PDFViewerModel? = nil
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        //Create an instance of the PDFViewerModel and reset it
        pdfViewer = PDFViewerModel()
        pdfViewer!.delegate = self
        
        thumbnailView.setPDFView(ourPDF)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePageNumber), name: PDFViewPageChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateDocument), name: PDFViewDocumentChangedNotification, object: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func updatePageNumber() {
        if !pdfViewer!.newDoc {
            pdfViewer!.pageUpdated(ourPDF.document().indexForPage(ourPDF.currentPage())+1)
            
            //Store notes value of prev page
            pdfViewer!.storeNote(notesField.stringValue)
            
            //Set notes value of current page
            notesField.stringValue = pdfViewer!.setNote()
            notesField.updateLayer()
            
            //Page elements
            currentPageNoLabel.stringValue = "Page \(pdfViewer!.currPage) of \(pdfViewer!.pages)"
        }
    }
    
    func updateDocument(){
        //Set notes value of previous page of previous document
        pdfViewer!.notes["\(pdfViewer!.docs[pdfViewer!.prevDoc].lastPathComponent!) Page \(pdfViewer!.currPage)"] = notesField.stringValue
        
        //Set notes value of first page of document
        let note = pdfViewer!.notes["\(pdfViewer!.docs[pdfViewer!.docIndex].lastPathComponent!) Page 1"]
        if  note != nil && note != "" {
            notesField.stringValue = note!
        }else{
            notesField.stringValue = ""
        }
        notesField.updateLayer()
        
        //Update variables associated with document
        pdfViewer!.docUpdated()
        pdfViewer!.pages = ourPDF.document().pageCount()
        
        //Update relevant fields
        docComboBox.stringValue = pdfViewer!.docs[pdfViewer!.docIndex].lastPathComponent!
        currentPageNoLabel.stringValue = "Page \(pdfViewer!.currPage) of \(pdfViewer!.pages)"
    }
    
    @IBAction func choosePDF(sender: AnyObject) {
        //remove previous documents navigation if there is any available
        if docComboBox.numberOfItems > 0 {
            docComboBox.removeAllItems()
        }
        
        if(pdfViewer!.choosePDF()){
            titleLabel.hidden = true
            subtitleLabel.hidden = true
            
            //update bookmarks
            if pdfViewer!.bookmarks.count > 0 {
                bookmarksOptions.removeAllItems()
                bookmarksOptions.hidden = true
                bookmarksOptions.updateLayer()
            }
            
            //set initial notes value
            notesField.stringValue = pdfViewer!.setNote()
            notesField.updateLayer()
            
            //allow navigation buttons if more than one document
            if(pdfViewer!.docs.count > 1){
                prevDocButton.hidden = false
                nextDocButton.hidden = false
            }else{
                prevDocButton.hidden = true
                nextDocButton.hidden = true
            }
            
            //add document selection to header combo box
            for url in pdfViewer!.docs {
                docComboBox.addItemWithObjectValue(url.lastPathComponent!)
            }
            docComboBox.stringValue = pdfViewer!.docs[0].lastPathComponent!
            docComboBox.hidden = false
            
            //set the pdfview to display the initial document
            setPDF(pdfViewer!.docs[0])
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
        if pdfViewer!.canGoToPrevDoc() {
            setPDF(pdfViewer!.docs[pdfViewer!.docIndex])
        }
    }
    
    @IBAction func nextDocument(sender: AnyObject) {
        if pdfViewer!.canGoToNextDoc() {
            setPDF(pdfViewer!.docs[pdfViewer!.docIndex])
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
        let page = Int(goToPageNoField.stringValue)
        if pdfViewer!.canGoToPage(page){
            ourPDF.goToPage(ourPDF.document().pageAtIndex(page!-1))
            goToPageNoField.stringValue.removeAll()
        }
    }
    
    @IBAction func saveNotes(sender: AnyObject) {
        pdfViewer!.saveNotes()
    }
    
    @IBAction func discardNotes(sender: AnyObject) {
        pdfViewer!.discardNotes()
        notesField.stringValue = ""
        notesField.updateLayer()
    }
    
    @IBAction func addBookmark(sender: AnyObject) {
        let bookmark = Bookmark(docIndex: pdfViewer!.docIndex, pageIndex: pdfViewer!.currPage-1)
        if pdfViewer!.canAddNewBookmark(bookmark) {
            let bItem = "\(pdfViewer!.docs[bookmark.doc].lastPathComponent!) - Page \(bookmark.page+1)"
            bookmarksOptions.addItemWithObjectValue(bItem)
            bookmarksOptions.stringValue = "Select a bookmark..."
            bookmarksOptions.updateLayer()
            bookmarksOptions.hidden = false
            bookmarksOptions.stringValue = "Select a bookmark..."
        }
    }
    
    @IBAction func bookmarkSelected(sender: AnyObject) {
        if pdfViewer!.loaded && pdfViewer!.bookmarks.count > 0 {
            let bookmark = pdfViewer!.bookmarks[bookmarksOptions.indexOfSelectedItem]
            let bDoc = pdfViewer!.docs[bookmark.doc]
            setPDF(bDoc)
            ourPDF.goToPage(ourPDF.document().pageAtIndex(bookmark.page))
            docComboBox.stringValue = bDoc.lastPathComponent!
            bookmarksOptions.stringValue = "Select a bookmark..."
        }
    }
    
    @IBAction func textSearch(sender: NSSearchField) {
        if pdfViewer!.loaded {
            if textSearchField.stringValue != "" {
                pdfViewer!.results = ourPDF.document().findString(textSearchField.stringValue, withOptions: 1)
                if !pdfViewer!.results.isEmpty {
                    casesLabel.hidden = false
                    searchCasesStepper.hidden = false
                    
                    pdfViewer!.handleResults()
                    
                    ourPDF.setHighlightedSelections(pdfViewer!.results)
                    ourPDF.goToSelection(pdfViewer!.results[0] as! PDFSelection)
                    casesLabel.stringValue = "Case \(pdfViewer!.currStepperVal+1) of \(pdfViewer!.results.count)"
                }
            }else{
                searchCasesStepper.hidden = true
                casesLabel.stringValue.removeAll()
                ourPDF.setHighlightedSelections(nil)
                pdfViewer!.currStepperVal = 0
            }
        }
    }
    
    @IBAction func changeSearchCase(sender: NSStepper) {
        let stepVal = searchCasesStepper.intValue
        
        pdfViewer!.updateSearchCase(stepVal)
        
        let rCount = Int32(pdfViewer!.results.count-1)
        if stepVal >= rCount {
            searchCasesStepper.intValue = rCount
        }
        ourPDF.goToSelection(pdfViewer!.results[pdfViewer!.currStepperVal] as! PDFSelection)
        ourPDF.setHighlightedSelections(pdfViewer!.results)
        casesLabel.stringValue = "Case \(pdfViewer!.currStepperVal+1) of \(pdfViewer!.results.count)"
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
        if pdfViewer!.loaded {
            pdfViewer!.newDoc = true
            setPDF(pdfViewer!.docs[sender.indexOfSelectedItem])
            pdfViewer!.docIndex = sender.indexOfSelectedItem
            docComboBox.stringValue = pdfViewer!.docs[sender.indexOfSelectedItem].lastPathComponent!
        }
    }
    
    @IBAction func aboutProgram(sender: AnyObject) {
        let about = NSAlert()
        about.messageText = pdfViewer!.aboutMessageText
        about.informativeText = pdfViewer!.aboutInformativeText
        about.alertStyle = NSAlertStyle.InformationalAlertStyle
        about.addButtonWithTitle("Close")
        if about.runModal() == NSAlertFirstButtonReturn {
            return
        }
    }
}