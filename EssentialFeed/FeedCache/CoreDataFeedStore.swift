//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Zadorozhnyy, Daniil on 30.07.2022.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
    
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        self.persistentContainer = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        self.context = persistentContainer.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        context.perform { [context] in
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                    completion(
                        .found(
                            feed: cache.localFeed,
                            timestamp: cache.timestamp
                        )
                    )
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.perform { [context] in
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(
        modelName name: String,
        url: URL,
        in bundle: Bundle
    ) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
    
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        NSOrderedSet(array: localFeed.map {
            let managed = ManagedFeedImage(context: context)
            managed.id = $0.id
            managed.imageDescription = $0.description
            managed.location = $0.location
            managed.url = $0.url
            
            return managed
        })
    }
    
    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
