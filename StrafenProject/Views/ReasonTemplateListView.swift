//
//  ReasonTemplateListView.swift
//  StrafenProject
//
//  Created by Steven on 13.06.23.
//

import SwiftUI

struct ReasonTemplateListView: View {
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var settingsManager: SettingsManager
    
    private let searchText: String
    
    init(search searchText: String) {
        self.searchText = searchText
    }
    
    var body: some View {
        let sortedReasonTemplates = self.appProperties.sortedReasonTemplates(by: self.settingsManager.sorting.reasonTemplateSorting)
        let reasonTemplates = sortedReasonTemplates.searchableGroup(search: self.searchText)
        if !reasonTemplates.isEmpty {
            ForEach(reasonTemplates) { reasonTemplate in
                ReasonTemplateRow(reasonTemplate)
            }
        }
    }
    
    struct ReasonTemplateRow: View {
        
        @Environment(\.redactionReasons) private var redactionReasons
        
        @EnvironmentObject private var appProperties: AppProperties
        
        private let reasonTemplate: ReasonTemplate
                
        init(_ reasonTemplate: ReasonTemplate) {
            self.reasonTemplate = reasonTemplate
        }
        
        var body: some View {
            NavigationLink {
                ReasonTemplateDetail(reasonTemplate)
            } label: {
                HStack {
                    Text(reasonTemplate.formatted)
                    Spacer()
                    Text(reasonTemplate.amount.formatted(.short))
                        .foregroundColor(.red)
                }
            }.disabled(self.redactionReasons.contains(.placeholder))
                .modifier(self.rootModifiers)
        }
        
        @ModifierBuilder private var rootModifiers: some ViewModifier {
            if self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder) {
                SwipeActionsModifier {
                    Button(role: .destructive) {
                        await self.deleteReasonTemplate(reasonTemplate)
                    } label: {
                        Label(String(localized: "delete-button", comment: "Text of delete button."), systemImage: "trash")
                            .unredacted()
                    }
                }
            }
        }
        
        private func deleteReasonTemplate(_ reasonTemplate: ReasonTemplate) async {
            do {
                let reasonTemplateEditFunction = ReasonTemplateEditFunction.delete(clubId: self.appProperties.club.id, reasonTemplateId: reasonTemplate.id)
                try await FirebaseFunctionCaller.shared.call(reasonTemplateEditFunction)
                self.appProperties.reasonTemplates[reasonTemplate.id] = nil
            } catch {}
        }
    }
}
