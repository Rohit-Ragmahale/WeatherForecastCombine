//
//  NetworkManager.swift
//  WeatherForecastCombine
//
//  Created by Rohit on 13/05/20.
//  Copyright © 2020 Rohit. All rights reserved.
//

import Foundation
//import UIKit

private func NetworkLog(_ message: String) {
    #if DEBUG
        print("NetworkManager--> \(message)")
    #endif
}

typealias TaskCompletionCallBack = ((_ task: Task, _ error: Error?) -> Void)

fileprivate struct NetworkConstant {
    static var OperationObserverKey: String { return "operations" }
    static var QueueName: String { return "DownloadQueue" }
}
//-----------------------------------------------
// NetworkManager: Singleton class for
// handing newtwok call
//-----------------------------------------------

class NetworkManager: NSObject {

    static let shared = NetworkManager()
    let queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = NetworkConstant.QueueName
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
    private var _shouldNewtwokActivity: Bool = false
    var shouldNewtwokActivity: Bool {
        get {return _shouldNewtwokActivity}
        set {
            if _shouldNewtwokActivity != newValue {
                _shouldNewtwokActivity = newValue
                self.setupObserver()
                self.checkForNetwrokActivity()
            }
        }
    }
    private func setupObserver() {
        if self.shouldNewtwokActivity {
            self.queue.addObserver(self, forKeyPath: NetworkConstant.OperationObserverKey, options: NSKeyValueObservingOptions(rawValue: UInt(0)), context: nil)
        } else {
            self.queue.removeObserver(self, forKeyPath: NetworkConstant.OperationObserverKey, context: nil)
        }
    }

    override init() {
        super.init()
        self.shouldNewtwokActivity = true
    }

    internal override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == NetworkConstant.OperationObserverKey, (object as? OperationQueue) == self.queue {
            self.checkForNetwrokActivity()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func checkForNetwrokActivity() {
        if self.queue.operationCount > 0 && self.shouldNewtwokActivity {
            //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        } else {
            //UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

}
//-----------------------------------------------
// ServiceTask: Methods exposed to user only
//-----------------------------------------------

extension NetworkManager {

    func add(downloadTask task: Task, completion:@escaping TaskCompletionCallBack) {
        let op = ServiceTask.init(task, serviceType: .download, completion: completion)
        op.queuePriority = .high
        self.queue.addOperation(op)
    }

    func task(withIdentifier: String) -> Task? {
        return (self.queue.operations.filter {
            return ($0 as? ServiceTask)?.task.identifier == withIdentifier
            }.first as? ServiceTask)?.task
    }

    func add( dataTask task: Task, completion:@escaping TaskCompletionCallBack) {
        let op = ServiceTask.init(task, serviceType: .data, completion: completion)
        op.queuePriority = .high
        self.queue.addOperation(op)
    }

    func cancelAllTask() {
        self.queue.cancelAllOperations()
    }

    var runningOpertaions: Int {
        return self.queue.operationCount
    }

    func downloadData(url: String, completion: @escaping ((_ data: [String : Any]?) -> Void)) {
        let task = Task(url: url)
        add(dataTask: task) { (task: Task, error) in
            if error == nil {
                task.response?.data({ (data) in
                    guard let data = data else {
                        return
                    }
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        print(jsonObject)
                        completion(jsonObject as? [String : Any])
                    } catch {
                        print("Json Eror \(error)")
                        completion(nil)
                    }
                    
                })
            } else {
                completion(nil)
            }
        }
    }
}

//-----------------------------------------------
// ServiceTask: Download data from Task
//-----------------------------------------------
private class ServiceTask: Operation {
    enum ServiceTaskType {
        case data, download, upload
    }

    private var taskType: ServiceTaskType
    fileprivate var completionHandler: TaskCompletionCallBack?
    fileprivate var session: URLSession!
    internal var task: Task

    internal var executingLocal: Bool = false
    internal var isFinishedLocal: Bool = false
    //internal var _isCancelled : Bool = false

    init(_ task: Task, serviceType type: ServiceTaskType, completion:@escaping TaskCompletionCallBack) {
        self.task = task
        self.taskType = type
        self.completionHandler = completion
    }

    override func start() {
        if self.isCancelled {
            self.updateState(.cancel)
            return
        }

        if let request = self.task.request {
            self.updateState(.shedule)
            self.session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.current)

            switch self.taskType {
            case .data: self.startDataTask(request: request)
            case .download: self.startDataDownloadTask(request: request)
            case .upload: self.startDataTask(request: request)
            }

            self.updateState(.running)
        } else {
            self.task.customError = NSError(domain: "Request not found", code: Task.StatusCode.requestNotFound.rawValue, userInfo: nil)
            self.handleResponse(object: nil, response: nil, error: nil)
        }
    }

    internal func startDataTask(request: URLRequest) {

        self.session.dataTask(with: request) {  [weak self] (data, response, error) in
            if let object = self?.handleResponse(object: data, response: response, error: error) {
                self?.task.response = Task.Response(urlResponse: response, data: object as? Data)
                self?.updateState(.success)
            }
            }.resume()

    }

    internal func startDataDownloadTask(request: URLRequest) {
        self.session.downloadTask(with: request).resume()
    }

    @discardableResult internal func handleResponse(object:Any?, response: URLResponse?, error: Error?) -> Any? {

        guard self.task.customError == nil else {
            self.task.response = Task.Response(urlResponse: nil, error: self.task.customError)
            self.updateState(.failed)
            return nil
        }

        guard error == nil, object != nil else {
            self.task.response = Task.Response(urlResponse: response, error: error!)
            self.updateState(.failed)
            return nil
        }

        guard let httpHeader = response as? HTTPURLResponse, httpHeader.statusCode == Task.StatusCode.success.rawValue else {

            let error = NSError.init(domain: "Bad response from server. Check httpStatusCode of Task", code: 12, userInfo: nil) as Error?
            self.task.response = Task.Response(urlResponse: response, error: error)
            NetworkLog("HTTP status should be 200. It is \(String(describing: self.task.response?.urlResponse?.statusCode))")
            self.updateState(.failed)
            return nil
        }
        return object
    }

    internal func updateState(_ state: Task.State) {

        self.task.state = state

        // Check for completion
        if state.rawValue > Task.State.running.rawValue {
            self.isExecuting = false
            self.isFinished = true
            self.completionHandler?(self.task, self.task.response?.error)

        } else if state == .running {
            self.isExecuting = true
            self.isFinished = false
        }
    }

}

//-----------------------------------------------
// ServiceTask: NSURL Session Delgate handling
//-----------------------------------------------

extension ServiceTask: URLSessionDelegate {

