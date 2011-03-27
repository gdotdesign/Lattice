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
    if GDotUI.selectors[".#{@get('class')}"]
      @size = Number.from GDotUI.selectors[".#{@get('class')}"]['width']
    else 
      @size = 0
    if GDotUI.selectors[".#{@get('class')}"]
      @minSize = Number.from(GDotUI.selectors[".#{@get('class')}"]['min-width'])
    else
      @minSize = 0
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
