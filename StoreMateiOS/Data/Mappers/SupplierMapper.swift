import Foundation

extension SupplierModel {
    func toDomain() -> Supplier {
        Supplier(
            id: id,
            name: name,
            contactPerson: contactPerson,
            email: email,
            phone: phone,
            address: address
        )
    }

    /// Applies domain values onto this persistence model (used when updating).
    func apply(_ supplier: Supplier) {
        name = supplier.name
        contactPerson = supplier.contactPerson
        email = supplier.email
        phone = supplier.phone
        address = supplier.address
    }
}
