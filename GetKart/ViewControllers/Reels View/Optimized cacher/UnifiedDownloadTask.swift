//
//  UnifiedDownloadTask.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 29/07/26.
//

/*
import Foundation
import AVFoundation

final class UnifiedDownloadTask: NSObject, URLSessionDataDelegate {

    private let url: URL
    private var streamingRequests: [AVAssetResourceLoadingRequest] = []

    private var session: URLSession!
    private var task: URLSessionTask?

    private var receivedData = Data()
    private var expectedLength: Int64 = 0
    private var mimeType: String?

    private let fileURL: URL
    private var fileHandle: FileHandle?

    private var onFinished: (() -> Void)?

    init(url: URL) {
        self.url = url
        self.fileURL = FileManager.default.cacheFileURL(for: url)
        super.init()

        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    // MARK: Streaming path (player is actively requesting bytes)

    func addStreamingRequest(_ request: AVAssetResourceLoadingRequest, onFinished: @escaping () -> Void) {

        self.onFinished = onFinished
        streamingRequests.append(request)
        startIfNeeded()
    }

    func cancel(request: AVAssetResourceLoadingRequest) {
        streamingRequests.removeAll { $0 === request }
    }

    // MARK: Silent background prefetch path (no player attached yet)

    func startBackgroundDownload(onFinished: @escaping () -> Void) {

        self.onFinished = onFinished
        startIfNeeded()
    }

    private func startIfNeeded() {

        guard task == nil else { return }

        FileManager.default.createFileIfNeeded(at: fileURL)
        fileHandle = try? FileHandle(forWritingTo: fileURL)

        var req = URLRequest(url: url)
        req.addValue("bytes=0-", forHTTPHeaderField: "Range")

        task = session.dataTask(with: req)
        task?.resume()
    }

    // MARK: URLSessionDataDelegate

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {

        expectedLength = response.expectedContentLength
        mimeType = response.mimeType

        if let http = response as? HTTPURLResponse {
            for request in streamingRequests {
                let content = request.contentInformationRequest
                content?.contentType = http.mimeType
                content?.contentLength = expectedLength
                content?.isByteRangeAccessSupported = true
            }
        }

        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {

        receivedData.append(data)
        fileHandle?.write(data)

        processStreamingRequests()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        processStreamingRequests()
        try? fileHandle?.close()

        if error == nil {
            UnifiedVideoCache.markComplete(
                for: url,
                expectedSize: Int64(receivedData.count),
                mimeType: mimeType
            )
        }

        onFinished?()
    }

    private func processStreamingRequests() {

        var finished: [AVAssetResourceLoadingRequest] = []

        for request in streamingRequests {

            guard let dataRequest = request.dataRequest else { continue }

            let requestedOffset = Int(dataRequest.requestedOffset)
            let currentOffset = Int(dataRequest.currentOffset)
            let requestedLength = dataRequest.requestedLength

            let bytesAvailable = receivedData.count
            let startOffset = currentOffset

            guard bytesAvailable > startOffset else { continue }

            let bytesToSend = min(bytesAvailable - startOffset, requestedLength)
            let chunk = receivedData.subdata(in: startOffset..<(startOffset + bytesToSend))

            dataRequest.respond(with: chunk)

            let endOffset = startOffset + bytesToSend

            if endOffset >= requestedOffset + requestedLength {
                request.finishLoading()
                finished.append(request)
            }
        }

        streamingRequests.removeAll { finished.contains($0) }
    }
}
*/



import Foundation
import AVFoundation

final class UnifiedDownloadTask: NSObject, URLSessionDataDelegate {

    private let url: URL
    private var streamingRequests: [AVAssetResourceLoadingRequest] = []

    private var session: URLSession!
    private var task: URLSessionTask?

    private var receivedData = Data()
    private var expectedLength: Int64 = 0
    private var mimeType: String?

    private let fileURL: URL
    private var fileHandle: FileHandle?

    private var onFinished: (() -> Void)?

    // Serializes all access to the mutable state above (streamingRequests,
    // receivedData, fileHandle, task) since URLSession delegate callbacks
    // and AVAssetResourceLoader calls can arrive on different threads.
    private let syncQueue = DispatchQueue(label: "com.getkart.UnifiedDownloadTask.sync")

    init(url: URL) {
        self.url = url
        self.fileURL = FileManager.default.cacheFileURL(for: url)
        super.init()

        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    // MARK: Streaming path (player is actively requesting bytes)

    func addStreamingRequest(_ request: AVAssetResourceLoadingRequest, onFinished: @escaping () -> Void) {
        syncQueue.async {
            self.onFinished = onFinished
            self.streamingRequests.append(request)
            self.startIfNeeded()
        }
    }

    func cancel(request: AVAssetResourceLoadingRequest) {
        syncQueue.async {
            self.streamingRequests.removeAll { $0 === request }
        }
    }

    // MARK: Silent background prefetch path (no player attached yet)

    func startBackgroundDownload(onFinished: @escaping () -> Void) {
        syncQueue.async {
            self.onFinished = onFinished
            self.startIfNeeded()
        }
    }

    // Must only be called while already on syncQueue.
    private func startIfNeeded() {

        guard task == nil else { return }

        FileManager.default.createFileIfNeeded(at: fileURL)
        fileHandle = try? FileHandle(forWritingTo: fileURL)

        var req = URLRequest(url: url)
        req.addValue("bytes=0-", forHTTPHeaderField: "Range")

        task = session.dataTask(with: req)
        task?.resume()
    }

    // MARK: URLSessionDataDelegate

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {

        syncQueue.async {
            self.expectedLength = response.expectedContentLength
            self.mimeType = response.mimeType

            if let http = response as? HTTPURLResponse {
                for request in self.streamingRequests {
                    let content = request.contentInformationRequest
                    content?.contentType = http.mimeType
                    content?.contentLength = self.expectedLength
                    content?.isByteRangeAccessSupported = true
                }
            }

            completionHandler(.allow)
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        syncQueue.async {
            self.receivedData.append(data)
            self.fileHandle?.write(data)

            self.processStreamingRequests()
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        syncQueue.async {
            self.processStreamingRequests()
            try? self.fileHandle?.close()

            if error == nil {
                UnifiedVideoCache.markComplete(
                    for: self.url,
                    expectedSize: Int64(self.receivedData.count),
                    mimeType: self.mimeType
                )
            }

            self.onFinished?()
        }
    }

    // Must only be called while already on syncQueue.
    private func processStreamingRequests() {

        var finished: [AVAssetResourceLoadingRequest] = []

        for request in streamingRequests {

            guard let dataRequest = request.dataRequest else { continue }

            let requestedOffset = Int(dataRequest.requestedOffset)
            let currentOffset = Int(dataRequest.currentOffset)
            let requestedLength = dataRequest.requestedLength

            let bytesAvailable = receivedData.count
            let startOffset = currentOffset

            guard bytesAvailable > startOffset else { continue }

            let bytesToSend = min(bytesAvailable - startOffset, requestedLength)
            let chunk = receivedData.subdata(in: startOffset..<(startOffset + bytesToSend))

            dataRequest.respond(with: chunk)

            let endOffset = startOffset + bytesToSend

            if endOffset >= requestedOffset + requestedLength {
                request.finishLoading()
                finished.append(request)
            }
        }

        streamingRequests.removeAll { finished.contains($0) }
    }
}
