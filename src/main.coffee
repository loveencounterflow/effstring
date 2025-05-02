

'use strict'

#===========================================================================================================
D3F                       = require 'd3-format'
{ log
  debug }                 = console
rpr                       = ( x ) -> ( require 'loupe' ).inspect x
{ default: width_of, }    = require 'string-width'


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
  constructor: ( ref, part, message = null ) -> super ref, message ? "illegal format expression #{rpr part}"

#-----------------------------------------------------------------------------------------------------------
class Effstring_lib_syntax_error extends Effstring_syntax_error
  constructor: ( ref, part, error ) ->
    super ref, part, "illegal format expression #{rpr part};\norginal error:\n#{error.stack}"

#-----------------------------------------------------------------------------------------------------------
class Effstring_syntax_fillwidth_error extends Effstring_syntax_error
  constructor: ( ref, fmt_spec, fill ) ->
    super ref, null, "illegal format expression #{rpr fmt_spec}: fill #{rpr fill} must be single-width BMP character"

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
  fullwidth:  true

#===========================================================================================================
_locale_cfg_from_bcp47 = ( bcp47 ) ->
  types.validate 'bcp47', bcp47
  return require "d3-format/locale/#{bcp47}"

#---------------------------------------------------------------------------------------------------------
_hint_as_locale_cfg = ( hint ) ->
  return _locale_cfg_from_bcp47  hint if types.isa.text hint
  return                         hint if types.isa.pod  hint
  throw new Effstring_validation_error 'Ωfstr___2', "text or object", hint

#---------------------------------------------------------------------------------------------------------
_locale_cfg_from_hints = ( hints... ) ->
  return Object.assign {}, _default_locale, ( ( _hint_as_locale_cfg hint ) for hint in hints )...

#===========================================================================================================
_fmtspec_re = ///
  ^:
  (?<fmt_spec>;?[^;]+);
  (?<tail>.*)
  $
  ///

#-----------------------------------------------------------------------------------------------------------
_escape_regex = ( text ) ->
  return text.replace ///[/\-\\^$*+?.()|[\]{}]///g, '\\$&'
  # return text.replace ///[.*+?^${}()|[\\]\\\\]///g, '\\\\$&'

#-----------------------------------------------------------------------------------------------------------
_to_width = ( text, fmt_cfg ) ->
  ### TAINT assuming fmt_cfg.fill has length 1, but could be any length ###
  switch fmt_cfg.align
    #.......................................................................................................
    when '<'
      while ( text.endsWith fmt_cfg.fill ) and ( width_of text ) > fmt_cfg.width
        text = text[ ... text.length - 1 ]
    #.......................................................................................................
    when '>'
      while ( text.startsWith fmt_cfg.fill ) and ( width_of text ) > fmt_cfg.width
        text = text[ 1 ... ]
    #.......................................................................................................
    when '^'
      p = 0
      loop
        break unless ( width_of text ) > fmt_cfg.width
        p++
        if ( p %% 2 ) is 0
          if text.startsWith fmt_cfg.fill       then text = text[ 1 ... ]
          else if text.endsWith fmt_cfg.fill    then text = text[ ... text.length - 1 ]
        else
          if text.endsWith fmt_cfg.fill         then text = text[ ... text.length - 1 ]
          else if text.startsWith fmt_cfg.fill  then text = text[ 1 ... ]
    #.......................................................................................................
    when '='
      break unless ( width_of text ) > fmt_cfg.width
      fill_re = _escape_regex fmt_cfg.fill
      matcher = /// ^ ( [^ #{fill_re} ]* ) #{fill_re} /// ### TAINT use unicode flag? ###
      loop
        shorter_text = text.replace matcher, '$1'
        break if text is shorter_text
        text = shorter_text
        break unless ( width_of text ) > fmt_cfg.width
  #.........................................................................................................
  return text

#-----------------------------------------------------------------------------------------------------------
new_ftag = ( hints... ) ->
  locale_cfg  = _locale_cfg_from_hints hints...
  format_fn   = ( D3F.formatLocale locale_cfg ).format
  return ( parts, expressions... ) ->
    R = parts[ 0 ]
    for value, idx in expressions
      part    = parts[ idx + 1 ]
      #.....................................................................................................
      if part.startsWith ':'
        unless ( match = part.match _fmtspec_re )?
          throw new Effstring_syntax_error 'Ωfstr___3', part
        { fmt_spec, tail, } = match.groups
        try literal = ( ( format_fn fmt_spec ) value ) catch error
          throw new Effstring_lib_syntax_error 'Ωfstr___4', fmt_spec, error
        if locale_cfg.fullwidth and ( fmt_cfg = D3F.formatSpecifier fmt_spec ).width?
          unless ( width_of fmt_cfg.fill ) is 1
            throw new Effstring_syntax_fillwidth_error 'Ωfstr___5', fmt_spec, fmt_cfg.fill
          literal = _to_width literal, fmt_cfg
        R += literal + tail
      #.....................................................................................................
      else
        literal = if ( typeof value is 'string' ) then value else rpr value
        R      += literal + part
    return R

#-----------------------------------------------------------------------------------------------------------
# f = new_ftag D3F.format
f = new_ftag 'en-US'



#===========================================================================================================
module.exports = {
  f,
  new_ftag,
  _d3_format: D3F,
  _default_locale,
  _hint_as_locale_cfg,
  _locale_cfg_from_bcp47
  _fmtspec_re,
  _locale_cfg_from_hints,
  Effstring_error,
  Effstring_syntax_error,
  Effstring_lib_syntax_error, }


