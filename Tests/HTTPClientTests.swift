//
//  HTTPClientTests.swift
//  HTTPClientTests
//
//  Created by Ariel Elkin on 17/07/2019.
//  Copyright © 2019 IRIS. All rights reserved.
//

import XCTest

@testable import Networker

class HTTPClientTests: XCTestCase { // swiftlint:disable force_try nesting

    struct MockErrorType: Error, Codable {
        let message: String
    }
    struct MockSuccessType: Codable {
        let value: Int
    }

    struct MockAPIRequestType: APIRequest {
        typealias SuccessfulResponseDataType = MockSuccessType
        typealias ErrorResponseDataType = MockErrorType
        let request = URLRequest(url: URL(string: "https://example.com")!)
    }

    func testLoaderSuccess() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString.contains("example"), true)

            let resultObject = MockSuccessType(value: 32)
            let resultJSON = try! JSONEncoder().encode(resultObject)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!

            return (response, resultJSON)
        }

        let expectation = XCTestExpectation(description: "response")

        let apiRequest = MockAPIRequestType()
        let loader = APIRequestLoader(apiRequest: apiRequest, urlSession: urlSession)
        loader.perform { (result) in
            switch result {
            case .success(let value):
                XCTAssert(value.value == 32)
                expectation.fulfill()
            case .failure (let error):
                XCTFail(String(describing: error))
            }
        }
        wait(for: [expectation], timeout: 1)
    }
}

class MockURLProtocol: URLProtocol {

    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler, let client = client else {
            XCTFail("Received unexpected request with no handler or client set")
            return
        }
        do {
            let (response, data) = try handler(request)
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client.urlProtocol(self, didLoad: data)
            client.urlProtocolDidFinishLoading(self)
        } catch {
            client.urlProtocol(self, didFailWithError: error)
        }
    }
    override func stopLoading() {

    }
}
