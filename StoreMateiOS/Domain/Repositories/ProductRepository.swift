import Foundation

/// Abstraction over product persistence. The Domain layer depends only on this
/// protocol; concrete implementations live in the Data layer.
protocol ProductRepository {
    func fetchAll() throws -> [Product]
    func fetch(id: UUID) throws -> Product?
    func add(_ product: Product) throws
    func update(_ product: Product) throws
    func delete(id: UUID) throws
}
