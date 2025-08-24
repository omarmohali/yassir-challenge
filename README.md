# Rick and Morty Characters App

## Overview
This iOS app displays a list of characters from the [Rick and Morty API](https://rickandmortyapi.com/). Users can browse characters, apply status filters, and view character details.  

The app combines **UIKit** for navigation and list presentation with **SwiftUI** for smaller, reusable views like character details, loading indicators, and filters.

## Steps to run
1. Clone the repository
```bash
git clone https://github.com/omarmohali/yassir-challenge
```
2. Open the project in Xcode.
3. Choose YassirChallenge and run the app

## Architecture & Implementation

### Modules

#### Network
- Abstraction over `URLSession` supporting GET requests.
- Designed for extensibility to add other HTTP methods if needed.

#### CharactersAPI
- Depends on `Network`.
- Defines DTOs for API responses and handles decoding.
- Provides **async/await** API methods.

#### CharactersUI
- Contains domain models and UI logic.
- Public entry point: `CharactersUIClient`.
- Implements **MVVM** for the character list:
  - `CharactersListViewModel` handles state (loading, loaded, error) and pagination.
  - `CharactersLoader` bridges async/await API calls to completion handlers for UIKit.
- Character details skip the ViewModel since there is no business logic.
- Uses `UITableView` with `UITableViewDiffableDataSource` for efficient updates and infinite scrolling.
- SwiftUI views embedded using `UIHostingController` for:
  - Character details (`CharacterDetailsView`)
  - Filters (`FiltersView`)
  - Loading and error states (`ProgressView`, `ErrorView`)

### Navigation
- `CharactersUIClient` exposes a method to return a `UINavigationController` containing the characters list.
- Character selection triggers a closure that pushes `CharacterDetailsView` wrapped in a `UIHostingController`.
- Custom back actions are handled inside the SwiftUI details view, maintaining UIKit navigation behavior.

---

## Assumptions & Decisions
- **Skipping ViewModel for character details**: Since no business logic or API calls exist, the SwiftUI view consumes the Character model directly. This simplifies the code while maintaining separation of concerns.
- **SwiftUI inside UIKit**: Required for smaller views as per challenge instructions. `UIHostingController` integrates SwiftUI views seamlessly.
- **Async/await handling in UIKit**: `CharactersLoader` converts results to completion handlers for easier integration with UIKit and the ViewModel.
- **Pagination & infinite scrolling**: The list loads additional characters as the user scrolls. The `willDisplay` table view delegate triggers fetching the next page.

---

## Challenges & Solutions

| Challenge | Solution |
|-----------|---------|
| Combining SwiftUI and UIKit | Embedded SwiftUI views using `UIHostingController` for filters, details, and loading/error states. |
| Asynchronous API calls in UIKit | `CharactersLoader` bridges async/await to completion handlers, updating the ViewModel on the main actor. |
| Infinite scrolling | Used `willDisplay` to detect the last visible cell and request the next page. Snapshots via `UITableViewDiffableDataSource` handle smooth updates. |
| Navigation and details view presentation | Character selection closure pushes SwiftUI views onto `UINavigationController`, keeping navigation logic decoupled from the ViewModel. |

---

## Testing

### Unit Tests
- Full coverage for `Network` and `CharactersAPI` modules.
- Full coverage for `CharactersLoader` and `CharactersListViewModel`.
- View controllers and SwiftUI views are not unit tested; an improvement would be adding snapshot tests for them.

### Integration Tests
- Integration tests are used to test the app behaviour, interaction with the API and navigation logic
- Example scenarios:
  - Filter characters by status and verify list updates correctly.
  - Tap a character and verify `CharacterDetailsView` appears.
  - Infinite scrolling verified by scrolling until a character from a later page is visible.
- Integration Tests failing can spot navigation issues and also issues with the backend
- Example integration tests (`YassirChallengeUITests.swift`):
  - `testFilteringAndNavigating()`
  - `testInfiniteScrolling()`

---

## AI Usage
- AI assistance was used only to speed up UI development and writing test scaffolding, such as generating XCUITest boilerplate and SwiftUI layout helpers, also to generate this Readme file :)
