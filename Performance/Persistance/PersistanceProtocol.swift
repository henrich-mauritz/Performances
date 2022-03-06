//
//  PersistanceProtocol.swift
//  Performance
//
//  Created by Henrich Mauritz on 5/03/2022.
//


protocol PersistanceProtocol {
    func get(completion: @escaping (_ performances: [Performance], _ error: Error?) -> Void)
    func remove(id: String, completion: @escaping (_ error: Error?) -> Void)
    func save(performance: Performance, completion: @escaping (_ error: Error?) -> Void)
}
