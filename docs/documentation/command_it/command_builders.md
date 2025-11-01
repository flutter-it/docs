# Command Builders

## CommandBuilder, reducing boilerplate
`command_it` includes a `CommandBuilder` widget which makes the code above a bit nicer:

```dart
child: CommandBuilder<String, List<WeatherEntry>>(
  command: weatherManager.updateWeatherCommand,
  whileExecuting: (context, _) => Center(
    child: SizedBox(
      width: 50.0,
      height: 50.0,
      child: CircularProgressIndicator(),
    ),
  ),
  onData: (context, data, _) => WeatherListView(data),
  onError: (context, error, param) => Column(
    children: [
      Text('An Error has occurred!'),
      Text(error.toString()),
      if (error != null) Text('For search term: $param')
    ],
  ),
),
```

In case your Command does not return a value you can use the `onSuccess` builder.


## toWidget() extension method on Command Result
I you are using a package `get_it_mixin`, `provider` or `flutter_hooks` you probably don't want to use the `CommandBuilder` for you there is an extension method for the `CommandResult` type that you can use like this:

```dart
return result.toWidget(
  whileExecuting: (lastValue, _) => Center(
    child: SizedBox(
      width: 50.0,
      height: 50.0,
      child: CircularProgressIndicator(),
    ),
  ),
  onResult: (data, _) => WeatherListView(data),
  onError: (error, lastValue, paramData) => Column(
    children: [
      Text('An Error has occurred!'),
      Text(result.error.toString()),
      if (result.error != null)
        Text('For search term: ${result.paramData}')
    ],
  ),
);
```
