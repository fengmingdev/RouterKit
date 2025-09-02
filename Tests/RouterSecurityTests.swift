import XCTest
@testable import RouterKit

class RouterSecurityTests: XCTestCase {

    var security: RouterSecurity!

    override func setUp() {
        super.setUp()
        security = RouterSecurity.shared
    }

    override func tearDown() {
        security = nil
        super.tearDown()
    }

    func testValidateParameters() {
        // 测试基本参数验证规则
        let rules: [String: ParameterRule] = [
            "name": BasicParameterRule(type: String.self, isRequired: true),
            "age": RangeParameterRule(type: Int.self, min: 0, max: 120, isRequired: false),
            "email": FormatParameterRule(type: String.self, regex: "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", formatDescription: "valid email format", isRequired: true)
        ]

        // 测试有效参数
        let validParams: [String: Any] = [
            "name": "John Doe",
            "age": 25,
            "email": "john@example.com"
        ]
        let validResult = security.validateParameters(validParams, against: rules)
        XCTAssertTrue(validResult.isValid)
        XCTAssertTrue(validResult.errors.isEmpty)

        // 测试无效参数
        let invalidParams: [String: Any] = [
            "name": 123, // 错误类型
            "age": 150, // 超出范围
            "email": "invalid-email" // 格式错误
        ]
        let invalidResult = security.validateParameters(invalidParams, against: rules)
        XCTAssertFalse(invalidResult.isValid)
        XCTAssertFalse(invalidResult.errors.isEmpty)

        // 测试缺少必需参数
        let missingParams: [String: Any] = [
            "age": 25
        ]
        let missingResult = security.validateParameters(missingParams, against: rules)
        XCTAssertFalse(missingResult.isValid)
        XCTAssertTrue(missingResult.errors.contains { $0.contains("name") })
    }

    func testSanitizeParameters() {
        let originalParams: [String: Any] = [
            "xss": "<script>alert('test')</script>",
            "html": "<div>content</div>",
            "special": "test&<>\"'chars",
            "normal": "normal_text"
        ]

        let sanitizedParams = security.sanitizeParameters(originalParams)

        // 验证HTML标签被移除
        XCTAssertEqual(sanitizedParams?["xss"] as? String, "alert(&#39;test&#39;)")
        XCTAssertEqual(sanitizedParams?["html"] as? String, "content")

        // 验证特殊字符被转义
        XCTAssertEqual(sanitizedParams?["special"] as? String, "test&amp;&lt;&gt;&quot;&#39;chars")

        // 验证正常文本不受影响
        XCTAssertEqual(sanitizedParams?["normal"] as? String, "normal_text")
    }
}
