import Foundation

extension ProductModel {
    func toDomain() -> Product {
        Product(
            id: id,
            name: name,
            barcode: barcode,
            price: price,
            stockQuantity: stockQuantity,
            lowStockThreshold: lowStockThreshold,
            category: category,
            supplier: supplier?.toDomain(),
            createdAt: createdAt
        )
    }

    /// Applies domain scalar values onto this persistence model. The `supplier`
    /// relationship is resolved separately by the repository (needs the context).
    func apply(_ product: Product) {
        name = product.name
        barcode = product.barcode
        price = product.price
        stockQuantity = product.stockQuantity
        lowStockThreshold = product.lowStockThreshold
        category = product.category
    }
}
