import Foundation
import Observation

@Observable
final class ProductListViewModel {
    private let repository: ProductRepository

    var products: [Product] = []
    var searchText = ""
    var errorMessage: String?

    init(repository: ProductRepository) {
        self.repository = repository
    }

    var filtered: [Product] {
        guard !searchText.isEmpty else { return products }
        return products.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.barcode.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    func load() {
        do {
            products = try repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(at offsets: IndexSet) {
        let targets = offsets.map { filtered[$0] }
        do {
            for product in targets {
                try repository.delete(id: product.id)
            }
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
