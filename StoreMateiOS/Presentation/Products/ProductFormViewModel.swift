import Foundation
import Observation

@Observable
final class ProductFormViewModel {
    private let repository: ProductRepository
    private let supplierRepository: SupplierRepository
    private let editingProduct: Product?

    var name = ""
    var barcode = ""
    var price = ""
    var stockQuantity = ""
    var lowStockThreshold = "5"
    var category = ""
    var selectedSupplier: Supplier?
    var suppliers: [Supplier] = []
    var errorMessage: String?

    init(
        repository: ProductRepository,
        supplierRepository: SupplierRepository,
        editing product: Product? = nil,
        initialBarcode: String? = nil
    ) {
        self.repository = repository
        self.supplierRepository = supplierRepository
        self.editingProduct = product

        if let product {
            name = product.name
            barcode = product.barcode
            price = String(product.price)
            stockQuantity = String(product.stockQuantity)
            lowStockThreshold = String(product.lowStockThreshold)
            category = product.category
            selectedSupplier = product.supplier
        } else if let initialBarcode {
            barcode = initialBarcode
        }
    }

    var isEditing: Bool { editingProduct != nil }
    var title: String { isEditing ? "Edit Product" : "New Product" }
    var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    func load() {
        do {
            suppliers = try supplierRepository.fetchAll()
            // Re-bind the selection to the freshly fetched instance so the Picker matches.
            if let selectedSupplier {
                self.selectedSupplier = suppliers.first { $0.id == selectedSupplier.id }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Persists the product. Returns `true` on success so the view can dismiss.
    func save() -> Bool {
        guard isValid else { return false }

        let product = Product(
            id: editingProduct?.id ?? UUID(),
            name: name,
            barcode: barcode,
            price: Double(price) ?? 0,
            stockQuantity: Int(stockQuantity) ?? 0,
            lowStockThreshold: Int(lowStockThreshold) ?? 5,
            category: category,
            supplier: selectedSupplier,
            createdAt: editingProduct?.createdAt ?? Date()
        )

        do {
            if isEditing {
                try repository.update(product)
            } else {
                try repository.add(product)
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
