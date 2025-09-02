import XCTest
@testable import RouterKit

class RouterCoreTests: XCTestCase {
    
    func testRoutePatternCreation() throws {
        // 测试基本路由模式创建
        let pattern1 = try RoutePattern("/user")
        XCTAssertEqual(pattern1.pattern, "/user")
        
        let pattern2 = try RoutePattern("/user/:id")
        XCTAssertEqual(pattern2.pattern, "/user/:id")
        
        let pattern3 = try RoutePattern("/files/*")
        XCTAssertEqual(pattern3.pattern, "/files/*")
    }
    
    func testRoutePatternMatching() throws {
        let pattern = try RoutePattern("/user/:id")
        let url = URL(string: "myapp:///user/123")!
        
        let (parameters, matches) = pattern.match(url)
        
        XCTAssertTrue(matches)
        XCTAssertEqual(parameters["id"] as? String, "123")
    }
    
    func testRoutePatternWithQuery() throws {
        let pattern = try RoutePattern("/search")
        let url = URL(string: "myapp:///search?q=test&page=1")!
        
        let (parameters, matches) = pattern.match(url)
        
        XCTAssertTrue(matches)
        XCTAssertEqual(parameters["q"] as? String, "test")
        XCTAssertEqual(parameters["page"] as? String, "1")
    }
    
    func testInvalidRoutePattern() {
        // 测试无效的路由模式
        XCTAssertThrowsError(try RoutePattern("")) { error in
            XCTAssertTrue(error is RouterError)
        }
    }
    
    func testRouteWithFragment() throws {
        let pattern = try RoutePattern("/page")
        let url = URL(string: "myapp:///page#section1")!
        
        let (parameters, matches) = pattern.match(url)
        
        XCTAssertTrue(matches)
        XCTAssertEqual(parameters["fragment"] as? String, "section1")
    }
    
    func testMultipleParameters() throws {
        let pattern = try RoutePattern("/user/:userId/post/:postId")
        let url = URL(string: "myapp:///user/456/post/789")!
        
        let (parameters, matches) = pattern.match(url)
        
        XCTAssertTrue(matches)
        XCTAssertEqual(parameters["userId"] as? String, "456")
        XCTAssertEqual(parameters["postId"] as? String, "789")
    }
    
    func testWildcardPattern() throws {
        let pattern = try RoutePattern("/files/*")
        
        // 测试单级匹配
        let url1 = URL(string: "myapp:///files/document.pdf")!
        let (params1, matches1) = pattern.match(url1)
        XCTAssertTrue(matches1)
        XCTAssertEqual(params1["*"] as? String, "document.pdf")
        
        // 测试多级匹配
        let url2 = URL(string: "myapp:///files/folder/subfolder/file.txt")!
        let (params2, matches2) = pattern.match(url2)
        XCTAssertTrue(matches2)
        XCTAssertEqual(params2["*"] as? String, "folder/subfolder/file.txt")
    }
    
    func testPatternEquality() throws {
        let pattern1 = try RoutePattern("/user/:id")
        let pattern2 = try RoutePattern("/user/:id")
        let pattern3 = try RoutePattern("/user/:userId")
        
        XCTAssertEqual(pattern1, pattern2)
        XCTAssertNotEqual(pattern1, pattern3)
    }
    
    func testPatternHashable() throws {
        let pattern1 = try RoutePattern("/user/:id")
        let pattern2 = try RoutePattern("/user/:id")
        
        var set = Set<RoutePattern>()
        set.insert(pattern1)
        set.insert(pattern2)
        
        XCTAssertEqual(set.count, 1)
    }
}

// 测试用的Routable实现
class TestRoutable: Routable {
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
}