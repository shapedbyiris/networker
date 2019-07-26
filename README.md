## Integration

### Cocoapods
```ruby
pod 'Networker',
    :git => 'https://github.com/shapedbyiris/networker.git',
    :tag => '~> 0.2',
    :testspecs => ['Tests']
```

### Swift Package Manager
In `Packages.swift`:
```swift
// Add this line in the `dependencies` array:
.package(url: "https://github.com/shapedbyiris/networker.git", from: "0.2.0")

// Add Networker to your target's dependencies:
.dependencies: ["Networker"]
```

Then run
```bash
swift package update
```

```bash
swift package init --type=executable # run this if you're starting from scratch
swift package generate-xcodeproj
```
## Usage
```
import Foundation
import Networker

// Define your model:
struct Slideshow: Codable {
    let author: String
    let title: String
}
struct SlideshowContainer: Codable {
    let slideshow: Slideshow
}

// Define your Error:
struct MyErrorType: Error, Codable {
    let message: String
}

// Define an APIRequest with the expected response type, error type, and URLRequest:
struct SlideshowRequest: APIRequest {
    let request = URLRequest(url: URL(string: "https://httpbin.org/json")!)

    typealias ErrorResponseDataType = MyErrorType

    typealias SuccessfulResponseDataType = SlideshowContainer
}

// Initialise an APIRequestLoader with the APIRequest. APIRequestLoader will smoothly know what to look for in the response and smoothyl report errors:
let loader = APIRequestLoader(apiRequest: SlideshowRequest())
loader.perform { result in
    print(result)
}
```
