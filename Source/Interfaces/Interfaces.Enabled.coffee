###
---

name: Interfaces.Enabled

description: Provides enable and disable function to elements.

license: MIT-style license.

provides: Interfaces.Enabled

...
###
Interfaces.Enabled: new Class {
  _$Enabled: ->
    @enabled: on
  enable: ->
    @enabled: on
    @base.removeClass 'disabled'
    @fireEvent 'enabled'
  disable: ->
    @enabled off
    @base.addClass 'disabled'
    @fireEvent 'disabled'
}