//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Daniil Zadorozhnyy on 02.04.2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ImageCommentsSnapshotTests: XCTestCase {
    func test_listWithContent() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_light_extraExtraExtraLarge")
    }
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        
        return controller
    }
    
    private func comments() -> [CellController] {
        return commentControllers().map { CellController(id: UUID(), $0) }
    }
    
    private func commentControllers() -> [ImageCommentCellController] {
        return [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series or murals painted directIv on a 1,316 m long remnant or the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long long username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North, Wales.",
                    date: "10 days ago",
                    username: "a username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "nice",
                    date: "1 hour ago",
                    username: "a."
                )
            ),
        ]
    }
}