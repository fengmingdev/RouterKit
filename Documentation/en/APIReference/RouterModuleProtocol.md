# RouterModuleProtocol

The `RouterModuleProtocol` defines methods and properties for modules in RouterKit, which are used to organize routes and dependencies.

## Protocol Definition

```swift
public protocol RouterModuleProtocol: AnyObject {
    var name: String { get }
    var dependencies: [String] { get }
    func registerRoutes(with router: Router)
}
```

## Properties

### name

The name of the module.

```swift
var name: String { get }
```

### dependencies

An array of module names that this module depends on.

```swift
var dependencies: [String] { get }
```

## Methods

### registerRoutes(with:)

Registers the module's routes with the specified router.

```swift
func registerRoutes(with router: Router)
```

## Example

```swift
class UserModule: RouterModuleProtocol {
    var name: String { return "User" }
    var dependencies: [String] { return ["Auth"] }

    func registerRoutes(with router: Router) {
        router.register("/user/profile") { context in
            return UserProfileViewController()
        }

        router.register("/user/settings") { context in
            return UserSettingsViewController()
        }

        router.register("/user/:id") { context in
            guard let userId = context.parameters["id"] else {
                return nil
            }
            return UserDetailViewController(userId: userId)
        }
    }
}

// Register the module
let userModule = UserModule()
Router.shared.registerModule(userModule)
```