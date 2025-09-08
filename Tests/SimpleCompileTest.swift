import XCTest
@testable import RouterKit

class SimpleCompileTest: XCTestCase {
    
    func testBasicCompilation() {
        // 简单的编译测试，确保基本类型可以正常使用
        let router = Router.shared
        XCTAssertNotNil(router)
        
        // 测试基本的状态访问
        let state = router.state
        XCTAssertNotNil(state)
    }
    
    func testRouterStateBasics() async {
        let router = Router.shared
        let state = router.state
        
        // 测试基本的状态方法
        let modules = await state.getModules()
        XCTAssertNotNil(modules)
    }
}