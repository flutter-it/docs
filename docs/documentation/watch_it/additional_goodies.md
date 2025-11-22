# Additional Goodies

## Pushing a new GetIt Scope

With `pushScope()` you can push a scope when a Widget/State is mounted, and automatically drop it when the Widget/State is destroyed. You can pass an optional init or dispose function.

```dart
void pushScope({void Function(GetIt getIt) init, void Function() dispose});
```

The newly created Scope gets a unique name so that it is ensured the right Scope is dropped even if you push or drop manually other Scopes.

## Find out more!

To learn more about GetIt, watch the presentation: [GetIt in action By Thomas Burkhart](https://youtu.be/YJ52kSfSMyM), in there the predecessor of this package called `get_it_mixin` is described but the video should still be helpful for the GetIt part.
