

'use strict'

D3F = require 'd3-format'
urge = help = console.log
rpr = ( x ) -> "#{x}"

#===========================================================================================================
format_re = ///
  ^:
  (?<fmt>.+?(?<!\\));
  (?<tail>.*)
  $
  ///

#---------------------------------------------------------------------------------------------------------
f = ( parts, expressions... ) ->
  R = parts[ 0 ]
  for value, idx in expressions
    part    = parts[ idx + 1 ]
    #.....................................................................................................
    if part.startsWith ':'
      unless ( match = part.match format_re )?
        throw new SyntaxError "Ω__14 illegal format expression #{rpr raw}"
      { fmt, tail, } = match.groups
      fmt = fmt.replace /\\;/g, ';'
      R  += ( ( D3F.format fmt ) value ) + tail
    #.....................................................................................................
    else
      literal = if ( typeof value is 'string' ) then value else rpr value
      R      += literal + part
  return R


#===========================================================================================================
module.exports = { f, }


