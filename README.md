## Usage

```swift
import Foundation
import Networker

// Define the response as a type that conforms to Decodable:
struct Slideshow: Decodable {
    let author: String
    let title: String
}
struct SlideshowContainer: Decodable {
    let slideshow: Slideshow
}

// Define your Error:
struct MyErrorType: Error, Decodable {
    let message: String
}

// Define an APIRequest with the expected response type, error type, and URLRequest:
struct SlideshowRequest: APIRequest {
    let request = URLRequest(url: URL(string: "https://httpbin.org/json")!)

    typealias ErrorResponseDataType = MyErrorType

    typealias SuccessfulResponseDataType = SlideshowContainer
}

// Call `perform` opn your `APIRequest` instance. `APIRequest` will know
// what to look for in the response and smoothly report success values or errors:
let result = try await SlideshowRequest().perform()
print(result.slideshow.author) // "Yours Truly"
```


## Integration

### Swift Package Manager

In `Packages.swift`:
```swift
// Add this line in the `dependencies` array:
.package(url: "https://github.com/shapedbyiris/networker.git", from: "1.0.0")

// Add Networker to your target's dependencies:
.dependencies: ["Networker"]
```

## Inspiration

[WWDC 2018 session 417 _Testing Tips & Tricks_](https://developer.apple.com/videos/play/wwdc2018/417/)
