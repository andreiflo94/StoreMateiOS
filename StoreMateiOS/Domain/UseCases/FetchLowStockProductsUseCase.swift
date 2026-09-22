import Foundation

/// Returns products at or below their low-stock threshold, lowest stock first.
///
/// Keeps the low-stock rule (`Product.isLowStock`) in the Domain layer rather than
/// expressing it as a SwiftData `#Predicate` in the Data layer.
struct FetchLowStockProductsUseCase {
    let productRepository: ProductRepository

    func callAsFunction() throws -> [Product] {
        try productRepository.fetchAll()
            .filter(\.isLowStock)
            .sorted { $0.stockQuantity < $1.stockQuantity }
    }
}
