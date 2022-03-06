//
//  AddItemViewModel.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import Foundation
import MapKit
import Combine

class AddItemViewModel: NSObject, ObservableObject {
    
    @Published var name: String = ""
    @Published var location = ""
    @Published var savingOnline = true
    @Published var locationResults: [MKLocalSearchCompletion] = []
    @Published var time = Time(hoursString: "", minutesString: "", secondsString: "")
    @Published private(set) var state: State = .idle
    
    private var cancellable = Set<AnyCancellable>()
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var currentPromise: ((Result<[MKLocalSearchCompletion], Error>) -> Void)?
    
    enum State: Equatable {
        case idle
        case loading
    }
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        
        $location
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .flatMap({ (currentSearchTerm) in
                self.searchTermToResults(searchTerm: currentSearchTerm)
            })
            .sink(receiveCompletion: { [weak self] error in
                guard let self = self else { return }
                switch error {
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    self.locationResults = []
                case .finished:
                    break
                }
            }, receiveValue: { (results) in
                self.locationResults = results
            })
            .store(in: &cancellable)
    }
    
    deinit {
        cancellable.forEach({ $0.cancel() })
    }
    
    func searchTermToResults(searchTerm: String) -> Future<[MKLocalSearchCompletion], Error> {
        Future { promise in
            self.searchCompleter.queryFragment = searchTerm
            self.currentPromise = promise
        }
    }
    
    func save(completion: @escaping (_ reloadType: PersistanceMode?, _ error: Error?) -> Void ) {
        guard isValid() else {
            return
        }
        let performance = Performance(id: UUID(),
                                      firestoreId: nil,
                                      name: name,
                                      location: location,
                                      time: time.timeInterval,
                                      dateCreated: Date(),
                                      savedOnline: savingOnline)
        if savingOnline {
            // save to Firestore
            let manager = FireStoreManager.shared
            manager.save(performance: performance) { error in
                if error == nil {
                    completion(.remote, nil)
                    return
                } else {
                    if let error = error {
                        completion(nil, error)
                    } else {
                        completion(nil, ErrorCase.firebaseCouldntSave)
                    }
                    return
                }
            }
        } else {
            // save to CoreData
            let manager = CoreDataManager.shared
            manager.save(performance: performance) { error in
                if error == nil {
                    completion(.local, nil)
                    return
                } else {
                    if let error = error {
                        completion(nil, error)
                    } else {
                        completion(nil, ErrorCase.coreDataSaveFailed)
                    }
                    return
                }
            }
        }
        state = .loading
    }
    
    func isValid() -> Bool {
        switch self.state {
        case .loading:
            return false
        default:
            return time.timeInterval > 0 && !name.isEmpty && !location.isEmpty
        }
    }
    
    func validateHours() {
        // maximum allowed characters
        let fieldLimit = 3
        if time.hoursString.count > fieldLimit {
            time.hoursString = String(time.hoursString.prefix(fieldLimit))
        }
        // allow only specified characters
        let filteredString = time.hoursString.filter {"0123456789".contains($0)}
        // check if not the same
        if filteredString != time.hoursString {
            time.hoursString = filteredString
        }
    }
    
    func validateMinutes() {
        // maximum allowed characters
        let fieldLimit = 2
        if time.minutesString.count > fieldLimit {
            time.minutesString = String(time.minutesString.prefix(fieldLimit))
        }
        // lesser than 60
        while time.minutes >= 60 {
            time.minutesString = String(time.minutesString.dropLast())
        }
        // allow only specified characters
        let filteredString = time.minutesString.filter {"0123456789".contains($0)}
        // check if not the same
        if filteredString != time.minutesString {
            time.minutesString = filteredString
        }
    }
    
    func validateSeconds() {
        // maximum allowed characters
        let fieldLimit = 6
        if time.secondsString.count > fieldLimit {
            time.secondsString = String(time.secondsString.prefix(fieldLimit))
        }
        // lesser than 60
        while time.seconds >= 60 {
            time.secondsString = String(time.secondsString.dropLast())
        }
        // allow only specified characters
        let correctedString = time.secondsString.replacingOccurrences(of: ",", with: ".")
        let filteredString = correctedString.filter {"0123456789.".contains($0)}
        // only allow one decimal separator
        let reducedString = String(filteredString.enumerated().filter {
            !($0.element == "." && $0.offset != filteredString.distance(of: "."))
        }.map { $0.element })
        // check if not the same
        if reducedString != time.secondsString {
            time.secondsString = reducedString
        }
    }
}

extension AddItemViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            currentPromise?(.success(completer.results))
        }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.locationResults = []
    }
}
