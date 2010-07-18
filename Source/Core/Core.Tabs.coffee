###
---

name: Core.Tabs

description: Tab navigation element.

license: MIT-style license.

requires: [Core.Abstract, Core.Tab]

provides: Core.Tabs

...
###
Core.Tabs: new Class {
  Extends: Core.Abstract
  Binds:['remove','change']
  options:{
    class: GDotUI.Theme.Tabs.class
  }
  initialize: (options) ->
    @tabs: []
    @active: null
    @parent options
  create: ->
    @base.addClass @options.class
  add: (tab) ->
    if @tabs.indexOf(tab) == -1
      @tabs.push tab
      @base.grab tab
      tab.addEvent 'remove', @remove
      tab.addEvent 'activate', @change
  remove: (tab) ->
    if @tabs.indexOf(tab) != -1
      @tabs.erase tab
      document.id(tab).dispose()
      if tab is @active
        if @tabs.length > 0
          @change @tabs[0]
      @fireEvent 'tabRemoved', tab
  change: (tab) ->
    if tab isnt @active
      @setActive tab
      @fireEvent 'change', tab
  setActive: (tab) ->
    if @active?
      @active.deactivate()
    tab.activate()
    @active: tab
}