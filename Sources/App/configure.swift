import Vapor

public func configure(_ app: Application) throws {
    try routes(app)

    if app.createFolder(path: "files") == nil {
        throw "Error creating files folder".asError
    }
}
