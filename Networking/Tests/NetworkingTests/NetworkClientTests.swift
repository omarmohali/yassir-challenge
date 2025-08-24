import XCTest
import Foundation
@testable import Networking

class GetCharactersTests: XCTestCase {
  lazy var session: URLSession = {
      let  configuration = URLSessionConfiguration.ephemeral
      configuration.protocolClasses = [MockURLProtocol.self]
      return URLSession(configuration: configuration)
  }()
  
  override func tearDown() {
      super.tearDown()
      MockURLProtocol.requestHandler = nil
  }
  
  func testConstructsRequestWithCorrectUrl() async throws {
    let anyURL = URL(string: "www.any-url.com")!
    let responseData = "example data".data(using: .utf8)!
    let sut = NetworkClient(session: session, baseURL: anyURL)

    var capturedRequest: URLRequest?
    MockURLProtocol.requestHandler = { request in
        capturedRequest = request
        return (.init(), responseData)
    }
    
    let _ = try await sut.get(path: "/path", queryItems: [
      .init(name: "name1", value: "value1"),
      .init(name: "name2", value: "value2")
    ])
    
    let request = try XCTUnwrap(capturedRequest)
    XCTAssertEqual(request.url?.absoluteString, "\(anyURL)/path?name1=value1&name2=value2")
  }
  
  func testReturnsCorrectDataWhenRequestSucceeds() async throws {
    let anyURL = URL(string: "www.any-url.com")!
    let responseData = "example data".data(using: .utf8)!
    let sut = NetworkClient(session: session, baseURL: anyURL)

    let response = try XCTUnwrap(
      HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)
    )
    MockURLProtocol.requestHandler = { request in
      return (response, responseData)
    }
    
    let data = try await sut.get(path: "/path", queryItems: [])
    XCTAssertEqual(data, responseData)
  }
  
  func testThrowsHttpErrorWhenResponseIs4xx() async throws {
    let anyURL = URL(string: "www.any-url.com")!
    let responseData = "example data".data(using: .utf8)!
    let sut = NetworkClient(session: session, baseURL: anyURL)

    let response = try XCTUnwrap(
      HTTPURLResponse(url: anyURL, statusCode: 400, httpVersion: nil, headerFields: nil)
    )
    MockURLProtocol.requestHandler = { request in
      return (response, responseData)
    }
    
    do {
      let _ = try await sut.get(path: "/path", queryItems: [])
      XCTFail("Should throw Network Error 400")
    } catch {
      XCTAssertEqual(error as? NetworkError, .httpError(.init(statusCode: 400, data: responseData)))
    }
  }
  
  func testThrowsHttpErrorWhenResponseIs5xx() async throws {
    let anyURL = URL(string: "www.any-url.com")!
    let responseData = "example data".data(using: .utf8)!
    let sut = NetworkClient(session: session, baseURL: anyURL)

    let response = try XCTUnwrap(
      HTTPURLResponse(url: anyURL, statusCode: 500, httpVersion: nil, headerFields: nil)
    )
    MockURLProtocol.requestHandler = { request in
      return (response, responseData)
    }
    
    do {
      let _ = try await sut.get(path: "/path", queryItems: [])
      XCTFail("Should throw Network Error 500")
    } catch {
      XCTAssertEqual(error as? NetworkError, .httpError(.init(statusCode: 500, data: responseData)))
    }
  }
  
  private func httpError(_ httpError: NetworkError.HttpError) -> NetworkError {
    .httpError(httpError)
  }
}
