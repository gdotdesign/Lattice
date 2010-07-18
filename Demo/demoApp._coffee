# Demo application...
App: new Class {
  initialize: ->
    @tabnav: new Core.Tabs()
    @aboutTab: new Core.Tab {label:'About'}
    @basicTab: new Core.Tab {label:'Basic Elements'}
    @pickerTab: new Core.Tab {label:'Pickers'}
    @floatTab: new Core.Tab {label:'Floats'}
    @formsTab: new Core.Tab {label:'Forms'}
    
    @content: $ 'content'
    
    @tabnav.add @aboutTab
    @tabnav.add @basicTab
    @tabnav.add @pickerTab
    @tabnav.add @floatTab
    @tabnav.add @formsTab
    
    @tabnav.addEvent 'change',( (tab) ->
      if tab is @aboutTab
        $('about').setStyle 'opacity', 1
        $('asd').setStyle 'opacity', 0
      if tab is @basicTab
        $('about').setStyle 'opacity', 0
        $('asd').setStyle 'opacity', 1
    ).bindWithEvent this
    $('tabs').grab @tabnav
    @createFloats()
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