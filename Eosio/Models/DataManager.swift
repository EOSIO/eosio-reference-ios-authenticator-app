//
//  DataManager.swift
//  Eosio
//
//  Created by Steve McCoole on 10/11/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import CoreData

@objc open
class DataManager : NSObject {

    private var modelName = "Eosio"

    lazy var container: NSPersistentContainer = {
        let persistenceContainer = NSPersistentContainer(name: modelName)
        persistenceContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load Core Data stack: \(error), \(error.userInfo)")
            }
            persistenceContainer.viewContext.automaticallyMergesChangesFromParent = true
        })
        return persistenceContainer
    }()

    public var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    static let shared: DataManager = {
        let instance = DataManager()
        return instance
    }()

    private override init() {

    }

    public func newPrivateContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }

    public func performBackgroundTask(block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }

    public func saveContext() {
        saveContext(viewContext)
    }

    public func saveContext(_ context: NSManagedObjectContext) {
        context.performAndWait {
            if !context.hasChanges { return }
            do {
                try context.save()
            } catch {
                fatalError("Failed to save context: \(error)")
            }
        }
    }

}
