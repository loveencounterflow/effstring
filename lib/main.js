(function() {
  'use strict';
  var D3F, Effstring_error, Effstring_lib_syntax_error, Effstring_syntax_error, Effstring_validation_error, _default_locale, _fmtspec_re, _format_cfg_from_hints, _hint_as_locale_cfg, _locale_cfg_from_bcp47, f, log, new_ftag, rpr, types;

  //===========================================================================================================
  D3F = require('d3-format');

  ({log} = console);

  rpr = function(x) {
    return (require('util')).inspect(x);
  };

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
    constructor(ref, message) {
      super();
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
    constructor(ref, part, message) {
      super(ref, message != null ? message : `illegal format expression ${rpr(part)}`);
    }

  };

  //-----------------------------------------------------------------------------------------------------------
  Effstring_lib_syntax_error = class Effstring_lib_syntax_error extends Effstring_syntax_error {
    constructor(ref, part, error) {
      super(ref, part, `illegal format expression ${rpr(part)};\norginal error:\n${error.stack}`);
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
    nan: 'NaN'
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
    throw new Effstring_validation_error('Ωfstr___4', "text or object", hint);
  };

  //---------------------------------------------------------------------------------------------------------
  _format_cfg_from_hints = function(...hints) {
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
  _fmtspec_re = /^:(?<fmtspec>;?[^;]+);(?<tail>.*)$/;

  //---------------------------------------------------------------------------------------------------------
  new_ftag = function(...hints) {
    var format_fn;
    format_fn = (D3F.formatLocale(_format_cfg_from_hints(...hints))).format;
    return function(parts, ...expressions) {
      var R, error, fmtspec, i, idx, len, literal, match, part, tail, value;
      R = parts[0];
      for (idx = i = 0, len = expressions.length; i < len; idx = ++i) {
        value = expressions[idx];
        part = parts[idx + 1];
        //.....................................................................................................
        if (part.startsWith(':')) {
          if ((match = part.match(_fmtspec_re)) == null) {
            throw new Effstring_syntax_error('Ωfstr___2', part);
          }
          ({fmtspec, tail} = match.groups);
          try {
            R += ((format_fn(fmtspec))(value)) + tail;
          } catch (error1) {
            error = error1;
            throw new Effstring_lib_syntax_error('Ωfstr___3', fmtspec, error);
          }
        } else {
          //.....................................................................................................
          literal = (typeof value === 'string') ? value : rpr(value);
          R += literal + part;
        }
      }
      return R;
    };
  };

  //---------------------------------------------------------------------------------------------------------
  // f = new_ftag D3F.format
  f = new_ftag('en-US');

  //===========================================================================================================
  module.exports = {
    f,
    new_ftag,
    _d3_format: D3F,
    _default_locale,
    _hint_as_locale_cfg,
    _locale_cfg_from_bcp47,
    _fmtspec_re,
    _format_cfg_from_hints,
    Effstring_error,
    Effstring_syntax_error,
    Effstring_lib_syntax_error
  };

}).call(this);

//# sourceMappingURL=main.js.map