    internal func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        NetworkLog("Challenge received for task identifier: \(self.task.identifier)")
        switch challenge.protectionSpace.authenticationMethod {

        case NSURLAuthenticationMethodServerTrust:
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))

        case NSURLAuthenticationMethodHTTPBasic,
             NSURLAuthenticationMethodHTTPDigest,
             NSURLAuthenticationMethodClientCertificate:

            if challenge.previousFailureCount > task.authenticationRetry {
                task.customError = NSError(domain: "Authentication challenge retry attempt exceed!", code: Task.StatusCode.authChellengeRetry.rawValue, userInfo: nil)
                session.invalidateAndCancel()
                break
            }
            if let result = task.authenticationHandler?(challenge) {
                completionHandler(result.0, result.1)
            } else {
                task.customError = NSError(domain: "Authentication challeange not handle. Use task.authentication", code: Task.StatusCode.authChellenge.rawValue, userInfo: nil)
                session.invalidateAndCancel()
            }
            break

        default:
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension ServiceTask: URLSessionTaskDelegate {
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            self.handleResponse(object: nil, response: nil, error: error)
        }
    }
}

extension ServiceTask: URLSessionDownloadDelegate {

    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.task.response = Task.Response(urlResponse: nil, url: location)
        self.updateState(.success)
    }

    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.task.trackProgress?(round((((Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))*100))*100)/100)
    }

}

//-----------------------------------------------
// ServiceTask: KVO handling
//-----------------------------------------------

extension ServiceTask {

