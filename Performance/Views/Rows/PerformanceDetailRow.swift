//
//  PerformanceDetailRow.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import SwiftUI

struct PerformanceDetailRow: View {
    var key: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(key)
                .foregroundColor(.primary)
                .font(.system(.headline))
            Text(value)
                .foregroundColor(.primary)
                .font(.system(.body))
        }
    }
}
