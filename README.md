

# EffString

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [EffString](#effstring)
  - [Simple Example](#simple-example)
  - [Format Specifier](#format-specifier)
  - [Locale Settings](#locale-settings)
  - [Pre-Defined Locales](#pre-defined-locales)
  - [Handling of 'Wide' Characters](#handling-of-wide-characters)
  - [Demo](#demo)
  - [Required NodeJS Version](#required-nodejs-version)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



# EffString

EffString re-packages the great [d3-format](https://d3js.org/d3-format) library to provide formatting for
numerical values in JavaScript [tagged
templates](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals#tagged_templates).

Using EffString is simple: to get formatting for the default locale `en-US`, simply import the tag function
`f` and put it in front of a JavaScript template literal; then, after each interpolated value field of the
string, you can put a [format specifier](#format-specifier) that is delineated by a leading colon `:` and a
trailing semicolon `;`.

For other [pre-defined locales]()

## Simple Example

JavaScript:

```js
const { f, } = require( 'effstring' );
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

```coffee
_default_locale =
  decimal:    '.'                                                   # decimal point
  thousands:  ','                                                   # group separator
  grouping:   [ 3, ]                                                # array of group sizes, cycled as needed
  currency:   [ '$', '', ]                                          # currency prefix and suffix
  numerals:   [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ] # array of ten strings to replace digits 0-9
  percent:    '%'                                                   # percent sign
  minus:      '−' # U+2212                                          # minus sign
  nan:        'NaN'                                                 # not-a-number value
```

## Pre-Defined Locales

For the following locales, `d3-format` provides ready-made settings:

|   Code   |                                    Description                                    |
|----------|-----------------------------------------------------------------------------------|
| `ar-001` | Arabic — World (global standard Arabic; "Modern Standard Arabic" typically used)  |
| `ar-AE`  | Arabic — United Arab Emirates (Gulf Arabic dialect)                               |
| `ar-BH`  | Arabic — Bahrain (Gulf Arabic dialect, Bahraini variant)                          |
| `ar-DJ`  | Arabic — Djibouti (East African Arabic)                                           |
| `ar-DZ`  | Arabic — Algeria (Maghrebi Arabic)                                                |
| `ar-EG`  | Arabic — Egypt (Egyptian Arabic, a widely influential dialect)                    |
| `ar-EH`  | Arabic — Western Sahara (Hassaniya Arabic, Maghrebi influence)                    |
| `ar-ER`  | Arabic — Eritrea (official language, used in government and some communities)     |
| `ar-IL`  | Arabic — Israel (Arabic spoken by Arab citizens of Israel)                        |
| `ar-IQ`  | Arabic — Iraq (Mesopotamian Arabic dialects)                                      |
| `ar-JO`  | Arabic — Jordan (Levantine Arabic)                                                |
| `ar-KM`  | Arabic — Comoros (formal/official language; Comorian Arabic influence)            |
| `ar-KW`  | Arabic — Kuwait (Gulf Arabic dialect)                                             |
| `ar-LB`  | Arabic — Lebanon (Levantine Arabic)                                               |
| `ar-LY`  | Arabic — Libya (Maghrebi Arabic)                                                  |
| `ar-MA`  | Arabic — Morocco (Maghrebi Arabic, Darija)                                        |
| `ar-MR`  | Arabic — Mauritania (Hassaniya Arabic)                                            |
| `ar-OM`  | Arabic — Oman (Gulf Arabic, with some unique Omani dialects)                      |
| `ar-PS`  | Arabic — Palestine (Levantine Arabic)                                             |
| `ar-QA`  | Arabic — Qatar (Gulf Arabic)                                                      |
| `ar-SA`  | Arabic — Saudi Arabia (Najdi, Hejazi, and Gulf Arabic variants)                   |
| `ar-SD`  | Arabic — Sudan (Sudanese Arabic)                                                  |
| `ar-SO`  | Arabic — Somalia (secondary language, limited usage)                              |
| `ar-SS`  | Arabic — South Sudan (minority usage; Arabic-based "Juba Arabic" in some regions) |
| `ar-SY`  | Arabic — Syria (Levantine Arabic)                                                 |
| `ar-TD`  | Arabic — Chad (Chadian Arabic, lingua franca)                                     |
| `ar-TN`  | Arabic — Tunisia (Tunisian Arabic, Maghrebi influence)                            |
| `ar-YE`  | Arabic — Yemen (Yemeni Arabic, with multiple regional dialects)                   |
| `ca-ES`  | Catalan — Spain (Catalonia, Valencia, Balearic Islands)                           |
| `cs-CZ`  | Czech — Czech Republic                                                            |
| `da-DK`  | Danish — Denmark                                                                  |
| `de-CH`  | German — Switzerland (Swiss Standard German)                                      |
| `de-DE`  | German — Germany (Standard German)                                                |
| `en-CA`  | English — Canada                                                                  |
| `en-GB`  | English — United Kingdom                                                          |
| `en-IE`  | English — Ireland                                                                 |
| `en-IN`  | English — India (Indian English variant)                                          |
| `en-US`  | English — United States                                                           |
| `es-BO`  | Spanish — Bolivia                                                                 |
| `es-ES`  | Spanish — Spain (Castilian Spanish)                                               |
| `es-MX`  | Spanish — Mexico                                                                  |
| `fi-FI`  | Finnish — Finland                                                                 |
| `fr-CA`  | French — Canada (mainly Québec French)                                            |
| `fr-FR`  | French — France (Standard French)                                                 |
| `he-IL`  | Hebrew — Israel                                                                   |
| `hu-HU`  | Hungarian — Hungary                                                               |
| `it-IT`  | Italian — Italy                                                                   |
| `ja-JP`  | Japanese — Japan                                                                  |
| `ko-KR`  | Korean — South Korea                                                              |
| `mk-MK`  | Macedonian — North Macedonia                                                      |
| `nl-NL`  | Dutch — Netherlands                                                               |
| `pl-PL`  | Polish — Poland                                                                   |
| `pt-BR`  | Portuguese — Brazil                                                               |
| `pt-PT`  | Portuguese — Portugal                                                             |
| `ru-RU`  | Russian — Russia                                                                  |
| `sl-SI`  | Slovenian — Slovenia                                                              |
| `sv-SE`  | Swedish — Sweden                                                                  |
| `uk-UA`  | Ukrainian — Ukraine                                                               |
| `zh-CN`  | Chinese (Simplified) — Mainland China                                             |

## Handling of 'Wide' Characters

EffString makes an effort to correctly handle so-called ['wide' or (Asian) 'fullwidth'
characters](https://en.wikipedia.org/wiki/Halfwidth_and_fullwidth_forms) (`d3-format` per se lacks that
capability).

```coffee
{ new_ftag, } = require 'effstring'
ja_jp_cfg     = {
  numerals: [ '〇', '一', '二', '三', '四', '五', '六', '七', '八', '九', ], }
f_en = new_ftag 'en-GB'
f_ja = new_ftag 'ja-JP', ja_jp_cfg
console.log f_en"#{'Alice'}:*<15c; is in #{'London'}:.^12c; and has #{1234}:_>$22,.2f; in their pocket."
console.log f_en"#{'Bob'}:*<15c; is in #{'London'}:.^12c; and has #{45678.93}:_>$22,.2f; in their pocket."
console.log f_ja"#{'アリスさん'}:*<15c; is in #{'倫敦'}:.^12c; and has #{1234}:_>$22,.2f; in their pocket."
console.log f_ja"#{'ボブさん'}:*<15c; is in #{'倫敦'}:.^12c; and has #{45678.93}:_>$22,.2f; in their pocket."
```

Output:

```
Alice********** is in ...London... and has _____________£1,234.00 in their pocket.
Bob************ is in ...London... and has ____________£45,678.93 in their pocket.
アリスさん***** is in ....倫敦.... and has ______一,二三四.〇〇円 in their pocket.
ボブさん******* is in ....倫敦.... and has ____四五,六七八.九三円 in their pocket.
```

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


## Required NodeJS Version

EffString relies on [`sindresorhus/string-width`](https://github.com/sindresorhus/string-width) to adjust
strings with fullwidth characters; since `string-width` is an ESM module but EffString uses CJS'
`require()`, EffString needs at least NodeJS v22 (with `--experimental-require-module` command line flag) or
v23 (without command line flag).

