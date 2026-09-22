import Testing
import Foundation
@testable import StoreMateiOS

@MainActor
struct FetchLowStockProductsUseCaseTests {
    @Test func returnsOnlyLowStockSortedByQuantityAscending() throws {
        let low = Product(name: "Low", stockQuantity: 2, lowStockThreshold: 5)
        let healthy = Product(name: "Healthy", stockQuantity: 20, lowStockThreshold: 5)
        let empty = Product(name: "Empty", stockQuantity: 0, lowStockThreshold: 5)
        let repo = InMemoryProductRepository([low, healthy, empty])
        let sut = FetchLowStockProductsUseCase(productRepository: repo)

        let result = try sut()

        #expect(result.map(\.id) == [empty.id, low.id])
    }

    @Test func returnsEmptyWhenAllHealthy() throws {
        let repo = InMemoryProductRepository([
            Product(name: "A", stockQuantity: 50, lowStockThreshold: 5),
        ])
        let sut = FetchLowStockProductsUseCase(productRepository: repo)

        #expect(try sut().isEmpty)
    }
}

@MainActor
struct ProductEntityTests {
    @Test func isLowStockIncludesThresholdBoundary() {
        #expect(Product(name: "x", stockQuantity: 5, lowStockThreshold: 5).isLowStock)
        #expect(Product(name: "x", stockQuantity: 4, lowStockThreshold: 5).isLowStock)
        #expect(Product(name: "x", stockQuantity: 6, lowStockThreshold: 5).isLowStock == false)
    }
}
