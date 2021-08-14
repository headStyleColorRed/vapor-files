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
            let fileName = self.iterateFileName(path: path, fileName: file.filename)

            return req.application.fileio.openFile(path: path + "/" + fileName,
                                                   mode: .write,
                                                   flags: .allowFileCreation(posixMode: 0x744),
                                                   eventLoop: req.eventLoop)
                .flatMap { handle in
                    req.application.fileio.write(fileHandle: handle,
                                                 buffer: file.data,
                                                 eventLoop: req.eventLoop)
                        .flatMapThrowing { _ in
                            try handle.close()
                            return fileName
                        }
                }
        }
        return futureFiles.flatten(on: req.eventLoop)
    }

    private func iterateFileName(path: String, fileName: String) -> String {
        var counter = 0

        if FileManager.default.fileExists(atPath: path.finished(with: "/") + fileName) {
            counter += 1
            while FileManager.default.fileExists(atPath: path.finished(with: "/") + "(\(counter))" + fileName) {
                counter += 1
            }
        }

        return counter == 0 ? fileName : "(\(counter))".appending(fileName)
    }






    func getFile(_ req: Request, app: Application) throws -> Response {
        guard let pathId = req.parameters.get("pathId"), let fileName = req.parameters.get("fileName") else {
            throw Abort(.custom(code: 418, reasonPhrase: "Missing parameters pathId or filename in url"))
        }


        let path = app.directory.workingDirectory + "files/" + pathId.finished(with: "/") + fileName

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

    // MARK: - Utils
}
