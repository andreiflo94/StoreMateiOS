import Foundation

/// Records a sale or restock and atomically adjusts the affected product's stock.
///
/// This is the core business rule that previously lived in `TransactionFormView.save()`.
struct RecordTransactionUseCase {
    enum Failure: Error, Equatable {
        case invalidQuantity
        case productNotFound
        case insufficientStock
    }

    let productRepository: ProductRepository
    let transactionRepository: TransactionRepository

    @discardableResult
    func callAsFunction(
        productID: UUID,
        type: TransactionType,
        quantity: Int,
        notes: String = ""
    ) throws -> StoreTransaction {
        guard quantity > 0 else { throw Failure.invalidQuantity }

        guard var product = try productRepository.fetch(id: productID) else {
            throw Failure.productNotFound
        }

        if type == .sale && quantity > product.stockQuantity {
            throw Failure.insufficientStock
        }

        product.stockQuantity += (type == .sale ? -quantity : quantity)

        let transaction = StoreTransaction(
            type: type,
            productID: product.id,
            productName: product.name,
            quantity: quantity,
            unitPrice: product.price,
            notes: notes
        )

        try productRepository.update(product)
        try transactionRepository.add(transaction)
        return transaction
    }
}
