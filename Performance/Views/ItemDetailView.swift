//
//  ItemDetailView.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import SwiftUI

struct ItemDetailView : View {
    @ObservedObject var model: ItemDetailViewModel

    var body: some View {
        Form {
            PerformanceDetailRow(key: "ID", value: model.item.id.uuidString)
            PerformanceDetailRow(key: "Location", value: model.item.location)
            PerformanceDetailRow(key: "Time", value: model.item.time.hourMinuteSecondMS)
            PerformanceDetailRow(key: "Created", value: model.item.dateCreated.stringFormatted)
        }
        .navigationTitle(model.item.name)
    }
}
