//
//  ImageDetailViewModelTests.swift
//  PurrfectPicTests
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import XCTest
@testable import PurrfectPic

final class ImageDetailViewModelTests: XCTestCase {
    func makeSut(
        likedCatsRepository: LikedCatsRepository = MockLikedCatsRepository(),
        mainCat: Cat
    ) -> ImageDetailViewModel {
        ImageDetailViewModel(
            likedCatsRepository: likedCatsRepository,
            mainCat: mainCat
        )
    }

    func mockCat(id: String = UUID().uuidString, tags: [String] = []) -> Cat {
        Cat(id: id, tags: tags, mimetype: "", createdAt: "")
    }

    func test_shouldNotDisplayTagsSection_whenMainCatDoesNotHaveTags() {
        // Given
        let sut = makeSut(mainCat: mockCat(tags: []))

        // When
        let result = sut.shouldDisplayMainCatTags

        // Then
        XCTAssertFalse(result)
    }

    func test_shouldNotDisplayTagsSection_whenThereAreNoRelatedCats() {
        // Given
        let sut = makeSut(mainCat: mockCat(tags: []))
        sut.cats = []

        // When
        let result = sut.shouldDisplayMainCatTags

        // Then
        XCTAssertFalse(result)
    }

    func test_shouldDisplayTagsSection_whenThereAreRelatedCatsAndMainCatHasTags() {
        // Given
        let sut = makeSut(mainCat: mockCat(tags: ["Test tag"]))
        sut.cats = [mockCat(), mockCat()]

        // When
        let result = sut.shouldDisplayMainCatTags

        // Then
        XCTAssertTrue(result)
    }
}
