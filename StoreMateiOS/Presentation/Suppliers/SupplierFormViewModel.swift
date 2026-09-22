import Foundation
import Observation

@Observable
final class SupplierFormViewModel {
    private let repository: SupplierRepository
    private let editingSupplier: Supplier?

    var name = ""
    var contactPerson = ""
    var email = ""
    var phone = ""
    var address = ""
    var errorMessage: String?

    init(repository: SupplierRepository, editing supplier: Supplier? = nil) {
        self.repository = repository
        self.editingSupplier = supplier

        if let supplier {
            name = supplier.name
            contactPerson = supplier.contactPerson
            email = supplier.email
            phone = supplier.phone
            address = supplier.address
        }
    }

    var isEditing: Bool { editingSupplier != nil }
    var title: String { isEditing ? "Edit Supplier" : "New Supplier" }
    var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    func save() -> Bool {
        guard isValid else { return false }

        let supplier = Supplier(
            id: editingSupplier?.id ?? UUID(),
            name: name,
            contactPerson: contactPerson,
            email: email,
            phone: phone,
            address: address
        )

        do {
            if isEditing {
                try repository.update(supplier)
            } else {
                try repository.add(supplier)
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
