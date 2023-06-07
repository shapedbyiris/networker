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

    func testLoaderSuccess() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString.contains("example"), true)

            let resultObject = MockSuccessType(value: 42)
            let resultJSON = try! JSONEncoder().encode(resultObject)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!

            return (response, resultJSON)
        }

        let expectation = XCTestExpectation(description: "doesn't timeout")

        Task {
            let apiRequest = MockAPIRequestType()
            let result = try await apiRequest.perform(urlSession: urlSession)
            XCTAssert(result.value == 42)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler, let client else {
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

    override func stopLoading() {}
}
