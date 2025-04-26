(function() {
  'use strict';
  var D3F, Effstring_error, Effstring_lib_syntax_error, Effstring_syntax_error, Effstring_validation_error, _format_re, _locale_cfg_from_bcp47, f, log, new_formatter, new_locale, rpr, types;

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
  _locale_cfg_from_bcp47 = function(bcp47) {
    types.validate('bcp47', bcp47);
    return require(`d3-format/locale/${bcp47}`);
  };

  //---------------------------------------------------------------------------------------------------------
  new_locale = function(cfg_or_bcp47) {
    var cfg;
    switch (true) {
      case types.isa.text(cfg_or_bcp47):
        cfg = _locale_cfg_from_bcp47(cfg_or_bcp47);
        break;
      case types.isa.pod(cfg_or_bcp47):
        cfg = cfg_or_bcp47;
        break;
      default:
        throw new Effstring_validation_error('Ωfstr___4', "text or object", cfg_or_bcp47);
    }
    return D3F.formatLocale(cfg);
  };

  //===========================================================================================================
  _format_re = /^:(?<fmt>;?[^;]+);(?<tail>.*)$/;

  //---------------------------------------------------------------------------------------------------------
  new_formatter = function(hint) {
    var format_fn;
    format_fn = (types.isa.function(hint)) ? hint : (new_locale(hint)).format;
    return function(parts, ...expressions) {
      var R, error, fmt, i, idx, len, literal, match, part, tail, value;
      R = parts[0];
      for (idx = i = 0, len = expressions.length; i < len; idx = ++i) {
        value = expressions[idx];
        part = parts[idx + 1];
        //.....................................................................................................
        if (part.startsWith(':')) {
          if ((match = part.match(_format_re)) == null) {
            throw new Effstring_syntax_error('Ωfstr___2', part);
          }
          ({fmt, tail} = match.groups);
          try {
            R += ((format_fn(fmt))(value)) + tail;
          } catch (error1) {
            error = error1;
            throw new Effstring_lib_syntax_error('Ωfstr___3', fmt, error);
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
  // f = new_formatter D3F.format
  f = new_formatter('en-US');

  //===========================================================================================================
  module.exports = {f, new_formatter, new_locale, _locale_cfg_from_bcp47, _format_re, Effstring_error, Effstring_syntax_error, Effstring_lib_syntax_error};

}).call(this);

//# sourceMappingURL=main.js.map