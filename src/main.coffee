

'use strict'

#===========================================================================================================
D3F                       = require 'd3-format'
rpr                       = ( x ) -> ( require 'util' ).inspect x


#===========================================================================================================
class Effstring_error extends Error
  constructor: ( ref, message ) ->
    super()
    if ref is null
      @message  = message
      return undefined
    @message  = "#{ref} (#{@constructor.name}) #{message}"
    @ref      = ref
    return undefined

#-----------------------------------------------------------------------------------------------------------
class Effstring_syntax_error extends Effstring_error
  constructor: ( ref, part ) -> super ref, "illegal format expression #{rpr part}"


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
        throw new Effstring_syntax_error 'Ω___1', part
      { fmt, tail, } = match.groups
      fmt = fmt.replace /\\;/g, ';'
      R  += ( ( D3F.format fmt ) value ) + tail
    #.....................................................................................................
    else
      literal = if ( typeof value is 'string' ) then value else rpr value
      R      += literal + part
  return R


#===========================================================================================================
module.exports = { f, Effstring_error, Effstring_syntax_error, }


