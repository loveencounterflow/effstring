

'use strict'

#===========================================================================================================
D3F                       = require 'd3-format'
{ log }                   = console
rpr                       = ( x ) -> ( require 'util' ).inspect x


#===========================================================================================================
types =

  #---------------------------------------------------------------------------------------------------------
  validate: ( typename, x ) ->
    return x if @isa[ typename ] x
    throw new Effstring_validation_error 'Ωfstr___1', typename, x

  #---------------------------------------------------------------------------------------------------------
  isa:
    # list:               ( x ) -> Array.isArray  x
    # object:             ( x ) -> x? and x instanceof Object
    function: ( x ) -> ( Object::toString.call x ) is '[object Function]'
    pod:      ( x ) -> x? and x.constructor in [ Object, undefined, ]
    text:     ( x ) -> ( typeof x ) is 'string'
    bcp47:    ( x ) ->
      return false unless @text x
      return /^[a-z]{2}-(?:[0-9]{3}|[A-Z]{2})$/.test x


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

#-----------------------------------------------------------------------------------------------------------
class Effstring_validation_error extends Effstring_error
  constructor: ( ref, typename, x ) ->
    super ref, "expected a #{typename} got #{rpr x}"


#===========================================================================================================
_locale_cfg_from_bcp47 = ( bcp47 ) ->
  types.validate 'bcp47', bcp47
  return require "d3-format/locale/#{bcp47}"

#---------------------------------------------------------------------------------------------------------
new_locale = ( cfg_or_bcp47 ) ->
  switch true
    when types.isa.text cfg_or_bcp47 then cfg = _locale_cfg_from_bcp47  cfg_or_bcp47
    when types.isa.pod  cfg_or_bcp47 then cfg =                         cfg_or_bcp47
    else throw new Effstring_validation_error 'Ωfstr___4', "text or object", cfg_or_bcp47
  return D3F.formatLocale cfg

#===========================================================================================================
_format_re = ///
  ^:
  (?<fmt>;?[^;]+);
  (?<tail>.*)
  $
  ///

#---------------------------------------------------------------------------------------------------------
new_formatter = ( hint ) ->
  format_fn = if ( types.isa.function hint ) then hint else ( new_locale hint ).format
  return ( parts, expressions... ) ->
    R = parts[ 0 ]
    for value, idx in expressions
      part    = parts[ idx + 1 ]
      #.....................................................................................................
      if part.startsWith ':'
        unless ( match = part.match _format_re )?
          throw new Effstring_syntax_error 'Ωfstr___2', part
        { fmt, tail, } = match.groups
        try R  += ( ( format_fn fmt ) value ) + tail catch error
          throw new Effstring_lib_syntax_error 'Ωfstr___3', fmt, error
      #.....................................................................................................
      else
        literal = if ( typeof value is 'string' ) then value else rpr value
        R      += literal + part
    return R

#---------------------------------------------------------------------------------------------------------
# f = new_formatter D3F.format
f = new_formatter 'en-US'



#===========================================================================================================
module.exports = {
  f,
  new_formatter,
  new_locale,
  _locale_cfg_from_bcp47
  _format_re,
  Effstring_error,
  Effstring_syntax_error,
  Effstring_lib_syntax_error, }


