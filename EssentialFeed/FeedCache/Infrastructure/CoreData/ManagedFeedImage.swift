//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Daniil Zadorozhnyy on 07.08.2022.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
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
