###
---

name: Data.Text

description: Text data element.

license: MIT-style license.

requires: [Data.Abstract, GDotUI]

provides: Data.Text

...
###
Data.Text = new Class {
  Extends: Data.Abstract
  Implements: Interfaces.Size  
  Attributes: {
    class: {
      value: GDotUI.Theme.Text.class
    }
  }
  initialize: (options) ->
    @parent options
  update: ->
    @text.setStyle 'width', @size
  create: ->
    @text = new Element 'textarea'
    @base.grab @text
    @addEvent 'show', ( ->
      @text.focus()
      ).bind this
    @text.addEvent 'keyup',( (e) ->
      @fireEvent 'change', @text.get('value')
    ).bind this
  getValue: ->
    @text.get('value')
  setValue: (text) ->
    @text.set('value',text);
}
