import XCTest
@testable import CharactersUI

final class CharactersListViewModelTests: XCTestCase {
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
    sut.stateDidChange = { scrollToTop in
      XCTAssertTrue(scrollToTop)
      expectation.fulfill()
    }
    
    sut.didLoad()
    
    XCTAssertEqual(loader.calls.first?.page, 1)
    XCTAssertNil(loader.calls.first?.filter)
    XCTAssertEqual(sut.state, .loaded(characters))
    
    waitForExpectations(timeout: 1)
  }
  
  @MainActor
  func testInitialLoadFailure() {
    let (sut, loader) = makeSUT()
    loader.result = .failure(NSError(domain: "", code: 0))
    
    let expectation = expectation(description: "State change called")
    sut.stateDidChange = { scrollToTop in
      XCTAssertFalse(scrollToTop)
      expectation.fulfill()
    }
    
    sut.didLoad()
    
    XCTAssertEqual(loader.calls.first?.page, 1)
    XCTAssertNil(loader.calls.first?.filter)
    XCTAssertEqual(sut.state, .error(message: "Something went wrong"))
    
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
    sut.stateDidChange = { scrollToTop in
      XCTAssertTrue(scrollToTop)
      initialExpectation.fulfill()
    }
    
    sut.didLoad()
    XCTAssertEqual(loader.calls.first?.page, 1)
    XCTAssertNil(loader.calls.first?.filter)
    XCTAssertEqual(sut.state, .loaded(firstPage))
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
    sut.stateDidChange = { scrollToTop in
      XCTAssertFalse(scrollToTop)
      loadMoreExpectation.fulfill()
    }
    
    sut.loadMore()
    
    XCTAssertEqual(loader.calls[1].page, 2)
    XCTAssertNil(loader.calls[1].filter)
    XCTAssertEqual(sut.state, .loaded(firstPage + secondPage))
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
    sut.stateDidChange = { scrollToTop in
      XCTAssertTrue(scrollToTop)
      expectation.fulfill()
    }
    
    sut.applyFilter(filter: .alive)
    
    XCTAssertEqual(loader.calls.first?.page, 1)
    XCTAssertEqual(loader.calls.first?.filter, .alive)
    XCTAssertEqual(sut.state, .loaded(characters))
    
    waitForExpectations(timeout: 1)
  }
  
  @MainActor
  func testRetryAfterError() {
    let (sut, loader) = makeSUT()
    loader.result = .failure(NSError(domain: "", code: 0))
    
    let errorExpectation = expectation(description: "Error state")
    sut.stateDidChange = { scrollToTop in
      XCTAssertFalse(scrollToTop)
      errorExpectation.fulfill()
    }
    
    sut.didLoad()
    XCTAssertEqual(loader.calls.first?.page, 1)
    XCTAssertNil(loader.calls.first?.filter)
    XCTAssertEqual(sut.state, .error(message: "Something went wrong"))
    waitForExpectations(timeout: 1)
    
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
    
    var callCount = 0
    sut.stateDidChange = { scrollToTop in
      callCount += 1
      if callCount == 1 {
        XCTAssertFalse(scrollToTop)
      } else if callCount == 2 {
        XCTAssertTrue(scrollToTop)
      }
      retryExpectation.fulfill()
    }
    
    sut.retry()
    
    XCTAssertEqual(loader.calls.first?.page, 1)
    XCTAssertNil(loader.calls.first?.filter)
    XCTAssertEqual(sut.state, .loaded(characters))
    waitForExpectations(timeout: 1)
  }
  
  @MainActor
  private func makeSUT() -> (CharactersListViewModel, MockCharactersLoader) {
    let loader = MockCharactersLoader()
    let sut = CharactersListViewModel(charactersLoader: loader)
    return (sut, loader)
  }
}

final class MockCharactersLoader: CharactersLoaderProtocol {
  var calls = [(page: Int, filter: Filter?)]()
  var result: Result<[Character], Error>?
  
  func getCharacters(for page: Int, filter: Filter?, completion: @escaping (Result<[Character], Error>) -> Void) {
    calls.append((page: page, filter: filter))
    guard let result else {
      fatalError("Result must be set before calling")
    }
    completion(result)
  }
}
