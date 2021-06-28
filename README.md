# Page Curl Widget

[![pub package](https://img.shields.io/pub/v/page_curl.svg)](https://pub.dartlang.org/packages/page_curl)

## Demo

![demo](https://raw.githubusercontent.com/jyotirmoy-paul/page_curl/master/demo.gif)

## Example

```dart
PageCurl(
    vertical: true,
    back: Image.asset(
        'assets/cards/front.png',
        height: heightOfCards,
        width: widthOfCards,
    ),
    front: Image.asset(
        'assets/cards/back.png',
        height: heightOfCards,
        width: widthOfCards,
    ),
    size: Size(widthOfCards, heightOfCards),
    ),
```
