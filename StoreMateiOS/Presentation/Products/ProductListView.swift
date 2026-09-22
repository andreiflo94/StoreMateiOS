import SwiftUI

struct ProductListView: View {
    @Bindable var model: ProductListViewModel
    @Environment(AppContainer.self) private var container

    @State private var showingForm = false
    @State private var productToEdit: Product?
    @State private var showingScanner = false
    @State private var scannedBarcode: String?

    var body: some View {
        NavigationStack {
            List {
                ForEach(model.filtered) { product in
                    ProductRow(product: product)
                        .contentShape(Rectangle())
                        .onTapGesture { productToEdit = product }
                }
                .onDelete(perform: model.delete)
            }
            .searchable(text: $model.searchText, prompt: "Name, barcode or category")
            .navigationTitle("Products")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showingScanner = true
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                    }
                    Button { showingForm = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingForm, onDismiss: { scannedBarcode = nil; model.load() }) {
                ProductFormView(model: container.makeProductFormViewModel(initialBarcode: scannedBarcode))
            }
            .sheet(item: $productToEdit, onDismiss: { model.load() }) { product in
                ProductFormView(model: container.makeProductFormViewModel(editing: product))
            }
#if os(iOS)
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerContainerView { code in
                    scannedBarcode = code
                    showingScanner = false
                    showingForm = true
                }
            }
#endif
            .errorAlert($model.errorMessage)
            .onAppear { model.load() }
        }
    }
}

private struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.headline)
                HStack(spacing: 6) {
                    if !product.category.isEmpty {
                        Text(product.category)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.quaternary, in: Capsule())
                    }
                    if !product.barcode.isEmpty {
                        Label(product.barcode, systemImage: "barcode")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(product.price, format: .currency(code: "USD"))
                    .font(.subheadline)
                HStack(spacing: 2) {
                    if product.isLowStock {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.caption2)
                    }
                    Text("Qty: \(product.stockQuantity)")
                        .font(.caption)
                        .foregroundStyle(product.isLowStock ? .orange : .secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
