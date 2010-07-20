###
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, Interfaces.Enabled]

provides: Core.Icon

...
###
Core.Icon: new Class {
  Extends:Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  options:{
    image: null
    class: GDotUI.Theme.Icon.class
  }
  initialize: (options) ->
    @parent options
  create: ( ->
    @base.addClass @options.class
    if @options.image?
      @base.setStyle 'background-image', 'url('+@options.image+')'
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [this, e]
      ).bindWithEvent this
    ).protect()
}