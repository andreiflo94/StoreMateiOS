import SwiftUI

struct SupplierFormView: View {
    @State private var model: SupplierFormViewModel
    @Environment(\.dismiss) private var dismiss

    init(model: SupplierFormViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Company") {
                    TextField("Name", text: $model.name)
                    TextField("Contact Person", text: $model.contactPerson)
                }
                Section("Contact") {
                    TextField("Email", text: $model.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone", text: $model.phone)
                        .keyboardType(.phonePad)
                    TextField("Address", text: $model.address, axis: .vertical)
                        .lineLimit(3...)
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
            .errorAlert($model.errorMessage)
        }
    }
}
