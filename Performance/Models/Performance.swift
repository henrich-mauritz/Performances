//
//  Performance.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import Foundation

struct Performance: Identifiable {
    var id: UUID
    var firestoreId: String?
    var name: String
    var location: String
    var time: Double
    var dateCreated: Date
    var savedOnline: Bool
    
    init?(coreDataItem: PerformanceCoreData) {
        guard let id = coreDataItem.id,
              let name = coreDataItem.name,
              let location = coreDataItem.location,
              let dataCreated = coreDataItem.dateCreated else {
                  return nil
              }
        self.id = id
        self.firestoreId = coreDataItem.firestoreId
        self.name = name
        self.location = location
        self.time = coreDataItem.time
        self.dateCreated = dataCreated
        self.savedOnline = false
    }
    
    init(id: UUID,
         firestoreId: String?,
         name: String,
         location: String,
         time: Double,
         dateCreated: Date,
         savedOnline: Bool) {
        self.id = id
        self.firestoreId = firestoreId
        self.name = name
        self.location = location
        self.time = time
        self.dateCreated = dateCreated
        self.savedOnline = savedOnline
    }
}
