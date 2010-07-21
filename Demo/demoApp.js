var App, Tabs;
var __hasProp = Object.prototype.hasOwnProperty;
Tabs = new Hash({
  'About': 'about',
  'Basic Elements': 'basic',
  'Pickers': 'pickers',
  'Floats': 'floats',
  'Forms': 'forms'
});
App = new Class({
  initialize: function() {
    var _a, _b, key;
    this.tabnav = new Core.Tabs();
    _b = Tabs;
    for (_a in _b) { if (__hasProp.call(_b, _a)) {
      (function() {
        var tab;
        var key = _a;
        var value = _b[_a];
        tab = new Core.Tab({
          label: key
        });
        tab.panel = $(value);
        tab.addEvent('activated', function(t) {
          return t.panel.setStyle('opacity', 1);
        });
        tab.addEvent('deactivated', function(t) {
          return t.panel.setStyle('opacity', 0);
        });
        return this.tabnav.add(tab);
      }).call(this);
    }}
    this.tabnav.setActive(this.tabnav.tabs[0]);
    $('tabs').grab(this.tabnav);
    this.createFloats();
    return this;
  },
  createBasic: function() {
    this.basicContent = new Element('div');
    return this.basicContent;
  },
  createPickers: function() {  },
  createFloats: function() {
    var a;
    this.textFloat = new Core.Float({
      editable: false,
      draggable: true,
      resizeable: false,
      cookieID: 'text',
      useCookie: false,
      restoreSize: true
    });
    this.textFel = new Data.Text();
    this.textFel.text.setStyles({
      'width': 200,
      'height': 200
    });
    this.textFloat.setContent(this.textFel);
    this.floatIconGroup = new Core.IconGroup({
      mode: 'horizontal',
      spacing: {
        x: 0,
        y: 0
      }
    });
    this.textFIcom = new Core.Icon({
      image: 'images/page_white.png',
      'class': 'h_menu_icon'
    });
    this.textFIcom.addEvent('invoked', (function() {
      return this.textFloat.toggle();
    }).bindWithEvent(this));
    this.textF_TIP = new Core.Tip({
      label: 'Your Notes',
      location: {
        x: "left",
        y: "bottom"
      }
    });
    this.textF_TIP.attach(this.textFIcom);
    this.floatIconGroup.addIcon(this.textFIcom);
    document.body.adopt(this.floatIconGroup);
    this.floatIconGroup.base.setStyles({
      'top': 0,
      'position': 'fixed',
      'right': 50
    });
    a = window.localStorage.getItem('float-text-note');
    if (a === null) {
      window.localStorage.setItem('float-text-note', 'Set notes here that will remain in your local storage...');
      this.textFel.setValue('Set notes here that will remain in your local storage...');
    } else {
      this.textFloat.show();
      this.textFel.setValue(a);
    }
    return this.textFel.addEvent('change', (function(value) {
      return window.localStorage.setItem('float-text-note', value);
    }).bindWithEvent(this));
  },
  tabChange: function() {  }
});