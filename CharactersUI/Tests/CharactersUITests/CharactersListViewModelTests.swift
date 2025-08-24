import XCTest
@testable import CharactersUI

final class CharactersListViewModelTests: XCTestCase {
  
  @MainActor
  func testInitialState() {
    let (sut, _) = makeSUT()
    XCTAssertEqual(sut.state, .loading)
  }
  
  @MainActor
  func testInitialLoadSuccess() {
    let (sut, loader) = makeSUT()
    let characters = [
      Character(
        id: 1,
        name: "Rick Sanchez",
        imageUrl: URL(string: "https://www.image.com/rick.png")!,
        species: "Human",
        status: .alive,
        gender: "Male"
      )
    ]
    
    loader.result = .success(characters)
    
    let expectation = expectation(description: "State change called")
    sut.stateDidChange = {
      expectation.fulfill()
    }
    
    sut.didLoad()
    
    XCTAssertEqual(loader.calls, [.init(page: 1, filter: nil)])
    XCTAssertEqual(sut.state, .loaded(characters, isFirstPage: true))
    
    waitForExpectations(timeout: 1)
  }
  
  @MainActor
  func testInitialLoadFailure() {
    let (sut, loader) = makeSUT()
    loader.result = .failure(NSError(domain: "", code: 0))
    
    let expectation = expectation(description: "State change called")
    sut.stateDidChange = {
      expectation.fulfill()
    }
    
    sut.didLoad()
    
    XCTAssertEqual(loader.calls, [.init(page: 1, filter: nil)])
    XCTAssertEqual(sut.state, .error(message: LocalizedString.Generic.somethingWentWrong))
    
    waitForExpectations(timeout: 1)
  }
  
  @MainActor
  func testLoadMoreAppendsCharacters() {
    let (sut, loader) = makeSUT()
    let firstPage = [
      Character(
        id: 1,
        name: "Rick Sanchez",
        imageUrl: URL(string: "https://www.image.com/rick.png")!,
        species: "Human",
        status: .alive,
        gender: "Male"
      )
    ]
    loader.result = .success(firstPage)
    
    let initialExpectation = expectation(description: "Initial load")
    sut.stateDidChange = {
      initialExpectation.fulfill()
    }
    
    sut.didLoad()
    XCTAssertEqual(loader.calls, [.init(page: 1, filter: nil)])
    XCTAssertEqual(sut.state, .loaded(firstPage, isFirstPage: true))
    waitForExpectations(timeout: 1)
    
    let secondPage = [
      Character(
        id: 2,
        name: "Morty Smith",
        imageUrl: URL(string: "https://www.image.com/morty.png")!,
        species: "Human",
        status: .alive,
        gender: "Male"
      )
    ]
    loader.result = .success(secondPage)
    
    let loadMoreExpectation = expectation(description: "Load more")
    sut.stateDidChange = {
      loadMoreExpectation.fulfill()
    }
    
    sut.loadMore()
    
    XCTAssertEqual(loader.calls[1].page, 2)
    XCTAssertNil(loader.calls[1].filter)
    XCTAssertEqual(loader.calls, [
      .init(page: 1, filter: nil), .init(page: 2, filter: nil)
    ])
    XCTAssertEqual(sut.state, .loaded(firstPage + secondPage, isFirstPage: false))
    waitForExpectations(timeout: 1)
  }
  
  @MainActor
  func testApplyFilterResetsPage() {
    let (sut, loader) = makeSUT()
    let characters = [
      Character(
        id: 1,
        name: "Rick Sanchez",
        imageUrl: URL(string: "https://www.image.com/rick.png")!,
        species: "Human",
        status: .alive,
        gender: "Male"
      )
    ]
    loader.result = .success(characters)
    
    let expectation = expectation(description: "Filter applied")
    sut.stateDidChange = {
      expectation.fulfill()
    }
    
    sut.applyFilter(filter: .alive)
    
    XCTAssertEqual(loader.calls, [.init(page: 1, filter: .alive)])
    XCTAssertEqual(sut.state, .loaded(characters, isFirstPage: true))
    
    waitForExpectations(timeout: 1)
  }
  
  @MainActor
  func testRetryAfterError() {
    let (sut, loader) = makeSUT()
    loader.result = .failure(NSError(domain: "", code: 0))
    
    let errorExpectation = expectation(description: "Error state")
    sut.stateDidChange = {
      errorExpectation.fulfill()
    }
    
    sut.didLoad()
    XCTAssertEqual(loader.calls, [.init(page: 1, filter: nil)])
    XCTAssertEqual(sut.state, .error(message: LocalizedString.Generic.somethingWentWrong))
    wait(for: [errorExpectation], timeout: 1)
    
    let characters = [
      Character(
        id: 2,
        name: "Morty Smith",
        imageUrl: URL(string: "https://www.image.com/morty.png")!,
        species: "Human",
        status: .alive,
        gender: "Male"
      )
    ]
    
    loader.result = .success(characters)
    
    let retryExpectation = expectation(description: "Retry loads successfully")
    retryExpectation.expectedFulfillmentCount = 2
    var didChangeToLoading = false
    sut.stateDidChange = {
      if !didChangeToLoading {
        XCTAssertEqual(sut.state, .loading)
        didChangeToLoading = true
      }
      retryExpectation.fulfill()
    }
    
    sut.retry()
    
    XCTAssertEqual(loader.calls, [
      .init(page: 1, filter: nil), .init(page: 1, filter: nil)
    ])
    XCTAssertEqual(sut.state, .loaded(characters, isFirstPage: true))
    wait(for: [retryExpectation], timeout: 1)
  }
  
  @MainActor
  private func makeSUT() -> (CharactersListViewModel, MockCharactersLoader) {
    let loader = MockCharactersLoader()
    let sut = CharactersListViewModel(charactersLoader: loader)
    return (sut, loader)
  }
}

final class MockCharactersLoader: CharactersLoaderProtocol {
  struct CharactersLoaderCall: Equatable {
    let page: Int
    let filter: Filter?
  }
  
  var calls = [CharactersLoaderCall]()
  var result: Result<[Character], Error>?
  
  func getCharacters(for page: Int, filter: Filter?, completion: @escaping (Result<[Character], Error>) -> Void) {
    calls.append(.init(page: page, filter: filter))
    guard let result else {
      fatalError("Result must be set before calling")
    }
    completion(result)
  }
}
