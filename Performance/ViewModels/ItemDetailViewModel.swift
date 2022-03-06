//
//  ItemDetailViewModel.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import Foundation

class ItemDetailViewModel: ObservableObject {
    @Published var item: Performance
    
    init(_ item: Performance) {
        self.item = item
    }

}
