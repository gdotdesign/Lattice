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
      tab.lastHeight: tab.panel.getSize().y
      tab.panel.setStyle 'height', 0
      tab.addEvent 'activated' , ( (t) ->
        t.panel.setStyle.delay(600,t.panel,['height', t.lastHeight])
        window.localStorage.setItem 'current-tab', @tabnav.tabs.indexOf(t)
      ).bindWithEvent @
      tab.addEvent 'deactivated' , (t) ->
        t.panel.setStyle 'height', 0
      @tabnav.add tab
      
    a: window.localStorage.getItem 'current-tab'
    if a == null 
      @tabnav.setActive @tabnav.tabs[0]
      window.localStorage.setItem 'current-tab', 0
    else
      @tabnav.setActive @tabnav.tabs[Number(window.localStorage.getItem('current-tab'))]
    
    $('tabs').grab @tabnav
    @createFloats()
    @createPickers()
    @createBasic()
    @
  createBasic: ->
    $("exButton").grab new Core.Button({text:"Hello there!"})
    $("exButton1").grab new Core.Button({text:"I'm red!",image:"images/delete.png",class:"alertButton"})
    $("exIcon").grab new Core.Icon({image:"images/delete.png"})
    icg: new Core.IconGroup();
    icg.addIcon new Core.Icon({image:"images/calendar.png"})
    icg.addIcon new Core.Icon({image:"images/database.png"})
    icg.addIcon new Core.Icon({image:"images/camera.png"})
    icg.addIcon new Core.Icon({image:"images/color_wheel.png"})
    
    @icgc: new Core.IconGroup({mode:'circular',angle:360,radius:30});
    @icgc.addIcon new Core.Icon({image:"images/calendar.png",class:'cicon'})
    @icgc.addIcon new Core.Icon({image:"images/database.png",class:'cicon'})
    @icgc.addIcon new Core.Icon({image:"images/camera.png",class:'cicon'})
    @icgc.addIcon new Core.Icon({image:"images/color_wheel.png",class:'cicon'})
    
    $("exIconG").grab icg
    icg.base.addEvent 'outerClick',( ->
      @icgc.base.dispose()
    ).bindWithEvent @
    icg.base.addEvent 'contextmenu',((e) ->
      e.stop()
      document.body.grab(@icgc);
      @icgc.base.setStyles { 'position':'absolute'
                           'top': e.page.y
                           'left': e.page.x }
    ).bindWithEvent @
    
    $("exSlider").grab new Core.Slider({mode:"horizontal",range:[0,100],steps:[100]});
    
    slot: new Core.Slot();
    slot.addItem new Iterable.ListItem({title:'List item 1', subtitle:'subtitle'});
    slot.addItem new Iterable.ListItem({title:'List item 2', subtitle:'subtitle'});
    slot.addItem new Iterable.ListItem({title:'List item 3', subtitle:'subtitle'});
    slot.addItem new Iterable.ListItem({title:'List item 4', subtitle:'subtitle'});  
    $("exSlot").grab slot
    
    ic: new Core.Icon({image:"images/calendar.png"});
    tip: new Core.Tip {label:'Calendar'
                              location: { x:"right",
                              y:"bottom" }
                              }
    tip.attach ic
    $("exTip").grab ic
  createPickers: ->
    Pickers.Color.setValue( '#fff', 100, 'hex')
    Pickers.Color.attach($('colorSelect'))
    Pickers.Text.attach($('textSelect'))
    Pickers.Date.attach($('dateSelect'))
    Pickers.Number.attach($('numberSelect'))
    Pickers.Time.attach($('timeSelect'))
    Pickers.DateTime.attach($('datetimeSelect'))
  createFloats: ->
    listFloat: new Core.Float({useCookie: off, cookieID:'lfloat',editable:true,resizeable:true})
    list: new Iterable.List()
    i: 0
    while i < 5
      item: new Iterable.ListItem {title:'List item '+i,draggable:off}
      list.addItem item
      i++
    listFloat.setContent(list);
    listFloatButton: new Core.Button({text:'Toggle',image:'images/layout.png'})
    $("exFloat1").grab listFloatButton
    g: window.localStorage.getItem 'lfloat.y'
    if g is null
      listFloat.base.setStyle 'opacity', 0
    listFloat.show()
    listFloatButton.addEvent 'invoked', ( ->
      if listFloat.base.getStyle('opacity') isnt 0
        listFloat.toggle()
      else
        listFloat.base.setStyle 'opacity', 1
      ).bindWithEvent @
    
    
    dateFloat: new Core.Float({useCookie: off, cookieID:'dfloat',editable:off,resizeable:off, closeable:off})
    date: new Data.DateTime();
    dateFloat.setContent(date);
    dateFloatButton: new Core.Button({text:'Toggle',image:'images/layout.png'})
    $("exFloat2").grab dateFloatButton
    g: window.localStorage.getItem 'dfloat.y'
    if g is null
      dateFloat.base.setStyle 'opacity', 0
    dateFloat.show()
    dateFloatButton.addEvent 'invoked', ( ->
      if dateFloat.base.getStyle('opacity') isnt 0
        dateFloat.toggle()
      else
        dateFloat.base.setStyle 'opacity', 1
      ).bindWithEvent @
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
      @textFloat.base.setStyles {'left':50, 'top':100}
      window.localStorage.setItem 'text.state', 'hidden'
    else
      @textFel.setValue a
      @textFloat.show()
    @textFel.addEvent 'change', ( (value) ->
      window.localStorage.setItem 'float-text-note',value
    ).bindWithEvent this
}
