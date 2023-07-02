//
//  PaypalMeButton.swift
//  StrafenProject
//
//  Created by Steven on 02.07.23.
//

import SwiftUI

struct PaypalMeButton: View {
    
    @EnvironmentObject private var appProperties: AppProperties
    
    private let amount: Amount
    
    @State private var isWebSheetShown = false
        
    init(amount: Amount) {
        self.amount = amount
    }
    
    var body: some View {
        if let paypalMeLink = self.appProperties.club.paypalMeLink,
           let paypalMeUrl = self.paypalMeUrl {
            Button {
                self.isWebSheetShown = true
            } label: {
                HStack {
                    Image("paypal_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    Text("Jetzt zahlen mit PayPal")
                }
            }.sheet(isPresented: self.$isWebSheetShown) {
                NavigationView {
                    WebView(url: paypalMeUrl)
                        .navigationTitle(paypalMeLink)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarButton(placement: .topBarTrailing, label: "Schließen") {
                                self.isWebSheetShown = false
                            }
                        }
                }
            }
        }
    }
    
    private var paypalMeUrl: URL? {
        guard let paypalMeLink = self.appProperties.club.paypalMeLink else {
            return nil
        }
        var amountPath = "\(self.amount.value)"
        if self.amount.subUnitValue != 0 {
            amountPath += ".\(self.amount.subUnitValue)"
        }
        amountPath += "EUR"
        return URL(string: "https://\(paypalMeLink)")?
            .appending(component: amountPath)
    }
}
