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
    let pageNo: Int
    let bookmarkStr: String
    
    var doc: Int{
        return docIndex
    }
    
    var page: Int{
        return pageNo
    }
    
    init(docIndex: Int, pageNo: Int){
        self.docIndex = docIndex
        self.pageNo = pageNo
        bookmarkStr = "\(docIndex) Page \(pageNo)"
    }
}