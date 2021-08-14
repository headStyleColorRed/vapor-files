import Vapor

func routes(_ app: Application) throws {
    let filesManager = FilesManager()
    app.get { req in
        return "It works!"
    }

    app.post("saveFiles") { req -> EventLoopFuture<[String]> in
        return try filesManager.saveFiles(req, app: app)
    }

    app.get("getFile", ":pathId", ":fileName") { req -> Response in
        return try filesManager.getFile(req, app: app)
    }

    app.delete("deleteFile") { req -> String in
        return try filesManager.deleteFile(req, app: app)
    }
}
