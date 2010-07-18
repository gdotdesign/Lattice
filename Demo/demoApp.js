var App;
App = new Class({
  initialize: function() {
    this.tabnav = new Core.Tabs();
    this.aboutTab = new Core.Tab({
      label: 'About'
    });
    this.basicTab = new Core.Tab({
      label: 'Basic Elements'
    });
    this.pickerTab = new Core.Tab({
      label: 'Pickers'
    });
    this.floatTab = new Core.Tab({
      label: 'Floats'
    });
    this.formsTab = new Core.Tab({
      label: 'Forms'
    });
    this.content = $('content');
    this.tabnav.add(this.aboutTab);
    this.tabnav.add(this.basicTab);
    this.tabnav.add(this.pickerTab);
    this.tabnav.add(this.floatTab);
    this.tabnav.add(this.formsTab);
    this.tabnav.addEvent('change', (function(tab) {
      if (tab === this.aboutTab) {
        $('about').setStyle('opacity', 1);
        $('asd').setStyle('opacity', 0);
      }
      if (tab === this.basicTab) {
        $('about').setStyle('opacity', 0);
        return $('asd').setStyle('opacity', 1);
      }
    }).bindWithEvent(this));
    $('tabs').grab(this.tabnav);
    return this.createFloats();
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
      this.textFel.setValue(a);
    }
    return this.textFel.addEvent('change', (function(value) {
      return window.localStorage.setItem('float-text-note', value);
    }).bindWithEvent(this));
  },
  tabChange: function() {  }
});