//
//  PDFViewerModel.swift
//  progA2
//
//  Created by Ashley Midgley on 10/13/16.
//  Copyright © 2016 Ashley Midgley. All rights reserved.
//

import Foundation
import Quartz

//classes implement this protocol to receive callbacks from the PDFViewerModel
public protocol PDFViewerModelDelegate {
}

public class PDFViewerModel: NSObject {
    
    var loaded = false
    
    var currPage = 1
    var prevPage = 1
    var pages = 0
    
    var docs = [NSURL]()
    var docIndex = 0
    var prevDoc = 0
    var newDoc = false
    
    var notes = [String: String]()
    
    var bookmarks = [Bookmark]()
    
    var currStepperVal = 0
    var results = [AnyObject]()
    let highlightBackColor = NSColor(red: 1, green: 1, blue: 0, alpha: 1)
    let highlightMainColor = NSColor(red: 1, green: 0.65, blue: 0, alpha: 1)
    
    let aboutMessageText = "About the program"
    let aboutInformativeText = "This Lecture notes organiser was created by Ash Midgley for a COSC346 - Object Oriented programming project.\n\nThe application is designed to open and manipulate PDF documents in a user friendly manner.\n\nNo programmers were harmed in the production of this PDF viewer."
    
    public var delegate: PDFViewerModelDelegate? = nil
    
    func pageUpdated(currPage: Int) {
        self.prevPage = self.currPage
        self.currPage = currPage
    }
    
    func docUpdated() {
        prevDoc = docIndex
        currPage = 1
        newDoc = false
    }
    
    func storeNote(note: String) {
        notes["\(docs[docIndex].lastPathComponent!) Page \(prevPage)"] = note
    }
    
    func setNote() -> String {
        let note = notes["\(docs[docIndex].lastPathComponent!) Page \(currPage)"]
        if  note != nil && note != "" {
            return note!
        }else{
            return ""
        }
    }
    
    func choosePDF() -> Bool {
        let fileChooser = NSOpenPanel();
        fileChooser.title = "Choose a .pdf file";
        fileChooser.showsResizeIndicator = true;
        fileChooser.showsHiddenFiles = false;
        fileChooser.canChooseDirectories = false;
        fileChooser.canCreateDirectories = true;
        fileChooser.allowsMultipleSelection = true;
        fileChooser.allowedFileTypes = ["pdf"];
        
        if(fileChooser.runModal() == NSModalResponseOK) {
            docs = [NSURL]()
            bookmarks.removeAll()
            loaded = true
            docs = fileChooser.URLs
            
            //unarchive saved notes
            if let savedNotes = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().resourcePath!+"/notesSave") as? [String: String] {
                notes = savedNotes
            }
            return true
        }else{
            //User clicked on "Cancel"
            return false
        }
    }
    
    func canGoToPrevDoc() -> Bool {
        if (!docs.isEmpty && docIndex != 0){
            docIndex -= 1
            newDoc = true
            return true
        }else{
            return false
        }
    }
    
    func canGoToNextDoc() -> Bool {
        if (!docs.isEmpty && docIndex != docs.count-1){
            docIndex += 1
            newDoc = true
            return true
        }else{
            return false
        }
    }
    
    func canGoToPage(page: Int?) -> Bool {
        return page != nil && page <= pages
    }
    
    func saveNotes(){
        NSKeyedArchiver.archiveRootObject(notes, toFile: NSBundle.mainBundle().resourcePath!+"/notesSave")
    }
    
    func discardNotes(){
        notes = [String: String]()
    }
    
    func canAddNewBookmark(bookmark: Bookmark) -> Bool {
        if loaded && !(containsBookmark(bookmarks, new: bookmark)) {
            bookmarks.append(bookmark)
            return true
        }
        return false
    }
    
    func containsBookmark(bookmarks: [Bookmark], new: Bookmark) -> Bool{
        for b in bookmarks{
            if b.bookmarkStr == new.bookmarkStr {
                return true
            }
        }
        return false
    }
    
    func handleResults() {
        results[0].setColor(highlightMainColor)
        if results.count > 1 {
            for i in 1..<results.count {
                results[i].setColor(highlightBackColor)
            }
        }
    }
    
    func updateSearchCase(stepVal: Int32){
        let cStepVal = Int32(currStepperVal)
        if stepVal < cStepVal && currStepperVal != 0{
            //moving downwards
            currStepperVal -= 1
        }else if stepVal > cStepVal && currStepperVal < results.count-1{
            //moving upwards
            currStepperVal += 1
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
    }
}