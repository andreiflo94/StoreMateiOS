import SwiftUI

struct TransactionListView: View {
    @Bindable var model: TransactionListViewModel
    @Environment(AppContainer.self) private var container

    @State private var showingForm = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(model.filtered) { transaction in
                    TransactionDetailRow(transaction: transaction)
                }
                .onDelete(perform: model.delete)
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    filterMenu
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingForm = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingForm, onDismiss: { model.load() }) {
                TransactionFormView(model: container.makeTransactionFormViewModel())
            }
            .errorAlert($model.errorMessage)
            .onAppear { model.load() }
        }
    }

    private var filterMenu: some View {
        Menu {
            Section("Filter") {
                Button {
                    model.filterType = nil
                } label: {
                    Label("All", systemImage: model.filterType == nil ? "checkmark" : "")
                }
                Button {
                    model.filterType = .sale
                } label: {
                    Label("Sales", systemImage: model.filterType == .sale ? "checkmark" : "")
                }
                Button {
                    model.filterType = .restock
                } label: {
                    Label("Restocks", systemImage: model.filterType == .restock ? "checkmark" : "")
                }
            }
            Section("Sort") {
                Button {
                    model.sortNewestFirst = true
                } label: {
                    Label("Newest First", systemImage: model.sortNewestFirst ? "checkmark" : "")
                }
                Button {
                    model.sortNewestFirst = false
                } label: {
                    Label("Oldest First", systemImage: model.sortNewestFirst ? "" : "checkmark")
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
}

private struct TransactionDetailRow: View {
    let transaction: StoreTransaction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.type == .sale ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.title2)
                .foregroundStyle(transaction.type == .sale ? .red : .green)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.productName)
                    .font(.headline)
                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !transaction.notes.isEmpty {
                    Text(transaction.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.type == .sale ? "-" : "+")\(transaction.quantity)")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(transaction.type == .sale ? .red : .green)
                Text(transaction.type.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
