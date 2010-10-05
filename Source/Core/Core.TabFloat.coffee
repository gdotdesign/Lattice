###
---

name: Core.TabFloat

description: Tabbed float.

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
      @lastTab = @tabs.active
      index = @tabs.tabs.indexOf tab
      @activeContent = @tabContents[index]
      @setContent @tabContents[index]
      @fireEvent 'tabChange'
      ).bindWithEvent @
    @tabContents = []
    @base.grab @tabs, 'top'
  addTab: (label,content) ->
    @tabs.add new Core.Tab({class:'floatTab',label:label})
    @tabContents.push content
  setContent: (element) ->
    index = null
    @tabContents.each (item,i) ->
      if item is element
        index = i
    if index?
      @tabs.setActive @tabs.tabs[index]
    @parent element
}
