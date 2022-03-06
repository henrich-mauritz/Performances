//
//  Error.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//

import Foundation

public enum ErrorCase: Error {
    case uuidFetchFailed
    case coreDataFetchFailed
    case coreDataSaveFailed
    case coreDataIdNotFound
    case firebaseCouldntSave
}

extension ErrorCase: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .uuidFetchFailed:
            return NSLocalizedString("Invalid UUID detected", comment: "")
            
        case .coreDataFetchFailed:
            return NSLocalizedString("CoreData fetching failed", comment: "")
            
        case .coreDataSaveFailed:
            return NSLocalizedString("CoreData save failed", comment: "")
         
        case .coreDataIdNotFound:
            return NSLocalizedString("Item with that ID couldn't be found in CoreData", comment: "")
            
        case .firebaseCouldntSave:
            return NSLocalizedString("ERROR: FireStore couldn't save performance", comment: "")
        }
    }
}
