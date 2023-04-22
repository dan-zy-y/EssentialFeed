//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Daniil Zadorozhnyy on 25.10.2022.
//

import os
import UIKit
import CoreData
import Combine
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.essentialDeveloper.infra.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var logger = Logger(subsystem: "com.essentialdeveloper.EssentialAppCaseStudy", category: "main")
    
    private lazy var baseURL: URL = URL(string:"https://ile-api.essentialdeveloper.com/essential-feed/v1")!
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(
                storeURL: NSPersistentContainer
                    .defaultDirectoryURL()
                    .appendingPathComponent("feed-store.sqlite")
            )
        } catch {
            assertionFailure("Failed to instantiate core data feed store with error \(error.localizedDescription)")
            logger.fault("Failed to instantiate core data feed store with error \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var navigationController: UINavigationController = {
        UINavigationController(
            rootViewController: FeedUIComposer.feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: makeLocalImageDataLoaderWithRemoteFallback,
                selection: showComments
            )
        )
    }()
    
    convenience init(
        httpClient: HTTPClient,
        store: FeedStore & FeedImageDataStore,
        scheduler: AnyDispatchQueueScheduler
    ) {
        self.init()
        self.httpClient = httpClient
        self.store = store
        self.scheduler = scheduler
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else {
            return
        }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache() { _ in }
    }
    
    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(for: url))
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteCommentsLoader(for url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [httpClient] in
            httpClient
                .getPublisher(url: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .eraseToAnyPublisher() 
    }
    
    private func makeFirstPage(_ items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(
            items: items,
            loadMorePublisher: last.map { last in
                { self.makeRemoteLoadMoreLoader(last: last) }
            }
        )
    }
    
    private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
        makeRemoteFeedLoader(after: last)
            .zip(localFeedLoader.loadPublisher()) { (newItems, cachedItems) in
                (cachedItems + newItems, newItems.last)
            }
            .map(makePage)
            .caching(to: localFeedLoader)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
        let url = FeedImagesEndpoint.get(after: after).url(baseURL: baseURL)
            
        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
    }
    
    private func makeLocalImageDataLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .logCacheMisses(url: url, logger: logger)
            .fallback(to: { [httpClient, logger, scheduler] in
                return httpClient
                    .getPublisher(url: url)
                    .logElapsedTime(url: url, logger: logger)
                    .logErrors(url: url, logger: logger)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
                    .subscribe(on: scheduler)
                    .eraseToAnyPublisher()
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

extension Publisher {
    func logCacheMisses(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents(receiveCompletion: { result in
                if case .failure = result {
                    logger.trace("Cache miss for url: \(url)")
                }
            }
        )
        .eraseToAnyPublisher()
    }
    
    func logErrors(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents(receiveCompletion: { result in
                if case let .failure(error) = result {
                    logger.trace("Failed to load url: \(url) with error \(error.localizedDescription)")
                }
            }
        )
        .eraseToAnyPublisher()
    }
    
    func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        var startTime = CACurrentMediaTime()
        return handleEvents(
            receiveSubscription: { _ in
                logger.trace("Started loading url: \(url)")
                startTime = CACurrentMediaTime()
            }, receiveCompletion: { result in
                let elapsed = CACurrentMediaTime() - startTime
                logger.trace("Finished logging url: \(url) in \(elapsed) seconds")
            }
        )
        .eraseToAnyPublisher()
    }
}
