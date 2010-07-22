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
    var _a, _b, a, key;
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
        tab.lastHeight = tab.panel.getSize().y;
        tab.panel.setStyle('height', 0);
        tab.addEvent('activated', (function(t) {
          t.panel.setStyle('height', t.lastHeight);
          return window.localStorage.setItem('current-tab', this.tabnav.tabs.indexOf(t));
        }).bindWithEvent(this));
        tab.addEvent('deactivated', function(t) {
          return t.panel.setStyle('height', 0);
        });
        return this.tabnav.add(tab);
      }).call(this);
    }}
    a = window.localStorage.getItem('current-tab');
    if (a === null) {
      this.tabnav.setActive(this.tabnav.tabs[0]);
      window.localStorage.setItem('current-tab', 0);
    } else {
      this.tabnav.setActive(this.tabnav.tabs[Number(window.localStorage.getItem('current-tab'))]);
    }
    $('tabs').grab(this.tabnav);
    this.createFloats();
    this.createPickers();
    this.createBasic();
    return this;
  },
  createBasic: function() {
    var ic, icg, slot, tip;
    $("exButton").grab(new Core.Button({
      text: "Hello there!"
    }));
    $("exButton1").grab(new Core.Button({
      text: "Hello there!",
      image: "images/delete.png",
      'class': "alertButton"
    }));
    $("exIcon").grab(new Core.Icon({
      image: "images/delete.png"
    }));
    icg = new Core.IconGroup();
    icg.addIcon(new Core.Icon({
      image: "images/calendar.png"
    }));
    icg.addIcon(new Core.Icon({
      image: "images/database.png"
    }));
    icg.addIcon(new Core.Icon({
      image: "images/camera.png"
    }));
    icg.addIcon(new Core.Icon({
      image: "images/color_wheel.png"
    }));
    this.icgc = new Core.IconGroup({
      mode: 'circular',
      angle: 360,
      radius: 30
    });
    this.icgc.addIcon(new Core.Icon({
      image: "images/calendar.png",
      'class': 'cicon'
    }));
    this.icgc.addIcon(new Core.Icon({
      image: "images/database.png",
      'class': 'cicon'
    }));
    this.icgc.addIcon(new Core.Icon({
      image: "images/camera.png",
      'class': 'cicon'
    }));
    this.icgc.addIcon(new Core.Icon({
      image: "images/color_wheel.png",
      'class': 'cicon'
    }));
    $("exIconG").grab(icg);
    icg.base.addEvent('outerClick', (function() {
      return this.icgc.base.dispose();
    }).bindWithEvent(this));
    icg.base.addEvent('contextmenu', (function(e) {
      e.stop();
      document.body.grab(this.icgc);
      return this.icgc.base.setStyles({
        'position': 'absolute',
        'top': e.page.y,
        'left': e.page.x
      });
    }).bindWithEvent(this));
    $("exSlider").grab(new Core.Slider({
      mode: "horizontal",
      range: [0, 100],
      steps: [100]
    }));
    slot = new Core.Slot();
    slot.addItem(new Iterable.ListItem({
      title: 'List item 1',
      subtitle: 'subtitle'
    }));
    slot.addItem(new Iterable.ListItem({
      title: 'List item 2',
      subtitle: 'subtitle'
    }));
    slot.addItem(new Iterable.ListItem({
      title: 'List item 3',
      subtitle: 'subtitle'
    }));
    slot.addItem(new Iterable.ListItem({
      title: 'List item 4',
      subtitle: 'subtitle'
    }));
    $("exSlot").grab(slot);
    ic = new Core.Icon({
      image: "images/calendar.png"
    });
    tip = new Core.Tip({
      label: 'Calendar',
      location: {
        x: "right",
        y: "bottom"
      }
    });
    tip.attach(ic);
    return $("exTip").grab(ic);
  },
  createPickers: function() {
    Pickers.Color.attach($('colorSelect'));
    Pickers.Text.attach($('textSelect'));
    Pickers.Date.attach($('dateSelect'));
    Pickers.Number.attach($('numberSelect'));
    Pickers.Time.attach($('timeSelect'));
    return Pickers.DateTime.attach($('datetimeSelect'));
  },
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