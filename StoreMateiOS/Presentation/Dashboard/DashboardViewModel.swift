import Foundation
import Observation

@Observable
final class DashboardViewModel {
    private let fetchLowStock: FetchLowStockProductsUseCase
    private let transactionRepository: TransactionRepository

    var lowStockProducts: [Product] = []
    var recentTransactions: [StoreTransaction] = []
    var errorMessage: String?

    init(fetchLowStock: FetchLowStockProductsUseCase, transactionRepository: TransactionRepository) {
        self.fetchLowStock = fetchLowStock
        self.transactionRepository = transactionRepository
    }

    func load() {
        do {
            lowStockProducts = try fetchLowStock()
            recentTransactions = Array(try transactionRepository.fetchAll().prefix(10))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
