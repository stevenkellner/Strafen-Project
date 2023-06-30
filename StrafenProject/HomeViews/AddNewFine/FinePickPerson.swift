//
//  FinePickPerson.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct FinePickPerson: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var settingsManager: SettingsManager
    
    @Binding private var personIds: [Person.ID]
    
    @State private var isFirstPersonSelect: Bool
    
    @State private var searchText = ""
    
    init(personIds: Binding<[Person.ID]>) {
        self._personIds = personIds
        self._isFirstPersonSelect = State(initialValue: personIds.wrappedValue.isEmpty)
    }
    
    var body: some View {
        NavigationView {
            List {
                let sortedPersons = self.appProperties.sortedPersons(by: self.settingsManager.sorting.personSorting).searchableGroup(search: self.searchText)
                ForEach(sortedPersons) { person in
                    Button {
                        if !self.personIds.contains(person.id) {
                            self.personIds.append(person.id)
                        } else {
                            self.personIds = self.personIds.filter { $0 != person.id }
                        }
                        if self.isFirstPersonSelect {
                            self.dismiss()
                        }
                    } label: {
                        PersonListView.PersonRow(person)
                            .amountHidden
                            .foregroundColor(self.personIds.contains(person.id) ? .green : .primary)
                    }
                }
            }.modifier(self.rootModifiers)
        }
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        NavigationTitleModifier(localized: LocalizedStringResource("fine-pick-person|title", comment: "Title of fine pick person."), displayMode: .large)
        SearchableModifier(text: self.$searchText, prompt: String(localized: "fine-pick-person|search-placeholder", comment: "Placeholder text of search bar in fine pick person."))
        ToolbarModifier {
            ToolbarButton(placement: .topBarTrailing, localized: self.isFirstPersonSelect ?  LocalizedStringResource("cancel-button", comment: "Text of cancel button.") : LocalizedStringResource("fine-pick-person|select-button", comment: "Text of select button.")) {
                self.dismiss()
            }
        }
    }
}
