import Foundation

/// Domain entity representing a vendor. Framework-free value type.
struct Supplier: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var contactPerson: String
    var email: String
    var phone: String
    var address: String

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
    }
}
