//
//  Bookmark.swift
//  progA2
//
//  Created by Ashley Midgley on 10/7/16.
//  Copyright © 2016 Ashley Midgley. All rights reserved.
//

import Foundation

public class Bookmark {
    
    let docIndex: Int
    let pageIndex: Int
    let bookmarkStr: String
    
    var doc: Int{
        return docIndex
    }
    
    var page: Int{
        return pageIndex
    }
    
    init(docIndex: Int, pageIndex: Int){
        self.docIndex = docIndex
        self.pageIndex = pageIndex
        bookmarkStr = "\(docIndex) Page \(pageIndex)"
    }
}