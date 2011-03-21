###
---

name: Core.Tabs

description: Tab navigation element.

license: MIT-style license.

requires: [Core.Abstract, Core.Tab, GDotUI]

provides: Core.Tabs

...
###
Core.Tabs = new Class {
  Extends: Core.Abstract
  Binds:['remove','change']
  Attributes: {
    class: {
      value:  GDotUI.Theme.Tabs.class
    }
  }
  options:{
    autoRemove: on
  }
  initialize: (options) ->
    @tabs = []
    @active = null
    @parent options
  add: (tab) ->
    if @tabs.indexOf tab == -1
      @tabs.push tab
      @base.grab tab
      tab.addEvent 'remove', @remove
      tab.addEvent 'activate', @change
  remove: (tab) ->
    if @tabs.indexOf tab != -1
      if @options.autoRemove
        @removeTab tab
      @fireEvent 'removed',tab
  removeTab: (tab) ->
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
    if @active isnt tab
      if @active?
        @active.deactivate()
      tab.activate()
      @active = tab
  getByLabel: (label) ->
    (@tabs.filter (item, i) ->
      if item.options.label is label
        true
      else
        false)[0]
}
