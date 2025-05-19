//
//  HomeViewModelTests.swift
//  PurrfectPicTests
//
//  Created by Nicolas Alejandro Fernandez Amorosino on 18/05/2025.
//

import XCTest
@testable import PurrfectPic

final class HomeViewModelTests: XCTestCase {
    func makeSut(
        catRepository: CatRepository = MockCatRepository(),
        likedCatsRepository: LikedCatsRepository = MockLikedCatsRepository(),
        tag: String = ""
    ) -> HomeViewModel {
        HomeViewModel(
            catRepository: catRepository,
            likedCatsRepository: likedCatsRepository,
            tag: tag
        )
    }

    func test_titleIsPurrterest_whenThereIsNoTag() {
        // Given
        let sut = makeSut()

        // When
        let result = sut.title

        // Then
        XCTAssertEqual(result, "Purrterest")
    }

    func test_titleIsTag_whenThereIsTag() {
        // Given
        let sut = makeSut(tag: "Test tag")

        // When
        let result = sut.title

        // Then
        XCTAssertEqual(result, "Test tag")
    }
}
