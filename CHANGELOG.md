# [3.1.1](https://github.com/Electrode-iOS/ELRouter/releases/tag/v3.1.1)

- Changed `deepLinkComponents` to not decode escaped slashes when determining path components, but to pass encoded parts on instead.

# [3.1.0](https://github.com/Electrode-iOS/ELRouter/releases/tag/v3.1.0)

- Added support for Xcode 8, Swift 2.3, and iOS 10

# [3.1.0](https://github.com/Electrode-iOS/ELRouter/releases/tag/v3.1.0)

- Added support for Xcode 8, Swift 2.3, and iOS 10

# [3.0.1](https://github.com/Electrode-iOS/ELRouter/releases/tag/v3.0.1)

## Fixes

- Changed `deepLinkComponents` to not decode escaped slashes when determining path components, but to pass encoded parts on instead.


# [3.0.0](https://github.com/Electrode-iOS/ELRouter/releases/tag/v3.0.0)

## Breaking

- Removed `.Alias` route type

## New Features

- Added `route(route: Route) -> Route` function to copy an existing route.
- Added `.Redirect` route type.

## Fixes

- Fixed bug where a popToRoot on a vc that was already at the root would hang the routing system temporarily.
- Added hacky fix for lock being held
- Short circut if we’ve stopped processing mid-way through.
- Fixed redirect func so it could be called from outside of ELRouter and work properly.

# [2.0.0](https://github.com/Electrode-iOS/ELRouter/releases/tag/v2.0.0)

## Breaking 

- Made `routeByName` a private API. Use `routeByEnum` instead.

## New Features

- Added `routeByEnum(routeEnum:) -> Route?` API that returns a single route for a give route enumeration.
- Added `.Alias` route type that returns an existing route to be used in place of this route.

## Fixes

- Increased asynchronous test timeouts to 15 seconds to reduce false negative results on some testing hosts.

- Static routes now call `popToRootViewController` if the route's viewController is a `UINavigationController`.

- Refactor unit tests - Unit tests were not waiting for full completion. By waiting on processing, the exection of routes would tickle the main thread and cause the unit tests to continue running before the Router’s processing thread was completed, killing any future routes.

# [1.0.1](https://github.com/Electrode-iOS/ELRouter/releases/tag/v1.0.1)

## Fixes

- Added missing call to `injectRouterSwizzles()` in Router init, fixing stuck locked routes

# [1.0.0](https://github.com/Electrode-iOS/ELRouter/releases/tag/v1.0.0)
