import XCTest
@testable import Asynchrone

final class DebounceAsyncSequenceTests: XCTestCase {
    private var stream: AsyncStream<Int>!
    
    // MARK: Setup
    
    override func setUpWithError() throws {
        self.stream = AsyncStream<Int> { continuation in
            continuation.yield(0)
            try? await Task.sleep(seconds: 0.3)
            continuation.yield(1)
            continuation.yield(2)
            try? await Task.sleep(seconds: 0.3)
            continuation.yield(3)
            try? await Task.sleep(seconds: 0.3)
            continuation.finish()
        }
    }

    // MARK: Tests
    
    func testDebounce() async {
        let values = await self.stream
            .debounce(for: 0.1)
            .collect()
        
        XCTAssertEqual(values, [0, 2, 3])
    }
    
    func testDebounceWithNoValues() async {
        let values = await AsyncStream<Int> {
            $0.finish()
        }
        .debounce(for: 0.3)
        .collect()
        
        XCTAssert(values.isEmpty)
    }
    
    func testWithSequenceInstantFinish() async {
        let values = await Just(0)
            .debounce(for: 0.3)
            .collect()
        
        print(values)
        XCTAssert(values.isEmpty)
    }
}
