import Testing
import Foundation
import SwiftData
@testable import StoreMateiOS

@MainActor
struct SwiftDataProductRepositoryTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([ProductModel.self, SupplierModel.self, StoreTransactionModel.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    @Test func addThenFetchRoundTripsIncludingSupplier() throws {
        let context = try makeContext()
        let supplierRepo = SwiftDataSupplierRepository(context: context)
        let productRepo = SwiftDataProductRepository(context: context)

        let supplier = Supplier(name: "Acme")
        try supplierRepo.add(supplier)

        let product = Product(
            name: "Widget",
            barcode: "123",
            price: 9.99,
            stockQuantity: 7,
            lowStockThreshold: 3,
            category: "Tools",
            supplier: supplier
        )
        try productRepo.add(product)

        let fetched = try productRepo.fetchAll()
        #expect(fetched.count == 1)
        let first = try #require(fetched.first)
        #expect(first.id == product.id)
        #expect(first.name == "Widget")
        #expect(first.barcode == "123")
        #expect(first.price == 9.99)
        #expect(first.stockQuantity == 7)
        #expect(first.category == "Tools")
        #expect(first.supplier?.id == supplier.id)
    }

    @Test func updatePersistsChanges() throws {
        let context = try makeContext()
        let productRepo = SwiftDataProductRepository(context: context)

        var product = Product(name: "Widget", stockQuantity: 5)
        try productRepo.add(product)

        product.name = "Gadget"
        product.stockQuantity = 12
        try productRepo.update(product)

        let fetched = try #require(try productRepo.fetch(id: product.id))
        #expect(fetched.name == "Gadget")
        #expect(fetched.stockQuantity == 12)
    }

    @Test func deleteRemovesProduct() throws {
        let context = try makeContext()
        let productRepo = SwiftDataProductRepository(context: context)

        let product = Product(name: "Widget")
        try productRepo.add(product)
        try productRepo.delete(id: product.id)

        #expect(try productRepo.fetchAll().isEmpty)
    }
}
