var Core, Data, Forms, GDotUI, Interfaces, Iterable, Pickers, ResetSlider, checkForKey;
var __hasProp = Object.prototype.hasOwnProperty;
/*
---

name: GDotUI

description: G.UI

license: MIT-style license.

provides: GDotUI

...
*/
Interfaces = {};
Core = {};
Data = {};
Iterable = {};
Pickers = {};
Forms = {};
!(typeof GDotUI !== "undefined" && GDotUI !== null) ? (GDotUI = {}) : null;
GDotUI.Config = {
  tipZindex: 100,
  floatZindex: 0,
  cookieDuration: 7 * 1000
};
/*
---

name: Interfaces.Mux

description: Runs function which names start with _$ after initialization. (Initialization for interfaces)

license: MIT-style license.

provides: Interfaces.Mux

...
*/
Interfaces.Mux = new Class({
  mux: function() {
    return (new Hash(this)).each((function(value, key) {
      return (key.test(/^_\$/) && $type(value) === "function") ? value.run(null, this) : null;
    }).bind(this));
  }
});
/*
---

name: Interfaces.Enabled

description: Provides enable and disable function to elements.

license: MIT-style license.

provides: Interfaces.Enabled

...
*/
Interfaces.Enabled = new Class({
  _$Enabled: function() {
    this.enabled = true;
    return this.enabled;
  },
  enable: function() {
    this.enabled = true;
    this.base.removeClass('disabled');
    return this.fireEvent('enabled');
  },
  disable: function() {
    this.enabled(false);
    this.base.addClass('disabled');
    return this.fireEvent('disabled');
  }
});
/*
---

name: Interfaces.Draggable

description: Porived dragging for elements that implements it.

license: MIT-style license.

requires:

provides: [Interfaces.Draggable, Drag.Float, Drag.Ghost]

...
*/
Drag.Float = new Class({
  Extends: Drag.Move,
  initialize: function(el, options) {
    return this.parent(el, options);
  },
  start: function(event) {
    return this.options.target === event.target ? this.parent(event) : null;
  }
});
Drag.Ghost = new Class({
  Extends: Drag.Move,
  options: {
    opacity: 0.65,
    pos: false,
    remove: ''
  },
  start: function(event) {
    if (!event.rightClick) {
      this.droppables = $$(this.options.droppables);
      this.ghost();
      return this.parent(event);
    }
  },
  cancel: function(event) {
    event ? this.deghost() : null;
    return this.parent(event);
  },
  stop: function(event) {
    this.deghost();
    return this.parent(event);
  },
  ghost: function() {
    this.element = (this.element.clone()).setStyles({
      'opacity': this.options.opacity,
      'position': 'absolute',
      'z-index': 5003,
      'top': this.element.getCoordinates()['top'],
      'left': this.element.getCoordinates()['left'],
      '-webkit-transition-duration': '0s'
    }).inject(document.body).store('parent', this.element);
    return this.element.getElements(this.options.remove).dispose();
  },
  deghost: function() {
    var e, newpos;
    e = this.element.retrieve('parent');
    newpos = this.element.getPosition(e.getParent());
    this.options.pos && this.overed === null ? e.setStyles({
      'top': newpos.y,
      'left': newpos.x
    }) : null;
    this.element.destroy();
    this.element = e;
    return this.element;
  }
});
Interfaces.Draggable = new Class({
  Implements: Options,
  options: {
    draggable: false,
    ghost: false,
    removeClasses: ''
  },
  _$Draggable: function() {
    if (this.options.draggable) {
      this.handle === null ? (this.handle = this.base) : null;
      this.options.ghost ? (this.drag = new Drag.Ghost(this.base, {
        target: this.handle,
        handle: this.handle,
        remove: this.options.removeClasses
      })) : (this.drag = new Drag.Float(this.base, {
        target: this.handle,
        handle: this.handle
      }));
      return this.drag.addEvent('drop', (function() {
        return this.fireEvent('dropped', arguments);
      }).bindWithEvent(this));
    }
  }
});
/*
---

name: Interfaces.Restoreable

description: Interface to store and restore elements status and position after refresh.

license: MIT-style license.

requires:

provides: Interfaces.Restoreable

...
*/
Interfaces.Restoreable = new Class({
  Impelments: [Options],
  Binds: ['savePosition'],
  options: {
    useCookie: true,
    cookieID: null
  },
  _$Restoreable: function() {
    return this.addEvent('dropped', this.savePosition);
  },
  saveState: function() {
    var state;
    state = this.base.isVisible() ? 'visible' : 'hidden';
    return $chk(this.options.cookieID) ? this.options.useCookie ? Cookie.write(this.options.cookieID + '.state', state, {
      duration: GDotUI.Config.cookieDuration
    }) : window.localStorage.setItem(this.options.cookieID + '.state', state) : null;
  },
  savePosition: function() {
    var position, state;
    if ($chk(this.options.cookieID)) {
      position = this.base.getPosition();
      state = this.base.isVisible() ? 'visible' : 'hidden';
      if (this.options.useCookie) {
        Cookie.write(this.options.cookieID + '.x', position.x, {
          duration: GDotUI.Config.cookieDuration
        });
        Cookie.write(this.options.cookieID + '.y', position.y, {
          duration: GDotUI.Config.cookieDuration
        });
        return Cookie.write(this.options.cookieID + '.state', state, {
          duration: GDotUI.Config.cookieDuration
        });
      } else {
        window.localStorage.setItem(this.options.cookieID + '.x', position.x);
        window.localStorage.setItem(this.options.cookieID + '.y', position.y);
        return window.localStorage.setItem(this.options.cookieID + '.state', state);
      }
    }
  },
  loadPosition: function(loadstate) {
    if ($chk(this.options.cookieID)) {
      if (this.options.useCookie) {
        this.base.setStyle('top', Cookie.read(this.options.cookieID + '.y') + "px");
        this.base.setStyle('left', Cookie.read(this.options.cookieID + '.x') + "px");
        return Cookie.read(this.options.cookieID + '.state') === "hidden" ? this.hide() : null;
      } else {
        this.base.setStyle('top', window.localStorage.getItem(this.options.cookieID + '.y') + "px");
        this.base.setStyle('left', window.localStorage.getItem(this.options.cookieID + '.x') + "px");
        return window.localStorage.getItem(this.options.cookieID + '.state') === "hidden" ? this.hide() : null;
      }
    }
  }
});
/*
---

name: Interfaces.Controls

description: Some control functions.

license: MIT-style license.

requires:

provides: Interfaces.Controls

...
*/
Interfaces.Controls = new Class({
  hide: function() {
    return this.base.setStyle('opacity', 0);
  },
  show: function() {
    return this.base.setStyle('opacity', 1);
  },
  toggle: function() {
    return this.base.getStyle('opacity') === 0 ? this.show() : this.hide();
  }
});
/*
---

name: Core.Abstract

description: "Abstract" base class for Core U.I. elements.

license: MIT-style license.

requires: [Interfaces.Mux]

provides: Core.Abstract

...
*/
Core.Abstract = new Class({
  Implements: [Events, Options, Interfaces.Mux],
  initialize: function(options) {
    var fn;
    this.setOptions(options);
    this.base = new Element('div');
    this.create();
    fn = this.ready.bindWithEvent(this);
    this.base.store('fn', fn);
    this.base.addEventListener('DOMNodeInsertedIntoDocument', fn, false);
    this.mux();
    return this;
  },
  create: function() {  },
  ready: function() {
    this.base.removeEventListener('DOMNodeInsertedIntoDocument', this.base.retrieve('fn'), false);
    return this.base.eliminate('fn');
  },
  toElement: function() {
    return this.base;
  }
});
/*
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, Interfaces.Enabled]

provides: Core.Icon

...
*/
Core.Icon = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Controls],
  options: {
    image: null,
    'class': GDotUI.Theme.Icon['class']
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: (function() {
    var _a;
    this.base.addClass(this.options['class']);
    (typeof (_a = this.options.image) !== "undefined" && _a !== null) ? this.base.setStyle('background-image', 'url(' + this.options.image + ')') : null;
    return this.base.addEvent('click', (function(e) {
      return this.enabled ? this.fireEvent('invoked', [this, e]) : null;
    }).bindWithEvent(this));
  }).protect()
});
/*
---

name: Core.IconGroup

description: Icon group with 4 types of layout.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls]

provides: Core.IconGroup

...
*/
Core.IconGroup = new Class({
  Extends: Core.Abstract,
  Implements: Interfaces.Controls,
  Binds: ['delegate'],
  options: {
    mode: "horizontal",
    spacing: {
      x: 0,
      y: 0
    },
    startAngle: 0,
    radius: 0,
    degree: 360,
    'class': GDotUI.Theme.IconGroup['class']
  },
  initialize: function(options) {
    this.icons = [];
    return this.parent(options);
  },
  create: (function() {
    this.base.setStyle('position', 'relative');
    return this.base.addClass(this.options['class']);
  }).protect(),
  delegate: function() {
    return this.fireEvent('invoked', arguments);
  },
  addIcon: function(icon) {
    if (this.icons.indexOf(icon === -1)) {
      icon.addEvent('invoked', this.delegate);
      this.base.grab(icon);
      this.icons.push(icon);
      return true;
    } else {
      return false;
    }
  },
  removeIcon: function(icon) {
    var index;
    index = this.icons.indexOf(icon);
    if (index !== -1) {
      icon.removeEvent('invoked', this.delegate);
      icon.base.dispose();
      this.icons.splice(index, 1);
      return true;
    } else {
      return false;
    }
  },
  ready: function() {
    return this.positionIcons();
  },
  positionIcons: function() {
    var _a, _b, _c, columns, fok, icpos, ker, n, radius, rows, spacing, startAngle, x, y;
    x = 0;
    y = 0;
    this.size = {
      x: 0,
      y: 0
    };
    spacing = this.options.spacing;
    if ((_a = this.options.mode) === 'grid') {
      if ((typeof (_b = this.options.columns) !== "undefined" && _b !== null)) {
        columns = this.options.columns;
        rows = this.icons.length / columns;
      }
      if ((typeof (_c = this.options.rows) !== "undefined" && _c !== null)) {
        rows = this.options.rows;
        columns = Math.round(this.icons.length / rows);
      }
      icpos = this.icons.map(function(item, i) {
        if (i % columns === 0) {
          x = 0;
          y = i === 0 ? y : y + item.base.getSize().y + spacing.y;
        } else {
          x = i === 0 ? x : x + item.base.getSize().x + spacing.x;
        }
        this.size.x = x + item.base.getSize().x;
        this.size.y = y + item.base.getSize().y;
        return {
          x: x,
          y: y
        };
      });
    } else if (_a === 'linear') {
      icpos = this.icons.map((function(item, i) {
        x = i === 0 ? x + x : x + spacing.x;
        y = i === 0 ? y + y : y + spacing.y;
        this.size.x = x + item.base.getSize().x;
        this.size.y = y + item.base.getSize().y;
        return {
          x: x,
          y: y
        };
      }).bind(this));
    } else if (_a === 'horizontal') {
      icpos = this.icons.map((function(item, i) {
        x = i === 0 ? x + x : x + item.base.getSize().x + spacing.x;
        y = i === 0 ? y : y + spacing.y;
        this.size.x = x + item.base.getSize().x;
        this.size.y = item.base.getSize().y;
        return {
          x: x,
          y: y
        };
      }).bind(this));
    } else if (_a === 'vertical') {
      icpos = this.icons.map((function(item, i) {
        x = i === 0 ? x : x + spacing.x;
        y = i === 0 ? y + y : y + item.base.getSize().y + spacing.y;
        this.size.x = item.base.getSize().x;
        this.size.y = y + item.base.getSize().y;
        return {
          x: x,
          y: y
        };
      }).bind(this));
    } else if (_a === 'circular') {
      n = this.icons.length;
      radius = this.options.radius;
      startAngle = this.options.startAngle;
      ker = 2 * this.radius * Math.PI;
      fok = this.options.degree / n;
      icpos = this.icons.map(function(item, i) {
        var foks;
        if (i === 0) {
          foks = startAngle * (Math.PI / 180);
          x = Math.round(radius * Math.sin(foks));
          y = -Math.round(radius * Math.cos(foks));
        } else {
          x = Math.round(radius * Math.sin(((fok * i) + startAngle) * (Math.PI / 180)));
          y = -Math.round(radius * Math.cos(((fok * i) + startAngle) * (Math.PI / 180)));
        }
        return {
          x: x,
          y: y
        };
      });
    }
    return this.icons.each(function(item, i) {
      item.base.setStyle('top', icpos[i].y);
      item.base.setStyle('left', icpos[i].x);
      return item.base.setStyle('position', 'absolute');
    });
  }
});
/*
---

name: Core.Tip

description: Tip class

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Tip

...
*/
Core.Tip = new Class({
  Extends: Core.Abstract,
  Binds: ['enter', 'leave'],
  options: {
    'class': GDotUI.Theme.Tip['class'],
    label: "",
    location: GDotUI.Theme.Tip.location,
    offset: GDotUI.Theme.Tip.offset,
    zindex: GDotUI.Theme.Tip.zindex
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.base.setStyle('position', 'absolute');
    this.base.setStyle('z-index', this.options.tipZindex);
    return this.base.set('html', this.options.label);
  },
  attach: function(item) {
    var _a;
    (typeof (_a = this.attachedTo) !== "undefined" && _a !== null) ? this.detach() : null;
    item.base.addEvent('mouseenter', this.enter);
    item.base.addEvent('mouseleave', this.leave);
    this.attachedTo = item;
    return this.attachedTo;
  },
  detach: function(item) {
    item.base.removeEvent('mouseenter', this.enter);
    item.base.removeEvent('mouseleave', this.leave);
    this.attachedTo = null;
    return this.attachedTo;
  },
  enter: function() {
    return this.attachedTo.enabled ? this.show() : null;
  },
  leave: function() {
    return this.attachedTo.enabled ? this.hide() : null;
  },
  ready: function() {
    var _a, _b, p, s, s1;
    p = this.attachedTo.base.getPosition();
    s = this.attachedTo.base.getSize();
    s1 = this.base.getSize();
    if ((_a = this.options.location.x) === "left") {
      this.base.setStyle('left', p.x - (s1.x + this.options.offset));
    } else if (_a === "right") {
      this.base.setStyle('left', p.x + (s.x + this.options.offset));
    } else if (_a === "center") {
      this.base.setStyle('left', p.x - s1.x / 2 + s.x / 2);
    }
    if ((_b = this.options.location.y) === "top") {
      return this.base.setStyle('top', p.y - (s.y + this.options.offset));
    } else if (_b === "bottom") {
      return this.base.setStyle('top', p.y + (s.y + this.options.offset));
    } else if (_b === "center") {
      return this.base.setStyle('top', p.y - s1.y / 2 + s.y / 2);
    }
  },
  hide: function() {
    return this.base.dispose();
  },
  show: function() {
    return document.getElement('body').grab(this.base);
  }
});
/*
---

name: Core.Slider

description: Slider element for other elements.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls]

provides: [Core.Slider, ResetSlider]

...
*/
ResetSlider = new Class({
  Extends: Slider,
  initialize: function(element, knob, options) {
    return this.parent(element, knob, options);
  },
  setRange: function(range) {
    this.min = $chk(range[0]) ? range[0] : 0;
    this.max = $chk(range[1]) ? range[1] : this.options.steps;
    this.range = this.max - this.min;
    this.steps = this.options.steps || this.full;
    this.stepSize = Math.abs(this.range) / this.steps;
    this.stepWidth = this.stepSize * this.full / Math.abs(this.range);
    return this.stepWidth;
  }
});
Core.Slider = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Controls],
  Delegates: {
    'slider': ['set', 'setRange']
  },
  options: {
    scrollBase: null,
    reset: false,
    steps: 0,
    range: [0, 0],
    mode: 'vertical',
    'class': GDotUI.Theme.Slider.barClass,
    knob: GDotUI.Theme.Slider.knobClass
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.base.addClass(this.options.mode);
    this.knob = (new Element('div')).addClass(this.options.knob);
    this.scrollBase = this.options.scrollBase;
    return this.base.grab(this.knob);
  },
  ready: function() {
    if (this.options.reset) {
      this.slider = new ResetSlider(this.base, this.knob, {
        mode: this.options.mode,
        steps: this.options.steps,
        range: this.options.range
      });
      this.slider.set(0);
    } else {
      this.slider = new Slider(this.base, this.knob, {
        mode: this.options.mode,
        range: this.options.range,
        steps: this.options.steps
      });
    }
    this.slider.addEvent('complete', (function(step) {
      return this.fireEvent('complete', step + '');
    }).bindWithEvent(this));
    this.slider.addEvent('change', (function(step) {
      var _a;
      typeof (step) === 'object' ? (step = 0) : null;
      this.fireEvent('change', step + '');
      return (typeof (_a = this.scrollBase) !== "undefined" && _a !== null) ? (this.scrollBase.scrollTop = (this.scrollBase.scrollHeight - this.scrollBase.getSize().y) / 100 * step) : null;
    }).bindWithEvent(this));
    return this.parent();
  }
});
/*
---

name: Core.Float

description: Core.Float is a "floating" panel, with controls. Think of it as a window, just more awesome.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Draggable, Interfaces.Restoreable, Core.Slider, Core.IconGroup]

provides: Core.Float

...
*/
Core.Float = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Draggable, Interfaces.Restoreable],
  Binds: ['resize', 'mouseEnter', 'mouseLeave', 'hide'],
  options: {
    classes: {
      'class': GDotUI.Theme.Float['class'],
      controls: GDotUI.Theme.Float.controls,
      content: GDotUI.Theme.Float.content,
      handle: GDotUI.Theme.Float.topHandle,
      bottom: GDotUI.Theme.Float.bottomHandle,
      active: GDotUI.Theme.Global.active,
      inactive: GDotUI.Theme.Global.inactive
    },
    iconOptions: GDotUI.Theme.Float.iconOptions,
    icons: {
      remove: GDotUI.Theme.Icons.remove,
      edit: GDotUI.Theme.Icons.edit
    },
    closeable: true,
    resizeable: false,
    editable: false,
    draggable: true,
    ghost: false
  },
  initialize: function(options) {
    this.showSilder = false;
    return this.parent(options);
  },
  ready: function() {
    this.base.adopt(this.controls);
    this.content.grab(this.contentElement);
    this.options.restoreable ? this.loadPosition() : this.base.position();
    if (this.scrollBase.getScrollSize().y > this.scrollBase.getSize().y) {
      if (!this.showSlider) {
        this.showSlider = true;
        this.mouseisover ? this.slider.show() : null;
      }
    }
    return this.parent();
  },
  create: function() {
    var _a;
    this.base.addClass(this.options.classes['class']);
    this.base.setStyle('position', 'fixed');
    this.base.setPosition({
      x: 0,
      y: 0
    });
    this.base.toggleClass(this.options.classes.inactive);
    this.controls = new Element('div', {
      'class': this.options.classes.controls
    });
    this.content = new Element('div', {
      'class': this.options.classes.content
    });
    this.handle = new Element('div', {
      'class': this.options.classes.handle
    });
    this.bottom = new Element('div', {
      'class': this.options.classes.bottom
    });
    this.base.adopt(this.handle, this.content);
    this.slider = new Core.Slider({
      scrollBase: this.content,
      range: [0, 100],
      steps: 100
    });
    this.slider.addEvent('complete', (function() {
      this.scrolling = false;
      return this.scrolling;
    }).bindWithEvent(this));
    this.slider.addEvent('change', (function() {
      this.scrolling = true;
      return this.scrolling;
    }).bindWithEvent(this));
    this.slider.hide();
    this.icons = new Core.IconGroup(this.options.iconOptions);
    this.controls.adopt(this.icons, this.slider);
    this.close = new Core.Icon({
      image: this.options.icons.remove
    });
    this.close.addEvent('invoked', (function() {
      return this.hide();
    }).bindWithEvent(this));
    this.edit = new Core.Icon({
      image: this.options.icons.edit
    });
    this.edit.addEvent('invoked', (function() {
      var _a, _b;
      if ((typeof (_b = this.contentElement) !== "undefined" && _b !== null)) {
        (typeof (_a = this.contentElement.toggleEdit) !== "undefined" && _a !== null) ? this.contentElement.toggleEdit() : null;
        return this.fireEvent('edit');
      }
    }).bindWithEvent(this));
    this.options.closeable ? this.icons.addIcon(this.close) : null;
    this.options.editable ? this.icons.addIcon(this.edit) : null;
    this.icons.hide();
    (typeof (_a = this.options.scrollBase) !== "undefined" && _a !== null) ? (this.scrollBase = this.options.scrollBase) : (this.scrollBase = this.content);
    this.scrollBase.setStyle('overflow', 'hidden');
    if (this.options.resizeable) {
      this.base.grab(this.bottom);
      this.sizeDrag = new Drag(this.scrollBase, {
        handle: this.bottom,
        modifiers: {
          x: '',
          y: 'height'
        }
      });
      this.sizeDrag.addEvent('drag', (function() {
        if (this.scrollBase.getScrollSize().y > this.scrollBase.getSize().y) {
          if (!this.showSlider) {
            this.showSlider = true;
            return this.mouseisover ? this.slider.show() : null;
          }
        } else {
          if (this.showSlider) {
            this.showSlider = false;
            return this.slider.hide();
          }
        }
      }).bindWithEvent(this));
    }
    this.base.addEvent('mouseenter', (function() {
      this.base.toggleClass(this.options.classes.active);
      this.base.toggleClass(this.options.classes.inactive);
      $clear(this.iconsTimout);
      $clear(this.sliderTimout);
      this.showSlider ? this.slider.show() : null;
      this.icons.show();
      this.mouseisover = true;
      return this.mouseisover;
    }).bindWithEvent(this));
    return this.base.addEvent('mouseleave', (function() {
      this.base.toggleClass(this.options.classes.active);
      this.base.toggleClass(this.options.classes.inactive);
      !this.scrolling ? this.showSlider ? (this.sliderTimout = this.slider.hide.delay(200, this.slider)) : null : null;
      this.iconsTimout = this.icons.hide.delay(200, this.icons);
      this.mouseisover = false;
      return this.mouseisover;
    }).bindWithEvent(this));
  },
  show: function() {
    document.getElement('body').grab(this.base);
    return this.saveState();
  },
  hide: function() {
    this.base.dispose();
    return this.saveState();
  },
  toggle: function(el) {
    return this.base.isVisible() ? this.hide(el) : this.show(el);
  },
  setContent: function(element) {
    this.contentElement = element;
    return this.contentElement;
  },
  center: function() {
    return this.base.position();
  }
});
/*
---

name: Core.Button

description: Basic button element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Enabled, Interfaces.Controls]

provides: Core.Button

...
*/
Core.Button = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Controls],
  options: {
    image: GDotUI.Theme.Button.defaultIcon,
    text: GDotUI.Theme.Button.defaultText,
    'class': GDotUI.Theme.Button['class']
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    delete this.base;
    this.base = new Element('button');
    this.base.addClass(this.options['class']).set('text', this.options.text);
    this.icon = new Core.Icon({
      image: this.options.image
    });
    return this.base.addEvent('click', (function(e) {
      return this.enabled ? this.fireEvent('invoked', [this, e]) : null;
    }).bindWithEvent(this));
  },
  ready: function() {
    this.base.grab(this.icon);
    return this.parent();
  }
});
/*
---

name: Core.Picker

description: Data picker class.

license: MIT-style license.

requires: [Core.Abstract]

provides: [Core.Picker, outerClick]

...
*/
(function() {
  var oldPrototypeStart;
  oldPrototypeStart = Drag.prototype.start;
  Drag.prototype.start = function() {
    window.fireEvent('outer');
    return oldPrototypeStart.run(arguments, this);
  };
  return Drag.prototype.start;
})();
Element.Events.outerClick = {
  base: 'mousedown',
  condition: function(event) {
    event.stopPropagation();
    return false;
  },
  onAdd: function(fn) {
    window.addEvent('click', fn);
    return window.addEvent('outer', fn);
  },
  onRemove: function(fn) {
    window.removeEvent('click', fn);
    return window.removeEvent('outer', fn);
  }
};
Core.Picker = new Class({
  Extends: Core.Abstract,
  Binds: ['show', 'hide'],
  options: {
    'class': GDotUI.Theme.Picker['class'],
    offset: GDotUI.Theme.Picker.offset,
    event: GDotUI.Theme.Picker.event,
    picking: GDotUI.Theme.Picker.picking
  },
  initialize: function(options) {
    this.parent(options);
    return this;
  },
  create: function() {
    this.base.addClass(this.options['class']);
    return this.base.setStyle('position', 'absolute');
  },
  ready: function() {
    var asize, offset, position, size, winscroll, winsize, x, xpos, y, ypos;
    !this.base.hasChild(this.contentElement) ? this.base.grab(this.contentElement) : null;
    winsize = window.getSize();
    winscroll = window.getScroll();
    asize = this.attachedTo.getSize();
    position = this.attachedTo.getPosition();
    size = this.base.getSize();
    offset = this.options.offset;
    x = '';
    y = '';
    if ((position.x - size.x - winscroll.x) < 0) {
      x = 'right';
      xpos = position.x + asize.x + offset;
    }
    if ((position.x + size.x + asize.x) > winsize.x) {
      x = 'left';
      xpos = position.x - size.x - offset;
    }
    if (!((position.x + size.x + asize.x) > winsize.x) && !((position.x - size.x) < 0)) {
      x = 'center';
      xpos = (position.x + asize.x / 2) - (size.x / 2);
    }
    if (position.y + size.y - winscroll.y > winsize.y) {
      y = 'up';
      ypos = position.y - size.y - offset;
    } else {
      y = 'down';
      x === 'center' ? (ypos = position.y + asize.y + offset) : (ypos = position.y);
    }
    return this.base.setStyles({
      'left': xpos,
      'top': ypos
    });
  },
  detach: function() {
    var _a, _b;
    (typeof (_a = this.contentElement) !== "undefined" && _a !== null) ? this.contentElement.removeEvents('change') : null;
    if ((typeof (_b = this.attachedTo) !== "undefined" && _b !== null)) {
      this.attachedTo.removeEvent(this.options.event, this.show);
      this.attachedTo = null;
      return this.fireEvent('detached');
    }
  },
  attach: function(input) {
    var _a, _b;
    (typeof (_a = this.attachedTo) !== "undefined" && _a !== null) ? this.detach() : null;
    input.addEvent(this.options.event, this.show);
    (typeof (_b = this.contentElement) !== "undefined" && _b !== null) ? this.contentElement.addEvent('change', (function(value) {
      this.attachedTo.set('value', value);
      return this.attachedTo.fireEvent('change', value);
    }).bindWithEvent(this)) : null;
    this.attachedTo = input;
    return this.attachedTo;
  },
  attachAndShow: function(el, e) {
    this.attach(el);
    return this.show(e);
  },
  show: function(e) {
    var _a, _b;
    document.getElement('body').grab(this.base);
    (typeof (_a = this.attachedTo) !== "undefined" && _a !== null) ? this.attachedTo.addClass(this.options.picking) : null;
    e.stop();
    (typeof (_b = this.contentElement) !== "undefined" && _b !== null) ? this.contentElement.fireEvent('show') : null;
    return this.base.addEvent('outerClick', this.hide.bindWithEvent(this));
  },
  hide: function(e) {
    var _a;
    if (this.base.isVisible() && !this.base.hasChild(e.target)) {
      if ((typeof (_a = this.attachedTo) !== "undefined" && _a !== null)) {
        this.attachedTo.removeClass(this.options.picking);
        this.detach();
      }
      return this.base.dispose();
    }
  },
  setContent: function(element) {
    this.contentElement = element;
    return this.contentElement;
  }
});
/*
---

name: Iterable.List

description: List element, with editing and sorting.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.List

...
*/
Iterable.List = new Class({
  Extends: Core.Abstract,
  options: {
    'class': GDotUI.Theme.List['class'],
    selected: GDotUI.Theme.List.selected
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.sortable = new Sortables(null);
    this.editing = false;
    this.items = [];
    return this.items;
  },
  removeItem: function(li) {
    li.removeEvents('invoked', 'edit', 'delete');
    return li.base.destroy();
  },
  removeAll: function() {
    this.selected = null;
    this.items.each((function(item) {
      console.log(item);
      return this.removeItem(item);
    }).bind(this));
    delete this.items;
    this.items = [];
    return this.items;
  },
  toggleEdit: function() {
    var bases;
    bases = this.items.map(function(item) {
      return item.base;
    });
    if (this.editing) {
      this.sortable.removeItems(bases);
      this.items.each(function(item) {
        return item.toggleEdit();
      });
      this.editing = false;
      return this.editing;
    } else {
      this.sortable.addItems(bases);
      this.items.each(function(item) {
        return item.toggleEdit();
      });
      this.editing = true;
      return this.editing;
    }
  },
  getItemFromTitle: function(title) {
    var filtered;
    filtered = this.items.filter(function(item) {
      return item.title.get('text') === String(title) ? true : false;
    });
    return filtered[0];
  },
  select: function(item) {
    var _a;
    if (this.selected !== item) {
      (typeof (_a = this.selected) !== "undefined" && _a !== null) ? this.selected.base.removeClass(this.options.selected) : null;
      this.selected = item;
      this.selected.base.addClass(this.options.selected);
      return this.fireEvent('select', item);
    }
  },
  addItem: function(li) {
    this.items.push(li);
    this.base.grab(li);
    li.addEvent('select', (function(item) {
      return this.select(item);
    }).bindWithEvent(this));
    li.addEvent('invoked', (function(item) {
      return this.fireEvent('invoked', arguments);
    }).bindWithEvent(this));
    li.addEvent('edit', (function() {
      return this.fireEvent('edit', arguments);
    }).bindWithEvent(this));
    return li.addEvent('delete', (function() {
      return this.fireEvent('delete', arguments);
    }).bindWithEvent(this));
  }
});
/*
---

name: Core.Slot

description: Generic icon element.

license: MIT-style license.

requires: [Core.Abstract, Iterable.List]

provides: Core.Slot

...
*/
Core.Slot = new Class({
  Extends: Core.Abstract,
  Binds: ['check', 'complete'],
  Delegates: {
    'list': ['addItem', 'removeAll', 'select']
  },
  options: {
    'class': GDotUI.Theme.Slot['class']
  },
  initilaize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.overlay = new Element('div', {
      'text': ' '
    });
    this.overlay.addClass('over');
    this.list = new Iterable.List();
    this.list.addEvent('select', (function(item) {
      this.update();
      return this.fireEvent('change', item);
    }).bindWithEvent(this));
    return this.base.adopt(this.list.base, this.overlay);
  },
  check: function(el, e) {
    var lastDistance, lastOne;
    this.dragging = true;
    lastDistance = 1000;
    lastOne = null;
    return this.list.items.each((function(item, i) {
      var distance;
      distance = -item.base.getPosition(this.base).y + this.base.getSize().y / 2;
      return distance < lastDistance && distance > 0 && distance < this.base.getSize().y / 2 ? this.list.select(item) : null;
    }).bind(this));
  },
  ready: function() {
    this.parent();
    this.base.setStyle('overflow', 'hidden');
    this.base.setStyle('position', 'relative');
    this.list.base.setStyle('position', 'absolute');
    this.list.base.setStyle('top', '0');
    this.base.setStyle('width', this.list.base.getSize().x);
    this.overlay.setStyle('width', this.base.getSize().x);
    this.overlay.addEvent('mousewheel', (function(e) {
      var _a, index;
      e.stop();
      (typeof (_a = this.list.selected) !== "undefined" && _a !== null) ? (index = this.list.items.indexOf(this.list.selected)) : e.wheel === 1 ? (index = 0) : (index = 1);
      index + e.wheel >= 0 && index + e.wheel < this.list.items.length ? this.list.select(this.list.items[index + e.wheel]) : null;
      index + e.wheel < 0 ? this.list.select(this.list.items[this.list.items.length - 1]) : null;
      return index + e.wheel > this.list.items.length - 1 ? this.list.select(this.list.items[0]) : null;
    }).bindWithEvent(this));
    this.drag = new Drag(this.list.base, {
      modifiers: {
        x: '',
        y: 'top'
      },
      handle: this.overlay
    });
    this.drag.addEvent('drag', this.check);
    this.drag.addEvent('beforeStart', (function() {
      return this.list.base.setStyle('-webkit-transition-duration', '0s');
    }).bindWithEvent(this));
    return this.drag.addEvent('complete', (function() {
      this.dragging = false;
      return this.update();
    }).bindWithEvent(this));
  },
  update: function() {
    var _a;
    if (!this.dragging) {
      this.list.base.setStyle('-webkit-transition-duration', '0.3s');
      return (typeof (_a = this.list.selected) !== "undefined" && _a !== null) ? this.list.base.setStyle('top', -this.list.selected.base.getPosition(this.list.base).y + this.base.getSize().y / 2 - this.list.selected.base.getSize().y / 2) : null;
    }
  }
});
/*
---

name: Data.Abstract

description: "Abstract" base class for data elements.

license: MIT-style license.

requires:

provides: Data.Abstract

...
*/
Data.Abstract = new Class({
  Implements: [Events, Options],
  options: {},
  initialize: function(options) {
    var fn;
    this.setOptions(options);
    this.base = new Element('div');
    fn = this.ready.bindWithEvent(this);
    this.base.store('fn', fn);
    this.base.addEventListener('DOMNodeInsertedIntoDocument', fn, false);
    this.create();
    return this;
  },
  create: function() {  },
  ready: function() {
    this.base.removeEventListener('DOMNodeInsertedIntoDocument', this.base.retrieve('fn'), false);
    return this.base.eliminate('fn');
  },
  toElement: function() {
    return this.base;
  },
  setValue: function() {  },
  getValue: function() {
    return this.value;
  }
});
/*
---

name: Data.Text

description: Text data element.

license: MIT-style license.

requires: Data.Abstract

provides: Data.Text

...
*/
Data.Text = new Class({
  Extends: Data.Abstract,
  options: {
    'class': GDotUI.Theme.Text['class']
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.text = new Element('textarea');
    this.base.grab(this.text);
    this.addEvent('show', (function() {
      return this.text.focus();
    }).bindWithEvent(this));
    return this.text.addEvent('keyup', (function(e) {
      return this.fireEvent('change', this.text.get('value'));
    }).bindWithEvent(this));
  },
  getValue: function() {
    return this.text.get('value');
  },
  setValue: function(text) {
    return this.text.set('value', text);
  }
});
/*
---

name: Data.Number

description: Number data element.

license: MIT-style license.

requires: [Data.Abstract, Core.Slider]

provides: Data.Number

...
*/
Data.Number = new Class({
  Extends: Data.Abstract,
  options: {
    'class': GDotUI.Theme.Number['class'],
    range: GDotUI.Theme.Number.range,
    reset: GDotUI.Theme.Number.reset,
    steps: GDotUI.Theme.Number.steps
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.text = new Element('input', {
      'type': 'text'
    });
    this.slider = new Core.Slider({
      reset: this.options.reset,
      range: this.options.range,
      steps: this.options.steps,
      mode: 'horizontal'
    });
    return this.slider;
  },
  ready: function() {
    this.justSet = false;
    this.slider.knob.grab(this.text);
    this.base.adopt(this.slider);
    this.slider.knob.addEvent('click', (function() {
      return this.text.focus();
    }).bindWithEvent(this));
    this.slider.addEvent('complete', (function(step) {
      this.options.reset ? this.slider.setRange([step - this.options.steps / 2, Number(step) + this.options.steps / 2]) : null;
      return this.slider.set(step);
    }).bindWithEvent(this));
    this.slider.addEvent('change', (function(step) {
      typeof (step) === 'object' ? this.text.set('value', 0) : this.text.set('value', step);
      return !this.justSet ? this.fireEvent('change', step) : (this.justSet = false);
    }).bindWithEvent(this));
    this.text.addEvent('change', (function() {
      var step;
      step = Number(this.text.get('value'));
      this.options.reset ? this.slider.setRange([step - this.options.steps / 2, Number(step) + this.options.steps / 2]) : null;
      return this.slider.set(step);
    }).bindWithEvent(this));
    this.text.addEvent('mousewheel', (function(e) {
      return this.slider.set(Number(this.text.get('value')) + e.wheel);
    }).bindWithEvent(this));
    return this.parent();
  },
  getValue: function() {
    return this.slider.slider.step;
  },
  setValue: function(step) {
    this.justSet = true;
    this.options.reset ? this.slider.setRange([step - this.options.steps / 2, Number(step) + this.options.steps / 2]) : null;
    return this.slider.set(step);
  }
});
/*
---

name: Data.Color

description: Color data element. ( color picker )

license: MIT-style license.

requires: Data.Abstract

provides: Data.Color

...
*/
Data.Color = new Class({
  Extends: Data.Abstract,
  Binds: ['change'],
  options: {
    'class': GDotUI.Theme.Color['class'],
    sb: GDotUI.Theme.Color.sb,
    hue: GDotUI.Theme.Color.hue,
    wrapper: GDotUI.Theme.Color.wrapper,
    white: GDotUI.Theme.Color.white,
    black: GDotUI.Theme.Color.black,
    format: GDotUI.Theme.Color.format
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.wrapper = new Element('div').addClass(this.options.wrapper);
    this.white = new Element('div').addClass(this.options.white);
    this.black = new Element('div').addClass(this.options.black);
    this.color = new Element('div').addClass(this.options.sb);
    this.xyKnob = new Element('div').set('id', 'xyknob');
    this.xyKnob.setStyles({
      'position': 'absolute',
      'top': 0,
      'left': 0
    });
    this.wrapper.adopt(this.color, this.white, this.black, this.xyKnob);
    this.colorData = new Data.Color.SlotControls();
    return this.base.adopt(this.wrapper, this.colorData);
  },
  ready: function() {
    var _a, sbSize;
    sbSize = this.color.getSize();
    this.wrapper.setStyles({
      width: sbSize.x,
      height: sbSize.y,
      'position': 'relative',
      'float': 'left'
    });
    $$(this.white, this.black, this.color).setStyles({
      'position': 'absolute',
      'top': 0,
      'left': 0,
      'width': 'inherit',
      'height': 'inherit'
    });
    this.xy = new Field(this.black, this.xyKnob, {
      setOnClick: true,
      x: [0, 1, 100],
      y: [0, 1, 100]
    });
    this.hue = this.colorData.hue;
    this.saturation = this.colorData.saturation;
    this.lightness = this.colorData.lightness;
    this.hue.addEvent('change', (function(step) {
      var colr;
      typeof (step) === "object" ? (step = 0) : null;
      this.bgColor.setHue(Number(step));
      colr = new $HSB(step, 100, 100);
      this.color.setStyle('background-color', colr);
      return this.setColor();
    }).bindWithEvent(this));
    this.saturation.addEvent('change', (function(step) {
      return this.xy.set({
        x: step,
        y: this.xy.get().y
      });
    }).bindWithEvent(this));
    this.lightness.addEvent('change', (function(step) {
      return this.xy.set({
        x: this.xy.get().x,
        y: 100 - step
      });
    }).bindWithEvent(this));
    this.xy.addEvent('tick', this.change);
    this.xy.addEvent('change', this.change);
    return this.setValue((typeof (_a = this.value) !== "undefined" && _a !== null) ? this.value : '#fff');
  },
  setValue: function(hex) {
    var colr;
    (typeof hex !== "undefined" && hex !== null) ? (this.bgColor = new Color(hex)) : null;
    this.hue.setValue(this.bgColor.hsb[0]);
    this.saturation.setValue(this.bgColor.hsb[1]);
    this.lightness.setValue(this.bgColor.hsb[2]);
    this.xy.set({
      x: this.bgColor.hsb[1],
      y: 100 - this.bgColor.hsb[2]
    });
    colr = new $HSB(this.bgColor.hsb[0], 100, 100);
    this.color.setStyle('background-color', colr);
    return this.setColor();
  },
  setColor: function() {
    var _a, ret;
    this.finalColor = this.bgColor.setSaturation(this.saturation.getValue()).setBrightness(this.lightness.getValue()).setHue(this.hue.getValue());
    ret = '';
    if ((_a = this.options.format) === "hsl") {
      ret = "hsl(" + (this.finalColor.hsb[0]) + ", " + (this.finalColor.hsb[1]) + "%, " + (this.finalColor.hsb[2]) + "%)";
    } else if (_a === "rgb") {
      ret = "rgb(" + (this.finalColor.rgb[0]) + ", " + (this.finalColor.rgb[1]) + ", " + (this.finalColor.rgb[2]) + ")";
    } else {
      ret = "#" + this.finalColor.hex.slice(1, 7);
    }
    this.fireEvent('change', {
      color: this.finalColor
    });
    this.value = this.finalColor;
    return this.value;
  },
  getValue: function() {
    var _a, ret;
    ret = '';
    if ((_a = this.options.format) === "hsl") {
      ret = "hsl(" + (this.finalColor.hsb[0]) + ", " + (this.finalColor.hsb[1]) + "%, " + (this.finalColor.hsb[2]) + "%)";
    } else if (_a === "rgb") {
      ret = "rgb(" + (this.finalColor.rgb[0]) + ", " + (this.finalColor.rgb[1]) + ", " + (this.finalColor.rgb[2]) + ")";
    } else {
      ret = "#" + this.finalColor.hex.slice(1, 7);
    }
    return ret;
  },
  change: function(pos) {
    this.saturation.setValue(pos.x);
    this.lightness.setValue(100 - pos.y);
    return this.setColor();
  }
});
Data.Color.SlotControls = new Class({
  Extends: Data.Abstract,
  options: {
    'class': GDotUI.Theme.Color.controls['class']
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.hue = new Data.Number({
      range: [0, 360],
      reset: false,
      steps: [360]
    });
    this.hue.addEvent('change', (function(value) {
      return this.saturation.slider.base.setStyle('background-color', new $HSB(value, 100, 100));
    }).bindWithEvent(this));
    this.saturation = new Data.Number({
      range: [0, 100],
      reset: false,
      steps: [100]
    });
    this.lightness = new Data.Number({
      range: [0, 100],
      reset: false,
      steps: [100]
    });
    return this.lightness;
  },
  ready: function() {
    return this.base.adopt(this.hue, this.saturation, this.lightness);
  }
});
/*
---

name: Data.Date

description: Date picker element with Core.Slot-s

license: MIT-style license.

requires: [Data.Abstract, Core.Slot]

provides: Data.Date

...
*/
Data.Date = new Class({
  Extends: Data.Abstract,
  options: {
    'class': GDotUI.Theme.Date['class'],
    format: GDotUI.Theme.Date.format,
    yearFrom: GDotUI.Theme.Date.yearFrom
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    var i, item;
    this.base.addClass(this.options['class']);
    this.days = new Core.Slot();
    this.month = new Core.Slot();
    this.years = new Core.Slot();
    this.years.addEvent('change', (function(item) {
      this.date.setYear(item.value);
      return this.setValue();
    }).bindWithEvent(this));
    this.month.addEvent('change', (function(item) {
      this.date.setMonth(item.value);
      return this.setValue();
    }).bindWithEvent(this));
    this.days.addEvent('change', (function(item) {
      this.date.setDate(item.value);
      return this.setValue();
    }).bindWithEvent(this));
    i = 0;
    while (i < 30) {
      item = new Iterable.ListItem({
        title: i + 1
      });
      item.value = i + 1;
      this.days.addItem(item);
      i++;
    }
    i = 0;
    while (i < 12) {
      item = new Iterable.ListItem({
        title: i + 1
      });
      item.value = i;
      this.month.addItem(item);
      i++;
    }
    i = this.options.yearFrom;
    while (i <= new Date().getFullYear()) {
      item = new Iterable.ListItem({
        title: i
      });
      item.value = i;
      this.years.addItem(item);
      i++;
    }
    return this.base.adopt(this.years, this.month, this.days);
  },
  ready: function() {
    var _a;
    return !(typeof (_a = this.date) !== "undefined" && _a !== null) ? this.setValue(new Date()) : null;
  },
  getValue: function() {
    return this.date.format(this.options.format);
  },
  setValue: function(date) {
    (typeof date !== "undefined" && date !== null) ? (this.date = date) : null;
    this.update();
    return this.fireEvent('change', this.date);
  },
  update: function() {
    var cdays, i, item, listlength;
    cdays = this.date.get('lastdayofmonth');
    listlength = this.days.list.items.length;
    if (cdays > listlength) {
      i = listlength + 1;
      while (i <= cdays) {
        item = new Iterable.ListItem({
          title: i
        });
        item.value = i;
        this.days.addItem(item);
        i++;
      }
    } else if (cdays < listlength) {
      i = listlength;
      while (i > cdays) {
        this.days.list.removeItem(this.days.list.items[i - 1]);
        i--;
      }
    }
    this.days.select(this.days.list.items[this.date.getDate() - 1]);
    this.month.select(this.month.list.items[this.date.getMonth()]);
    return this.years.select(this.years.list.getItemFromTitle(this.date.getFullYear()));
  }
});
/*
---

name: Data.Time

description: Time picker element with Core.Slot-s

license: MIT-style license.

requires: Data.Abstract

provides: Data.Time

...
*/
Data.Time = new Class({
  Extends: Data.Abstract,
  options: {
    'class': GDotUI.Theme.Date.Time['class'],
    format: GDotUI.Theme.Date.Time.format
  },
  initilaize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.hourList = new Core.Slot();
    this.minuteList = new Core.Slot();
    this.hourList.addEvent('change', (function(item) {
      this.time.setHours(item.value);
      return this.setValue();
    }).bindWithEvent(this));
    return this.minuteList.addEvent('change', (function(item) {
      this.time.setMinutes(item.value);
      return this.setValue();
    }).bindWithEvent(this));
  },
  getValue: function() {
    return this.time.format(this.options.format);
  },
  setValue: function(date) {
    (typeof date !== "undefined" && date !== null) ? (this.time = date) : null;
    this.hourList.select(this.hourList.list.items[this.time.getHours()]);
    this.minuteList.select(this.minuteList.list.items[this.time.getMinutes()]);
    return this.fireEvent('change', this.time.format(this.options.format));
  },
  ready: function() {
    var i, item;
    i = 0;
    while (i < 24) {
      item = new Iterable.ListItem({
        title: i
      });
      item.value = i;
      this.hourList.addItem(item);
      i++;
    }
    i = 0;
    while (i < 60) {
      item = new Iterable.ListItem({
        title: i < 10 ? '0' + i : i
      });
      item.value = i;
      this.minuteList.addItem(item);
      i++;
    }
    this.base.adopt(this.hourList, this.minuteList);
    this.setValue(new Date());
    return this.parent();
  }
});
/*
---

name: Data.DateTime

description:  Date & Time picker element with Core.Slot-s

license: MIT-style license.

requires: [Data.Abstract, Data.Date, Data.Time]

provides: Data.DateTime

...
*/
Data.DateTime = new Class({
  Extends: Data.Abstract,
  options: {
    'class': GDotUI.Theme.Date.DateTime['class'],
    format: GDotUI.Theme.Date.DateTime.format
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.datea = new Data.Date();
    this.time = new Data.Time();
    return this.time;
  },
  ready: function() {
    this.base.adopt(this.datea, this.time);
    this.setValue(new Date());
    this.datea.addEvent('change', (function() {
      this.date.setYear(this.datea.date.getFullYear());
      this.date.setMonth(this.datea.date.getMonth());
      this.date.setDate(this.datea.date.getDate());
      return this.fireEvent('change', this.date.format(this.options.format));
    }).bindWithEvent(this));
    this.time.addEvent('change', (function() {
      this.date.setHours(this.time.time.getHours());
      this.date.setMinutes(this.time.time.getMinutes());
      return this.fireEvent('change', this.date.format(this.options.format));
    }).bindWithEvent(this));
    return this.parent();
  },
  getValue: function() {
    return this.date.format(this.options.format);
  },
  setValue: function(date) {
    (typeof date !== "undefined" && date !== null) ? (this.date = date) : null;
    this.datea.setValue(this.date);
    this.time.setValue(this.date);
    return this.fireEvent('change', this.date.format(this.options.format));
  }
});
/*
---

name: Data.Table

description: Text data element.

requires: Data.Abstract

provides: Data.Table

...
*/
checkForKey = function(key, hash, i) {
  var _a, _b;
  !(typeof i !== "undefined" && i !== null) ? (i = 0) : null;
  return !(typeof (_a = hash[key]) !== "undefined" && _a !== null) ? key : !(typeof (_b = hash[key + i]) !== "undefined" && _b !== null) ? key + i : checkForKey(key, hash, i + 1);
};
Data.Table = new Class({
  Extends: Data.Abstract,
  Binds: ['update'],
  options: {
    columns: 1,
    'class': GDotUI.Theme.Table['class']
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.table = new Element('table', {
      cellspacing: 0,
      cellpadding: 0
    });
    this.base.grab(this.table);
    this.rows = [];
    this.columns = this.options.columns;
    this.header = new Data.TableRow({
      columns: this.columns
    });
    this.header.addEvent('next', (function() {
      this.addCloumn('');
      return this.header.cells.getLast().editStart();
    }).bindWithEvent(this));
    this.header.addEvent('editEnd', (function() {
      this.fireEvent('change', this.getData());
      return !this.header.cells.getLast().editing ? this.header.cells.getLast().getValue() === '' ? this.removeLast() : null : null;
    }).bindWithEvent(this));
    this.table.grab(this.header);
    this.addRow(this.columns);
    return this;
  },
  ready: function() {  },
  addCloumn: function(name) {
    this.columns++;
    this.header.add(name);
    return this.rows.each(function(item) {
      return item.add('');
    });
  },
  removeLast: function() {
    this.header.removeLast();
    this.columns--;
    return this.rows.each(function(item) {
      return item.removeLast();
    });
  },
  addRow: function(columns) {
    var row;
    row = new Data.TableRow({
      columns: columns
    });
    row.addEvent('editEnd', this.update);
    row.addEvent('next', (function(row) {
      var index;
      index = this.rows.indexOf(row);
      return index !== this.rows.length - 1 ? this.rows[index + 1].cells[0].editStart() : null;
    }).bindWithEvent(this));
    this.rows.push(row);
    return this.table.grab(row);
  },
  removeRow: function(row) {
    row.removeEvents('editEnd');
    row.removeEvents('next');
    row.removeAll();
    this.rows.erase(row);
    row.base.destroy();
    return delete row;
  },
  removeAll: function(addColumn) {
    !(typeof addColumn !== "undefined" && addColumn !== null) ? (addColumn = true) : null;
    this.header.removeAll();
    (this.rows.filter(function() {
      return true;
    })).each((function(row) {
      return this.removeRow(row);
    }).bind(this));
    this.columns = 0;
    if (addColumn) {
      this.addCloumn();
      return this.addRow(this.columns);
    }
  },
  update: function() {
    var length, longest, rowsToRemove;
    length = this.rows.length - 1;
    longest = 0;
    rowsToRemove = [];
    this.rows.each((function(row, i) {
      var empty;
      empty = row.empty();
      empty && i !== 0 && i !== length ? rowsToRemove.push(row) : null;
      return i === length && !empty ? this.addRow(this.columns) : null;
    }).bind(this));
    rowsToRemove.each((function(item) {
      return this.removeRow(item);
    }).bind(this));
    return this.fireEvent('change', this.getData());
  },
  getData: function() {
    var headers, ret;
    ret = {};
    headers = [];
    this.header.cells.each(function(item) {
      var value;
      value = item.getValue();
      ret[checkForKey(value, ret)] = [];
      return headers.push(ret[value]);
    });
    this.rows.each((function(row) {
      return !row.empty() ? row.getValue().each(function(item, i) {
        return headers[i].push(item);
      }) : null;
    }).bind(this));
    return ret;
  },
  getValue: function() {
    return this.getData();
  },
  setValue: function(obj) {
    var j, rowa, self;
    this.removeAll(false);
    console.log(this);
    rowa = [];
    j = 0;
    self = this;
    new Hash(obj).each(function(value, key) {
      self.addCloumn(key);
      value.each(function(item, i) {
        var _a;
        !(typeof (_a = rowa[i]) !== "undefined" && _a !== null) ? (rowa[i] = []) : null;
        rowa[i][j] = item;
        return i++;
      });
      return j++;
    });
    rowa.each(function(item, i) {
      self.addRow(self.columns);
      return self.rows[i].setValue(item);
    });
    return this;
  }
});
Data.TableRow = new Class({
  Extends: Data.Abstract,
  Delegates: {
    base: ['getChildren']
  },
  options: {
    columns: 1,
    'class': ''
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    var _a, i;
    delete this.base;
    this.base = new Element('tr');
    this.base.addClass(this.options['class']);
    this.cells = [];
    i = 0;
    _a = [];
    while (i < this.options.columns) {
      _a.push((function() {
        this.add('');
        return i++;
      }).call(this));
    }
    return _a;
  },
  add: function(value) {
    var cell;
    cell = new Data.TableCell({
      value: value
    });
    cell.addEvent('editEnd', (function() {
      return this.fireEvent('editEnd');
    }).bindWithEvent(this));
    cell.addEvent('next', (function(cell) {
      var index;
      index = this.cells.indexOf(cell);
      return index === this.cells.length - 1 ? this.fireEvent('next', this) : this.cells[index + 1].editStart();
    }).bindWithEvent(this));
    this.cells.push(cell);
    return this.base.grab(cell);
  },
  empty: function() {
    var filtered;
    filtered = this.cells.filter(function(item) {
      return item.getValue() !== '' ? true : false;
    });
    return filtered.length > 0 ? false : true;
  },
  removeLast: function() {
    return this.remove(this.cells.getLast());
  },
  remove: function(cell, remove) {
    cell.removeEvents('editEnd');
    cell.removeEvents('next');
    this.cells.erase(cell);
    cell.base.destroy();
    return delete cell;
  },
  removeAll: function() {
    return (this.cells.filter(function() {
      return true;
    })).each((function(cell) {
      return this.remove(cell);
    }).bind(this));
  },
  getValue: function() {
    return this.cells.map(function(cell) {
      return cell.getValue();
    });
  },
  setValue: function(value) {
    return this.cells.each(function(item, i) {
      return item.setValue(value[i]);
    });
  }
});
Data.TableCell = new Class({
  Extends: Data.Abstract,
  Binds: ['editStart', 'editEnd'],
  options: {
    editable: true,
    value: ''
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    delete this.base;
    this.base = new Element('td', {
      text: this.options.value
    });
    this.value = this.options.value;
    return this.options.editable ? this.base.addEvent('click', this.editStart) : null;
  },
  editStart: function() {
    var size;
    if (!this.editing) {
      this.editing = true;
      this.input = new Element('input', {
        type: 'text',
        value: this.value
      });
      this.base.set('html', '');
      this.base.grab(this.input);
      this.input.addEvent('change', (function() {
        return this.setValue(this.input.get('value'));
      }).bindWithEvent(this));
      this.input.addEvent('keydown', (function(e) {
        e.key === 'enter' ? this.input.blur() : null;
        if (e.key === 'tab') {
          e.stop();
          return this.fireEvent('next', this);
        }
      }).bindWithEvent(this));
      size = this.base.getSize();
      this.input.setStyles({
        width: size.x + "px !important",
        height: size.y + "px !important"
      });
      this.input.focus();
      return this.input.addEvent('blur', this.editEnd);
    }
  },
  editEnd: function(e) {
    this.editing ? (this.editing = false) : null;
    this.setValue(this.input.get('value'));
    this.input.removeEvents(['change', 'keydown']);
    this.input.destroy();
    delete this.input;
    return this.fireEvent('editEnd');
  },
  setValue: function(value) {
    this.value = value;
    return !this.editing ? this.base.set('text', this.value) : null;
  },
  getValue: function() {
    return this.base.get('text');
  }
});
/*
---

name: Data.Select

description: Color data element. ( color picker )

license: MIT-style license.

requires: Data.Abstract

provides: Data.Select

...
*/
Data.Select = new Class({
  Extends: Data.Abstract,
  options: {
    'class': GDotUI.Theme.Select['class'],
    list: {}
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.select = new Element('select');
    this.base.grab(this.select);
    new Hash(this.options.list).each((function(value, key) {
      var option;
      option = new Element('option');
      option.set('value', value);
      option.set('text', key);
      return this.select.grab(option);
    }).bind(this));
    return this.select.addEvent('change', (function() {
      this.value = this.select.get('value');
      return this.fireEvent('change', this.value);
    }).bindWithEvent(this));
  },
  setList: function(list) {
    this.select.getElements("option").destroy();
    console.log(list);
    return new Hash(list).each((function(value, key) {
      var option;
      option = new Element('option');
      option.set('value', value);
      option.set('text', key);
      return this.select.grab(option);
    }).bind(this));
  },
  setValue: function(value) {
    var _a, selected;
    selected = this.select.getElements("option[value=" + value + "]");
    if ((typeof (_a = selected[0]) !== "undefined" && _a !== null)) {
      this.select.getElements("option").set('selected', null);
      selected.set('selected', true);
      this.value = value;
      return this.value;
    }
  },
  getValue: function() {
    var _a;
    !(typeof (_a = this.value) !== "undefined" && _a !== null) ? (this.value = this.select.get('value')) : null;
    return this.value;
  }
});
/*
---

name: Data.Unit

description: Color data element. ( color picker )

license: MIT-style license.

requires: Data.Abstract

provides: Data.Unit

...
*/
Data.Unit = new Class({
  Extends: Data.Abstract,
  options: {
    'class': GDotUI.Theme.Unit['class']
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.number = new Data.Number({
      range: [-100, 100],
      reset: true,
      steps: [200]
    });
    this.sel = new Data.Select({
      list: {
        px: "px",
        '%': "%",
        em: "em"
      }
    });
    this.number.addEvent('change', (function(value) {
      this.value = value;
      return this.fireEvent('change', String(this.value) + this.sel.value);
    }).bindWithEvent(this));
    this.sel.addEvent('change', (function() {
      return this.fireEvent('change', String(this.value) + this.sel.value);
    }).bindWithEvent(this));
    return this.base.adopt(this.number, this.sel);
  },
  setValue: function(value) {
    var match, unit;
    if (typeof value === 'string') {
      match = value.match(/(-?\d*)(.*)/);
      value = match[1];
      unit = match[2];
      this.sel.setValue(unit);
    }
    return this.number.setValue(value);
  },
  getValue: function() {
    return String(this.value) + this.sel.value;
  }
});
/*
---

name: Data.List

description: Text data element.

requires: Data.Abstract

provides: Data.List

...
*/
Data.List = new Class({
  Extends: Data.Abstract,
  Binds: ['update'],
  options: {
    'class': GDotUI.Theme.DataList['class']
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.table = new Element('table', {
      cellspacing: 0,
      cellpadding: 0
    });
    this.base.grab(this.table);
    this.cells = [];
    return this.add('');
  },
  update: function() {
    this.cells.each((function(item) {
      return item.getValue() === '' ? this.remove(item) : null;
    }).bind(this));
    this.cells.length === 0 ? this.add('') : null;
    this.cells.getLast().getValue() !== '' ? this.add('') : null;
    return this.fireEvent('change', {
      value: this.getValue()
    });
  },
  add: function(value) {
    var cell, tr;
    cell = new Data.TableCell({
      value: value
    });
    cell.addEvent('editEnd', this.update);
    this.cells.push(cell);
    tr = new Element('tr');
    this.table.grab(tr);
    return tr.grab(cell);
  },
  remove: function(cell, remove) {
    cell.removeEvents('editEnd');
    this.cells.erase(cell);
    cell.base.getParent('tr').destroy();
    cell.base.destroy();
    return delete cell;
  },
  removeAll: function() {
    return (this.cells.filter(function() {
      return true;
    })).each((function(cell) {
      return this.remove(cell);
    }).bind(this));
  },
  getValue: function() {
    var map;
    map = this.cells.map(function(cell) {
      return cell.getValue();
    });
    map.splice(this.cells.length - 1, 1);
    return map;
  },
  setValue: function(value) {
    var self;
    this.removeAll();
    self = this;
    return value.each(function(item) {
      return self.add(item);
    });
  }
});
/*
---

name: Iterable.ListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

...
*/
Element.implement({
  toggleTransition: function() {
    return this.handles.base.setStyle('-webkit-transition-duration', this.handles.base.retrieve('transition-dur'));
  }
});
Iterable.ListItem = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Draggable, Interfaces.Enabled],
  options: {
    classes: {
      'class': GDotUI.Theme.ListItem['class'],
      title: GDotUI.Theme.ListItem.title,
      subtitle: GDotUI.Theme.ListItem.subTitle,
      handle: GDotUI.Theme.ListItem.handle
    },
    icons: {
      remove: GDotUI.Theme.Icons.remove,
      handle: GDotUI.Theme.Icons.handleVertical
    },
    offset: GDotUI.Theme.ListItem.offset,
    title: '',
    subtitle: '',
    draggable: true,
    ghost: true,
    removeClasses: '.' + GDotUI.Theme.Icon['class'],
    invokeEvent: 'click',
    selectEvent: 'click'
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options.classes['class']).setStyle('position', 'relative');
    this.remove = new Core.Icon({
      image: this.options.icons.remove
    });
    this.handles = new Core.Icon({
      image: this.options.icons.handle
    });
    this.handles.base.addClass(this.options.classes.handle);
    $$(this.remove.base, this.handles.base).setStyle('position', 'absolute');
    this.title = new Element('div').addClass(this.options.classes.title).set('text', this.options.title);
    this.subtitle = new Element('div').addClass(this.options.classes.subtitle).set('text', this.options.subtitle);
    this.base.adopt(this.title, this.subtitle, this.remove, this.handles);
    this.base.addEvent(this.options.selectEvent, (function() {
      return this.fireEvent('select', this);
    }).bindWithEvent(this));
    this.base.addEvent(this.options.invokeEvent, (function() {
      return this.enabled && !this.options.draggable ? this.fireEvent('invoked', this) : null;
    }).bindWithEvent(this));
    this.addEvent('dropped', (function(el, drop, e) {
      return this.fireEvent('invoked', [this, e]);
    }).bindWithEvent(this));
    return this.base.addEvent('dblclick', (function() {
      return this.enabled ? this.editing ? this.fireEvent('edit', this) : null : null;
    }).bindWithEvent(this));
  },
  toggleEdit: function() {
    if (this.editing) {
      this.options.draggable ? this.drag.attach() : null;
      this.remove.base.setStyle('right', -this.remove.base.getSize().x);
      this.handles.base.setStyle('left', -this.handles.base.getSize().x);
      this.base.setStyle('padding-left', this.base.retrieve('padding-left:old'));
      this.base.setStyle('padding-right', this.base.retrieve('padding-right:old'));
      this.editing = false;
      return this.editing;
    } else {
      this.options.draggable ? this.drag.detach() : null;
      this.remove.base.setStyle('right', this.options.offset);
      this.handles.base.setStyle('left', this.options.offset);
      this.base.store('padding-left:old', this.base.getStyle('padding-left'));
      this.base.store('padding-right:old', this.base.getStyle('padding-left'));
      this.base.setStyle('padding-left', Number(this.base.getStyle('padding-left').slice(0, -2)) + this.handles.base.getSize().x);
      this.base.setStyle('padding-right', Number(this.base.getStyle('padding-right').slice(0, -2)) + this.remove.base.getSize().x);
      this.editing = true;
      return this.editing;
    }
  },
  ready: function() {
    var baseSize, handSize, remSize;
    if (!this.editing) {
      handSize = this.handles.base.getSize();
      remSize = this.remove.base.getSize();
      baseSize = this.base.getSize();
      this.remove.base.setStyles({
        "right": -remSize.x,
        "top": (baseSize.y - remSize.y) / 2
      });
      this.handles.base.setStyles({
        "left": -handSize.x,
        "top": (baseSize.y - handSize.y) / 2
      });
      this.parent();
      return this.options.draggable ? this.drag.addEvent('beforeStart', (function() {
        return this.fireEvent('select', this);
      }).bindWithEvent(this)) : null;
    }
  }
});
/*
---

name: Pickers

description: Pickers for Data classes.

license: MIT-style license.

requires: [Core.Picker, Data.Color, Data.Number, Data.Text, Data.Date, Data.Time, Data.DateTime ]

provides: [Pickers.Base, Pickers.Color, Pickers.Number, Pickers.Text, Pickers.Time, Pickers.Date, Pickers.DateTime ]

...
*/
Pickers.Base = new Class({
  Implements: Options,
  Delegates: {
    picker: ['attach', 'detach', 'attachAndShow'],
    data: ['setValue', 'getValue']
  },
  options: {
    type: ''
  },
  initialize: function(options) {
    this.setOptions(options);
    this.picker = new Core.Picker();
    this.data = new Data[this.options.type]();
    this.picker.setContent(this.data);
    return this;
  }
});
Pickers.Color = new Pickers.Base({
  type: 'Color'
});
Pickers.Number = new Pickers.Base({
  type: 'Number'
});
Pickers.Time = new Pickers.Base({
  type: 'Time'
});
Pickers.Text = new Pickers.Base({
  type: 'Text'
});
Pickers.Date = new Pickers.Base({
  type: 'Date'
});
Pickers.DateTime = new Pickers.Base({
  type: 'DateTime'
});
Pickers.Table = new Pickers.Base({
  type: 'Table'
});
Pickers.Unit = new Pickers.Base({
  type: 'Unit'
});
Pickers.Select = new Pickers.Base({
  type: 'Select'
});
Pickers.List = new Pickers.Base({
  type: 'List'
});
/*
---

name: Core.Overlay

description: Overlay for modal dialogs and stuff.

license: MIT-style license.

requires: Core.Abstract

provides: Core.Overlay

...
*/
Core.Overlay = new Class({
  Extends: Core.Abstract,
  options: {
    'class': GDotUI.Theme.Overlay['class']
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.setStyles({
      "position": "fixed",
      "top": 0,
      "left": 0,
      "right": 0,
      "bottom": 0,
      "opacity": 0
    });
    this.base.addClass(this.options['class']);
    document.getElement('body').grab(this.base);
    return this.base.addEventListener('webkitTransitionEnd', (function(e) {
      return e.propertyName === "opacity" && this.base.getStyle('opacity') === 0 ? this.base.setStyle('visiblity', 'hidden') : null;
    }).bindWithEvent(this));
  },
  hide: function() {
    return this.base.setStyle('opacity', 0);
  },
  show: function() {
    return this.base.setStyles({
      'visiblity': 'visible',
      'opacity': 1
    });
  }
});
/*
---

name: Forms.Input

description: Input elements for Forms.

license: MIT-style license.

requires: Core.Abstract

provides: Forms.Input

...
*/
Forms.Input = new Class({
  Extends: Core.Abstract,
  options: {
    type: '',
    name: ''
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    var _a;
    delete this.base;
    (this.options.type === 'text' || this.options.type === 'password' || this.options.type === 'checkbox' || this.options.type === 'button') ? (this.base = new Element('input', {
      type: this.options.type,
      name: this.options.name
    })) : null;
    this.options.type === "textarea" ? (this.base = new Element('textarea', {
      name: this.options.name
    })) : null;
    if (this.options.type === "select") {
      this.base = new Element('select', {
        name: this.options.name
      });
      this.options.options.each((function(item) {
        return this.base.grab(new Element('option', {
          value: item.value,
          text: item.label
        }));
      }).bind(this));
    }
    if (this.options.type === "radio") {
      this.base = new Element('div');
      this.options.options.each((function(item, i) {
        var input, label;
        label = new Element('label', {
          'text': item.label
        });
        input = new Element('input', {
          type: 'radio',
          name: this.options.name,
          value: item.value
        });
        return this.base.adopt(label, input);
      }).bind(this));
    }
    (typeof (_a = this.options.validate) !== "undefined" && _a !== null) ? $splat(this.options.validate).each((function(val) {
      return this.options.type !== "radio" ? this.base.addClass(val) : null;
    }).bind(this)) : null;
    return this.base;
  }
});
/*
---

name: Forms.Field

description: Field Element for Forms.Fieldset.

license: MIT-style license.

requires: [Core.Abstract, Forms.Input]

provides: Forms.Field

...
*/
Forms.Field = new Class({
  Extends: Core.Abstract,
  options: {
    structure: GDotUI.Theme.Forms.Field.struct,
    label: ''
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    var _a, h, key;
    h = new Hash(this.options.structure);
    _a = h;
    for (key in _a) { if (__hasProp.call(_a, key)) {
      this.base = new Element(key);
      this.createS(h.get(key), this.base);
      break;
    }}
    return this.options.hidden ? this.base.setStyle('display', 'none') : null;
  },
  createS: function(item, parent) {
    var _a, _b, _c, data, el, key;
    if (!(typeof parent !== "undefined" && parent !== null)) {
      return null;
    }
    if ((_a = $type(item)) === "object") {
      _b = []; _c = item;
      for (key in _c) { if (__hasProp.call(_c, key)) {
        _b.push((function() {
          data = new Hash(item).get(key);
          if (key === 'input') {
            this.input = new Forms.Input(this.options);
            el = this.input;
          } else if (key === 'label') {
            this.label = new Element('label', {
              'text': this.options.label
            });
            el = this.label;
          } else {
            el = new Element(key);
          }
          parent.grab(el);
          return this.createS(data, el);
        }).call(this));
      }}
      return _b;
    }
  }
});
/*
---

name: Forms.Fieldset

description: Fieldset for Forms.Form.

license: MIT-style license.

requires: [Core.Abstract, Forms.Field]

provides: Forms.Fieldset

...
*/
Forms.Fieldset = new Class({
  Extends: Core.Abstract,
  options: {
    name: '',
    inputs: []
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    delete this.base;
    this.base = new Element('fieldset');
    this.legend = new Element('legend', {
      text: this.options.name
    });
    this.base.grab(this.legend);
    return this.options.inputs.each(((function(item) {
      return this.base.grab(new Forms.Field(item));
    }).bindWithEvent(this)));
  }
});
/*
---

name: Forms.Form

description: Class for creating forms from javascript objects.

license: MIT-style license.

requires: [Core.Abstract, Forms.Fieldset]

provides: Forms.Form

...
*/
Forms.Form = new Class({
  Extends: Core.Abstract,
  Binds: ['success', 'faliure'],
  options: {
    data: {}
  },
  initialize: function(options) {
    this.fieldsets = [];
    return this.parent(options);
  },
  create: function() {
    var _a;
    delete this.base;
    this.base = new Element('form');
    (typeof (_a = this.options.data) !== "undefined" && _a !== null) ? this.options.data.each((function(fs) {
      return this.addFieldset(new Forms.Fieldset(fs));
    }).bind(this)) : null;
    this.extra = this.options.extra;
    this.useRequest = this.options.useRequest;
    if (this.useRequest) {
      this.request = new Request.JSON({
        url: this.options.action,
        resetForm: false,
        method: this.options.method
      });
      this.request.addEvent('success', this.success);
      this.request.addEvent('faliure', this.faliure);
    } else {
      this.base.set('action', this.options.action);
      this.base.set('method', this.options.method);
    }
    this.submit = new Element('input', {
      type: 'button',
      value: this.options.submit
    });
    this.base.grab(this.submit);
    this.validator = new Form.Validator(this.base, {
      serial: false
    });
    this.validator.start();
    return this.submit.addEvent('click', (function() {
      return this.validator.validate() ? this.useRequest ? this.send() : this.fireEvent('passed', this.geatherdata()) : this.fireEvent('failed', {
        message: 'Validation failed'
      });
    }).bindWithEvent(this));
  },
  addFieldset: function(fieldset) {
    if (this.fieldsets.indexOf(fieldset) === -1) {
      this.fieldsets.push(fieldset);
      return this.base.grab(fieldset);
    }
  },
  geatherdata: function() {
    var data;
    data = {};
    this.base.getElements('select, input[type=text], input[type=password], textarea, input[type=radio]:checked, input[type=checkbox]:checked').each(function(item) {
      data[item.get('name')] = item.get('type') === "checkbox" ? true : item.get('value');
      return data[item.get('name')];
    });
    return data;
  },
  send: function() {
    return this.request.send({
      data: $extend(this.geatherdata(), this.extra)
    });
  },
  success: function(data) {
    return this.fireEvent('success', data);
  },
  faliure: function() {
    return this.fireEvent('failed', {
      message: 'Request error!'
    });
  }
});
/*
---

name: Core.Tab

description: Tab element for Core.Tabs.

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Tab

...
*/
Core.Tab = new Class({
  Extends: Core.Abstract,
  options: {
    'class': GDotUI.Theme.Tab['class'],
    label: '',
    image: GDotUI.Theme.Icons.remove,
    active: GDotUI.Theme.Global.active,
    removeable: false
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.base.addEvent('click', (function() {
      return this.fireEvent('activate', this);
    }).bindWithEvent(this));
    this.label = new Element('div', {
      text: this.options.label
    });
    this.icon = new Core.Icon({
      image: this.options.image
    });
    this.icon.addEvent('invoked', (function(ic, e) {
      e.stop();
      return this.fireEvent('remove', this);
    }).bindWithEvent(this));
    this.base.adopt(this.label);
    return this.options.removeable ? this.base.grab(this.icon) : null;
  },
  activate: function() {
    this.fireEvent('activated', this);
    return this.base.addClass(this.options.active);
  },
  deactivate: function() {
    this.fireEvent('deactivated', this);
    return this.base.removeClass(this.options.active);
  }
});
/*
---

name: Core.Tabs

description: Tab navigation element.

license: MIT-style license.

requires: [Core.Abstract, Core.Tab]

provides: Core.Tabs

...
*/
Core.Tabs = new Class({
  Extends: Core.Abstract,
  Binds: ['remove', 'change'],
  options: {
    'class': GDotUI.Theme.Tabs['class']
  },
  initialize: function(options) {
    this.tabs = [];
    this.active = null;
    return this.parent(options);
  },
  create: function() {
    return this.base.addClass(this.options['class']);
  },
  add: function(tab) {
    if (this.tabs.indexOf(tab) === -1) {
      this.tabs.push(tab);
      this.base.grab(tab);
      tab.addEvent('remove', this.remove);
      return tab.addEvent('activate', this.change);
    }
  },
  remove: function(tab) {
    if (this.tabs.indexOf(tab) !== -1) {
      this.tabs.erase(tab);
      document.id(tab).dispose();
      tab === this.active ? this.tabs.length > 0 ? this.change(this.tabs[0]) : null : null;
      return this.fireEvent('tabRemoved', tab);
    }
  },
  change: function(tab) {
    if (tab !== this.active) {
      this.setActive(tab);
      return this.fireEvent('change', tab);
    }
  },
  setActive: function(tab) {
    var _a;
    (typeof (_a = this.active) !== "undefined" && _a !== null) ? this.active.deactivate() : null;
    tab.activate();
    this.active = tab;
    return this.active;
  },
  getByLabel: function(label) {
    return (this.tabs.filter(function(item, i) {
      return item.options.label === label ? true : false;
    }))[0];
  }
});