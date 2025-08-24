import XCTest
@testable import CharactersUI
@testable import CharactersAPI

final class CharactersLoaderTests: XCTestCase {
  
  @MainActor
  func testGetCharactersReturnsCorrectCharactersWhenAPISucceeds() async {
    let (sut, api) = makeSUT()
    
    let sampleResponse = CharactersResponseDto(
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
    
    api.result = .success(sampleResponse)
    
    let expectation = expectation(description: "Completion called")
    var received: Result<[Character], Error>?
    
    sut.getCharacters(for: 1, filter: .alive) { result in
      received = result
      expectation.fulfill()
    }
    
    await fulfillment(of: [expectation], timeout: 1)
    
    let characters = try? received?.get()
    
    XCTAssertEqual(
      characters,
      [
        .init(
          id: 1,
          name: "Rick Sanchez",
          imageUrl: URL(string: "https://www.image.com/rick.png")!,
          species: "Human",
          status: .alive,
          gender: "Male"
        ),
        .init(
          id: 2,
          name: "Morty Smith",
          imageUrl: URL(string: "https://www.image.com/morty.png")!,
          species: "Human",
          status: .alive,
          gender: "Male"
        )
      ]
    )
    
    XCTAssertEqual(api.calls.count, 1)
    XCTAssertEqual(api.calls.first?.page, 1)
    XCTAssertEqual(api.calls.first?.filter, .alive)
  }
  
  @MainActor
  func testGetCharactersReturnsFailureWhenAPIFails() async {
    let (sut, api) = makeSUT()
    let sampleError = AnyError()
    api.result = .failure(sampleError)
    
    let expectation = expectation(description: "Completion called")
    var received: Result<[Character], Error>?
    
    sut.getCharacters(for: 1, filter: nil) { result in
      received = result
      expectation.fulfill()
    }
    
    await fulfillment(of: [expectation], timeout: 1)
    
    switch received {
    case let .failure(error as AnyError)?:
      XCTAssertEqual(error, AnyError())
    default:
      XCTFail("Expected failure with AnyError")
    }
  }
  
  private func makeSUT() -> (CharactersLoader, CharactersAPIMock) {
    let api = CharactersAPIMock()
    let sut = CharactersLoader(api: api)
    return (sut, api)
  }
}

final class CharactersAPIMock: CharactersAPIProtocol {
  var calls = [(page: Int, filter: FilterDto?)]()
  var result: Result<CharactersResponseDto, Error>?
  
  func getCharacters(page: Int, filter: FilterDto?) async throws -> CharactersResponseDto {
    calls.append((page: page, filter: filter))
    
    guard let result else {
      fatalError("Result must be set before calling")
    }
    
    switch result {
    case let .success(response): return response
    case let .failure(error): throw error
    }
  }
}

private struct AnyError: Error, Equatable {}
