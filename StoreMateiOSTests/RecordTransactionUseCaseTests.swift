import Testing
import Foundation
@testable import StoreMateiOS

@MainActor
struct RecordTransactionUseCaseTests {
    private func makeSUT(
        product: Product
    ) -> (RecordTransactionUseCase, InMemoryProductRepository, InMemoryTransactionRepository) {
        let productRepo = InMemoryProductRepository([product])
        let transactionRepo = InMemoryTransactionRepository()
        let sut = RecordTransactionUseCase(
            productRepository: productRepo,
            transactionRepository: transactionRepo
        )
        return (sut, productRepo, transactionRepo)
    }

    @Test func saleReducesStockAndSnapshotsProduct() throws {
        let product = Product(name: "Widget", price: 4.5, stockQuantity: 10)
        let (sut, productRepo, transactionRepo) = makeSUT(product: product)

        let transaction = try sut(productID: product.id, type: .sale, quantity: 3, notes: "hi")

        #expect(try productRepo.fetch(id: product.id)?.stockQuantity == 7)
        #expect(transactionRepo.transactions.count == 1)
        #expect(transaction.type == .sale)
        #expect(transaction.productName == "Widget")
        #expect(transaction.unitPrice == 4.5)
        #expect(transaction.quantity == 3)
        #expect(transaction.notes == "hi")
    }

    @Test func restockIncreasesStock() throws {
        let product = Product(name: "Widget", stockQuantity: 10)
        let (sut, productRepo, _) = makeSUT(product: product)

        try sut(productID: product.id, type: .restock, quantity: 5)

        #expect(try productRepo.fetch(id: product.id)?.stockQuantity == 15)
    }

    @Test func saleBeyondAvailableStockThrowsAndDoesNotMutate() throws {
        let product = Product(name: "Widget", stockQuantity: 2)
        let (sut, productRepo, transactionRepo) = makeSUT(product: product)

        #expect(throws: RecordTransactionUseCase.Failure.insufficientStock) {
            try sut(productID: product.id, type: .sale, quantity: 3)
        }
        #expect(try productRepo.fetch(id: product.id)?.stockQuantity == 2)
        #expect(transactionRepo.transactions.isEmpty)
    }

    @Test func nonPositiveQuantityThrows() throws {
        let product = Product(name: "Widget", stockQuantity: 10)
        let (sut, _, _) = makeSUT(product: product)

        #expect(throws: RecordTransactionUseCase.Failure.invalidQuantity) {
            try sut(productID: product.id, type: .sale, quantity: 0)
        }
    }

    @Test func unknownProductThrows() throws {
        let product = Product(name: "Widget", stockQuantity: 10)
        let (sut, _, _) = makeSUT(product: product)

        #expect(throws: RecordTransactionUseCase.Failure.productNotFound) {
            try sut(productID: UUID(), type: .sale, quantity: 1)
        }
    }
}
