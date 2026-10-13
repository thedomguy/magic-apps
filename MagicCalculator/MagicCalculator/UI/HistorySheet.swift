import SwiftUI

struct HistorySheet: View {
    @ObservedObject var engine: CalculatorEngine
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var selectedIDs: Set<UUID> = []

    var body: some View {
        NavigationStack {
            Group {
                if engine.history.isEmpty {
                    ContentUnavailableView(
                        "No History",
                        systemImage: "clock",
                        description: Text("Completed calculations will appear here.")
                    )
                } else {
                    List {
                        ForEach(groupedSections, id: \.title) { section in
                            Section {
                                ForEach(section.entries) { entry in
                                    historyRow(entry)
                                }
                            } header: {
                                Text(section.title)
                                    .font(.subheadline)
                                    .foregroundStyle(CalculatorTheme.historySection)
                                    .textCase(nil)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(CalculatorTheme.historySheet.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !engine.history.isEmpty {
                        Button(isEditing ? "Done" : "Edit") {
                            withAnimation {
                                isEditing.toggle()
                                if !isEditing { selectedIDs.removeAll() }
                            }
                        }
                        .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Color.white.opacity(0.15)))
                    }
                    .accessibilityLabel("Close")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                if isEditing && !selectedIDs.isEmpty {
                    Button(role: .destructive) {
                        engine.deleteHistory(ids: selectedIDs)
                        selectedIDs.removeAll()
                        if engine.history.isEmpty { isEditing = false }
                    } label: {
                        Text("Delete")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(CalculatorTheme.historySheet)
    }

    @ViewBuilder
    private func historyRow(_ entry: HistoryEntry) -> some View {
        Button {
            if isEditing {
                if selectedIDs.contains(entry.id) {
                    selectedIDs.remove(entry.id)
                } else {
                    selectedIDs.insert(entry.id)
                }
            } else {
                engine.applyHistoryResult(entry)
                dismiss()
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                if isEditing {
                    Image(systemName: selectedIDs.contains(entry.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(selectedIDs.contains(entry.id) ? Color.accentColor : Color.white.opacity(0.35))
                        .padding(.top, 4)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.expression)
                        .font(.subheadline)
                        .foregroundStyle(CalculatorTheme.historyExpression)
                    Text(entry.result)
                        .font(.title2.weight(.regular))
                        .foregroundStyle(CalculatorTheme.historyResult)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
        .listRowSeparatorTint(CalculatorTheme.historyDivider)
    }

    private var groupedSections: [(title: String, entries: [HistoryEntry])] {
        var order: [String] = []
        var map: [String: [HistoryEntry]] = [:]
        for entry in engine.history {
            let title = entry.monthSectionTitle
            if map[title] == nil {
                order.append(title)
                map[title] = []
            }
            map[title, default: []].append(entry)
        }
        return order.map { (title: $0, entries: map[$0] ?? []) }
    }
}
