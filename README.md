## Usage
```
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
