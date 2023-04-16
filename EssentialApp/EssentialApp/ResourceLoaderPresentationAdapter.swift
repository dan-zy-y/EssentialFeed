//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Daniil Zadorozhnyy on 25.08.2022.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class ResourceLoaderPresentationAdapter<Resource, View: ResourceView> {
    var presenter: LoadResourcePresenter<Resource, View>?
    
    private var isLoading: Bool = false
    private var cancellable: AnyCancellable?
    private let loader: () -> AnyPublisher<Resource, Error>
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        guard !isLoading else { return }
        
        presenter?.didStartLoading()
        isLoading = true
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                }
                self?.isLoading = false
            }, receiveValue: { [weak self] resource in
                self?.presenter?.didFinishLoading(with: resource)
            })
    }
}

extension ResourceLoaderPresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
