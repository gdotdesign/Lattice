###
---

name: Forms.Field

description: 

license: MIT-style license.

requires: [Core.Abstract, Forms.Input]

provides: Forms.Field

...
###
Forms.Field: new Class {
  Extends:Core.Abstract
  options:{
    structure: GDotUI.Theme.Forms.Field.struct
    label: 'hello'
  }
  initialize: (options) ->
    @parent options
    this
  create: ->
    h: new Hash @options.structure
    for key of h
      @base: new Element key
      @createS h.get( key ), @base
      break
    if @options.hidden
      @base.setStyle 'display', 'none'
  createS: (item,parent) ->
    if not parent?
      return null
    switch $type(item)
      when "object"
        for key of item
          data: new Hash(item).get key
          if key == 'input'
            @input: new Forms.Input @options  ## @createinput
            el: @input
          else if key == 'label'
            @label: new Element 'label', {'text':@options.label}
            el: @label
          else
            el: new Element key 
          parent.grab el
          @createS data , el
          
}