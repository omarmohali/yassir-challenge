import XCTest
@testable import CharactersUI
@testable import CharactersAPI

class CharactersAPITests: XCTestCase {
  
  func testGetCharactersReturnsCorrectCharactersWhenAPISucceeds() async throws {
    let (sut, charactersApi) = makeSUT()
    
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
    
    charactersApi.result = .success(sampleResponse)

    let characters = try await sut.getCharacters(for: 1, filter: .alive)

    XCTAssertEqual(
      characters,
      [
        .init(
          id: 1,
          name: "Rick Sanchez",
          imageUrl: URL(string: "https://www.image.com/rick.png")!,
          species: "Human",
          status: "Alive",
          gender: "Male"
        ),
        .init(
          id: 2,
          name: "Morty Smith",
          imageUrl: URL(string: "https://www.image.com/morty.png")!,
          species: "Human",
          status: "Alive",
          gender: "Male"
        )
      ]
    )

    XCTAssertEqual(charactersApi.calls.count, 1)
    XCTAssertEqual(charactersApi.calls.first?.page, 1)
    XCTAssertEqual(charactersApi.calls.first?.filter, .alive)
  }
  
  func testGetCharactersThrowsErrorAPIFails() async throws {
    let (sut, networkClient) = makeSUT()
    
    let sampleError = AnyError()
    networkClient.result = .failure(sampleError)

    do {
      let _ = try await sut.getCharacters(for: 1, filter: nil)
      XCTFail("Should throw error")
    } catch {
      XCTAssertEqual(error as? AnyError, AnyError())
    }
  }
  
  
  func makeSUT() -> (CharactersRepository, CharactersAPIMock)  {
    let charactersApi = CharactersAPIMock()
    let sut = CharactersRepository(api: charactersApi)
    return (sut, charactersApi)
  }
}

class CharactersAPIMock: CharactersAPIProtocol {
  var calls = [(page: Int, filter: FilterDto?)]()
  var result: Result<CharactersResponseDto, Error>?
  func getCharacters(page: Int, filter: FilterDto?) async throws -> CharactersResponseDto {
    calls.append((page: page, filter: filter))

    guard let result = result else {
      fatalError("result should be set before calling this function")
    }
    
    switch result {
    case let .success(response):
      return response
    case let .failure(error):
      throw error
    }
  }
}

private struct AnyError: Error, Equatable { }
