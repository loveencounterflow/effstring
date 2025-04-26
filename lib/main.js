(function() {
  'use strict';
  var D3F, Effstring_error, Effstring_lib_syntax_error, Effstring_syntax_error, f, format_re, log, rpr;

  //===========================================================================================================
  D3F = require('d3-format');

  ({log} = console);

  rpr = function(x) {
    return (require('util')).inspect(x);
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

  //===========================================================================================================
  format_re = /^:(?<fmt>;?[^;]+);(?<tail>.*)$/;

  //---------------------------------------------------------------------------------------------------------
  f = function(parts, ...expressions) {
    var R, error, fmt, i, idx, len, literal, match, part, tail, value;
    R = parts[0];
    for (idx = i = 0, len = expressions.length; i < len; idx = ++i) {
      value = expressions[idx];
      part = parts[idx + 1];
      //.....................................................................................................
      if (part.startsWith(':')) {
        if ((match = part.match(format_re)) == null) {
          throw new Effstring_syntax_error('Ω___1', part);
        }
        ({fmt, tail} = match.groups);
        fmt = fmt.replace(/\\;/g, ';');
        try {
          R += ((D3F.format(fmt))(value)) + tail;
        } catch (error1) {
          error = error1;
          throw new Effstring_lib_syntax_error('Ω___2', fmt, error);
        }
      } else {
        //.....................................................................................................
        literal = (typeof value === 'string') ? value : rpr(value);
        R += literal + part;
      }
    }
    return R;
  };

  //===========================================================================================================
  module.exports = {
    f,
    _format_re: format_re,
    Effstring_error,
    Effstring_syntax_error,
    Effstring_lib_syntax_error
  };

}).call(this);

//# sourceMappingURL=main.js.map