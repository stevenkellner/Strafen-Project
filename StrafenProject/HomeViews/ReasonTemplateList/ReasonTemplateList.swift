//
//  ReasonTemplateList.swift
//  StrafenProject
//
//  Created by Steven on 27.04.23.
//

import SwiftUI

struct ReasonTemplateList: View {
    
    @Environment(\.redactionReasons) private var redactionReasons
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @State private var searchText = ""
    
    @State private var isReasonTemplateAddSheetShown = false
        
    var body: some View {
        NavigationStack {
            List {
                let sortedReasonTemplates = self.appProperties.sortedReasonTemplates
                let reasonTemplates = sortedReasonTemplates.sortedSearchableList(search: self.searchText)
                if !reasonTemplates.isEmpty {
                    ForEach(reasonTemplates) { reasonTemplate in
                        self.reasonTemplatesListRow(reasonTemplate: reasonTemplate)
                    }
                }
            }.redacted(reason: self.redactionReasons)
                .refreshable {
                    await self.appProperties.refresh()
                }
                .navigationTitle(String(localized: "reason-template-list|navigation-title", comment: "Title of the reason template list."))
                .if(self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder)) { view in
                    view.toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                self.isReasonTemplateAddSheetShown = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: self.$isReasonTemplateAddSheetShown) {
                        ReasonTemplateAddAndEdit()
                    }
                }
        }.searchable(text: self.$searchText, prompt: String(localized: "reason-template-list|search-placeholer", comment: "Placeholder text of search bar in reason template list."))
            .unredacted()
    }
    
    @ViewBuilder private func reasonTemplatesListRow(reasonTemplate: ReasonTemplate) -> some View {
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
            .if(self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder)) { view in
                view.swipeActions {
                    Button(role: .destructive) {
                        Task {
                            await self.deleteReasonTemplate(reasonTemplate)
                        }
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
