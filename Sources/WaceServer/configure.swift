import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	app.http.server.configuration.port = 4167

    // register routes
    try routes(app)
}
