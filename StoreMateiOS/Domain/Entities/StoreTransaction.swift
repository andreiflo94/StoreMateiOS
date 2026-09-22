import Foundation

enum TransactionType: String, Codable, CaseIterable, Sendable {
    case sale = "Sale"
    case restock = "Restock"
}

/// Domain entity representing a sale or restock. Framework-free value type.
///
/// `productName` and `unitPrice` are snapshotted at creation so history survives
/// product edits or deletion; `productID` links back to the product when it still exists.
struct StoreTransaction: Identifiable, Equatable, Sendable {
    let id: UUID
    var type: TransactionType
    var productID: UUID?
    var productName: String
    var quantity: Int
    var unitPrice: Double
    var date: Date
    var notes: String

    init(
        id: UUID = UUID(),
        type: TransactionType,
        productID: UUID?,
        productName: String,
        quantity: Int,
        unitPrice: Double,
        date: Date = Date(),
        notes: String = ""
    ) {
        self.id = id
        self.type = type
        self.productID = productID
        self.productName = productName
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.date = date
        self.notes = notes
    }
}
