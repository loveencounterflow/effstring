(function() {
  'use strict';
  var D3F, Effstring_error, Effstring_lib_syntax_error, Effstring_syntax_error, Effstring_syntax_fillwidth_error, Effstring_validation_error, _default_locale, _escape_regex, _fmtspec_re, _fmtspec_unit_re, _hint_as_locale_cfg, _locale_cfg_from_bcp47, _locale_cfg_from_hints, _to_width, _unit_magnitudes, debug, f, log, new_ftag, rpr, types, width_of,
    modulo = function(a, b) { return (+a % (b = +b) + b) % b; };

  //===========================================================================================================
  D3F = require('d3-format');

  ({log, debug} = console);

  rpr = function(x) {
    return (require('loupe')).inspect(x);
  };

  ({
    default: width_of
  } = require('string-width'));

  //===========================================================================================================
  types = {
    //---------------------------------------------------------------------------------------------------------
    validate: function(typename, x) {
      if (this.isa[typename](x)) {
        return x;
      }
      throw new Effstring_validation_error('Ωfstr___1', typename, x);
    },
    //---------------------------------------------------------------------------------------------------------
    isa: {
      // list:               ( x ) -> Array.isArray  x
      // object:             ( x ) -> x? and x instanceof Object
      function: function(x) {
        return (Object.prototype.toString.call(x)) === '[object Function]';
      },
      pod: function(x) {
        var ref1;
        return (x != null) && ((ref1 = x.constructor) === Object || ref1 === (void 0));
      },
      text: function(x) {
        return (typeof x) === 'string';
      },
      bcp47: function(x) {
        if (!this.text(x)) {
          return false;
        }
        return /^[a-z]{2}-(?:[0-9]{3}|[A-Z]{2})$/.test(x);
      }
    }
  };

  //===========================================================================================================
  Effstring_error = class Effstring_error extends Error {
    constructor(ref, message, cause = null) {
      super();
      if (cause != null) {
        this.cause = cause;
      }
      if (ref === null) {
        this.message = message;
        return void 0;
      }
      this.message = `${ref} (${this.constructor.name}) ${message}`;
      this.ref = ref;
      return void 0;
    }

  };

  //-----------------------------------------------------------------------------------------------------------
  Effstring_syntax_error = class Effstring_syntax_error extends Effstring_error {
    constructor(ref, part, message = null, cause = null) {
      if (message == null) {
        message = `illegal format specifier ${rpr(part)}`;
      }
      super(ref, message, cause);
    }

  };

  //-----------------------------------------------------------------------------------------------------------
  Effstring_lib_syntax_error = class Effstring_lib_syntax_error extends Effstring_syntax_error {
    constructor(ref, part, cause) {
      super(ref, part, `illegal format specifier ${rpr(part)}`, cause);
    }

  };

  //-----------------------------------------------------------------------------------------------------------
  Effstring_syntax_fillwidth_error = class Effstring_syntax_fillwidth_error extends Effstring_syntax_error {
    constructor(ref, fmt_spec, fill) {
      super(ref, null, `illegal format specifier ${rpr(fmt_spec)}: fill ${rpr(fill)} must be single-width BMP character`);
    }

  };

  //-----------------------------------------------------------------------------------------------------------
  Effstring_validation_error = class Effstring_validation_error extends Effstring_error {
    constructor(ref, typename, x) {
      super(ref, `expected a ${typename} got ${rpr(x)}`);
    }

  };

  //===========================================================================================================
  _default_locale = {
    decimal: '.',
    thousands: ',',
    grouping: [3],
    currency: ['$', ''],
    numerals: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
    percent: '%',
    minus: '−', // U+2212
    nan: 'NaN',
    fullwidth: true
  };

  //===========================================================================================================
  _locale_cfg_from_bcp47 = function(bcp47) {
    types.validate('bcp47', bcp47);
    return require(`d3-format/locale/${bcp47}`);
  };

  //---------------------------------------------------------------------------------------------------------
  _hint_as_locale_cfg = function(hint) {
    if (types.isa.text(hint)) {
      return _locale_cfg_from_bcp47(hint);
    }
    if (types.isa.pod(hint)) {
      return hint;
    }
    throw new Effstring_validation_error('Ωfstr___2', "text or object", hint);
  };

  //---------------------------------------------------------------------------------------------------------
  _locale_cfg_from_hints = function(...hints) {
    var hint;
    return Object.assign({}, _default_locale, ...((function() {
      var i, len, results;
      results = [];
      for (i = 0, len = hints.length; i < len; i++) {
        hint = hints[i];
        results.push(_hint_as_locale_cfg(hint));
      }
      return results;
    })()));
  };

  //===========================================================================================================
  _fmtspec_re = /^:(?<fmt_spec>;?[^;]+);(?<tail>.*)$/;

  //-----------------------------------------------------------------------------------------------------------
  _fmtspec_unit_re = /f(?<discard>\/(?<unit>[yzafpnµm1kMGTPEZY]))$/;

  //-----------------------------------------------------------------------------------------------------------
  _unit_magnitudes = Object.freeze({
    'y': 1e-24,
    'z': 1e-21,
    'a': 1e-18,
    'f': 1e-15,
    'p': 1e-12,
    'n': 1e-09,
    'µ': 1e-06,
    'm': 1e-03,
    '1': 1e+00,
    'k': 1e+03,
    'M': 1e+06,
    'G': 1e+09,
    'T': 1e+12,
    'P': 1e+15,
    'E': 1e+18,
    'Z': 1e+21,
    'Y': 1e+24
  });

  //-----------------------------------------------------------------------------------------------------------
  _escape_regex = function(text) {
    return text.replace(/[\/\-\\^$*+?.()|[\]{}]/g, '\\$&');
  };

  // return text.replace ///[.*+?^${}()|[\\]\\\\]///g, '\\\\$&'

  //-----------------------------------------------------------------------------------------------------------
  _to_width = function(text, fmt_cfg, has_si_unit_prefix) {
    /* TAINT assuming fmt_cfg.fill has length 1, but could be any length */
    var field_width, fill_re, matcher, p, shorter_text/* TAINT use unicode flag? */, si_unit_correction;
    si_unit_correction = has_si_unit_prefix ? 1 : 0;
    field_width = fmt_cfg.width + si_unit_correction;
    switch (fmt_cfg.align) {
      //.......................................................................................................
      case '<':
        /* TAINT don't re-calculate width, just inc/dec by width of fmt_cfg.fill */
        while ((text.endsWith(fmt_cfg.fill)) && (width_of(text)) > field_width) {
          text = text.slice(0, text.length - 1);
        }
        while ((width_of(text)) < field_width) {
          text += fmt_cfg.fill;
        }
        break;
      //.......................................................................................................
      case '>':
        while ((text.startsWith(fmt_cfg.fill)) && (width_of(text)) > field_width) {
          text = text.slice(1);
        }
        while ((width_of(text)) < field_width) {
          text = fmt_cfg.fill + text;
        }
        break;
      //.......................................................................................................
      case '^':
        p = 0;
        while (true) {
          if (!((width_of(text)) > field_width)) {
            break;
          }
          p++;
          if ((modulo(p, 2)) === 0) {
            if (text.startsWith(fmt_cfg.fill)) {
              text = text.slice(1);
            } else if (text.endsWith(fmt_cfg.fill)) {
              text = text.slice(0, text.length - 1);
            }
          } else {
            if (text.endsWith(fmt_cfg.fill)) {
              text = text.slice(0, text.length - 1);
            } else if (text.startsWith(fmt_cfg.fill)) {
              text = text.slice(1);
            }
          }
        }
        break;
      //.......................................................................................................
      case '=':
        if (!((width_of(text)) > field_width)) {
          break;
        }
        fill_re = _escape_regex(fmt_cfg.fill);
        matcher = RegExp(`^([^${fill_re}]*)${fill_re}`);
        while (true) {
          shorter_text = text.replace(matcher, '$1');
          if (text === shorter_text) {
            break;
          }
          text = shorter_text;
          if (!((width_of(text)) > field_width)) {
            break;
          }
        }
    }
    //.........................................................................................................
    return text;
  };

  //-----------------------------------------------------------------------------------------------------------
  new_ftag = function(...hints) {
    var locale, locale_cfg;
    locale_cfg = _locale_cfg_from_hints(...hints);
    locale = D3F.formatLocale(locale_cfg);
    return function(parts, ...expressions) {
      var R, discard, error, fmt_cfg, fmt_spec, has_si_unit_prefix, i, idx, len, literal, match, part, tail, unit, unit_match, value;
      R = parts[0];
      for (idx = i = 0, len = expressions.length; i < len; idx = ++i) {
        value = expressions[idx];
        part = parts[idx + 1];
        //.....................................................................................................
        if (part.startsWith(':')) {
          if ((match = part.match(_fmtspec_re)) == null) {
            throw new Effstring_syntax_error('Ωfstr___3', part);
          }
          ({fmt_spec, tail} = match.groups);
          //...................................................................................................
          /* Handle SI unit prefix specifier: */
          if ((unit_match = fmt_spec.match(_fmtspec_unit_re)) != null) {
            has_si_unit_prefix = true;
            ({discard, unit} = unit_match.groups);
            fmt_spec = fmt_spec.slice(0, fmt_spec.length - discard.length);
            try {
              literal = (locale.formatPrefix(fmt_spec, _unit_magnitudes[unit]))(value);
            } catch (error1) {
              error = error1;
              if (error.constructor !== Error) {
                /* d3-format own errors are unspecific, specific ones are likely from unexpected causes (and are therefore likely not fmt spec syntax errors) */
                throw error;
              }
              throw new Effstring_lib_syntax_error('Ωfstr___5', fmt_spec, error);
            }
          } else {
            //...................................................................................................
            /* Handle format specifiers without SI unit prefix: */
            has_si_unit_prefix = false;
            try {
              literal = (locale.format(fmt_spec))(value);
            } catch (error1) {
              error = error1;
              if (error.constructor !== Error) {
                /* d3-format own errors are unspecific, specific ones are likely from unexpected causes (and are therefore likely not fmt spec syntax errors) */
                throw error;
              }
              throw new Effstring_lib_syntax_error('Ωfstr___7', fmt_spec, error);
            }
          }
          //...................................................................................................
          /* Correct field width: */
          if (locale_cfg.fullwidth && ((fmt_cfg = D3F.formatSpecifier(fmt_spec)).width != null)) {
            /* TAINT this should have been validated earlier */
            if ((width_of(fmt_cfg.fill)) !== 1) {
              throw new Effstring_syntax_fillwidth_error('Ωfstr___8', fmt_spec, fmt_cfg.fill);
            }
            literal = _to_width(literal, fmt_cfg, has_si_unit_prefix);
          }
          //...................................................................................................
          R += literal + tail;
        } else {
          //.....................................................................................................
          literal = (typeof value === 'string') ? value : rpr(value);
          R += literal + part;
        }
      }
      return R;
    };
  };

  //-----------------------------------------------------------------------------------------------------------
  // f = new_ftag D3F.format
  f = new_ftag('en-US');

  //===========================================================================================================
  module.exports = {
    f,
    new_ftag,
    Effstring_error,
    Effstring_syntax_error,
    Effstring_lib_syntax_error,
    Effstring_syntax_fillwidth_error,
    Effstring_validation_error,
    _d3_format: D3F,
    _default_locale,
    _hint_as_locale_cfg,
    _locale_cfg_from_bcp47,
    _fmtspec_re,
    _fmtspec_unit_re,
    _locale_cfg_from_hints,
    _unit_magnitudes
  };

}).call(this);

//# sourceMappingURL=main.js.map