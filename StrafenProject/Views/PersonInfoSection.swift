//
//  PersonInfoSection.swift
//  StrafenProject
//
//  Created by Steven on 10.06.23.
//

import SwiftUI

struct PersonInfoSection<Person, ExtraRows>: View where Person: PersonWithFines, ExtraRows: View {
    
    @EnvironmentObject private var appProperties: AppProperties
    
    @EnvironmentObject private var imageStorage: FirebaseImageStorage
    
    private let person: Person
    
    private let extraRows: ExtraRows?
    
    init(_ person: Person, @ViewBuilder extraRows: () -> ExtraRows) {
        self.person = person
        self.extraRows = extraRows()
    }
    
    var body: some View {
        Section {
            self.imageRow
            let fines = self.appProperties.fines(of: self.person)
            self.amountRow(fines.unpayedAmount, title: LocalizedStringResource("person-info-section|still-open-amount", comment: "Section text of still open fines."), color: .red)
            self.amountRow(fines.totalAmount, title: LocalizedStringResource("person-info-section|total-amount", comment: "Section text of total fines."), color: .green)
            if let extraRows = self.extraRows {
                extraRows
            }
        }.task {
            await self.imageStorage.fetch(.person(clubId: self.appProperties.club.id, personId: self.person.id))
        }
    }
    
    @ViewBuilder private var imageRow: some View {
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
    }
    
    @ViewBuilder private func amountRow(_ amount: Amount, title: LocalizedStringResource, color: Color) -> some View {
        HStack {
            Text(title)
                .unredacted()
            Spacer()
            Text(amount.formatted(.short))
                .foregroundColor(color)
        }
    }
}

extension PersonInfoSection where ExtraRows == EmptyView {
    init(_ person: Person) {
        self.person = person
        self.extraRows = nil
    }
}
