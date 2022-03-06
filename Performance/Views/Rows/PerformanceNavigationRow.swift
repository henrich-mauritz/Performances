//
//  PerformanceNavigationRow.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import SwiftUI

struct PerformanceNavigationRow: View {
    var performance: Performance
    
    var body: some View {
        NavigationLink(destination: ItemDetailView(model: ItemDetailViewModel(performance))) {
            VStack(alignment: .leading) {
                Text(performance.name)
                    .foregroundColor(.primary)
                Text(performance.dateCreated.stringFormatted)
                    .foregroundColor(.primary)
                    .font(.system(.caption))
            }
        }
        .listRowBackground(performance.savedOnline ? Color.orange : Color.teal)
    }
}
