import Vapor

public func configure(_ app: Application) throws {

    // Configure routes
    try routes(app)

    // Server port
    app.http.server.configuration.port = 8893

    // Cors configuration
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    app.middleware.use(CORSMiddleware(configuration: corsConfiguration), at: .beginning)

    app.routes.defaultMaxBodySize = "10mb"

    // Files folder creation
    if app.createFolder(path: "files") == nil {
        throw "Error creating files folder".asError
    }
}
