import SwiftUI
import SwiftData

@main
struct StoreMateiOSApp: App {
    private let modelContainer: ModelContainer
    @State private var container: AppContainer

    init() {
        let schema = Schema([
            ProductModel.self,
            SupplierModel.self,
            StoreTransactionModel.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            self.modelContainer = modelContainer
            _container = State(initialValue: AppContainer(modelContext: modelContainer.mainContext))
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
        }
    }
}
