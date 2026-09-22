import SwiftUI

struct DashboardView: View {
    @Bindable var model: DashboardViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Low Stock") {
                    if model.lowStockProducts.isEmpty {
                        Text("All products are well stocked")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(model.lowStockProducts) { product in
                            LowStockRow(product: product)
                        }
                    }
                }

                Section("Recent Transactions") {
                    if model.recentTransactions.isEmpty {
                        Text("No transactions yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(model.recentTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .errorAlert($model.errorMessage)
            .onAppear { model.load() }
        }
    }
}

private struct LowStockRow: View {
    let product: Product

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.headline)
                Text(product.category.isEmpty ? "No category" : product.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(product.stockQuantity)")
                    .font(.headline)
                    .foregroundStyle(product.stockQuantity == 0 ? .red : .orange)
                Text("/ \(product.lowStockThreshold) threshold")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct TransactionRow: View {
    let transaction: StoreTransaction

    var body: some View {
        HStack {
            Image(systemName: transaction.type == .sale ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundStyle(transaction.type == .sale ? .red : .green)
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.productName)
                    .font(.subheadline)
                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(transaction.type == .sale ? "-" : "+")\(transaction.quantity)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(transaction.type == .sale ? .red : .green)
        }
    }
}
