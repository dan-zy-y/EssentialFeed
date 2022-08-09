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
            completion(Result {
                try ManagedCache.find(in: context).map {
                    return CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        context.perform { [context] in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.perform { [context] in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
    }
}

