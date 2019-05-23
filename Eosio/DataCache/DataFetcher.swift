//
//  DataFetcher.swift
//  EosioReferenceAuthenticator
//
//  Created by Todd Bowden on 9/27/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation

public enum DataFetcherState: Int, CustomStringConvertible {
    case WaitingForNetwork = 1
    case NotConnectedToInternet = 2
    case NetworkConnectionLost = 3
    public var description : String {
        switch self {
        case .WaitingForNetwork: return "Waiting for network connection"
        case .NotConnectedToInternet: return "Not connected to internet"
        case .NetworkConnectionLost: return "Network connection lost"
        }
    }
}

public class DataFetcher: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    private (set) var url: URL
    private (set) var session: URLSession?
    private (set) var task: URLSessionDataTask?
    private (set) var maxBytes: UInt64?
    private (set) var statusCode: Int?
    private var data = Data()
    private var completion: ((Data?, AppError?) -> Void)?
    private var progress: ((DataFetcher, DataFetcherState) -> Void)?
    
    public init(url: URL, maxBytes: UInt64?, configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.url = url
        self.maxBytes = maxBytes
        super.init()
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        // We're not using waitsForConnectivity here because it blocks and we can't re-enter the
        // network offline screen if we are on the countdown style.
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    deinit {
        // UrlSession keeps a strong reference to its delegate.  If the session owner is also the delegate you can
        // end up with a retain cycle unless you call invlidateAndCancel on the session to release the delegate and
        // break the cycle.
        session?.invalidateAndCancel()
    }
    
    public func fetch(completion: @escaping (Data?, AppError?)->Void, progress: ((DataFetcher, DataFetcherState) -> Void)? = nil) {
        self.completion = completion
        self.progress = progress
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        self.task = createTask()
        self.task?.resume()
    }
    
    public func cancelCurrentTask() {
        self.task?.cancel()
        completion?(nil, AppError(AppErrorCode.resourceRetrievalError, reason:"User Cancelled"))
    }
    
    public func retryCurrentTask() {
        // Cannot reuse old task.  Must create a new one.
        self.task = createTask()
        self.task?.resume()
    }
    
    private func createTask() -> URLSessionDataTask? {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        return self.session?.dataTask(with: urlRequest)
    }
    
    private var isSuccessStatusCode: Bool {
        return statusCode == 200
    }
    
    public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        // This only fires if the we're waiting for the initial connection.  If the network drops after
        // making the connection, we will get back an error in completion handler or the session delegate.
        DispatchQueue.main.async {
            self.progress?(self, DataFetcherState.WaitingForNetwork)
        }
    }
    
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data = self.data + data
        if let maxBytes = maxBytes, self.data.count > maxBytes {
            dataTask.cancel()
            completion?(nil, AppError(AppErrorCode.resourceRetrievalError, reason:"Exceeded \(maxBytes) max bytes"))
            completion = nil
        }
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Swift.Error?) {
        if let error = error {
            // Need NSError to distinguish domain and code further up the line
            let err = error as NSError
            self.completion?(nil, AppError(AppErrorCode.resourceRetrievalError,
                                        reason: err.localizedDescription,
                                        originalError: err))
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        statusCode = (task.response as? HTTPURLResponse)?.statusCode
        
        if let error = error {
            let err = error as NSError
            if err.domain == NSURLErrorDomain && err.code == NSURLErrorNotConnectedToInternet {
                DispatchQueue.main.async {
                    self.progress?(self, DataFetcherState.NotConnectedToInternet)
                }
            } else if err.domain == NSURLErrorDomain && err.code == NSURLErrorNetworkConnectionLost {
                DispatchQueue.main.async {
                    self.progress?(self, DataFetcherState.NetworkConnectionLost)
                }
            } else {
                self.completion?(nil, AppError(AppErrorCode.resourceRetrievalError, reason: err.localizedDescription, originalError: err))
            }
            return
        }
        
        guard isSuccessStatusCode else {
            var reason = "Cannot access item at \(url.absoluteURL)."
            if let statusCode = statusCode {
                reason = reason + " Status code \(statusCode)."
            }
            self.completion?(nil, AppError(AppErrorCode.resourceRetrievalError, reason:reason))
            return
        }
        
        self.completion?(data, nil)
    }
    
}
