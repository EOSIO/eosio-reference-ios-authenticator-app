//
//  Fetchable.swift
//  Eosio
//
//  Created by Steve McCoole on 10/11/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import CoreData

protocol Fetchable {
    associatedtype T: NSManagedObject = Self
    static func getAll(predicate: NSPredicate?, sorted: [NSSortDescriptor]?, context: NSManagedObjectContext) -> [T]?
    static func getAll(predicate: NSPredicate?, context:NSManagedObjectContext) -> [T]?
    static func getAll(context: NSManagedObjectContext) -> [T]?
    static func countAll(predicate: NSPredicate?, context: NSManagedObjectContext) -> Int
    static func countAll(context: NSManagedObjectContext) -> Int
    static func fetch(string: String?, propertyName: String, context: NSManagedObjectContext) -> T?
}

extension Fetchable {

    static func getAll(predicate: NSPredicate?, sorted: [NSSortDescriptor]?, context: NSManagedObjectContext = DataManager.shared.viewContext) -> [T]? {

        guard let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> else { return nil }

        if let pred = predicate { fetchRequest.predicate = pred }
        if let sort = sorted { fetchRequest.sortDescriptors = sort }

        var results: [T]? = nil
        var fetchError: NSError?

        do {
            results = try context.fetch(fetchRequest)
        } catch let error as NSError {
            fetchError = error
        }

        if let error = fetchError {
            ZAssert(false, message: "Error loading \(fetchRequest) \(String(describing: predicate)) \(error)")
        }

        return results
    }

    static func getAll(predicate: NSPredicate?, context: NSManagedObjectContext = DataManager.shared.viewContext) -> [T]? {
        return getAll(predicate: predicate, sorted: nil, context: context)
    }

    static func getAll(context: NSManagedObjectContext = DataManager.shared.viewContext) -> [T]? {
        return getAll(predicate: nil, sorted: nil, context: context)
    }

    static func fetch(string: String?, propertyName: String, context: NSManagedObjectContext = DataManager.shared.viewContext) -> T? {
        guard let idString = string, idString.isEmpty == false else { return nil }

        let predicate = NSPredicate.init(format: "%K == %@", propertyName, idString)
        let fetched = getAll(predicate: predicate, context: context)
        guard let results = fetched else { return nil }

        switch results.count {
        case 0:
            return nil
        case 1:
            return results.last
        default:
            // TODO handle error
            ZAssert(results.count < 2, message: "Expected to find 1 item with key \(propertyName) and value \(idString) but found \(results.count)")
            return results.last
        }
    }

    static func countAll(predicate: NSPredicate?, context: NSManagedObjectContext = DataManager.shared.viewContext) -> Int {

        guard let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> else { return 0 }

        if let pred = predicate { fetchRequest.predicate = pred }

        var results = 0
        var fetchError: NSError?

        do {
            results = try context.count(for: fetchRequest)
        } catch let error as NSError {
            fetchError = error
        }

        if let error = fetchError {
            ZAssert(false, message: "Error loading \(fetchRequest) \(String(describing: predicate)) \(error)")
        }

        return results
    }

    static func countAll(context: NSManagedObjectContext = DataManager.shared.viewContext) -> Int {
        return countAll(predicate: nil, context: context)
    }

    static func deleteAll(context: NSManagedObjectContext = DataManager.shared.viewContext) {
        let fetchRequest: NSFetchRequest = T.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        var deleteError: NSError?
        context.performAndWait {
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch let error as NSError {
                deleteError = error
            }
        }

        if let error = deleteError {
            ZAssert(false, message: "Error deleting \(fetchRequest) \(error)")
        }

        return
    }

}
