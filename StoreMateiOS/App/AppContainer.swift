import Foundation
import SwiftData
import Observation

/// Composition root. Owns the SwiftData `ModelContext`, builds the concrete
/// repositories and use cases, and vends ViewModels to the Presentation layer.
/// Injected into the SwiftUI environment so sheet-presented forms can build their
/// own ViewModels on demand.
@MainActor
@Observable
final class AppContainer {
    @ObservationIgnored private let modelContext: ModelContext

    @ObservationIgnored private lazy var productRepository: ProductRepository =
        SwiftDataProductRepository(context: modelContext)
    @ObservationIgnored private lazy var supplierRepository: SupplierRepository =
        SwiftDataSupplierRepository(context: modelContext)
    @ObservationIgnored private lazy var transactionRepository: TransactionRepository =
        SwiftDataTransactionRepository(context: modelContext)

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: Use cases

    private var recordTransaction: RecordTransactionUseCase {
        RecordTransactionUseCase(
            productRepository: productRepository,
            transactionRepository: transactionRepository
        )
    }

    private var fetchLowStock: FetchLowStockProductsUseCase {
        FetchLowStockProductsUseCase(productRepository: productRepository)
    }

    // MARK: ViewModel factories

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(fetchLowStock: fetchLowStock, transactionRepository: transactionRepository)
    }

    func makeProductListViewModel() -> ProductListViewModel {
        ProductListViewModel(repository: productRepository)
    }

    func makeProductFormViewModel(editing product: Product? = nil, initialBarcode: String? = nil) -> ProductFormViewModel {
        ProductFormViewModel(
            repository: productRepository,
            supplierRepository: supplierRepository,
            editing: product,
            initialBarcode: initialBarcode
        )
    }

    func makeSupplierListViewModel() -> SupplierListViewModel {
        SupplierListViewModel(repository: supplierRepository)
    }

    func makeSupplierFormViewModel(editing supplier: Supplier? = nil) -> SupplierFormViewModel {
        SupplierFormViewModel(repository: supplierRepository, editing: supplier)
    }

    func makeTransactionListViewModel() -> TransactionListViewModel {
        TransactionListViewModel(repository: transactionRepository)
    }

    func makeTransactionFormViewModel() -> TransactionFormViewModel {
        TransactionFormViewModel(recordTransaction: recordTransaction, productRepository: productRepository)
    }
}
