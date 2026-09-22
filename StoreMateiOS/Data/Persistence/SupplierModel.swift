import Foundation
import SwiftData

/// SwiftData persistence model for a supplier. Lives in the Data layer; mapped to
/// the framework-free `Supplier` domain entity via `SupplierMapper`.
@Model
final class SupplierModel {
    var id: UUID
    var name: String
    var contactPerson: String
    var email: String
    var phone: String
    var address: String
    @Relationship(deleteRule: .nullify, inverse: \ProductModel.supplier) var products: [ProductModel]

    init(
        id: UUID = UUID(),
        name: String,
        contactPerson: String = "",
        email: String = "",
        phone: String = "",
        address: String = ""
    ) {
        self.id = id
        self.name = name
        self.contactPerson = contactPerson
        self.email = email
        self.phone = phone
        self.address = address
        self.products = []
    }
}
