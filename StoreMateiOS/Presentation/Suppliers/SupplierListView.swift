import SwiftUI

struct SupplierListView: View {
    @Bindable var model: SupplierListViewModel
    @Environment(AppContainer.self) private var container

    @State private var showingForm = false
    @State private var supplierToEdit: Supplier?

    var body: some View {
        NavigationStack {
            List {
                ForEach(model.filtered) { supplier in
                    SupplierRow(supplier: supplier)
                        .contentShape(Rectangle())
                        .onTapGesture { supplierToEdit = supplier }
                }
                .onDelete(perform: model.delete)
            }
            .searchable(text: $model.searchText, prompt: "Name, contact or email")
            .navigationTitle("Suppliers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingForm = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingForm, onDismiss: { model.load() }) {
                SupplierFormView(model: container.makeSupplierFormViewModel())
            }
            .sheet(item: $supplierToEdit, onDismiss: { model.load() }) { supplier in
                SupplierFormView(model: container.makeSupplierFormViewModel(editing: supplier))
            }
            .errorAlert($model.errorMessage)
            .onAppear { model.load() }
        }
    }
}

private struct SupplierRow: View {
    let supplier: Supplier

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(supplier.name)
                .font(.headline)
            HStack(spacing: 12) {
                if !supplier.contactPerson.isEmpty {
                    Label(supplier.contactPerson, systemImage: "person")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !supplier.email.isEmpty {
                    Label(supplier.email, systemImage: "envelope")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if !supplier.phone.isEmpty {
                Label(supplier.phone, systemImage: "phone")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
