###
---

name: Forms.Field

description: Field Element for Forms.Fieldset.

license: MIT-style license.

requires: [Core.Abstract, Forms.Input, GDotUI]

provides: Forms.Field

...
###
Forms.Field = new Class {
  Extends:Core.Abstract
  options:{
    structure: GDotUI.Theme.Forms.Field.struct
    label: ''
  }
  initialize: (options) ->
    @options = options
    @options.structure = GDotUI.Theme.Forms.Field.struct
    @parent options
    @
  create: ->
    h = new Hash @options.structure
    h.each ((value,key) ->
      @base = new Element key
      @createS value, @base
    ).bind @
    if @options.hidden
      @base.setStyle 'display', 'none'
  createS: (item,parent) ->
    if not parent?
      null
    else
      console.log typeOf(item)
      switch typeOf(item)
        when "object"
          for key of item
            data = new Hash(item).get key
            if key == 'input'
              @input = new Forms.Input @options  
              el = @input
            else if key == 'label'
              @label = new Element 'label', {'text':@options.label}
              el = @label
            else
              el = new Element key 
            console.log document.id(el)
            parent.grab el
            @createS data , el
          
}
