import Vapor

struct VisitorCount: Codable {
	var count: Int
	var downloads: Int
}

@MainActor
struct CounterStore {
	static let filename = "visitorCount.json"

	static func path(for app: Application) -> String {
		return app.directory.workingDirectory + filename
	}

	static func load(app: Application) -> VisitorCount {
		let filePath = path(for: app)
		guard let data = FileManager.default.contents(atPath: filePath) else {
			return .init(count: 0, downloads: 0)
		}
		return (try? JSONDecoder().decode(VisitorCount.self, from: data)) ?? .init(count: 0, downloads: 0)
	}

	static func save(_ vc: VisitorCount, app: Application) {
		let filePath = path(for: app)
		do {
			let data = try JSONEncoder().encode(vc)
			try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
		} catch {
			print("Failed to save visitor count:", error)
		}
	}
}

func routes(_ app: Application) throws {
	app.get { _ async in
		"wace server is healthy!"
	}

	app.get("health") { _ async -> String in
		"wace server is healthy"
	}

	// Increment visitors
	app.post("increment") { _ async -> String in
		var vc = await CounterStore.load(app: app)
		vc.count += 1
		await CounterStore.save(vc, app: app)
		return String(vc.count)
	}

	// Fetch visitor count
	app.get("visitors") { _ async -> String in
		let vc = await CounterStore.load(app: app)
		return String(vc.count)
	}

	// Increment downloads
	app.post("downloaded") { _ async -> String in
		var vc = await CounterStore.load(app: app)
		vc.downloads += 1
		await CounterStore.save(vc, app: app)
		return String(vc.downloads)
	}

	// Fetch download count
	app.get("downloads") { _ async -> String in
		let vc = await CounterStore.load(app: app)
		return String(vc.downloads)
	}
}
