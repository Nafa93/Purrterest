//
//  CatCardViewModelTests.swift
//  PurrfectPicTests
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import XCTest
@testable import PurrfectPic

final class CatCardViewModelTests: XCTestCase {
    func makeSut(
        repository: CatRepository = MockCatRepository(),
        likedCatsRepository: LikedCatsRepository = NetworkLikedCatsRepository(coreDataManager: CoreDataManager(inMemory: true)),
        cat: Cat
    ) -> CatCardViewModel {
        return CatCardViewModel(repository: repository, likedCatsRepository: likedCatsRepository, cat: cat)
    }

    func mockCat(id: String = UUID().uuidString, tags: [String] = []) -> Cat {
        Cat(id: id, tags: tags, mimetype: "", createdAt: "")
    }

    func test_isLiked_isFalse() {
        // Given
        let sut = makeSut(cat: mockCat())

        // When viewModel is created and cat doesn't exist in core data

        // Then
        XCTAssertFalse(sut.isLiked)
    }

    @MainActor
    func test_isLiked_isTrue_whenCatIsUpsertedToCoreData() {
        // Given
        let sut = makeSut(cat: mockCat())

        // When
        sut.upsertToCoreData()

        // Then
        XCTAssertTrue(sut.isLiked)
    }

    @MainActor
    func test_isLiked_isFalse_whenCatIsUpsertedToCoreData_andCatExists() {
        // Given
        let sut = makeSut(cat: mockCat())
        sut.isLiked = true

        // When
        sut.upsertToCoreData()

        // Then
        XCTAssertFalse(sut.isLiked)
    }

    func test_heartImageName_isHeart_whenCatIsNotLiked() {
        // Given
        let sut = makeSut(cat: mockCat())

        // When
        sut.isLiked = false

        // Then
        XCTAssertEqual(sut.heartImageName, "heart")
    }

    func test_heartImageName_isHeartFill_whenCatIsLiked() {
        // Given
        let sut = makeSut(cat: mockCat())

        // When
        sut.isLiked = true

        // Then
        XCTAssertEqual(sut.heartImageName, "heart.fill")
    }

    func test_heartImageColor_isBlack_whenCatIsNotLiked() {
        // Given
        let sut = makeSut(cat: mockCat())

        // When
        sut.isLiked = false

        // Then
        XCTAssertEqual(sut.heartImageColor, .black)
    }

    func test_heartImageColor_isRed_whenCatIsLiked() {
        // Given
        let sut = makeSut(cat: mockCat())

        // When
        sut.isLiked = true

        // Then
        XCTAssertEqual(sut.heartImageColor, .red)
    }

    func test_viewModelBuilder() {
        // Given
        let cats = [mockCat(), mockCat()]

        // When
        let viewModels = CatCardViewModel.build(from: Set(cats), likedCatsRepository: MockLikedCatsRepository())

        // Then
        XCTAssertEqual(viewModels.count, 2)
        XCTAssertNotNil(viewModels[cats[0]])
        XCTAssertNotNil(viewModels[cats[1]])
    }
}
