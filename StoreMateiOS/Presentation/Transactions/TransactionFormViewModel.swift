import Foundation
import Observation

@Observable
final class TransactionFormViewModel {
    private let recordTransaction: RecordTransactionUseCase
    private let productRepository: ProductRepository

    var products: [Product] = []
    var selectedProduct: Product?
    var type: TransactionType = .sale
    var quantity = "1"
    var notes = ""
    var errorMessage: String?

    init(recordTransaction: RecordTransactionUseCase, productRepository: ProductRepository) {
        self.recordTransaction = recordTransaction
        self.productRepository = productRepository
    }

    func load() {
        do {
            products = try productRepository.fetchAll()
            if let selectedProduct {
                self.selectedProduct = products.first { $0.id == selectedProduct.id }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var quantityValue: Int { Int(quantity) ?? 0 }

    /// Projected stock after this transaction, for the form's summary section.
    var newStock: Int? {
        guard let selectedProduct else { return nil }
        return type == .sale
            ? selectedProduct.stockQuantity - quantityValue
            : selectedProduct.stockQuantity + quantityValue
    }

    var canSave: Bool {
        guard let selectedProduct, quantityValue > 0 else { return false }
        if type == .sale && quantityValue > selectedProduct.stockQuantity { return false }
        return true
    }

    func save() -> Bool {
        guard let selectedProduct else { return false }
        do {
            try recordTransaction(
                productID: selectedProduct.id,
                type: type,
                quantity: quantityValue,
                notes: notes
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
