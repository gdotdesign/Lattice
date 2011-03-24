###
---

name: Forms.Field

description: Field Element for Forms.Fieldset.

license: MIT-style license.

requires: 
  - GDotUI
  - Forms.Input

provides: Forms.Field

...
###
Forms.Field = new Class {
  Implements: [
    Events
    Options
  ]
  Attributes: {
    structure: {
      readOnly: true
      value: GDotUI.Theme.Forms.Field.struct
    }
  }
  initialize: (options) ->
    @setOptions options
    h = new Hash @get 'structure'
    h.each ((value,key) ->
      @base = new Element key
      @create value, @base
    ).bind @
  create: (item,parent) ->
    if not parent?
      null
    else
      switch typeOf(item)
        when "object"
          for key of item
            data = new Hash(item).get key
            if key == 'input'
              el = new Forms.Input @options  
            else if key == 'label'
              el = new Element 'label', {'text':@options.label}
            else
              el = new Element key 
            parent.grab el
            @create data , el
  toElement: ->
    @base
}
