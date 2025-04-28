

# EffString

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [EffString](#effstring)
  - [Simple Example](#simple-example)
  - [Format Specifier](#format-specifier)
  - [Locale Settings](#locale-settings)
  - [Demo](#demo)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



# EffString

EffString re-packages the great [d3-format](https://d3js.org/d3-format) library to provide formatting for
numerical values in JavaScript [tagged
templates](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals#tagged_templates).

Using EffString is simple: to get formatting for the default locale `en-US`, simply import the tag function
`f` and put it in front of a JavaScript template literal; then, after each interpolated value field of the
string, you can put a format specifier that is delineated by a leading colon `:` and a trailing semicolon
`;`.

## Simple Example

JavaScript:

```js
const { f, } = require( 'effstring' );
console.log( f`Max has ${1234}:$10,.00; in his pocket.` );
console.log( f`${'Alice'}:*<15c; has ${1234}:_>$12,.00f; in their pocket.`   );
console.log( f`${'Bob'}:*<15c; has ${45678.93}:_>$12,.00f; in their pocket.` );
```

CoffeeScript:

```coffee
{ f, } = require 'effstring'
console.log f"#{'Alice'}:*<15c; has #{1234}:_>$12,.00f; in their pocket."
console.log f"#{'Bob'}:*<15c; has #{45678.93}:_>$12,.00f; in their pocket."
```

Result:

```
Alice********** has ___$1,234.00 in their pocket.
Bob************ has __$45,678.93 in their pocket.
┌──────────────     ┌───────────
│                   │ 12 characters right aligned
│                   │ filled with underscores
│                   │ currency, 2 decimals
│                   │ thousands separator
│
│ 20 characters left aligned
│ filled with asterisks
```

## Format Specifier

The general form of a specifier is:

```
[[fill]align][sign][symbol][0][width][,][.precision][~][type]
```


## Locale Settings

decimal - the decimal point (e.g., ".").
thousands - the group separator (e.g., ",").
grouping - the array of group sizes (e.g., [3]), cycled as needed.
currency - the currency prefix and suffix (e.g., ["$", ""]).
numerals - optional; an array of ten strings to replace the numerals 0-9.
percent - optional; the percent sign (defaults to "%").
minus - optional; the minus sign (defaults to "−").
nan - optional; the not-a-number value (defaults "NaN").



## Demo



| Input                        | Output                      | Notes                                         |
| ---                          | :---------                  | :----------                                   |
| `f''`                        | `''`                        | empty string remains empty string. Yay!       |
| `f'helo'`                    | `'helo'`                    | any string without interpolation...           |
| `f'(#{123})'`                | `'(#{123})'`                | ...just remains as-is                         |
| `f"(#{123})"`                | `'(123)'`                   |                                               |
| `f"(#{123}:5;)"`             | `'(  123)'`                 |                                               |
| `f"(#{123}:>5;)"`            | `'(  123)'`                 |                                               |
| `f"(#{123}:<5;)"`            | `'(123  )'`                 |                                               |
| `f"(#{123.456}:>5.2;)"`      | `'(1.2e+2)'`                |                                               |
| `f"(#{123.456}:>5.2f;)"`     | `'(123.46)'`                |                                               |
| `f"(#{123.456}:>15.2f;)"`    | `'(         123.46)'`       |                                               |
| `f"(#{1234.567}:>15.2f;)"`   | `'(        1234.57)'`       |                                               |
| `f"(#{1234.567}:=>15.2f;)"`  | `'(========1234.57)'`       |                                               |
| `f"(#{1234.567}:=>15,.2f;)"` | `'(=======1,234.57)'`       |                                               |
| `f"(#{123.456}:<15.2f;)"`    | `'(123.46         )'`       |                                               |
| `f"(#{1234.567}:<15.2f;)"`   | `'(1234.57        )'`       |                                               |
| `f"(#{1234.567}:=<15.2f;)"`  | `'(1234.57========)'`       |                                               |
| `f"(#{1234.567}:=<15,.2f;)"` | `'(1,234.57=======)'`       |                                               |
| `f"#{0.123}:.0%;"`           | `'12%'`                     | rounded percentage                            |
| `f"#{-3.5}:($.2f;"`          | `'($3.50)'`                 | localized fixed-point currency                |
| `f"#{-3.5}:($.2f;"`          | `'(£3.50)'`                 | localized fixed-point currency                |
| `f"#{42}:+20;"`              | `'                 +42'`    | space-filled and signed                       |
| `f"#{42}:.^20;"`             | `'.........42.........'`    | dot-filled and centered                       |
| `f"#{42e6}:.2s;"`            | `'42M'`                     | SI-prefix with two significant digits         |
| `f"#{48879}:#x;"`            | `'0xbeef'`                  | prefixed lowercase hexadecimal                |
| `f"#{4223}:,.2r;"`           | `'4,200'`                   | grouped thousands with two significant digits |

| Input           | Error                       | Notes       |
| ---             | :---------                  | :---------- |
| `f"(#{123}:)"`  | `illegal format expression` |             |
| `f"(#{123}:;)"` | `illegal format expression` |             |




