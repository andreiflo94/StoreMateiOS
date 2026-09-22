import Foundation
import SwiftData

/// SwiftData persistence model for an inventory item. Mapped to the `Product`
/// domain entity via `ProductMapper`.
@Model
final class ProductModel {
    var id: UUID
    var name: String
    var barcode: String
    var price: Double
    var stockQuantity: Int
    var lowStockThreshold: Int
    var category: String
    @Relationship(deleteRule: .nullify) var supplier: SupplierModel?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        barcode: String = "",
        price: Double = 0,
        stockQuantity: Int = 0,
        lowStockThreshold: Int = 5,
        category: String = "",
        supplier: SupplierModel? = nil,
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
}
