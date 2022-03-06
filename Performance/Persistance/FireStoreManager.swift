//
//  FireStoreManager.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import Firebase

struct FireStoreManager: PersistanceProtocol {
    static let shared = FireStoreManager()
    
    func get(completion: @escaping ([Performance], Error?) -> Void) {
            let db = Firestore.firestore()
        
            db.collection("performances").getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    guard let snapshot = snapshot,
                          error == nil else {
                              completion([], error)
                              return
                          }
                    
                    var performances: [Performance] = []
                    snapshot.documents.forEach { d in
                        guard let stringUUID = d["id"] as? String,
                              let uuid = UUID(uuidString: stringUUID),
                              let firTimestamp = d["dateCreated"] as? Timestamp
                        else {
                                  let error: Error = ErrorCase.uuidFetchFailed
                                  completion([], error)
                                  return
                              }
                        
                        let performance = Performance(
                            id: uuid,
                            firestoreId: d.documentID,
                            name: d["name"] as? String ?? "",
                            location: d["location"] as? String ?? "",
                            time: d["time"] as? Double ?? 0.0,
                            dateCreated: firTimestamp.dateValue(),
                            savedOnline: d["savedOnline"] as? Bool ?? true )
                        performances.append(performance)
                    }
                    completion(performances, nil)
                }
            }
    }
    
    func remove(id: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("performances").document(id) .delete { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(nil)
                } else {
                    completion(error)
                }
            }
        }
    }
    
    func save(performance: Performance, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("performances").addDocument(data: [
            "id": performance.id.uuidString,
            "name": performance.name,
            "location": performance.location,
            "time": performance.time,
            "dateCreated": performance.dateCreated,
            "savedOnline": performance.savedOnline
        ]) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(nil)
                } else {
                    completion(error)
                }
            }
        }
    }
}
