import Foundation

protocol SupplierRepository {
    func fetchAll() throws -> [Supplier]
    func add(_ supplier: Supplier) throws
    func update(_ supplier: Supplier) throws
    func delete(id: UUID) throws
}
