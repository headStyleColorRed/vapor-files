//
//  FilesManager.swift
//  FilesManager
//
//  Created by Rodrigo Labrador Serrano on 11/8/21.
//

import Vapor

final class FilesManager {
    func saveFiles(_ req: Request, app: Application) throws -> EventLoopFuture<[String]> {
        let body = try req.content.decode(NewFileQuery.self)
        let path = app.directory.workingDirectory + "files/" + body.pathId

        guard app.createFolder(path: "files/" + body.pathId) != nil else {
            throw Abort(.custom(code: 418, reasonPhrase: ""))
        }

        let futureFiles = body.files.map { file -> EventLoopFuture<String> in
            let fileNameResponse = body.pathId.finished(with: "/") + file.filename
            return req.application.fileio.openFile(path: path + "/" + file.filename,
                                                   mode: .write,
                                                   flags: .allowFileCreation(posixMode: 0x744),
                                                   eventLoop: req.eventLoop)
                .flatMap { handle in
                    req.application.fileio.write(fileHandle: handle,
                                                 buffer: file.data,
                                                 eventLoop: req.eventLoop)
                        .flatMapThrowing { _ in
                            try handle.close()
                            return "fileNameResponse"
                        }
                }
        }
        return futureFiles.flatten(on: req.eventLoop)
    }

    func getFile(_ req: Request, app: Application) throws -> Response {
        let body = try req.content.decode(RetrieveFilesQuery.self)
        let path = app.directory.workingDirectory + "files/" + body.pathId.finished(with: "/") + body.fileName

        if FileManager.default.fileExists(atPath: path) {
            return req.fileio.streamFile(at: path)
        } else {
            throw Abort(.custom(code: 400, reasonPhrase: "File not found"))
        }
    }

    func deleteFile(_ req: Request, app: Application) throws -> String {
        let body = try req.content.decode(DeleteFileQuery.self)
        let path = app.directory.workingDirectory + "files/" + body.pathId.finished(with: "/") + body.fileName

        do {
            try FileManager.default.removeItem(atPath: path)
            return "File \(body.fileName) deleted succesfullly"
        } catch {
            throw Abort(.custom(code: 400, reasonPhrase: "File not found"))
        }
    }
}
