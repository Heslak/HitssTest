//
//  CoreDataService.swift
//  Programa de Reconocimientos de Ford
//
//  Created by Sergio Acosta on 6/17/19.
//  Copyright © 2019 Alus. All rights reserved.
//

import Foundation
import CoreData

class CoreDataService {
    
    static let shared: CoreDataService = CoreDataService()
    
    private init() {}

    private let container = AppDelegate.shared.persistentContainer
    private var contextChilden: [NSManagedObjectContext] = [NSManagedObjectContext]()
    
    func saveObjects<D: NSManagedObject>(typeObject type: D.Type, objects: [Codable], completion: (([D]) -> Void)?) {
        var newObjectArray: [NSManagedObject] = [NSManagedObject]()
        var objectsInMain: [D] = [D]()
        let mainContext = self.container.viewContext
        self.container.performBackgroundTask { context in
            for object in objects {
                if let newObject = self.recursiveSetObject(entityName: type.description(),
                                                           data: object.dictionary, context: context) {
                    self.save(context: context)
                    newObjectArray.append(newObject)
                    
                }
            }
        
            DispatchQueue.main.async {
               
                for newObject in newObjectArray {
                    guard let objectInMain = mainContext.object(with: newObject.objectID) as? D else {
                        return
                    }
                    
                    objectsInMain.append(objectInMain)
                }
            
                completion?(objectsInMain)
            }
            
        }
    }
    
    func saveObject<D: NSManagedObject>(typeObject type: D.Type, data: [String: Any], completion: ((D) -> Void)?) {
        let mainContext = self.container.viewContext
        self.container.performBackgroundTask { context in
            if let newObject = self.recursiveSetObject(entityName: type.description(),
                                                       data: data, context: context) {
                
                self.save(context: context, object: newObject)

                DispatchQueue.main.async {
                    
                    guard let objectInMain = mainContext.object(with: newObject.objectID) as? D else {
                        return
                    }
                    
                    completion?(objectInMain)
                }
                
            }
        }
    }
    
    private func recursiveSetObject(entityName: String, data: [String: Any],
                                    toUpdateObject: NSManagedObject? = nil,
                                    context: NSManagedObjectContext) -> NSManagedObject? {
           
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return nil }

        var newObject: NSManagedObject!
        var predicate: NSPredicate!
        
        if let identifier = data["id"] as? Int {
           predicate = NSPredicate(format: "id == %i", identifier)
        }

        if let dbObject = getObject(entityName: entityName, predicate: predicate,
                                    currentContext: context).first, predicate != nil {
           newObject = dbObject
        } else {
           if let updateObject = toUpdateObject {
               newObject = updateObject
           } else {
               newObject = NSManagedObject(entity: entity, insertInto: context)
           }
        }

        for attribute in data {
           let key: String = attribute.key
           let value: Any = attribute.value
           switch value {
           case let dictionary as [String: Any]:
                setChild(child: dictionary, father: newObject, keyChild: key, entity: entity, context: context)
           case let arrayDictionary as [[String: Any]]:
                setChildArray(children: arrayDictionary, father: newObject,
                              keyChild: key, entity: entity, context: context)
           case is NSNull :
                continue
           default:
               newObject.setValue(value, forKey: key)
           }
        }

        return newObject
    }
    
    func getObject<D: NSManagedObject>(typeObject type: D.Type,
                                       predicate: NSPredicate? = nil,
                                       sortDescription: [NSSortDescriptor]? = nil,
                                       currentContext: NSManagedObjectContext? = nil) -> [D] {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "\(type)")
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        if let sortDescription = sortDescription {
            fetchRequest.sortDescriptors = sortDescription
        }
        
        let context = currentContext ?? container.viewContext
        do {
            let objects = try context.fetch(fetchRequest) as? [D] ?? []
            return objects
        } catch let error as NSError {
            debugPrint("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func getObject(entityName: String, predicate: NSPredicate? = nil,
                   sortDescription: [NSSortDescriptor]? = nil,
                   currentContext: NSManagedObjectContext) -> [NSManagedObject] {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        if let sortDescription = sortDescription {
            fetchRequest.sortDescriptors = sortDescription
        }
        
        do {
            let objects = try currentContext.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            debugPrint("Could not fetch. \(error), \(error.userInfo)")
            return []
        }

    }
    
    func deleteObjects(_ objects: [NSManagedObject], context: NSManagedObjectContext) {
        for object in objects {
            deleteObject(object, context: context)
        }
    }
    
    func deleteAllRows(nameObject: String, context: NSManagedObjectContext) {
        debugPrint("Deleting all rows of \(nameObject)")
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: nameObject)
        let request =  NSBatchDeleteRequest(fetchRequest: fetch)
        execute(request, context: context)
        save(context: context)
        
    }
    
    private func setChild(child: [String: Any], father: NSManagedObject,
                          keyChild: String, entity: NSEntityDescription,
                          context: NSManagedObjectContext) {
        
        guard let entityChildName = entity.relationshipsByName[keyChild]?.destinationEntity?.name else { return }
        guard let newChildObject = addChild(father: father, entityName: entityChildName,
                                            key: keyChild, data: child, context: context) else { return }
        father.setValue(newChildObject, forKey: keyChild)
        
    }
    
    private func setChildArray(children: [[String: Any]], father: NSManagedObject,
                               keyChild: String, entity: NSEntityDescription,
                               context: NSManagedObjectContext) {
        
        let mutableArray = father.mutableSetValue(forKey: keyChild)
        mutableArray.removeAllObjects()
        for child in children {
            guard let entityChildName = entity.relationshipsByName[keyChild]?.destinationEntity?.name else { continue }
            guard let newChildObject = addChild(father: father, entityName: entityChildName,
                                                key: keyChild, data: child, context: context) else { continue }
            mutableArray.addObjects(from: [newChildObject])
        }
    }
    
    private func addChild(father: NSManagedObject, entityName: String,
                          key: String, data: [String: Any],
                          context: NSManagedObjectContext) -> NSManagedObject? {

        if let child = father.value(forKey: key) as? NSManagedObject {
            return recursiveSetObject(entityName: entityName, data: data, toUpdateObject: child, context: context)
        }
        guard let newChildObject = recursiveSetObject(entityName: entityName, data: data, context: context) else {
            return nil
        }
        return newChildObject
    }
    
    func save(context: NSManagedObjectContext, object: NSManagedObject? = nil) {
        if context.hasChanges {
            do {
                try context.save()
                if let identifier = object?.value(forKey: "id") as? Int {
                    debugPrint("Save or update object with id: \(identifier)")
                }
            } catch let err {
                debugPrint("Failed saving: \(err)")
            }
        }
    }
    
    private func execute(_ request: NSPersistentStoreRequest, context: NSManagedObjectContext) {
        do {
            try context.execute(request)
        } catch let error as NSError {
            debugPrint("Failed deleting \(error)")
            
        }
    }
    
    func deleteObject(_ object: NSManagedObject, context: NSManagedObjectContext) {
        context.delete(object)
        save(context: context, object: object)
    }

}
