import Foundation
import SwiftData

/// `SupplierRepository` backed by SwiftData. Persists on every mutating call.
final class SwiftDataSupplierRepository: SupplierRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [Supplier] {
        let descriptor = FetchDescriptor<SupplierModel>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func add(_ supplier: Supplier) throws {
        let model = SupplierModel(
            id: supplier.id,
            name: supplier.name,
            contactPerson: supplier.contactPerson,
            email: supplier.email,
            phone: supplier.phone,
            address: supplier.address
        )
        context.insert(model)
        try context.save()
    }

    func update(_ supplier: Supplier) throws {
        guard let model = try model(id: supplier.id) else { return }
        model.apply(supplier)
        try context.save()
    }

    func delete(id: UUID) throws {
        guard let model = try model(id: id) else { return }
        context.delete(model)
        try context.save()
    }

    private func model(id: UUID) throws -> SupplierModel? {
        var descriptor = FetchDescriptor<SupplierModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
