//
//  PersonDetail.swift
//  StrafenProject
//
//  Created by Steven on 26.04.23.
//

import SwiftUI

struct PersonDetail: View {
    
    @Environment(\.redactionReasons) private var redactionReasons
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @Binding private var person: Person
        
    @State private var isEditPersonSheetShown = false
    
    @State private var isAddNewFineSheetShown = false
    
    init(_ person: Binding<Person>) {
        self._person = person
    }
    
    var body: some View {
        List {
            PersonInfoSection(self.person) {
                if self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder) {
                    Button {
                        self.isAddNewFineSheetShown = true
                    } label: {
                        HStack {
                            Text("person-detail|add-new-fine-button", comment: "Text of add new fine button.")
                            Spacer()
                            Image(systemName: "plus.viewfinder")
                        }
                    }
                }
            }
            FineListView(of: self.person)
        }.modifier(self.rootModifiers)
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        DismissHandlerModifier()
        NavigationTitleModifier(self.person.name.formatted(.long), displayMode: .large)
        RefreshableModifier {
            await self.appProperties.refresh()
        }
        if self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder) {
            ToolbarModifier {
                if self.person.signInData == nil {
                    InvitationButton(placement: .topBarTrailing, person: self.person)
                }
                ToolbarButton(placement: .topBarTrailing, localized: LocalizedStringResource("edit-button", comment: "Text of the edit button.")) {
                    self.isEditPersonSheetShown = true
                }
            }
            SheetModifier(isPresented: self.$isEditPersonSheetShown) {
                PersonAddAndEdit(person: self.personBinding)
            }
            SheetModifier(isPresented: self.$isAddNewFineSheetShown) {
                FineAddAndEdit(personId: self.person.id, referrer: .addNewFineList)
            }
        }
    }
    
    private var personBinding: Binding<Person?> {
        return Binding {
            return self.appProperties.persons[self.person.id] ?? self.person
        } set: { person in
            if let person {
                self.person = person
            }
        }
    }
}
