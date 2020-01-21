//
//  FilesService.swift
//  FilesXPCService
//
//  Created by Maria Holubieva on 17.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import XPCSupport
import Combine

public class FilesXPCService: NSObject, FilesXPCServiceProtocol {

    private let remoteObjectProxy: FilesXPCProgress

    private let getAttributesUseCase = GetAttributes()
    private var getAttributes: AnyCancellable?

    private let getHashUseCase = CalculateHash()
    private var getHashes: AnyCancellable?

    private let duplicateUseCase = Duplicate()
    private var createDuplicates: AnyCancellable?

    init(remoteObjectProxy: FilesXPCProgress) {
        self.remoteObjectProxy = remoteObjectProxy
    }

    public func getAttributesForFiles(at pathes: [FileEntity], withReply reply: @escaping ([FileAttributes], Error?) -> Void) {

        remoteObjectProxy.updateProgress(0)
        getAttributes?.cancel()

        var completionsCount: Double = 0
        getAttributes = Publishers.MergeMany(pathes.map({ getAttributesUseCase.execute(with: $0) }))
            .compactMap({ [weak self] (attrs) in
                completionsCount += 1
                self?.remoteObjectProxy.updateProgress((completionsCount/Double(pathes.count))*100.0);
                return attrs })
            .collect()
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished:             break
                case .failure(let error):   reply([], error)
                }

            }, receiveValue: { (attributes: [FileAttributes]) in
                reply(attributes, nil)
            })
    }

    public func getHashForFiles(_ files: [FileEntity], withReply reply: @escaping ([FileHash], Error?) -> Void) {

        remoteObjectProxy.updateProgress(0)
        getAttributes?.cancel()

        var completionsCount: Double = 0
        getAttributes = Publishers.MergeMany(files.map({ getHashUseCase.execute(with: $0) }))
            .compactMap({ [weak self] (attrs) in
                completionsCount += 1
                self?.remoteObjectProxy.updateProgress((completionsCount/Double(files.count))*100.0);
                return attrs })
            .collect()
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished:             break
                case .failure(let error):   reply([], error)
                }

            }, receiveValue: { (hashes: [FileHash]) in
                reply(hashes, nil)
            })
    }

    public func duplicateFiles(at pathes: [String], withReply reply: @escaping ([String], Error?) -> Void) {
        remoteObjectProxy.updateProgress(0)
        getAttributes?.cancel()

        var completionsCount: Double = 0
        getAttributes = Publishers.MergeMany(pathes.map({ duplicateUseCase.execute(with: $0) }))
            .compactMap({ [weak self] (attrs) in
                completionsCount += 1
                self?.remoteObjectProxy.updateProgress((completionsCount/Double(pathes.count))*100.0);
                return attrs })
            .collect()
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .finished:             break
                case .failure(let error):   reply([], error)
                }

            }, receiveValue: { (duplicatesPathes: [String]) in
                reply(duplicatesPathes, nil)
            })
        
//        createDuplicates?.cancel()
//        createDuplicates = Publishers.MergeMany(pathes.map({ Duplicate().execute(with: $0) }))
//            .collect()
//            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
//                if case .failure(let error) = completion {
//                    reply([], error)
//
//                } }, receiveValue: { (newPathes: [String]) in
//                    reply(newPathes, nil)
//            })
    }

}
