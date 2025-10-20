//
//  AddablePickers.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/18/25.
//  This will be used by the CustomizeView page.

import SwiftUI

struct AddablePicker: View {
    let title: String
    @Binding var selections: Set<String>
    @Binding var options: [String]

    @State private var showSheet = false
    @State private var input = ""
    @State private var showAdd = false
    
    private var summary: String {
        if selections.isEmpty {
            "None"
        } else {
            selections.sorted().joined(separator: ", ")
        }
    }
    
    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack {
                Text(title)
                Spacer()
                Text(summary).lineLimit(1).truncationMode(.tail)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.down")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        // user should be able to select/deselect options
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                List {
                    // append items to list if chosen and delete from list if deselected
                    ForEach(options, id: \.self) { opt in
                        Button {
                            if selections.contains(opt) {
                                selections.remove(opt)
                            } else {
                                selections.insert(opt)
                            }
                        } label: {
                            HStack {
                                Text(opt)
                                Spacer()
                                // show checkmark if option is selected
                                if selections.contains(opt) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .navigationTitle(title)
                // toolbar should allow you to close the selection view by pressing done or add an item
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { showSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            input = ""; showAdd = true
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                // add choice if not shown already in list
                .sheet(isPresented: $showAdd) {
                    NavigationStack {
                        Form {
                            TextField("Enter new item", text: $input)
                                .textInputAutocapitalization(.words)
                        }
                        .navigationTitle("Add \(title.dropLast(title.hasSuffix("s") ? 1 : 0))")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { showAdd = false }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Add") {
                                    let new = input.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !new.isEmpty else { return }
                                    if !options.map({ $0.lowercased() }).contains(new.lowercased()) {
                                        options.append(new)
                                    }
                                    selections.insert(new)
                                    showAdd = false
                                }
                                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                    }
                }
            }
        }
    }
}
