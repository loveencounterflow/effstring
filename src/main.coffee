

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
  constructor: ( ref, message, cause = null ) ->
    super()
    @cause = cause if cause?
    if ref is null
      @message  = message
      return undefined
    @message  = "#{ref} (#{@constructor.name}) #{message}"
    @ref      = ref
    return undefined

#-----------------------------------------------------------------------------------------------------------
class Effstring_syntax_error extends Effstring_error
  constructor: ( ref, part, message = null, cause = null ) ->
    message ?= "illegal format specifier #{rpr part}"
    super ref, message, cause

#-----------------------------------------------------------------------------------------------------------
class Effstring_lib_syntax_error extends Effstring_syntax_error
  constructor: ( ref, part, cause ) ->
    super ref, part, "illegal format specifier #{rpr part}", cause

#-----------------------------------------------------------------------------------------------------------
class Effstring_syntax_fillwidth_error extends Effstring_syntax_error
  constructor: ( ref, fmt_spec, fill ) ->
    super ref, null, "illegal format specifier #{rpr fmt_spec}: fill #{rpr fill} must be single-width BMP character"

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
_fmtspec_unit_re = /// f (?<discard> \/ (?<unit> [yzafpnµm1kMGTPEZY] ) ) $ ///

#-----------------------------------------------------------------------------------------------------------
_unit_magnitudes = Object.freeze
  'y':  1e-24
  'z':  1e-21
  'a':  1e-18
  'f':  1e-15
  'p':  1e-12
  'n':  1e-09
  'µ':  1e-06
  'm':  1e-03
  '1':  1e+00
  'k':  1e+03
  'M':  1e+06
  'G':  1e+09
  'T':  1e+12
  'P':  1e+15
  'E':  1e+18
  'Z':  1e+21
  'Y':  1e+24

#-----------------------------------------------------------------------------------------------------------
_escape_regex = ( text ) ->
  return text.replace ///[/\-\\^$*+?.()|[\]{}]///g, '\\$&'
  # return text.replace ///[.*+?^${}()|[\\]\\\\]///g, '\\\\$&'

#-----------------------------------------------------------------------------------------------------------
_to_width = ( text, fmt_cfg, has_si_unit_prefix ) ->
  ### TAINT assuming fmt_cfg.fill has length 1, but could be any length ###
  si_unit_correction  = if has_si_unit_prefix then 1 else 0
  field_width         = fmt_cfg.width + si_unit_correction
  switch fmt_cfg.align
    #.......................................................................................................
    when '<'
      ### TAINT don't re-calculate width, just inc/dec by width of fmt_cfg.fill ###
      while ( text.endsWith fmt_cfg.fill ) and ( width_of text ) > field_width
        text = text[ ... text.length - 1 ]
      while ( width_of text ) < field_width
        text += fmt_cfg.fill
    #.......................................................................................................
    when '>'
      while ( text.startsWith fmt_cfg.fill ) and ( width_of text ) > field_width
        text = text[ 1 ... ]
      while ( width_of text ) < field_width
        text = fmt_cfg.fill + text
    #.......................................................................................................
    when '^'
      p = 0
      loop
        break unless ( width_of text ) > field_width
        p++
        if ( p %% 2 ) is 0
          if text.startsWith fmt_cfg.fill       then text = text[ 1 ... ]
          else if text.endsWith fmt_cfg.fill    then text = text[ ... text.length - 1 ]
        else
          if text.endsWith fmt_cfg.fill         then text = text[ ... text.length - 1 ]
          else if text.startsWith fmt_cfg.fill  then text = text[ 1 ... ]
    #.......................................................................................................
    when '='
      break unless ( width_of text ) > field_width
      fill_re = _escape_regex fmt_cfg.fill
      matcher = /// ^ ( [^ #{fill_re} ]* ) #{fill_re} /// ### TAINT use unicode flag? ###
      loop
        shorter_text = text.replace matcher, '$1'
        break if text is shorter_text
        text = shorter_text
        break unless ( width_of text ) > field_width
  #.........................................................................................................
  return text

#-----------------------------------------------------------------------------------------------------------
new_ftag = ( hints... ) ->
  locale_cfg  = _locale_cfg_from_hints hints...
  locale      = D3F.formatLocale locale_cfg
  return ( parts, expressions... ) ->
    R = parts[ 0 ]
    for value, idx in expressions
      part    = parts[ idx + 1 ]
      #.....................................................................................................
      if part.startsWith ':'
        unless ( match = part.match _fmtspec_re )?
          throw new Effstring_syntax_error 'Ωfstr___3', part
        { fmt_spec, tail, } = match.groups
        #...................................................................................................
        ### Handle SI unit prefix specifier: ###
        if ( unit_match = fmt_spec.match _fmtspec_unit_re )?
          has_si_unit_prefix  = true
          { discard, unit,  } = unit_match.groups
          fmt_spec = fmt_spec[ ... fmt_spec.length - discard.length ]
          try literal = ( ( locale.formatPrefix fmt_spec, _unit_magnitudes[ unit ] ) value ) catch error
            ### d3-format own errors are unspecific, specific ones are likely from unexpected causes (and are therefore likely not fmt spec syntax errors) ###
            throw error unless error.constructor is Error
            throw new Effstring_lib_syntax_error 'Ωfstr___5', fmt_spec, error
        #...................................................................................................
        ### Handle format specifiers without SI unit prefix: ###
        else
          has_si_unit_prefix  = false
          try literal = ( ( locale.format fmt_spec ) value ) catch error
            ### d3-format own errors are unspecific, specific ones are likely from unexpected causes (and are therefore likely not fmt spec syntax errors) ###
            throw error unless error.constructor is Error
            throw new Effstring_lib_syntax_error 'Ωfstr___7', fmt_spec, error
        #...................................................................................................
        ### Correct field width: ###
        if locale_cfg.fullwidth and ( fmt_cfg = D3F.formatSpecifier fmt_spec ).width?
          ### TAINT this should have been validated earlier ###
          unless ( width_of fmt_cfg.fill ) is 1
            throw new Effstring_syntax_fillwidth_error 'Ωfstr___8', fmt_spec, fmt_cfg.fill
          literal = _to_width literal, fmt_cfg, has_si_unit_prefix
        #...................................................................................................
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
  Effstring_error,
  Effstring_syntax_error,
  Effstring_lib_syntax_error,
  Effstring_syntax_fillwidth_error,
  Effstring_validation_error,
  _d3_format: D3F,
  _default_locale,
  _hint_as_locale_cfg,
  _locale_cfg_from_bcp47,
  _fmtspec_re,
  _fmtspec_unit_re,
  _locale_cfg_from_hints,
  _unit_magnitudes, }


