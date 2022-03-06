//
//  Persistence.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import CoreData

struct CoreDataManager: PersistanceProtocol {
    static let shared = CoreDataManager()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Performance")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func get(completion: @escaping ([Performance], Error?) -> Void) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<PerformanceCoreData>
        fetchRequest = PerformanceCoreData.fetchRequest()
        
        do {
            let coreDataItems = try context.fetch(fetchRequest)
            let performances = coreDataItems.compactMap { Performance(coreDataItem: $0) }
            completion(performances, nil)
        } catch {
            let error = ErrorCase.coreDataFetchFailed
            completion([], error)
        }
    }
    
    func remove(id: String, completion: @escaping (Error?) -> Void) {
        let context = container.viewContext
        let request: NSFetchRequest<PerformanceCoreData> = PerformanceCoreData.fetchRequest()
        do {
            let coreDataItems = try context.fetch(request)
            let item = coreDataItems.filter {
                if let i = $0.id {
                   return i.uuidString == id
                }
                return false
            }.first
            
            if let itemToDelete = item {
                container.viewContext.delete(itemToDelete)
                try container.viewContext.save()
                completion(nil)
            } else {
                let error = ErrorCase.coreDataIdNotFound
                completion(error)
            }
        } catch {
            let error = ErrorCase.coreDataFetchFailed
            completion(error)
        }
    }
    
    func save(performance: Performance, completion: @escaping (Error?) -> Void) {
        let newPerformance = PerformanceCoreData(context: container.viewContext)
        newPerformance.id = UUID()
        newPerformance.firestoreId = performance.firestoreId
        newPerformance.name = performance.name
        newPerformance.location = performance.location
        newPerformance.time = performance.time
        newPerformance.dateCreated = Date()

        do {
            try container.viewContext.save()
            completion(nil)
        } catch {
            let error = ErrorCase.coreDataSaveFailed
            completion(error)
        }
    }
}
