###
---

name: Data.Text

description: 

license: MIT-style license.

requires: Data.Abstract

provides: Data.Text

...
###
Data.Text: new Class {
  Implements:Events
  initialize: ->
    @base: new Element 'div' 
    @text: new Element 'textarea'
    @base.grab @text
    @addEvent 'show', ( ->
      @text.focus()
      ).bindWithEvent this
    @text.addEvent 'keyup',( (e) ->
      @fireEvent 'change', @text.get('value')
    ).bindWithEvent this
    this
  setValue: (text) ->
    @text.set('value',text);
  toElement: ->
    @base
}