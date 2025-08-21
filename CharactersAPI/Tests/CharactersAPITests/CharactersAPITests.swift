import XCTest
@testable import CharactersAPI
@testable import Networking

class CharactersAPITests: XCTestCase {
  
  func testGetCharactersReturnsCorrectCharactersResponseWhenNetworkSucceeds() async throws {
    let (sut, networkClient) = makeSUT()
    
    let sampleJSON = """
    {
        "results": [
            {
                "id": 1,
                "name": "Rick Sanchez",
                "status": "Alive",
                "gender": "Male",
                "species": "Human",
                "image": "https://www.image.com/rick.png"
            },
            {
                "id": 2,
                "name": "Morty Smith",
                "status": "Alive",
                "gender": "Male",
                "species": "Human",
                "image": "https://www.image.com/morty.png"
            }
        ]
    }
    """.data(using: .utf8)!
    
    networkClient.result = .success(sampleJSON)

    let response = try await sut.getCharacters(page: 1)

    XCTAssertEqual(
      response,
      .init(
        results: [
          .init(
            id: 1,
            name: "Rick Sanchez",
            status: "Alive",
            species: "Human",
            gender: "Male",
            image: URL(string: "https://www.image.com/rick.png")!
          ),
          .init(
            id: 2,
            name: "Morty Smith",
            status: "Alive",
            species: "Human",
            gender: "Male",
            image: URL(string: "https://www.image.com/morty.png")!
          )
        ]
      )
    )

    XCTAssertEqual(networkClient.calls.count, 1)
    XCTAssertEqual(networkClient.calls.first?.path, "/character/")
    XCTAssertTrue(networkClient.calls.first!.queryItems.contains { $0.name == "page" && $0.value == "1" })
    XCTAssertTrue(networkClient.calls.first!.queryItems.contains { $0.name == "count" && $0.value == "20" })
  }
  
  func testGetCharactersThrowsErrorWhenParsingFails() async throws {
    let (sut, networkClient) = makeSUT()
    
    let sampleJSON = "Non parsable".data(using: .utf8)!
    
    networkClient.result = .success(sampleJSON)

    do {
      let _ = try await sut.getCharacters(page: 1)
      XCTFail("Should throw Error")
    } catch { }
  }
  
  func testGetCharactersThrowsErrorWhenNetworkFails() async throws {
    let (sut, networkClient) = makeSUT()
    
    let sampleError = NetworkError(statusCode: 500, data: .init())
    networkClient.result = .failure(sampleError)

    do {
      let _ = try await sut.getCharacters(page: 1)
      XCTFail("Should throw Network Error 500")
    } catch {
      XCTAssertEqual(error as? NetworkError, NetworkError(statusCode: 500, data: .init()))
    }
  }
  
  
  func makeSUT() -> (CharactersAPI, NetworkClientMock)  {
    let networkClient = NetworkClientMock()
    let sut = CharactersAPI(networkClient: networkClient)
    return (sut, networkClient)
  }
}

class NetworkClientMock: NetworkClientProtocol {
  var calls = [(path: String, queryItems: [URLQueryItem])]()
  var result: Result<Data, Error>?
  func get(path: String, queryItems: [URLQueryItem]) async throws -> Data {
    calls.append((path: path, queryItems: queryItems))

    guard let result = result else {
      fatalError("result should be set before calling this function")
    }
    
    switch result {
    case let .success(data):
      return data
    case let .failure(error):
      throw error
    }
  }
}
