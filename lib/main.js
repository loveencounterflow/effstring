(function() {
  'use strict';
  var D3F, Effstring_syntax_error, f, format_re, rpr;

  //===========================================================================================================
  D3F = require('d3-format');

  rpr = function(x) {
    return (require('util')).inspect(x);
  };

  //===========================================================================================================
  this.Effstring_error = class Effstring_error extends Error {
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
  Effstring_syntax_error = class Effstring_syntax_error extends this.Effstring_error {
    constructor(ref, part) {
      super(ref, `illegal format expression ${rpr(part)}`);
    }

  };

  //===========================================================================================================
  format_re = /^:(?<fmt>.+?(?<!\\));(?<tail>.*)$/;

  //---------------------------------------------------------------------------------------------------------
  f = function(parts, ...expressions) {
    var R, fmt, i, idx, len, literal, match, part, tail, value;
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
        R += ((D3F.format(fmt))(value)) + tail;
      } else {
        //.....................................................................................................
        literal = (typeof value === 'string') ? value : rpr(value);
        R += literal + part;
      }
    }
    return R;
  };

  //===========================================================================================================
  module.exports = {f, Effstring_error, Effstring_syntax_error};

}).call(this);

//# sourceMappingURL=main.js.map