//
//  InvitationButton.swift
//  StrafenProject
//
//  Created by Steven on 13.06.23.
//

import SwiftUI

struct InvitationButton: ToolbarContent {
    
    @EnvironmentObject private var appProperties: AppProperties
    
    private let placement: ToolbarItemPlacement
    
    private let person: Person
    
    @State private var invitationLink: String?
    
    @State private var isCreatedInvitationAlertShown = false
    
    @State private var isInvitationWithdrawAlertShown = false
    
    @State private var isLoading = false
    
    init(placement: ToolbarItemPlacement, person: Person) {
        self.placement = placement
        self.person = person
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: self.placement) {
            Group {
                if self.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Button {
                        if let invitationLinkId = self.person.invitationLinkId {
                            await MainActor.run {
                                UIPasteboard.general.string = self.invitationLink(id: invitationLinkId)
                                self.isInvitationWithdrawAlertShown = true
                            }
                        } else {
                            await self.invitePerson()
                        }
                    } label: {
                        Text("invitation-button|title", comment: "Title of the person invitation button.")
                    }
                }
            }.modifier(self.rootModifiers)
        }
    }
    
    @ModifierBuilder private var rootModifiers: some ViewModifier {
        let title = String(localized: "invitation-button|alert-title?name=\(self.person.name.formatted())", comment: "Title of the invitation alert that is shown after the invite button is pressed. 'name' parameter is the name of the person to invite.")
        let invitationCreatedTitle = String(localized: "invitation-button|created-alert-title?name=\(self.person.name.formatted())", comment: "Title of the alert that is shown after a new invitation link is created, so this link can be pass to that person. 'name' parameter is the name of the person that is invited.")
        AlertModifier(invitationCreatedTitle, isPresented: self.$isCreatedInvitationAlertShown) {
            Button {} label: {
                Text("got-it-button", comment: "Text of a 'got it' button.")
            }
        } message: {
            if let invitationLink = self.invitationLink {
                Text("invitation-button|created-alert-message?invitaion-link=\(invitationLink)", comment: "Message of the alert that is shown after a new invitation link is created. It also says that the link is copied to the paste board. 'invitation-link' parameter is the link of the invitation.")
            }
        }
        AlertModifier(title, isPresented: self.$isInvitationWithdrawAlertShown) {
            Button(role: .destructive) {
                await self.withdrawInvitation()
            } label: {
                Text("invitation-button|alert-withdraw-invitation-button", comment: "Withdraw invitation button of the invitation alert that is shown after the invite button is pressed and the person is already invited.")
            }
            Button(role: .cancel) {} label: {
                Text("got-it-button", comment: "Text of a 'got it' button.")
            }
        } message: {
            Text("invitation-button|alert-already-invited", comment: "Message of the invitation alert that is shown after the invite button is pressed and the person is already invited.")
        }
    }
    
    private func invitationLink(id invitationLinkId: String) -> String {
        return "invitation/\(invitationLinkId)"
    }
    
    private func withdrawInvitation() async {
        self.isLoading = true
        defer {
            self.isLoading = false
        }
        do {
            let invitationLinkWithdrawFunction = InvitationLinkWithdrawFunction(clubId: self.appProperties.club.id, personId: self.person.id)
            try await FirebaseFunctionCaller.shared.call(invitationLinkWithdrawFunction)
            self.appProperties.persons[self.person.id]?.invitationLinkId = nil
        } catch {}
    }
    
    private func invitePerson() async {
        self.isLoading = true
        defer {
            self.isLoading = false
        }
        do {
            let invitationLinkCreateIdFunction = InvitationLinkCreateIdFunction(clubId: self.appProperties.club.id, personId: self.person.id)
            let invitationLinkId = try await FirebaseFunctionCaller.shared.call(invitationLinkCreateIdFunction)
            self.invitationLink = self.invitationLink(id: invitationLinkId)
            UIPasteboard.general.string = self.invitationLink
            self.appProperties.persons[self.person.id]?.invitationLinkId = invitationLinkId
            Task {
                await MainActor.run {
                    self.isCreatedInvitationAlertShown = true                    
                }
            }
        } catch {}
    }
}
