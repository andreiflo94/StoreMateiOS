import Foundation
import SwiftData

/// SwiftData persistence model for a sale or restock. Mapped to the
/// `StoreTransaction` domain entity via `StoreTransactionMapper`.
@Model
final class StoreTransactionModel {
    var id: UUID
    var type: TransactionType
    @Relationship(deleteRule: .nullify) var product: ProductModel?
    var productName: String
    var quantity: Int
    var unitPrice: Double
    var date: Date
    var notes: String

    init(
        id: UUID = UUID(),
        type: TransactionType,
        product: ProductModel?,
        productName: String,
        quantity: Int,
        unitPrice: Double,
        date: Date = Date(),
        notes: String = ""
    ) {
        self.id = id
        self.type = type
        self.product = product
        self.productName = productName
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.date = date
        self.notes = notes
    }
}
