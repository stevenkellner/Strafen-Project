//
//  FineListView.swift
//  StrafenProject
//
//  Created by Steven on 10.06.23.
//

import SwiftUI

struct FineListView<Person>: View where Person: PersonWithFines {
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var settingsManager: SettingsManager
    
    private let person: Person
    
    init(of person: Person) {
        self.person = person
    }
    
    var body: some View {
        let sortedFines = self.appProperties.sortedFinesGroups(of: self.person, by: self.settingsManager.sorting.fineSorting)
        self.listSection(fines: sortedFines.group(of: .unpayed), header: LocalizedStringResource("fine-list|open-fines", comment:  "Section header of still open fines."))
        self.listSection(fines: sortedFines.group(of: .payed), header: LocalizedStringResource("fine-list|payed-fines", comment:  "Section header of already payed fines."))
    }
    
    @ViewBuilder private func listSection(fines: [Fine], header: LocalizedStringResource) -> some View {
        if !fines.isEmpty {
            Section {
                ForEach(fines) { fine in
                    FineRow(fine, personName: self.person.name)
                }
            } header: {
                Text(header)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
                    .unredacted()
            }
        }
    }
    
    struct FineRow: View {
        
        @Environment(\.redactionReasons) private var redactionReasons
        
        @EnvironmentObject private var appProperties: AppProperties
        
        @EnvironmentObject private var imageStorage: FirebaseImageStorage
        
        private var fine: Fine
        
        private let personName: PersonName
        
        init(_ fine: Fine, personName: PersonName) {
            self.fine = fine
            self.personName = personName
        }
        
        var body: some View {
            NavigationLink {
                FineDetail(self.fineBinding, personName: self.personName)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(self.fine.reasonMessage)
                        Text(self.fine.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(self.fine.amount.formatted(.short))
                        .foregroundColor(self.fine.payedState == .payed ? .green : .red)
                }
            }.disabled(self.redactionReasons.contains(.placeholder))
                .modifier(self.rootModifiers)
        }
        
        @ModifierBuilder private var rootModifiers: some ViewModifier {
            if self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder) {
                SwipeActionsModifier {
                    Button(role: .destructive) {
                        await self.deleteFine()
                    } label: {
                        Label(String(localized: "delete-button", comment: "Text of delete button."), systemImage: "trash")
                            .unredacted()
                    }
                }
            }
        }
        
        private var fineBinding: Binding<Fine> {
            return Binding {
                return self.appProperties.fines[self.fine.id] ?? self.fine
            } set: { fine in
                self.appProperties.fines[fine.id] = fine
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
