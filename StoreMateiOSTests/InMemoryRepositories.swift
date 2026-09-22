import Foundation
@testable import StoreMateiOS

/// Lightweight in-memory `ProductRepository` for testing the Domain layer
/// without SwiftData.
@MainActor
final class InMemoryProductRepository: ProductRepository {
    var products: [Product]

    init(_ products: [Product] = []) {
        self.products = products
    }

    func fetchAll() throws -> [Product] { products }

    func fetch(id: UUID) throws -> Product? { products.first { $0.id == id } }

    func add(_ product: Product) throws { products.append(product) }

    func update(_ product: Product) throws {
        guard let index = products.firstIndex(where: { $0.id == product.id }) else { return }
        products[index] = product
    }

    func delete(id: UUID) throws { products.removeAll { $0.id == id } }
}

@MainActor
final class InMemoryTransactionRepository: TransactionRepository {
    var transactions: [StoreTransaction] = []

    func fetchAll() throws -> [StoreTransaction] { transactions }

    func add(_ transaction: StoreTransaction) throws { transactions.append(transaction) }

    func delete(id: UUID) throws { transactions.removeAll { $0.id == id } }
}
