//
//  WeatherCoreData.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 13/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//


import CoreData

class WeatherCoreData {

    let kWeather = "Weather"

    static let shared = WeatherCoreData()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: kWeather)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()

    func newWorkerContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    func mainContext() -> NSManagedObjectContext {
        if _mainObjectContext == nil {
            _mainObjectContext = persistentContainer.viewContext
        }
        return _mainObjectContext!
    }
    private var _mainObjectContext: NSManagedObjectContext?

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func saveContext(context: NSManagedObjectContext) {
        if context.hasChanges {
            context.performAndWait {
                do {
                    try context.save()
                    saveContext()
                } catch {
                    let nserror = error as NSError
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }

    /// This method delete Object
    ///
    /// - Parameter object: The selected Object to be deleted.
    func deleteObject(object: NSManagedObject) {
        object.managedObjectContext?.delete(object)
        self.saveContext()
    }

}

extension WeatherCoreData {
    /// Fetch Entity
    ///
    /// - Parameters:
    ///   - request: NSFetchRequest<Entity>
    ///   - onContext: Managed Object Context
    /// - Returns: Array of Entity
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>, onContext: NSManagedObjectContext) -> [T]? {
        do {
            let objests = try onContext.fetch(request)
            return objests
        } catch {
            print("Error: \(error)")
        }
        return nil
    }

    /// Get count for Entity
    ///
    /// - Parameters:
    ///   - entity: Entity name
    ///   - pred: predicate if any
    ///   - sortOrder: Sort order
    /// - Returns: count for Entity
    func count(forEntity entity: String,
               predicate pred: NSPredicate? = nil,
               sortDescriptor sortOrder: [NSSortDescriptor]? = nil) -> Int {
        let request: NSFetchRequest<NSFetchRequestResult>
        if #available(iOS 10.0, OSX 10.12, *) {
            request = NSFetchRequest(entityName: entity)
        } else {
            request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        }
        request.predicate = pred
        request.sortDescriptors = sortOrder
        do {
            let count = try mainContext().count(for: request)
            return count
        } catch let error {
            print("Error :: - \(error),\(error.localizedDescription)")
        }
        return 0
    }

    /// This methods saves data in current context
    ///
    /// - Parameter context: context to be saved
    func saveContext(_ context: NSManagedObjectContext) {
        if context == self.mainContext() {
            saveContext()
        } else {
            if context.hasChanges {
                context.performAndWait {[weak self] in
                    do {
                        try context.save()
                        if let weakSelf = self {
                            weakSelf.saveContext()
                        }
                    } catch let error as NSError {

                        print("Unresolved error while saving main context \(error), \(error.userInfo)")
                    }
                }

            }
        }
    }
}

extension NSManagedObject {
    var className: String {
        return String(describing: self)
    }
}

class Entity<T: NSManagedObject> {

    class func genericName() -> String {
        return "\(T.self)"
    }

    /// Creates new Entity
    ///
    /// - Parameter onContext: context
    /// - Returns: newly created Entity
    class func create(onContext: NSManagedObjectContext) -> T? {
        return NSEntityDescription.insertNewObject(forEntityName: String(describing: genericName()),
                                                   into: onContext) as? T
    }

    /// Creates new FetchRequest
    ///
    /// - Parameters:
    ///   - predicate: predicate if any
    ///   - sortOrder: Sort order
    /// - Returns: newly created fetchRequest
    class func fetchRequest(predicate: NSPredicate? = nil, sortOrder: [NSSortDescriptor]? = nil) -> NSFetchRequest<T> {
        let request =  NSFetchRequest<T>.init(entityName: genericName())
        request.predicate = predicate
        request.sortDescriptors = sortOrder
        return request
    }

    /// Fetch Entity
    ///
    /// - Parameters:
    ///   - onContext: Context to use
    ///   - predicate: predicate if any
    ///   - sortOrder: Sort order
    /// - Returns: newly created fetchRequest
    class func fetch(onContext: NSManagedObjectContext,
                     predicate: NSPredicate? = nil,
                     sortOrder: [NSSortDescriptor]? = nil) -> [T] {
        let request =  fetchRequest(predicate: predicate, sortOrder: sortOrder)
        request.predicate = predicate
        request.sortDescriptors = sortOrder
        if let data = WeatherCoreData.shared.fetch(request: request, onContext: onContext) {
            return data
        }
        return []
    }

    /// Fetch Entity
    ///
    /// - Parameters:
    ///   - onContext: context to be used
    ///   - predicate: predicate
    ///   - sortOrder: result order
    ///   - fetchLimit: fetch max limit
    /// - Returns: array of Entity
    class func fetch(onContext: NSManagedObjectContext,
                     predicate: NSPredicate? = nil,
                     sortOrder: [NSSortDescriptor]? = nil,
                     fetchLimit: Int) -> [T] {
        let request =  fetchRequest(predicate: predicate, sortOrder: sortOrder)
        request.fetchLimit = fetchLimit
        request.predicate = predicate
        request.sortDescriptors = sortOrder
        if let data = WeatherCoreData.shared.fetch(request: request, onContext: onContext) {
            return data
        }
        return []
    }

    class func fetch(onContext: NSManagedObjectContext, predicate: NSPredicate? = nil) -> [T] {
        return fetch(onContext: onContext, predicate: predicate, sortOrder: nil)
    }

    class func count(predicate: NSPredicate? = nil) -> Int {
        return WeatherCoreData.shared.count(forEntity: genericName(), predicate: predicate)
    }

    /// This method is used to delete all objects
    ///
    /// - Parameters:
    ///   - predicate: Condition for matching objects to delete.
    ///   - context: Managed object context to delete objects.
    class func deleteAllObjectsOfType(predicate: NSPredicate?, context: NSManagedObjectContext) {
        let request = fetchRequest(predicate: predicate, sortOrder: nil)
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            let fetchedEntities = try context.fetch(request)
            for entity in fetchedEntities {
                context.delete(entity)
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        WeatherCoreData.shared.saveContext(context)
    }
}

extension NSManagedObjectContext {
    /// This methods saves data in current context
    func saveContext() {
        WeatherCoreData.shared.saveContext(self)
    }
}
