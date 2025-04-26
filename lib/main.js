(function() {
  'use strict';
  var D3F, f, format_re, help, rpr, urge;

  D3F = require('d3-format');

  urge = help = console.log;

  rpr = function(x) {
    return `${x}`;
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
          throw new SyntaxError(`Ω__14 illegal format expression ${rpr(raw)}`);
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
  module.exports = {f};

}).call(this);

//# sourceMappingURL=main.js.map