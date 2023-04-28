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
    
    @EnvironmentObject private var imageStorage: FirebaseImageStorage
    
    @Binding private var personId: Person.ID?
    
    @State private var searchText = ""
    
    init(personId: Binding<Person.ID?>) {
        self._personId = personId
    }
    
    var body: some View {
        NavigationView {
            List {
                let sortedPersons = self.appProperties.sortedPersons.sortedSearchableList(search: self.searchText)
                ForEach(sortedPersons) { person in
                    Button {
                        self.personId = person.id
                        self.dismiss()
                    } label: {
                        HStack {
                            if let image = self.imageStorage.personImages[person.id] {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person")
                                    .frame(width: 30, height: 30)
                                    .unredacted()
                            }
                            Text(person.name.formatted())
                        }.foregroundColor(.primary)
                            .task {
                                await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: person.id))
                            }
                    }
                }
            }.navigationTitle(String(localized: "fine-pick-person|title", comment: "Title of fine pick person."))
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: self.$searchText, prompt: String(localized: "fine-pick-person|search-placeholder", comment: "Placeholder text of search bar in fine pick person."))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.dismiss()
                        } label: {
                            Text("cancel-button", comment: "Text of cancel button.")
                        }
                    }
                }
        }
    }
}
