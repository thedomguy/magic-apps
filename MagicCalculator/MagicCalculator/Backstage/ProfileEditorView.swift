import SwiftUI

/// Edits save as you go, like Settings; swiping back just leaves.
struct ProfileEditorView: View {
    let id: Profile.ID

    @EnvironmentObject private var store: ProfileStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDelete = false
    @FocusState private var focusedField: ProfileField.ID?

    /// A field longer than this can't be keyed as one number (the calculator caps entries at 9 digits).
    private static let maxDigitsPerNumber = 9

    var body: some View {
        if let profile = store.profile(id: id) {
            form(profile)
        } else {
            ContentUnavailableView("Profile Deleted", systemImage: "rectangle.stack")
        }
    }

    private func form(_ profile: Profile) -> some View {
        Form {
            Section {
                TextField("Name", text: binding(\.name), prompt: Text("Profile \(profile.slot)"))
                Picker("Key", selection: Binding(
                    get: { profile.slot },
                    set: { store.move(id, toSlot: $0) }
                )) {
                    ForEach(Array(Profile.slotRange), id: \.self) { slot in
                        Text(slotTitle(slot, editing: profile)).tag(slot)
                    }
                }
            } footer: {
                Text("Hold \(profile.slot) on the calculator for 1.5 seconds to load this profile.")
            }

            Section {
                ForEach(Array(profile.fields.enumerated()), id: \.element.id) { index, field in
                    fieldRow(field, index: index, profile: profile)
                }
                .onDelete { offsets in
                    store.update(id) { $0.fields.remove(atOffsets: offsets) }
                }
                .onMove { from, to in
                    store.update(id) { $0.fields.move(fromOffsets: from, toOffset: to) }
                }
                .deleteDisabled(profile.fields.count <= 1)

                Button {
                    let field = ProfileField(label: "", digitCount: 2)
                    store.update(id) { $0.fields.append(field) }
                    focusedField = field.id
                } label: {
                    Label("Add Field", systemImage: "plus")
                }
            } header: {
                Text("Fields")
            } footer: {
                Text(fieldsFooter(profile))
            }

            Section("Shown when loaded") {
                Text(profile.flashText)
                    .font(.system(size: 22, weight: .light))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
            }

            Section {
                Button("Delete Profile", role: .destructive) { confirmDelete = true }
            }
        }
        .navigationTitle(profile.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete \(profile.displayName)?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete Profile", role: .destructive) {
                dismiss()
                store.delete(id)
            }
        }
    }

    private func fieldRow(_ field: ProfileField, index: Int, profile: Profile) -> some View {
        HStack {
            TextField("Field \(index + 1)", text: Binding(
                get: { field.label },
                set: { newValue in updateField(field.id) { $0.label = newValue } }
            ))
            .focused($focusedField, equals: field.id)

            Stepper(value: Binding(
                get: { field.digitCount },
                set: { newValue in updateField(field.id) { $0.digitCount = newValue } }
            ), in: ProfileField.digitRange) {
                Text("\(field.digitCount) digit\(field.digitCount == 1 ? "" : "s")")
                    .monospacedDigit()
                    .foregroundStyle(
                        !profile.isSingleField && field.digitCount > Self.maxDigitsPerNumber
                            ? Color.red : Color.secondary
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .fixedSize()
        }
    }

    private func fieldsFooter(_ profile: Profile) -> String {
        if profile.isSingleField {
            return "Keyed in as a run of additions until all \(profile.fields[0].digitCount) digits are in."
        }
        var text = "Each field is one number in a multiplication, in this order."
        if profile.fields.contains(where: { $0.digitCount > Self.maxDigitsPerNumber }) {
            text += " A single number can't go past \(Self.maxDigitsPerNumber) digits."
        }
        return text
    }

    private func slotTitle(_ slot: Int, editing profile: Profile) -> String {
        guard slot != profile.slot, let other = store.profile(slot: slot) else { return "\(slot)" }
        return "\(slot) · swap with \(other.displayName)"
    }

    private func binding(_ keyPath: WritableKeyPath<Profile, String>) -> Binding<String> {
        Binding(
            get: { store.profile(id: id)?[keyPath: keyPath] ?? "" },
            set: { newValue in store.update(id) { $0[keyPath: keyPath] = newValue } }
        )
    }

    private func updateField(_ fieldID: ProfileField.ID, _ change: (inout ProfileField) -> Void) {
        store.update(id) { profile in
            guard let index = profile.fields.firstIndex(where: { $0.id == fieldID }) else { return }
            change(&profile.fields[index])
        }
    }
}
