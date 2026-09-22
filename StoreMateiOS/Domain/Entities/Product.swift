import Foundation

/// Domain entity representing an inventory item. Framework-free value type.
struct Product: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var barcode: String
    var price: Double
    var stockQuantity: Int
    var lowStockThreshold: Int
    var category: String
    var supplier: Supplier?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        barcode: String = "",
        price: Double = 0,
        stockQuantity: Int = 0,
        lowStockThreshold: Int = 5,
        category: String = "",
        supplier: Supplier? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.barcode = barcode
        self.price = price
        self.stockQuantity = stockQuantity
        self.lowStockThreshold = lowStockThreshold
        self.category = category
        self.supplier = supplier
        self.createdAt = createdAt
    }

    /// Business rule: an item is low on stock once it reaches or falls below its threshold.
    var isLowStock: Bool { stockQuantity <= lowStockThreshold }
}
