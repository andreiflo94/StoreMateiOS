import SwiftUI

struct ContentView: View {
    private let container: AppContainer
    @State private var dashboard: DashboardViewModel
    @State private var products: ProductListViewModel
    @State private var suppliers: SupplierListViewModel
    @State private var transactions: TransactionListViewModel

    init(container: AppContainer) {
        self.container = container
        _dashboard = State(initialValue: container.makeDashboardViewModel())
        _products = State(initialValue: container.makeProductListViewModel())
        _suppliers = State(initialValue: container.makeSupplierListViewModel())
        _transactions = State(initialValue: container.makeTransactionListViewModel())
    }

    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "chart.bar.fill") {
                DashboardView(model: dashboard)
            }
            Tab("Products", systemImage: "shippingbox.fill") {
                ProductListView(model: products)
            }
            Tab("Suppliers", systemImage: "building.2.fill") {
                SupplierListView(model: suppliers)
            }
            Tab("Transactions", systemImage: "arrow.left.arrow.right") {
                TransactionListView(model: transactions)
            }
        }
        .environment(container)
    }
}
