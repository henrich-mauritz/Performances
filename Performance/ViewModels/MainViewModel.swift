//
//  MainViewModel.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import CoreData

enum PersistanceMode: String, CaseIterable, Identifiable {
    case all
    case local
    case remote
    
    var id: Self { self }
}

class MainViewModel: ObservableObject {
    @Published private(set) var state: State = .idle
    @Published var persistanceMode: PersistanceMode = .all
    @Published var showingAlert = false
    
    private let fireStoreManager = FireStoreManager.shared
    private let coreDataManager = CoreDataManager.shared
    
    private var performancesCoreDate = [Performance]()
    private var performancesFirestore = [Performance]()
    
    var performances: [Performance] {
        switch persistanceMode {
        case .local:
            return performancesCoreDate.sorted(by: { $0.dateCreated > $1.dateCreated })
        case .remote:
            return performancesFirestore.sorted(by: { $0.dateCreated > $1.dateCreated })
        case .all:
            return (performancesCoreDate + performancesFirestore).sorted(by: { $0.dateCreated > $1.dateCreated })
        }
    }
    
    enum State {
        case idle
        case loading
        case loaded
    }
    
    func delete(performance: Performance, completion: @escaping (_ error: Error?) -> Void) {
        if performance.savedOnline {
            guard let id = performance.firestoreId else  {
                return
            }
            fireStoreManager.remove(id: id) { [weak self] error in
                if let error = error {
                    completion(error)
                } else {
                    self?.load(.remote, false) { error in
                        completion(error)
                    }
                }
            }
        } else {
            coreDataManager.remove(id: performance.id.uuidString) { [weak self] error in
                if let error = error {
                    completion(error)
                } else {
                    self?.load(.local, false) { error in
                        completion(error)
                    }
                }
            }
        }
    }
    
    func load(_ type: PersistanceMode, _ loadingIndicator: Bool, completion: @escaping (_ error: Error) -> Void) {
        if loadingIndicator {
            state = .loading
        }

        switch type {
        case .local:
            performancesCoreDate = []
            coreDataManager.get(completion: { [weak self] (performances, error) in
                self?.state = .loaded
                if let error = error {
                    completion(error)
                } else {
                    self?.performancesCoreDate = performances
                }
            })
            
        case .remote:
            performancesFirestore = []
            fireStoreManager.get(completion: { [weak self] (performances, error) in
                self?.state = .loaded
                if let error = error {
                    completion(error)
                } else {
                    self?.performancesFirestore = performances
                }
            })
            
        case .all:
            performancesFirestore = []
            performancesCoreDate = []
            
            coreDataManager.get(completion: { [weak self] (performances, error) in
                if let error = error {
                    self?.state = .loaded
                    completion(error)
                } else {
                    self?.performancesCoreDate = performances
                    self?.fireStoreManager.get(completion: { [weak self] (performances, error) in
                        self?.state = .loaded
                        if let error = error {
                            completion(error)
                        } else {
                            self?.performancesFirestore = performances
                        }
                    })
                }
            })
        }
    }
}
