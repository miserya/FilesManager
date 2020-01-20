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

    private let getAttributesUseCase = GetAttributes()
    private var getAttributes: AnyCancellable?

    private let getHashsUseCase = CalculateHash()
    private var getHashes: AnyCancellable?
    private var createDuplicates: AnyCancellable?

    public func getAttributesForFiles(at pathes: [FileEntity], withReply reply: @escaping ([FileAttributes], Error?) -> Void) {

        let dispatchGroup = DispatchGroup()
        var shouldSendSuccessResult: Bool = true
        var results = [FileAttributes]()

        pathes.forEach({ getAttributesUseCase.execute(with: $0, dispatchGroup: dispatchGroup) { (result: Result<FileAttributes, Error>) in
            switch result {
            case .failure(let error):
                shouldSendSuccessResult = false
                reply([], error)

            case .success(let attrs):
                results.append(attrs)
            }
            }
        })

        dispatchGroup.notify(queue: DispatchQueue.global()) {
            if shouldSendSuccessResult {
                reply(results, nil)
            }
        }
    }

    public func getHashForFile(_ file: FileEntity, withReply reply: @escaping (FileHash?, Error?) -> Void) {
        let result = getHashsUseCase.build(with: file)
        switch result {
        case .success(let hash):
            reply(hash, nil)
        case .failure(let error):
            reply(nil, error)
        }
    }

//    public func getHashForFiles(at pathes: [String], withReply reply: @escaping ([String], Error?) -> Void) {
//        getHashes?.cancel()
//        getHashes = CalculateHash().execute(with: pathes.first!).map({ [$0] })
////        getHashes = Publishers.MergeMany(pathes.map({ CalculateHash().execute(with: $0) }))
////            .collect()
////            .handleEvents(receiveSubscription: { (subscription: Subscription) in
////                debugPrint("Here")
////
////            }, receiveOutput: { (attributes: [String]) in
////                reply(attributes, nil)
////
////            }, receiveCompletion: { (completion: Subscribers.Completion<Error>) in
////                if case .failure(let error) = completion {
////                    reply([], error)
////                }
////
////            }, receiveCancel: {
////                reply([], FilesXPCServiceError.cancel)
////
////            }, receiveRequest: { (demand: Subscribers.Demand) in
////                debugPrint("Got \(demand)")
////            })
//            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
//                if case .failure(let error) = completion {
//                    reply([], error)
//
//                } }, receiveValue: { (hashes: [String]) in
//                    reply(hashes, nil)
//            })
//    }

    public func duplicateFiles(at pathes: [String], withReply reply: @escaping ([String], Error?) -> Void) {
        createDuplicates?.cancel()
        createDuplicates = Publishers.MergeMany(pathes.map({ Duplicate().execute(with: $0) }))
            .collect()
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                if case .failure(let error) = completion {
                    reply([], error)

                } }, receiveValue: { (newPathes: [String]) in
                    reply(newPathes, nil)
            })
    }


    /*
    private let fileManager = FileManager.default

    let concurrentQueue = DispatchQueue(label: "com.miserya.Concurrent", attributes: .concurrent)

    public func getAttributesForFiles(at pathes: [String], withReply reply: @escaping ([NSDictionary], Error?) -> Void) {

        var attributesList = [NSDictionary]()

        var total = 100.0
        let part = total/Double(pathes.count)

        let dispathchGroup = DispatchGroup()
        pathes.forEach { (path: String) in

            dispathchGroup.enter()
            concurrentQueue.async { [weak self] in
                guard let self = self else { return }

                do {
                    let attributes = try NSDictionary(dictionary: self.fileManager.attributesOfItem(atPath: path))
                    attributesList.append(attributes)

                } catch {
                    reply([], error)
                }

                dispathchGroup.leave()

                total -= part
//                progress?(total)
            }
        }

        dispathchGroup.notify(queue: DispatchQueue.global()) {
            reply(attributesList, nil)
        }
    }

    public func getHashForFiles(at pathes: [String], withReply reply: @escaping ([String], Error?) -> Void) {
        let url = pathes.compactMap({ URL(fileURLWithPath: $0) })
        var hashes = [String]()

        var total = 100.0
        let part = total/Double(pathes.count)

        let dispathchGroup = DispatchGroup()
        url.forEach { (url: URL) in

            dispathchGroup.enter()
            concurrentQueue.async {
                if let hash: String = MD5Hasher().sha256(url: url)?.map({ String(format: "%02hhx", $0) }).joined() {
                    hashes.append(hash)
                } else {
                    reply([], FilesXPCServiceError.invalidHash(url.path))
                }

                dispathchGroup.leave()

                total -= part
//                progress?(total)
            }
        }
        dispathchGroup.notify(queue: DispatchQueue.global()) {
            reply(hashes, nil)
        }
    }

    public func duplicateFiles(at pathes: [String], withReply reply: @escaping ([String], Error?) -> Void) {

        var newPathes = [String]()

        var total = 100.0
        let part = total/Double(pathes.count)
        
        let dispathchGroup = DispatchGroup()
        pathes.forEach { (path: String) in

            dispathchGroup.enter()
            concurrentQueue.async { [weak self] in
                guard let self = self else { return }

                do {
                    let sourceURL = URL(fileURLWithPath: path)

                    let pathExtension = sourceURL.pathExtension
                    var fileName = sourceURL.lastPathComponent.replacingOccurrences(of: ".\(pathExtension)", with: "")

                    var destinationURL = sourceURL
                        .deletingLastPathComponent()
                        .appendingPathComponent(fileName)
                        .appendingPathExtension(pathExtension)
                    while self.fileManager.fileExists(atPath: destinationURL.path) {
                        fileName.append("-copy")

                        destinationURL = sourceURL
                        .deletingLastPathComponent()
                        .appendingPathComponent(fileName)
                        .appendingPathExtension(pathExtension)
                    }
                    
                    try self.fileManager.copyItem(at: sourceURL, to: destinationURL)
                    newPathes.append(destinationURL.path)

                } catch {
                    reply([], error)
                }

                dispathchGroup.leave()

                total -= part
//                progress?(total)
            }
        }

        dispathchGroup.notify(queue: DispatchQueue.global()) {
            reply(newPathes, nil)
        }
    }
 */
}
