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
    
    @EnvironmentObject private var imageStorage: FirebaseImageStorage
    
    private let person: Person
        
    @State private var isEditPersonSheetShown = false
    
    init(_ person: Person) {
        self.person = person
    }
    
    var body: some View {
        List {
            Section {
                if let image = self.imageStorage.personImages[self.person.id] {
                    HStack {
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        Spacer()
                    }
                }
                HStack {
                    Text("person-detail|still-open-amount", comment: "Text for the fine amount of the person that is still open.")
                    Spacer()
                    Text(self.appProperties.fines(of: self.person).unpayedAmount.formatted)
                        .foregroundColor(.red)
                }
                HStack {
                    Text("person-detail|total-amount", comment: "Text for the total fine amount of the person.")
                    Spacer()
                    Text(self.appProperties.fines(of: self.person).totalAmount.formatted)
                        .foregroundColor(.green)
                }
            }
            let sortedFines = self.appProperties.sortedFines(of: self.person)
            if !sortedFines.unpayedFines.isEmpty {
                Section {
                    ForEach(sortedFines.unpayedFines) { fine in
                        PersonDetail.FineRow(fine)
                    }
                } header: {
                    Text("person-detail|open-fines", comment: "Section text of still open fines.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                }
            }
            if !sortedFines.payedFines.isEmpty {
                Section {
                    ForEach(sortedFines.payedFines) { fine in
                        PersonDetail.FineRow(fine)
                    }
                } header: {
                    Text("person-detail|payed-fines", comment: "Section text of already payed fines.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                }
            }
        }.navigationTitle(self.person.name.formatted(.long))
            .navigationBarTitleDisplayMode(.large)
            .task {
                await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: self.person.id))
            }
            .if(self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder)) { view in
                view.toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                self.isEditPersonSheetShown = true
                            } label: {
                                Text("edit-button", comment: "Text of the edit button.")
                            }
                        }
                    }
                    .sheet(isPresented: self.$isEditPersonSheetShown) {
                        PersonAddAndEdit(person: self.person)
                    }
            }
    }
}

extension PersonDetail {
    struct FineRow: View {
        
        @Environment(\.redactionReasons) private var redactionReasons
        
        @EnvironmentObject private var appProperties: AppProperties
        
        @EnvironmentObject private var imageStorage: FirebaseImageStorage

        private let fine: Fine
        
        init(_ fine: Fine) {
            self.fine = fine
        }
        
        var body: some View {
            NavigationLink {
                Text(self.fine.formatted) // TODO
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(self.fine.formatted)
                        Text(self.fine.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(self.fine.totalAmount.formatted)
                        .foregroundColor(self.fine.isPayed ? .green : .red)
                }
            }.disabled(self.redactionReasons.contains(.placeholder))
                .if(self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder)) { view in
                    view.swipeActions {
                        Button(role: .destructive) {
                            Task {
                                await self.deleteFine()
                            }
                        } label: {
                            Label(String(localized: "delete-button", comment: "Text of delete button."), systemImage: "trash")
                                .unredacted()
                        }
                    }
                }
        }
        
        private func deleteFine() async {
            do {
                let fineEditFunction = FineEditFunction.delete(clubId: self.appProperties.club.id, fineId: self.fine.id)
                try await FirebaseFunctionCaller.shared.call(fineEditFunction)
                self.appProperties.fines[self.fine.id] = nil
                self.appProperties.persons[self.fine.personId]?.fineIds.removeAll { $0 == fine.id }
            } catch {}
        }
    }
}
