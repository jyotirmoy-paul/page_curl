# Page Curl Widget
Curl your pages - Page Curl adds curling effects to your widgets.

[![pub package](https://img.shields.io/pub/v/page_curl.svg)](https://pub.dartlang.org/packages/page_curl)

## Demo

![demo](https://raw.githubusercontent.com/jyotirmoy-paul/page_curl/master/demo.gif)

## Example

```dart
PageCurl(
    vertical: false,
    back: _buildContainer('This is BACK'),
    front: _buildContainer(
        'This is FRONT',
        color: Colors.blueGrey,
    ),
    size: const Size(200, 150),
    ),
```

## Credits
The page curling idea is inspired from [numAndroidPageCurlEffect](https://github.com/numetriclabz/numAndroidPageCurlEffect) by [numetriclabz](https://github.com/numetriclabz)
