###
---

name: Interfaces.Size

description: Size minsize from css....

license: MIT-style license.

provides: Interfaces.Size

requires: [GDotUI]
...
###
Interfaces.Size = new Class {
  _$Size: ->
    @size = Number.from getCSS("/\\.#{@get('class')}$/",'width')
    @minSize = Number.from(getCSS("/\\.#{@get('class')}$/",'min-width')) or 0
    @addAttribute 'minSize', {
      value: null
      setter: (value,old) ->
        @base.setStyle 'min-width', value
        value      
    }
    @addAttribute 'size', {
      value: null
      setter: (value, old) ->
        size = if value < @minSize then @minSize else value
        @base.setStyle 'width', size
        size
    }
  
}