    override var isExecuting: Bool {
        get { return executingLocal }
        set {
            willChangeValue(forKey: "isExecuting")
            self.executingLocal = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    override var isFinished: Bool {
        get { return isFinishedLocal }
        set {
            willChangeValue(forKey: "isFinished")
            isFinishedLocal = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    fileprivate override func cancel() {
        super.cancel()
        self.updateState(.cancel)
    }

}

//-----------------------------------------------
// Task: Task will execute in operation
//-----------------------------------------------

class Task {

    fileprivate var customError: NSError?
    private let _identifier: String = UUID().uuidString
    fileprivate var trackStateBlock: ((Task.State) -> Void)?
    fileprivate var authenticationHandler: ((URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))?
    fileprivate var trackProgress: ((Double) -> Void)?

    fileprivate let urlString: String
    var identifier: String { return self._identifier }

    var userInfo: [String:AnyObject]?
    var headers: [String:AnyObject]?
    var requestBody: [String:AnyObject]?
    var method = Task.Method.none
    var timeout: TimeInterval = 30
    var authenticationRetry = 1

    var state = Task.State.pending {
        didSet {
            if state != oldValue {
                self.trackStateBlock?(state)
            }
        }
    }

    var response: Task.Response?

    init(url: String) { self.urlString = url }

    func trackState(block: @escaping (_ state: Task.State) -> Void) {
        self.trackStateBlock = block
    }

    func authentication(block: @escaping (URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?)) {
        self.authenticationHandler = block
    }

    func progress(block: @escaping (Double) -> Void) {
        self.trackProgress = block
    }
}

extension Task {

    var request: URLRequest? {

        if let url = URL(string: self.urlString) {
            var req = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: self.timeout)
            if self.method != .none {
                req.httpMethod = self.method.rawValue
            }
            // Set header
            if self.headers != nil {
                for (key, value) in self.headers! {
                    req.setValue(value as? String, forHTTPHeaderField: key)
                }
            }

            // set body
            if self.requestBody != nil && JSONSerialization.isValidJSONObject(self.requestBody!) {
                do {
                    req.httpBody = try JSONSerialization.data(withJSONObject: self.requestBody!, options: .prettyPrinted)
                } catch {
                    NetworkLog("HTTP request body error: \(error)")
                }
            }
            return req

        }
        return nil
    }
}

//-----------------------------------------------
// Task: Enum for Task
//-----------------------------------------------

extension Task {

    enum Method: String {
        case post = "POST", get = "GET", put = "PUT", head = "HEAD", delete="DELETE", connect = "CONNECT", option = "OPTIONS", trace = "TRACE", none = "NONE"
    }

    enum State: Int {
        case pending = 1, shedule = 2, running = 3, success = 4, cancel = 5, failed = 6
    }

    enum StatusCode: Int {
        case success = 200, unknwon = -1, authChellenge = 91, authChellengeRetry = 90, requestNotFound = 101
    }
}

//-----------------------------------------------
// Task: Response data handler
//-----------------------------------------------

internal extension Task {

    struct Response {

        let data: ResponseData?
        let urlResponse: HTTPURLResponse?
        let error: Error?

        init(urlResponse res: URLResponse?, data: Data?) {
            self.data = ResponseData(data: data)
            self.urlResponse = res as? HTTPURLResponse
            self.error = nil
        }

        init(urlResponse res: URLResponse?, url: URL) {
            self.data = ResponseData(URL: url)
            self.urlResponse = res as? HTTPURLResponse
            self.error = nil
        }

        init(urlResponse res: URLResponse?, error: Error?) {
            self.error = error
            self.urlResponse = res as? HTTPURLResponse
            self.data = nil
        }

        func data(_ block: (Data?) -> Void) {
            self.data?.data(block)
        }

    }

    struct ResponseData {

        private let _data: Data?
        private let _url: URL?

        init(data: Data?) {
            self._data = data
            self._url = nil
        }

        init(URL url: URL) {
            self._url = url
            self._data = nil
        }

        func json(_ block:(Any?) -> Void) {

            guard let data = self._data else {
                block(nil)
                return
            }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                block(jsonObject)
            } catch {
                NetworkLog("Json Eror \(error)")
                block(nil)
            }
        }

        func downloadedURL(_ block: (URL?) -> Void) {
            block(self._url)
        }

        fileprivate func data(_ block: (Data?) -> Void) {
            block(self._data)
        }
    }
}
