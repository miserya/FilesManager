//
//  FilesServiceImplTests.swift
//  DataLayerTests
//
//  Created by Maria Holubieva on 21.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import XCTest
import Combine
@testable import DataLayer

class FilesServiceImplTests: XCTestCase {

    private var filesService: FilesService!
    private var serviceManager: MockFilesXPCServiceManager = MockFilesXPCServiceManager()
    private var filesCache: MockFilesServiceCache = MockFilesServiceCache()

    override func setUp() {
        filesService = FilesServiceImpl(serviceManager: serviceManager, cache: filesCache)
    }

    override func tearDown() {
        serviceManager.mockPathes = []
        serviceManager.mockFiles = []
        serviceManager.mockError = nil
        serviceManager.shouldThrowError = false
        filesCache.mockFiles = []
    }

    func testSuccessfulGetFiles() {
        filesCache.mockFiles = [ File.mock(), File.mock(), File.mock() ]

        let expectation_isSequenceCompleted = XCTestExpectation(description: "isSequenceCompleted")
        let expectation_receiveValue = XCTestExpectation(description: "receiveValue")

        _ = filesService.getFiles()
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished: expectation_isSequenceCompleted.fulfill()
                case .failure(_): XCTFail("Wrong completion!")
                }
            }, receiveValue: { [weak self] (files: [File]) in
                expectation_receiveValue.fulfill()
                XCTAssertEqual(self?.filesCache.mockFiles.count, files.count, "Wrong files count!")
            })

        wait(for: [ expectation_isSequenceCompleted, expectation_receiveValue ], timeout: 1)
    }

    func testSuccessfulRemoveFiles() {
        let expectation_isSequenceCompleted = XCTestExpectation(description: "isSequenceCompleted")
        let expectation_receiveValue = XCTestExpectation(description: "receiveValue")

        let input = [ File.mock(), File.mock(), File.mock() ]
        filesCache.mockFiles = input

        _ = filesService.remove(files: input, progress: nil)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished: expectation_isSequenceCompleted.fulfill()
                case .failure(_): XCTFail("Wrong completion!")
                }
            }, receiveValue: { [weak self] in
                expectation_receiveValue.fulfill()
                XCTAssertTrue(self?.filesCache.getFiles().isEmpty ?? false, "Wrong files count!")
            })

        wait(for: [ expectation_isSequenceCompleted, expectation_receiveValue ], timeout: 1)
    }

    //MARK: - Add Files

    func testSuccessfulAddFiles() {
        let expectation_isSequenceCompleted = XCTestExpectation(description: "isSequenceCompleted")

        serviceManager.mockFiles = [ File.mock(), File.mock(), File.mock() ]

        let input = [ URL(fileURLWithPath: "Path/To/File/Name.png") ]
        _ = filesService.add(filesAt: input, progress: nil)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished: expectation_isSequenceCompleted.fulfill()
                case .failure(_): XCTFail("Wrong completion!")
                }
            }, receiveValue: { [weak self] (value: Void) in
                XCTAssertEqual(self?.serviceManager.mockFiles.count, self?.filesCache.mockFiles.count, "Wrong count of saved files!")
            })

        wait(for: [ expectation_isSequenceCompleted ], timeout: 1)
    }

    func testFailueAddFiles_publisherFail() {
        let expectation_isSequenceCompleted = XCTestExpectation(description: "isSequenceCompleted")

        serviceManager.mockError = TestingError.test

        let input = [ URL(fileURLWithPath: "Path/To/File/Name.png") ]
        _ = filesService.add(filesAt: input, progress: nil)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished: XCTFail("Wrong completion!")
                case .failure(_): expectation_isSequenceCompleted.fulfill()
                }
            }, receiveValue: { (_) in
                XCTFail("There should be no value because of error!")
            })

        wait(for: [ expectation_isSequenceCompleted ], timeout: 1)
    }

    func testFailueAddFiles_serviceManagerFail() {
        let expectation_isSequenceCompleted = XCTestExpectation(description: "isSequenceCompleted")

        serviceManager.shouldThrowError = true

        let input = [ URL(fileURLWithPath: "Path/To/File/Name.png") ]
        _ = filesService.add(filesAt: input, progress: nil)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished: XCTFail("Wrong completion!")
                case .failure(_): expectation_isSequenceCompleted.fulfill()
                }
            }, receiveValue: { (_) in
                XCTFail("There should be no value because of error!")
            })

        wait(for: [ expectation_isSequenceCompleted ], timeout: 1)
    }

    //MARK: - Duplicate Files

    func testSuccessfulDuplicateFiles() {
        let expectation_isSequenceCompleted = XCTestExpectation(description: "isSequenceCompleted")

        let input = [ File.mock(), File.mock(), File.mock() ]
        serviceManager.mockPathes = input.map({ $0.location.path })

        _ = filesService.duplicate(files: input, progress: nil)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished: expectation_isSequenceCompleted.fulfill()
                case .failure(_): XCTFail("Wrong completion!")
                }
            }, receiveValue: { [weak self] (value: [String]) in
                XCTAssertEqual(input.count, value.count, "Wrong count of duplicated files!")
                XCTAssertTrue(self?.filesCache.mockFiles.isEmpty ?? false, "Wrong count of saved files!")
            })

        wait(for: [ expectation_isSequenceCompleted ], timeout: 1)
    }

    func testFailueDuplicateFiles_publisherFail() {
        let expectation_isSequenceCompleted = XCTestExpectation(description: "isSequenceCompleted")

        serviceManager.mockError = TestingError.test

        let input = [ File.mock(), File.mock(), File.mock() ]
        _ = filesService.duplicate(files: input, progress: nil)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished: XCTFail("Wrong completion!")
                case .failure(_): expectation_isSequenceCompleted.fulfill()
                }
            }, receiveValue: { (_) in
                XCTFail("There should be no value because of error!")
            })

        wait(for: [ expectation_isSequenceCompleted ], timeout: 1)
    }

    func testFailueDuplicateFiles_serviceManagerFail() {
        let expectation_isSequenceCompleted = XCTestExpectation(description: "isSequenceCompleted")

        serviceManager.shouldThrowError = true

        let input = [ File.mock(), File.mock(), File.mock() ]
        _ = filesService.duplicate(files: input, progress: nil)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished: XCTFail("Wrong completion!")
                case .failure(_): expectation_isSequenceCompleted.fulfill()
                }
            }, receiveValue: { (_) in
                XCTFail("There should be no value because of error!")
            })

        wait(for: [ expectation_isSequenceCompleted ], timeout: 1)
    }

    //MARK: - Caclulate Hash

    func testSuccessfulHashCalculation() {
        let expectation_isSequenceCompleted = XCTestExpectation(description: "isSequenceCompleted")

        let input = [ File.mock(), File.mock(), File.mock() ]
        serviceManager.mockPathes = input.map({ $0.location.path })

        _ = filesService.calculateHash(for: input, progress: nil)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished: expectation_isSequenceCompleted.fulfill()
                case .failure(_): XCTFail("Wrong completion!")
                }
            }, receiveValue: { [weak self] (value: [File]) in
                XCTAssertEqual(input.count, value.count, "Wrong count of duplicated files!")
                XCTAssertTrue(self?.filesCache.mockFiles.isEmpty ?? false, "Wrong count of saved files!")
            })

        wait(for: [ expectation_isSequenceCompleted ], timeout: 1)
    }

    func testFailueHashCalculation_publisherFail() {
        let expectation_isSequenceCompleted = XCTestExpectation(description: "isSequenceCompleted")

        serviceManager.mockError = TestingError.test

        let input = [ File.mock(), File.mock(), File.mock() ]
        _ = filesService.calculateHash(for: input, progress: nil)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished: XCTFail("Wrong completion!")
                case .failure(_): expectation_isSequenceCompleted.fulfill()
                }
            }, receiveValue: { (_) in
                XCTFail("There should be no value because of error!")
            })

        wait(for: [ expectation_isSequenceCompleted ], timeout: 1)
    }

    func testFailueHashCalculation_serviceManagerFail() {
        let expectation_isSequenceCompleted = XCTestExpectation(description: "isSequenceCompleted")

        serviceManager.shouldThrowError = true

        let input = [ File.mock(), File.mock(), File.mock() ]
        _ = filesService.calculateHash(for: input, progress: nil)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished: XCTFail("Wrong completion!")
                case .failure(_): expectation_isSequenceCompleted.fulfill()
                }
            }, receiveValue: { (_) in
                XCTFail("There should be no value because of error!")
            })

        wait(for: [ expectation_isSequenceCompleted ], timeout: 1)
    }

}

