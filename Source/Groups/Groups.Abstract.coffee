define ["Core.Abstract","Interfaces.Children"], "Groups.Abstract", ->
  new Class
    Extends: Core.Abstract
    Implements: Interfaces.Children
    addItem: (el,where) ->
      @addChild el, where
    removeItem: (el) ->
      @removeChild el
