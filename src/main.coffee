

'use strict'

#===========================================================================================================
D3F                       = require 'd3-format'
{ log }                   = console
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
  constructor: ( ref, part, message ) -> super ref, message ? "illegal format expression #{rpr part}"

#-----------------------------------------------------------------------------------------------------------
class Effstring_lib_syntax_error extends Effstring_syntax_error
  constructor: ( ref, part, error ) ->
    super ref, part, "illegal format expression #{rpr part};\norginal error:\n#{error.stack}"


#===========================================================================================================
format_re = ///
  ^:
  (?<fmt>;?[^;]+);
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
        throw new Effstring_syntax_error 'Ωfstr___1', part
      { fmt, tail, } = match.groups
      try R  += ( ( D3F.format fmt ) value ) + tail catch error
        throw new Effstring_lib_syntax_error 'Ωfstr___2', fmt, error
    #.....................................................................................................
    else
      literal = if ( typeof value is 'string' ) then value else rpr value
      R      += literal + part
  return R


#===========================================================================================================
module.exports = {
  f, \
  _format_re: format_re, \
  Effstring_error, \
  Effstring_syntax_error, \
  Effstring_lib_syntax_error, }


