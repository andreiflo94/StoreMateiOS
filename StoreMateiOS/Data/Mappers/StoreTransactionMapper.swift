import Foundation

extension StoreTransactionModel {
    func toDomain() -> StoreTransaction {
        StoreTransaction(
            id: id,
            type: type,
            productID: product?.id,
            productName: productName,
            quantity: quantity,
            unitPrice: unitPrice,
            date: date,
            notes: notes
        )
    }
}
