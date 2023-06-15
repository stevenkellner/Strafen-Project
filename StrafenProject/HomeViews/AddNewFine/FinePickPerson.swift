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
    
    @Binding private var personId: Person.ID?
    
    @State private var searchText = ""
    
    init(personId: Binding<Person.ID?>) {
        self._personId = personId
    }
    
    var body: some View {
        NavigationView {
            List {
                let sortedPersons = self.appProperties.sortedPersons(by: self.settingsManager.sorting.personSorting).searchableGroup(search: self.searchText)
                ForEach(sortedPersons) { person in
                    Button {
                        self.personId = person.id
                        self.dismiss()
                    } label: {
                        PersonListView.PersonRow(person)
                            .amountHidden
                            .foregroundColor(.primary)
                    }
                }
            }.modifier(self.rootModifiers)
        }
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        NavigationTitleModifier(localized: LocalizedStringResource("fine-pick-person|title", comment: "Title of fine pick person."), displayMode: .large)
        SearchableModifier(text: self.$searchText, prompt: String(localized: "fine-pick-person|search-placeholder", comment: "Placeholder text of search bar in fine pick person."))
        ToolbarModifier {
            ToolbarButton(placement: .topBarTrailing, localized: LocalizedStringResource("cancel-button", comment: "Text of cancel button.")) {
                self.dismiss()
            }
        }
    }
}
