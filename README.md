

# EffString

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [EffString](#effstring)
  - [Demo](#demo)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



# EffString

## Demo

```coffee
urge 'Ω__17', rpr f"AAA#{1234.5678}:\\;>+20,.3f;D\t\\;DD#{98.76}:+7.2f;ZZZ"
```


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




