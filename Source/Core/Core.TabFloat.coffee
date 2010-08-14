###
---

name: Core.TabFloat

description:

license: MIT-style license.

requires: [Core.Float, Core.Tabs]

provides: Core.TabFloat

...
###
Core.TabFloat = new Class {
  Extends: Core.Float
  options: {
  }
  initialize: (options) ->
    @parent options
  create: ->
    @parent()
    @tabs = new Core.Tabs({class:'floatTabs'})
    @tabs.addEvent 'change', ( (tab) ->
      index = @tabs.tabs.indexOf tab
      @setContent @tabContents[index]
      ).bindWithEvent @
    @tabContents = []
    @base.grab @tabs, 'top'
  addTab: (label,content) ->
    @tabs.add new Core.Tab({class:'floatTab',label:label})
    @tabContents.push content
  
}
