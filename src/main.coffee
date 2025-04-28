

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
_default_locale =
  decimal:    '.'
  thousands:  ','
  grouping:   [ 3, ]
  currency:   [ '$', '', ]
  numerals:   [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ]
  percent:    '%'
  minus:      '−' # U+2212
  nan:        'NaN'

#===========================================================================================================
_locale_cfg_from_bcp47 = ( bcp47 ) ->
  types.validate 'bcp47', bcp47
  return require "d3-format/locale/#{bcp47}"

#---------------------------------------------------------------------------------------------------------
_hint_as_locale_cfg = ( hint ) ->
  return _locale_cfg_from_bcp47  hint if types.isa.text hint
  return                         hint if types.isa.pod  hint
  throw new Effstring_validation_error 'Ωfstr___4', "text or object", hint

#---------------------------------------------------------------------------------------------------------
_format_cfg_from_hints = ( hints... ) ->
  return Object.assign {}, _default_locale, ( ( _hint_as_locale_cfg hint ) for hint in hints )...

#===========================================================================================================
_fmtspec_re = ///
  ^:
  (?<fmtspec>;?[^;]+);
  (?<tail>.*)
  $
  ///

#---------------------------------------------------------------------------------------------------------
new_ftag = ( hints... ) ->
  format_fn = ( D3F.formatLocale _format_cfg_from_hints hints... ).format
  return ( parts, expressions... ) ->
    R = parts[ 0 ]
    for value, idx in expressions
      part    = parts[ idx + 1 ]
      #.....................................................................................................
      if part.startsWith ':'
        unless ( match = part.match _fmtspec_re )?
          throw new Effstring_syntax_error 'Ωfstr___2', part
        { fmtspec, tail, } = match.groups
        try R  += ( ( format_fn fmtspec ) value ) + tail catch error
          throw new Effstring_lib_syntax_error 'Ωfstr___3', fmtspec, error
      #.....................................................................................................
      else
        literal = if ( typeof value is 'string' ) then value else rpr value
        R      += literal + part
    return R

#---------------------------------------------------------------------------------------------------------
# f = new_ftag D3F.format
f = new_ftag 'en-US'



#===========================================================================================================
module.exports = {
  f,
  new_ftag,
  _d3_format: D3F,
  _hint_as_locale_cfg,
  _locale_cfg_from_bcp47
  _fmtspec_re,
  _format_cfg_from_hints,
  Effstring_error,
  Effstring_syntax_error,
  Effstring_lib_syntax_error, }


