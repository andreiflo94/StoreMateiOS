import SwiftUI

struct TransactionFormView: View {
    @State private var model: TransactionFormViewModel
    @Environment(\.dismiss) private var dismiss

    init(model: TransactionFormViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    Picker("Product", selection: $model.selectedProduct) {
                        Text("Select a product").tag(Optional<Product>.none)
                        ForEach(model.products) { product in
                            HStack {
                                Text(product.name)
                                Spacer()
                                Text("Stock: \(product.stockQuantity)")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            .tag(Optional(product))
                        }
                    }
                }

                Section("Transaction") {
                    Picker("Type", selection: $model.type) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Quantity", text: $model.quantity)
                        .keyboardType(.numberPad)
                }

                Section("Notes") {
                    TextField("Optional notes", text: $model.notes, axis: .vertical)
                        .lineLimit(3...)
                }

                if let product = model.selectedProduct, let newStock = model.newStock {
                    Section("Summary") {
                        LabeledContent("Current Stock", value: "\(product.stockQuantity)")
                        LabeledContent("New Stock", value: "\(max(0, newStock))")
                            .foregroundStyle(newStock < 0 ? .red : .primary)
                    }
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if model.save() { dismiss() }
                    }
                    .disabled(!model.canSave)
                }
            }
            .errorAlert($model.errorMessage)
            .onAppear { model.load() }
        }
    }
}
