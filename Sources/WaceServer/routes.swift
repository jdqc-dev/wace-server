import Vapor

struct VisitorCount: Codable {
	var count: Int
}

@MainActor
struct CounterStore {
	static let path = "/tmp/wace-server/visitorCount.json"
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
	app.get { _ async in
		"wace server is healthy!"
	}

	app.get("health") { _ async -> String in
		"wace server is healthy"
	}

	app.get("increment") { _ async -> String in
		var vc = await CounterStore.load()
		vc.count += 1
		await CounterStore.save(vc)
		return String(vc.count)
	}

	app.get("visitors") { _ async -> String in
		let vc = await CounterStore.load()
		return String(vc.count)
	}
}
