import Foundation
import SwiftData

/// `TransactionRepository` backed by SwiftData. Persists on every mutating call
/// and resolves the product relationship by id.
final class SwiftDataTransactionRepository: TransactionRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [StoreTransaction] {
        let descriptor = FetchDescriptor<StoreTransactionModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func add(_ transaction: StoreTransaction) throws {
        let model = StoreTransactionModel(
            id: transaction.id,
            type: transaction.type,
            product: try productModel(id: transaction.productID),
            productName: transaction.productName,
            quantity: transaction.quantity,
            unitPrice: transaction.unitPrice,
            date: transaction.date,
            notes: transaction.notes
        )
        context.insert(model)
        try context.save()
    }

    func delete(id: UUID) throws {
        var descriptor = FetchDescriptor<StoreTransactionModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else { return }
        context.delete(model)
        try context.save()
    }

    private func productModel(id: UUID?) throws -> ProductModel? {
        guard let id else { return nil }
        var descriptor = FetchDescriptor<ProductModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
