import SwiftUI

struct ProductFormView: View {
    @State private var model: ProductFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingScanner = false

    init(model: ProductFormViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $model.name)
                    HStack {
                        TextField("Barcode", text: $model.barcode)
                        Button {
                            showingScanner = true
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                        }
                        .buttonStyle(.borderless)
                    }
                    TextField("Category", text: $model.category)
                }

                Section("Pricing & Stock") {
                    TextField("Price", text: $model.price)
                        .keyboardType(.decimalPad)
                    TextField("Stock Quantity", text: $model.stockQuantity)
                        .keyboardType(.numberPad)
                    TextField("Low Stock Threshold", text: $model.lowStockThreshold)
                        .keyboardType(.numberPad)
                }

                Section("Supplier") {
                    Picker("Supplier", selection: $model.selectedSupplier) {
                        Text("None").tag(Optional<Supplier>.none)
                        ForEach(model.suppliers) { supplier in
                            Text(supplier.name).tag(Optional(supplier))
                        }
                    }
                }
            }
            .navigationTitle(model.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if model.save() { dismiss() }
                    }
                    .disabled(!model.isValid)
                }
            }
#if os(iOS)
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerContainerView { code in
                    model.barcode = code
                    showingScanner = false
                }
            }
#endif
            .errorAlert($model.errorMessage)
            .onAppear { model.load() }
        }
    }
}
