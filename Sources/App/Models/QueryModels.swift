//
//  QueryModels.swift
//  QueryModels
//
//  Created by Rodrigo Labrador Serrano on 11/8/21.
//

import Vapor

struct NewFileQuery: Content {
    let pathId: String
    let files: [File]
}

struct DeleteFileQuery: Content {
    let fileName: String
    let pathId: String
}
