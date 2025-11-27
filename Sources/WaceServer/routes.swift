import Vapor

struct VisitorCount: Codable {
	var count: Int
}

@MainActor
struct CounterStore {
	static let path = "/var/lib/vapor/visitorCount.json"
	@MainActor static let fm = FileManager.default

	static func load() -> VisitorCount {
		guard let data = fm.contents(atPath: path) else { return .init(count: 0) }
		return (try? JSONDecoder().decode(VisitorCount.self, from: data)) ?? .init(count: 0)
	}

	static func save(_ vc: VisitorCount) {
		let data = try! JSONEncoder().encode(vc)
		try! data.write(to: URL(fileURLWithPath: path), options: .atomic)
	}
}

func routes(_ app: Application) throws {
    app.get { req async in
        "wace server is healthy!"
    }

    app.get("health") { req async -> String in
        "wace server is healthy"
    }

	app.post("increment") { req async throws -> String in
		var vc = await CounterStore.load()
		vc.count += 1
		await CounterStore.save(vc)
		return String(vc.count)
	}


}
