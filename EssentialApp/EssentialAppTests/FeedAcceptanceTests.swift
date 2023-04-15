//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Daniil Zadorozhnyy on 16.11.2022.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateLoadMoreFeedAction()
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData2())
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateLoadMoreFeedAction()
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData2())
        XCTAssertFalse(feed.canLoadMoreFeed)
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        
        let offlineFeed = launch(httpClient: .offline, store: sharedStore)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData1())
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
    }
    
    func test_onImageSelection_displaysComments() {
        let comments = showCommentsForFirstImage()
        
        XCTAssertEqual(comments.numberOfRenderedComments(), 1)
        XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
        XCTAssertEqual(comments.commentUsername(at: 0), makeCommentUsername())
    }
    
    // MARK: - Helpers
    
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryFeedStore = .empty
    ) -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! ListViewController
    }
    
    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private func showCommentsForFirstImage() -> ListViewController {
        let feed = launch(httpClient: .online(response), store: .empty)
        
        feed.simulateTapOnFeedImage(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = feed.navigationController
        return nav?.topViewController as! ListViewController
    }
    
    private class HTTPClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        private let stub: (URL) -> HTTPClient.Result
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub(stub: { url in .success(stub(url)) })
        }
    }
    
    private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
        var feedCache: CachedFeed?
        private var feedImageDataCache: [URL: Data] = [:]
        
        init(feedCache: CachedFeed? = nil) {
            self.feedCache = feedCache
        }
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            feedCache = nil
            completion(.success(()))
        }
        
        func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            feedCache = CachedFeed(feed: feed, timestamp: timestamp)
            completion(.success(()))
        }
        
        func retrieve(completion: @escaping RetrievalCompletion) {
            completion(.success(feedCache))
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            feedImageDataCache[url] = data
            completion(.success(()))
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            completion(.success(feedImageDataCache[url]))
        }
        
        static var empty: InMemoryFeedStore {
            return InMemoryFeedStore()
        }
        
        static var withExpiredFeedCache: InMemoryFeedStore {
            return InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
        }
        
        static var withNonExpiredFeedCache: InMemoryFeedStore {
            return InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
        }
    }
    
    func response(for url: URL) -> (Data, HTTPURLResponse) {
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), urlResponse)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.path {
        case "/image-0":
            return makeImageData0()
        case "/image-1":
            return makeImageData1()
        case "/image-2":
            return makeImageData2()
        case "/essential-feed/v1/feed" where url.query?.contains("after_id") == false:
            return makeFirstPageFeedData()
        case "/essential-feed/v1/feed" where url.query?.contains("after_id=142A6583-2460-4F14-BC88-1511BB27C86C") == true:
            return makeSecondPageFeedData()
        case "/essential-feed/v1/feed" where url.query?.contains("after_id=21DDE613-829B-4E31-B2DD-F1A89E5EE954") == true:
            return makeLastEmptyPageFeedData()
        case "/essential-feed/v1/image/73A89829-8DA3-4BD9-A2F9-C724545A21B0/comments":
            return makeImageCommentsData()
        default:
            return Data()
        }
    }
    
    private func makeImageData0() -> Data {
        return UIImage.make(withColor: .green).pngData()!
    }
    
    private func makeImageData1() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeImageData2() -> Data {
        return UIImage.make(withColor: .blue).pngData()!
    }
    
    private func makeImageData3() -> Data {
        return UIImage.make(withColor: .yellow).pngData()!
    }
    
    private func makeFirstPageFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "items": [
                ["id": "73A89829-8DA3-4BD9-A2F9-C724545A21B0", "image": "http://feed.com/image-0"],
                ["id": "142A6583-2460-4F14-BC88-1511BB27C86C", "image": "http://feed.com/image-1"],
            ]
        ])
    }
    
    private func makeSecondPageFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "items": [
                ["id": "21DDE613-829B-4E31-B2DD-F1A89E5EE954", "image": "http://feed.com/image-2"]
            ]
        ])
    }
    
    private func makeLastEmptyPageFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": []])
    }
    
    private func makeImageCommentsData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "items": [
                [
                    "id": UUID().uuidString,
                    "message": makeCommentMessage(),
                    "created_at": "2020-01-01T12:31:22+00:00",
                    "author": [
                        "username": makeCommentUsername()
                    ]
                ]
            ]
        ])
    }
    
    private func makeCommentMessage() -> String {
        return "a message"
    }
    
    private func makeCommentUsername() -> String {
        return "a username"
    }
}
