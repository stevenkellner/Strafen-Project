//
//  ReasonTemplateDetail.swift
//  StrafenProject
//
//  Created by Steven on 28.04.23.
//

import SwiftUI

struct ReasonTemplateDetail: View {
    @Environment(\.redactionReasons) private var redactionReasons
    
    @EnvironmentObject private var appProperties: AppProperties
        
    private let reasonTemplate: ReasonTemplate
    
    @State private var isEditReasonTemplateSheetShown = false
    
    init(_ reasonTemplate: ReasonTemplate) {
        self.reasonTemplate = reasonTemplate
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("reason-template-detail|reason-message", comment: "Text before the reason message of the reason template.")
                    Spacer()
                    Text(self.reasonTemplate.reasonMessage)
                        .multilineTextAlignment(.trailing)
                }
                if let counts = self.reasonTemplate.counts {
                    HStack {
                        Text("reason-template-detail|counts-item", comment: "Text before the counts item of the reason template.")
                        Spacer()
                        Text(counts.item.formatted)
                    }
                    if let maxCount = counts.maxCount {
                        HStack {
                            Text("reason-template-detail|max-count", comment: "Text before the max count of the reason template")
                            Spacer()
                            Text("reason-template-detail|max-count-description?max-count=\(maxCount)", comment: "Description of the max count of the reason template. 'max-count' parameter is the number of max count.")
                        }
                    }
                }
                HStack {
                    Text(String(localized: "reason-template-detail|amount", comment: "Text before the amount of the reason template."))
                    Spacer()
                    Text(self.reasonTemplate.amount.formatted)
                        .foregroundColor(.red)
                }
            }
        }.navigationTitle(self.reasonTemplate.formatted)
            .navigationBarTitleDisplayMode(.large)
            .if(self.appProperties.signedInPerson.isAdmin && !self.redactionReasons.contains(.placeholder)) { view in
                view.toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.isEditReasonTemplateSheetShown = true
                        } label: {
                            Text("edit-button", comment: "Text of the edit button.")
                        }
                    }
                }
                .sheet(isPresented: self.$isEditReasonTemplateSheetShown) {
                    ReasonTemplateAddAndEdit(reasonTemplate: self.reasonTemplate)
                }
            }
    }
}
