import Foundation
import SwiftData

/// `ProductRepository` backed by SwiftData. Persists on every mutating call and
/// resolves the supplier relationship by id.
final class SwiftDataProductRepository: ProductRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [Product] {
        let descriptor = FetchDescriptor<ProductModel>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func fetch(id: UUID) throws -> Product? {
        try model(id: id)?.toDomain()
    }

    func add(_ product: Product) throws {
        let model = ProductModel(
            id: product.id,
            name: product.name,
            barcode: product.barcode,
            price: product.price,
            stockQuantity: product.stockQuantity,
            lowStockThreshold: product.lowStockThreshold,
            category: product.category,
            supplier: try supplierModel(id: product.supplier?.id),
            createdAt: product.createdAt
        )
        context.insert(model)
        try context.save()
    }

    func update(_ product: Product) throws {
        guard let model = try model(id: product.id) else { return }
        model.apply(product)
        model.supplier = try supplierModel(id: product.supplier?.id)
        try context.save()
    }

    func delete(id: UUID) throws {
        guard let model = try model(id: id) else { return }
        context.delete(model)
        try context.save()
    }

    private func model(id: UUID) throws -> ProductModel? {
        var descriptor = FetchDescriptor<ProductModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func supplierModel(id: UUID?) throws -> SupplierModel? {
        guard let id else { return nil }
        var descriptor = FetchDescriptor<SupplierModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
