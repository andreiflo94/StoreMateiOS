import Foundation
import Observation

@Observable
final class TransactionListViewModel {
    private let repository: TransactionRepository

    var transactions: [StoreTransaction] = []
    var filterType: TransactionType?
    var sortNewestFirst = true
    var errorMessage: String?

    init(repository: TransactionRepository) {
        self.repository = repository
    }

    /// `transactions` arrives newest-first from the repository.
    var filtered: [StoreTransaction] {
        var result = transactions
        if let filterType {
            result = result.filter { $0.type == filterType }
        }
        return sortNewestFirst ? result : result.reversed()
    }

    func load() {
        do {
            transactions = try repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(at offsets: IndexSet) {
        let targets = offsets.map { filtered[$0] }
        do {
            for transaction in targets {
                try repository.delete(id: transaction.id)
            }
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
