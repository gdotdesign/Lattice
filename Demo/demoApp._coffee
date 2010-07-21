# Demo application...
Tabs: new Hash {
  'About':'about'
  'Basic Elements':'basic'
  'Pickers':'pickers'
  'Floats':'floats'
  'Forms':'forms'
}
App: new Class {
  initialize: ->
    @tabnav: new Core.Tabs()
    for key, value of Tabs
      tab: new Core.Tab {label:key}
      tab.panel: $ value
      tab.addEvent 'activated' , (t) ->
        t.panel.setStyle 'opacity', 1
      tab.addEvent 'deactivated' , (t) ->
        t.panel.setStyle 'opacity', 0
      @tabnav.add tab
    
    @tabnav.setActive @tabnav.tabs[0]
    
    $('tabs').grab @tabnav
    @createFloats()
    @
  createBasic: ->
    @basicContent: new Element 'div'
  createPickers: ->
  createFloats: ->
    @textFloat: new Core.Float {editable:off
                          draggable: on
                          resizeable: off
                          cookieID: 'text'
                          useCookie: off
                          restoreSize:on }
    @textFel: new Data.Text();
    @textFel.text.setStyles {
      'width': 200
      'height': 200
    }
    @textFloat.setContent @textFel
    @floatIconGroup: new Core.IconGroup {mode:'horizontal'
                                         spacing:{x:0,y:0}}
    @textFIcom: new Core.Icon {image:'images/page_white.png',class:'h_menu_icon'}
    @textFIcom.addEvent 'invoked', ( ->
        @textFloat.toggle();
      ).bindWithEvent this
    @textF_TIP: new Core.Tip {label:'Your Notes'
                              location: { x:"left",
                              y:"bottom" }
                              }
    @textF_TIP.attach @textFIcom
    @floatIconGroup.addIcon @textFIcom
    
    document.body.adopt @floatIconGroup
    @floatIconGroup.base.setStyles {
      'top': 0
      'position': 'fixed'
      'right': 50
    }
    a: window.localStorage.getItem 'float-text-note'
    if a == null
      window.localStorage.setItem 'float-text-note', 'Set notes here that will remain in your local storage...'
      @textFel.setValue 'Set notes here that will remain in your local storage...'
    else
      @textFloat.show()
      @textFel.setValue a
    @textFel.addEvent 'change', ( (value) ->
      window.localStorage.setItem 'float-text-note',value
    ).bindWithEvent this
  tabChange: ->
    
}