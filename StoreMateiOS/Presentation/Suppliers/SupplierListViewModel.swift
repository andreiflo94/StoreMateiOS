import Foundation
import Observation

@Observable
final class SupplierListViewModel {
    private let repository: SupplierRepository

    var suppliers: [Supplier] = []
    var searchText = ""
    var errorMessage: String?

    init(repository: SupplierRepository) {
        self.repository = repository
    }

    var filtered: [Supplier] {
        guard !searchText.isEmpty else { return suppliers }
        return suppliers.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.contactPerson.localizedCaseInsensitiveContains(searchText) ||
            $0.email.localizedCaseInsensitiveContains(searchText)
        }
    }

    func load() {
        do {
            suppliers = try repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(at offsets: IndexSet) {
        let targets = offsets.map { filtered[$0] }
        do {
            for supplier in targets {
                try repository.delete(id: supplier.id)
            }
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
