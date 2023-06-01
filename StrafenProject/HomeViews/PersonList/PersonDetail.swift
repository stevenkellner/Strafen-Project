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
    
    @EnvironmentObject private var settingsManager: SettingsManager
    
    @Binding private var person: Person
        
    @State private var isEditPersonSheetShown = false
    
    @State private var isInvitationAlertShown = false
    
    @State private var invitationLink: String?
    
    @State private var isCreatedInvitationAlertShown = false
    
    @State private var isInviteButtonLoading = false
    
    @State private var isAddNewFineSheetShown = false
    
    init(_ person: Binding<Person>) {
        self._person = person
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
                        .unredacted()
                    Spacer()
                    Text(self.appProperties.fines(of: self.person).unpayedAmount.formatted(.short))
                        .foregroundColor(.red)
                }
                HStack {
                    Text("person-detail|total-amount", comment: "Text for the total fine amount of the person.")
                        .unredacted()
                    Spacer()
                    Text(self.appProperties.fines(of: self.person).totalAmount.formatted(.short))
                        .foregroundColor(.green)
                }
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
            let sortedFines = self.appProperties.sortedFinesGroups(of: self.person, by: self.settingsManager.sorting.fineSorting)
            let unpayedFines = sortedFines.sortedList(of: .unpayed)
            if !unpayedFines.isEmpty {
                Section {
                    ForEach(unpayedFines) { fine in
                        PersonDetail.FineRow(fine, personName: self.person.name)
                    }
                } header: {
                    Text("person-detail|open-fines", comment: "Section text of still open fines.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                        .unredacted()
                }
            }
            let payedFines = sortedFines.sortedList(of: .payed)
            if !payedFines.isEmpty {
                Section {
                    ForEach(payedFines) { fine in
                        PersonDetail.FineRow(fine, personName: self.person.name)
                    }
                } header: {
                    Text("person-detail|payed-fines", comment: "Section text of already payed fines.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                        .unredacted()
                }
            }
        }.dismissHandler
            .refreshable {
                await self.appProperties.refresh()
            }.navigationTitle(self.person.name.formatted(.long))
                .navigationBarTitleDisplayMode(.large)
                .task {
                    await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: self.person.id))
                }
                .if(self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder)) { view in
                    view.toolbar {
                        if self.person.signInData == nil {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                if self.isInviteButtonLoading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                } else {
                                    Button {
                                        self.isInvitationAlertShown = true
                                    } label: {
                                        Text("person-detail|invitation-button", comment: "Invite this person button in person detail.")
                                    }
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                self.isEditPersonSheetShown = true
                            } label: {
                                Text("edit-button", comment: "Text of the edit button.")
                            }
                        }
                    }.sheet(isPresented: self.$isEditPersonSheetShown) {
                        let personBinding = Binding<Person?> {
                            return self.appProperties.persons[self.person.id] ?? self.person
                        } set: { person in
                            if let person {
                                self.person = person
                            }
                        }
                        PersonAddAndEdit(person: personBinding)
                    }.sheet(isPresented: self.$isAddNewFineSheetShown) {
                        FineAddAndEdit(personId: self.person.id, shownOnSheet: true)
                    }.alert(String(localized: "person-detail|invitation-alert|title?name=\(self.person.name.formatted())", comment: "Title of the invitation alert that is shown after the invite button is pressed. 'name' parameter is the name of the person to invite."), isPresented: self.$isInvitationAlertShown) {
                        if self.person.isInvited {
                            Button(role: .destructive) {
                                Task {
                                    await self.withdrawInvitation()
                                }
                            } label: {
                                Text("person-detail|invitation-alert|withdraw-invitation-button", comment: "Withdraw invitation button of the invitation alert that is shown after the invite button is pressed and the person is already invited.")
                            }
                            Button(role: .cancel) {} label: {
                                Text("got-it-button", comment: "Text of a 'got it' button.")
                            }
                        } else {
                            Button {
                                Task {
                                    await self.invitePerson()
                                }
                            } label: {
                                Text("person-detail|invitation-alert|invite-button", comment: "Invite button of the invitation alert that is shown after the invite button is pressed.")
                            }
                            Button(role: .cancel) {} label: {
                                Text("cancel-button", comment: "Text of cancel button.")
                            }
                        }
                    } message: {
                        if self.person.isInvited {
                            Text("person-detail|invitation-alert|already-invited", comment: "Message of the invitation alert that is shown after the invite button is pressed and the person is already invited.")
                        }
                    }.alert(String(localized: "person-detail|invitation-created-alert|title?name=\(self.person.name.formatted())", comment: "Title of the alert that is shown after a new invitation link is created, so this link can be pass to that person. 'name' parameter is the name of the person that is invited."), isPresented: self.$isCreatedInvitationAlertShown) {
                        Button {} label: {
                            Text("got-it-button", comment: "Text of a 'got it' button.")
                        }
                    } message: {
                        if let invitationLink = self.invitationLink {
                            Text("person-detail|invitation-created-alert|message?invitaion-link=\(invitationLink)", comment: "Message of the alert that is shown after a new invitation link is created. It also says that the link is copied to the paste board. 'invitation-link' parameter is the link of the invitation.")
                        }
                    }
                }
    }
    
    private func withdrawInvitation() async {
        self.isInviteButtonLoading = true
        defer {
            self.isInviteButtonLoading = false
        }
        do {
            let invitationLinkWithdrawFunction = InvitationLinkWithdrawFunction(clubId: self.appProperties.club.id, personId: self.person.id)
            try await FirebaseFunctionCaller.shared.call(invitationLinkWithdrawFunction)
            self.appProperties.persons[self.person.id]?.isInvited = false
        } catch {}
    }
    
    private func invitePerson() async {
        self.isInviteButtonLoading = true
        defer {
            self.isInviteButtonLoading = false
        }
        do {
            let invitationLinkCreateIdFunction = InvitationLinkCreateIdFunction(clubId: self.appProperties.club.id, personId: self.person.id)
            let invitationLinkId = try await FirebaseFunctionCaller.shared.call(invitationLinkCreateIdFunction)
            self.invitationLink = "invitation/\(invitationLinkId)"
            UIPasteboard.general.string = self.invitationLink
            self.appProperties.persons[self.person.id]?.isInvited = true
            self.isCreatedInvitationAlertShown = true
        } catch {}
    }
}

extension PersonDetail {
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
