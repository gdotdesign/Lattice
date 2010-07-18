###
---

name: Data.Text

description: Text data element.

license: MIT-style license.

requires: Data.Abstract

provides: Data.Text

...
###
Data.Text: new Class {
  Extends: Data.Abstract
  initialize: (options) ->
    @parent options
  create: ->
    @text: new Element 'textarea'
    @base.grab @text
    @addEvent 'show', ( ->
      @text.focus()
      ).bindWithEvent this
    @text.addEvent 'keyup',( (e) ->
      @fireEvent 'change', @text.get('value')
    ).bindWithEvent this
  getValue: ->
    @text.get('value')
  setValue: (text) ->
    @text.set('value',text);
}