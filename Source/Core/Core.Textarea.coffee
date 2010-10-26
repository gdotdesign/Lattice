###
---

name: Core.Textarea

description: Html from markdown.

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Textarea

...
###
Core.Textarea = new Class {
  Extends: Core.Abstract
  initialize: (options) ->
    @parent options
  create: ->
    @parent
}
