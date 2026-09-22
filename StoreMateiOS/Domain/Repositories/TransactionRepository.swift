import Foundation

protocol TransactionRepository {
    func fetchAll() throws -> [StoreTransaction]
    func add(_ transaction: StoreTransaction) throws
    func delete(id: UUID) throws
}
