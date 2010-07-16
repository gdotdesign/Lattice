var Core, Data, GDotUI, Interfaces, Iterable, Pickers, ResetSlider;
/*
---

name: GDotUI

description:

license: MIT-style license.

requires:

provides: GDotUI

...
*/
Interfaces = {};
Core = {};
Data = {};
Iterable = {};
Pickers = {};
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

description: Porived dragging for elements that implements this.

license: MIT-style license.

requires:

provides: [Interfaces.Draggable, Drag.Float]

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
Interfaces.Draggable = new Class({
  Implements: Options,
  options: {
    draggable: false
  },
  _$Draggable: function() {
    if (this.options.draggable) {
      this.handle === null ? (this.handle = this.base) : null;
      this.drag = new Drag.Float(this.base, {
        target: this.handle,
        handle: this.handle
      });
      return this.drag.addEvent('drop', (function() {
        return this.fireEvent('dropped', this);
      }).bindWithEvent(this));
    }
  }
});
/*
---

name: Interfaces.Restoreable

description:

license: MIT-style license.

requires:

provides: Interfaces.Restoreable

...
*/
Interfaces.Restoreable = new Class({
  Impelments: [Options],
  options: {
    useCookie: true,
    cookieID: null
  },
  _$Restoreable: function() {
    this.addEvent('hide', (function() {
      return $chk(this.options.cookieID) ? this.options.useCookie ? Cookie.write(this.options.cookieID + '.state', 'hidden', {
        duration: GDotUI.Config.cookieDuration
      }) : window.localStorage.setItem(this.options.cookieID + '.state', 'hidden') : null;
    }).bindWithEvent(this));
    return this.addEvent('dropped', this.savePosition.bindWithEvent(this));
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
  loadPosition: function() {
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

description:

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
  }
});
/*
---

name: Core.Abstract

description:

license: MIT-style license.

requires: [Interfaces.Enabled, Interfaces.Controls]

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
    this.parent(options);
    this.enabled = true;
    return this;
  },
  create: function() {
    var _a;
    this.base.addClass(this.options['class']);
    (typeof (_a = this.options.image) !== "undefined" && _a !== null) ? this.base.setStyle('background-image', 'url(' + this.options.image + ')') : null;
    return this.base.addEvent('click', (function(e) {
      return this.enabled ? this.fireEvent('invoked', [this, e]) : null;
    }).bindWithEvent(this));
  }
});
/*
---

name: Core.IconGroup

description: Icon group with 4 types of layout.

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.IconGroup

...
*/
Core.IconGroup = new Class({
  Extends: Core.Abstract,
  Implements: Interfaces.Controls,
  options: {
    mode: "horizontal",
    spacing: {
      x: 20,
      y: 20
    },
    startAngle: 0,
    radius: 0,
    degree: 360
  },
  initialize: function(options) {
    this.parent(options);
    this.icons = [];
    return this;
  },
  create: function() {
    return this.base.setStyle('position', 'relative');
  },
  addIcon: function(icon) {
    if (this.icons.indexOf(icon === -1)) {
      this.base.grab(icon);
      this.icons.push(icon);
      return true;
    } else {
      return false;
    }
  },
  removeIcon: function(icon) {
    if (this.icons.indexOf(icon !== -1)) {
      icon.base.dispose();
      this.icons.push(icon);
      return true;
    } else {
      return false;
    }
  },
  ready: function() {
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
        return {
          x: x,
          y: y
        };
      });
    } else if (_a === 'horizontal') {
      icpos = this.icons.map(function(item, i) {
        x = i === 0 ? x + x : x + item.base.getSize().x + spacing.x;
        y = i === 0 ? y : y + spacing.y;
        return {
          x: x,
          y: y
        };
      });
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
          x = -Math.round(radius * Math.cos(foks));
          y = Math.round(radius * Math.sin(foks));
        } else {
          x = -Math.round(radius * Math.cos(((fok * i) + startAngle) * (Math.PI / 180)));
          y = Math.round(radius * Math.sin(((fok * i) + startAngle) * (Math.PI / 180)));
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

description: Tip class.... (TODO Description)

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Tip

...
*/
Core.Tip = new Class({
  Extends: Core.Abstract,
  Binds: ['enter', 'leave'],
  options: {
    text: "",
    location: {
      x: "left",
      y: "bottom"
    },
    offset: 5
  },
  initialize: function(options) {
    this.parent(options);
    this.create();
    return this;
  },
  create: function() {
    this.base.addClass(GDotUI.Theme.tipClass);
    this.base.setStyle('position', 'absolute');
    this.base.setStyle('z-index', GDotUI.Config.tipZindex);
    return this.base.set('html', this.options.text);
  },
  attach: function(item) {
    var _a;
    !(typeof (_a = this.attachedTo) !== "undefined" && _a !== null) ? this.detach() : null;
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
    return this.attachedTo.enabled ? this.showTip() : null;
  },
  leave: function() {
    return this.attachedTo.enabled ? this.hideTip() : null;
  },
  showTip: function() {
    var _a, _b, p, s, s1;
    p = this.attachedTo.base.getPosition();
    s = this.attachedTo.base.getSize();
    document.getElement('body').grab(this.base);
    s1 = this.base.measure(function() {
      return this.getSize();
    });
    if ((_a = this.options.location.x) === "left") {
      this.tip.setStyle('left', p.x + (s.x + this.options.offset));
    } else if (_a === "right") {
      this.tip.setStyle('left', p.x + (s.x + this.options.offset));
    } else if (_a === "center") {
      this.tip.setStyle('left', p.x - s1.x / 2 + s.x / 2);
    }
    if ((_b = this.options.location.y) === "top") {
      return this.tip.setStyle('top', p.y - (s.y + this.options.offset));
    } else if (_b === "bottom") {
      return this.tip.setStyle('top', p.y + (s.y + this.options.offset));
    } else if (_b === "center") {
      return this.tip.setStyle('top', p.y - s1.y / 2 + s.y / 2);
    }
  },
  hideTip: function() {
    return this.base.dispose();
  }
});
/*
---

name: Core.Slider

description:

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
    var _a, _b;
    this.min = (typeof (_a = $chk(range[0])) !== "undefined" && _a !== null) ? $chk(range[0]) : (range[0] = 0);
    this.max = (typeof (_b = $chk(range[1])) !== "undefined" && _b !== null) ? $chk(range[1]) : (range[1] = this.steps);
    this.range = this.max - this.min;
    this.steps = this.options.steps || this.full;
    this.stepSize = Math.abs(this.range) / this.steps;
    this.stepWidth = this.stepSize * this.full / Math.abs(this.range);
    return this.stepWidth;
  }
});
Class.Mutators.Delegates = function(delegations) {
  var self;
  self = this;
  return (new Hash(delegations)).each(function(delegates, target) {
    return ($splat(delegates)).each(function(delegate) {
      self.prototype[delegate] = function() {
        var ret;
        ret = this[target][delegate].apply(this[target], arguments);
        return ret === this[target] ? this : ret;
      };
      return self.prototype[delegate];
    });
  });
};
Core.Slider = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Controls],
  Delegates: {
    slider: ['set', 'setRange']
  },
  options: {
    scrollBase: null,
    reset: false,
    mode: 'vertical',
    'class': GDotUI.Theme.Slider.barClass,
    knob: GDotUI.Theme.Slider.knobClass
  },
  initialize: function(options) {
    this.parent(options);
    return this;
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.knob = (new Element('div')).addClass(this.options.knob);
    if (this.options.mode === "vertical") {
      this.base.setStyles({
        'width': GDotUI.Theme.Slider.width,
        'height': GDotUI.Theme.Slider.length
      });
      this.knob.setStyles({
        'width': GDotUI.Theme.Slider.width,
        'height': GDotUI.Theme.Slider.width * 2
      });
    } else {
      this.base.setStyles({
        'width': GDotUI.Theme.Slider.length,
        'height': GDotUI.Theme.Slider.width
      });
      this.knob.setStyles({
        'width': GDotUI.Theme.Slider.width * 2,
        'height': GDotUI.Theme.Slider.width
      });
    }
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
        steps: 100
      });
    }
    this.slider.addEvent('complete', (function(step) {
      return this.fireEvent('complete', step + '');
    }).bindWithEvent(this));
    this.slider.addEvent('change', (function(step) {
      typeof (step) === 'object' ? (step = 0) : null;
      this.fireEvent('change', step + '');
      return this.scrollBase !== null ? (this.scrollBase.scrollTop = (this.scrollBase.scrollHeight - this.scrollBase.getSize().y) / 100 * step) : null;
    }).bindWithEvent(this));
    return this.parent();
  }
});
/*
---

name: Core.Float

description:

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Draggable, Interfaces.Restoreable, Core.Slider]

provides: Core.Float

...
*/
Core.Float = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Draggable, Interfaces.Restoreable],
  Binds: ['resize', 'mouseEnter', 'mouseLeave', 'hide'],
  options: {
    'class': GDotUI.Theme.Float['class'],
    overlay: false,
    closeable: true,
    resizeable: false,
    editable: false
  },
  initialize: function(options) {
    this.parent(options);
    this.showSilder = false;
    return this;
  },
  ready: function() {
    this.loadPosition();
    this.base.adopt(this.icons, this.slider);
    this.icons.base.setStyle('right', -6);
    this.icons.base.setStyle('top', 0);
    this.slider.base.setStyle('right', -(this.slider.base.getSize().x) - 6);
    this.slider.base.setStyle('top', this.icons.size.y);
    console.log(this.icons.size.y);
    return this.parent();
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.base.setStyle('position', 'absolute');
    this.base.setPosition({
      x: 0,
      y: 0
    });
    this.base.toggleClass('inactive');
    this.content = new Element('div', {
      'class': GDotUI.Theme.Float.baseClass
    });
    this.handle = new Element('div', {
      'class': GDotUI.Theme.Float.handleClass
    });
    this.bottom = new Element('div', {
      'class': GDotUI.Theme.Float.bottomHandleClass
    });
    this.base.adopt(this.handle, this.content);
    this.slider = new Core.Slider({
      scrollBase: this.content
    });
    this.slider.base.setStyle('position', 'absolute');
    this.slider.addEvent('complete', (function() {
      this.scrolling = false;
      return this.scrolling;
    }).bindWithEvent(this));
    this.slider.addEvent('change', (function() {
      this.scrolling = true;
      return this.scrolling;
    }).bindWithEvent(this));
    this.slider.hide();
    this.icons = new Core.IconGroup(GDotUI.Theme.Float.iconOptions);
    this.icons.base.setStyle('position', 'absolute');
    this.icons.base.addClass(GDotUI.Theme.Float.iconsClass);
    this.close = new Core.Icon({
      'class': GDotUI.Theme.Float.closeClass
    });
    this.close.addEvent('invoked', (function() {
      return this.hide();
    }).bindWithEvent(this));
    this.edit = new Core.Icon({
      'class': GDotUI.Theme.Float.editClass
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
    this.icons.hide;
    $chk(this.options.scrollBase) ? (this.scrollBase = this.options.scrollBase) : (this.scrollBase = this.content);
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
      this.sizeDrag.addEvent('drag', this.resize);
    }
    this.base.addEvent('mouseenter', this.mouseEnter);
    return this.base.addEvent('mouseleave', this.mouseLeave);
  },
  mouseEnter: function() {
    this.base.toggleClass('active');
    this.base.toggleClass('inactive');
    $clear(this.iconsTimout);
    $clear(this.sliderTimout);
    this.showSlider ? this.slider.show() : null;
    this.icons.show();
    this.mouseisover = true;
    return this.mouseisover;
  },
  mouseLeave: function() {
    this.base.toggleClass('active');
    this.base.toggleClass('inactive');
    !this.scrolling ? this.showSlider ? (this.sliderTimout = this.slider.hide.delay(200, this.slider)) : null : null;
    this.iconsTimout = this.icons.hide.delay(200, this.icons);
    this.mouseisover = false;
    return this.mouseisover;
  },
  resize: function() {
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
  },
  show: function() {
    if (!this.base.isVisible()) {
      document.getElement('body').grab(this.base);
      if (this.options.overlay) {
        GDotUI.Misc.Overlay.show();
        return this.base.setStyle('z-index', 801);
      }
    }
  },
  hide: function() {
    return this.base.dispose();
  },
  toggle: function(el) {
    return this.base.isVisible() ? this.hide(el) : this.show(el);
  },
  setContent: function(element) {
    this.contentElement = element;
    return this.content.grab(element.base);
  },
  center: function() {
    return this.base.position();
  }
});
/*
---

name: Core.Button

description:

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Enabled, Interfaces.Controls]

provides: Core.Button

...
*/
Core.Button = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Controls],
  options: {
    image: '',
    text: '',
    'class': GDotUI.Theme.Button['class']
  },
  initialize: function(options) {
    this.parent(options);
    this.enabled = true;
    return this;
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
    this.icon.base.setStyle('float', 'left');
    return this.parent();
  }
});
/*
---

name: Core.Picker

description:

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Picker

...
*/
Element.Events.outerClick = {
  base: 'click',
  condition: function(event) {
    event.stopPropagation();
    return false;
  },
  onAdd: function(fn) {
    return window.addEvent('click', fn);
  },
  onRemove: function(fn) {
    return window.removeEvent('click', fn);
  }
};
Core.Picker = new Class({
  Extends: Core.Abstract,
  Binds: ['show', 'hide'],
  options: {
    'class': GDotUI.Theme.Picker['class'],
    offset: GDotUI.Theme.Picker.offset
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
    var asize, offset, position, size, winsize, x, xpos, y, ypos;
    !this.base.hasChild(this.contentElement) ? this.base.grab(this.contentElement) : null;
    winsize = window.getSize();
    asize = this.attachedTo.getSize();
    position = this.attachedTo.getPosition();
    size = this.base.getSize();
    offset = this.options.offset;
    x = '';
    y = '';
    if ((position.x - size.x) < 0) {
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
    if (position.y > (winsize.x / 2)) {
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
  attach: function(input) {
    input.addEvent('click', this.show);
    this.contentElement.addEvent('change', (function(value) {
      this.attachedTo.set('value', value);
      return this.attachedTo.fireEvent('change', value);
    }).bindWithEvent(this));
    this.attachedTo = input;
    return this.attachedTo;
  },
  show: function(e) {
    document.getElement('body').grab(this.base);
    this.attachedTo.addClass('picking');
    e.stop();
    return this.base.addEvent('outerClick', this.hide);
  },
  hide: function() {
    if (this.base.isVisible()) {
      this.attachedTo.removeClass('picking');
      return this.base.dispose();
    }
  },
  setContent: function(element) {
    return this.contentElement(element);
  }
});
/*
---

name: Core.Slot

description: Generic icon element.

license: MIT-style license.

requires: [Core.Abstract]

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

description:

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
  getValue: function() {  }
});
/*
---

name: Data.Date

description:

license: MIT-style license.

requires: [Data.Abstract, Core.Slot]

provides: Data.Date

...
*/
Data.Date = new Class({
  Extends: Data.Abstract,
  options: {
    'class': GDotUI.Theme.Date.Slot['class'],
    format: GDotUI.Theme.Date.format
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
    i = 1950;
    while (i < 2012) {
      item = new Iterable.ListItem({
        title: i
      });
      item.value = i;
      this.years.addItem(item);
      i++;
    }
    return this;
  },
  ready: function() {
    this.base.adopt(this.years, this.month, this.days);
    this.setValue(new Date());
    this.base.setStyle('height', this.days.base.getSize().y);
    $$(this.days.base, this.month.base, this.years.base).setStyles({
      'float': 'left'
    });
    return this.parent();
  },
  setValue: function(date) {
    (typeof date !== "undefined" && date !== null) ? (this.date = date) : null;
    this.update();
    return this.fireEvent('change', this.date.format(this.options.format));
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

name: Iterable.ListItem

description:

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

...
*/
Iterable.ListItem = new Class({
  Extends: Core.Abstract,
  options: {
    'class': GDotUI.Theme.ListItem['class'],
    title: '',
    subtitle: ''
  },
  initialize: function(options) {
    this.parent(options);
    this.enabled = true;
    return this.enabled;
  },
  create: function() {
    this.base.addClass(this.options['class']).setStyle('position', 'relative');
    this.remove = new Core.Icon({
      image: GDotUI.Theme.Icons.remove
    });
    this.handle = new Core.Icon({
      image: GDotUI.Theme.Icons.handleVertical
    });
    this.handle.base.addClass('list-handle');
    $$(this.remove.base, this.handle.base).setStyle('position', 'absolute');
    this.title = new Element('div').addClass(GDotUI.Theme.ListItem.title).set('text', this.options.title);
    this.subtitle = new Element('div').addClass(GDotUI.Theme.ListItem.subTitle).set('text', this.options.subtitle);
    this.base.adopt(this.title, this.subtitle, this.remove, this.handle);
    this.base.addEvent('click', (function() {
      return this.enabled ? this.fireEvent('invoked', this) : null;
    }).bindWithEvent(this));
    return this.base.addEvent('dblclick', (function() {
      return this.enabled ? this.editing ? this.fireEvent('edit', this) : null : null;
    }).bindWithEvent(this));
  },
  toggleEdit: function() {
    if (this.editing) {
      this.remove.base.setStyle('right', -this.remove.base.getSize().x);
      this.handle.base.setStyle('left', -this.handle.base.getSize().x);
      this.base.setStyle('padding-left', this.base.retrieve('padding-left:old'));
      this.base.setStyle('padding-right', this.base.retrieve('padding-right:old'));
      this.editing = false;
      return this.editing;
    } else {
      this.remove.base.setStyle('right', GDotUI.Theme.ListItem.iconOffset);
      this.handle.base.setStyle('left', GDotUI.Theme.ListItem.iconOffset);
      this.base.store('padding-left:old', this.base.getStyle('padding-left'));
      this.base.store('padding-right:old', this.base.getStyle('padding-left'));
      this.base.setStyle('padding-left', Number(this.base.getStyle('padding-left').slice(0, -2)) + this.handle.base.getSize().x);
      this.base.setStyle('padding-right', Number(this.base.getStyle('padding-right').slice(0, -2)) + this.remove.base.getSize().x);
      this.editing = true;
      return this.editing;
    }
  },
  ready: function() {
    var baseSize, handSize, remSize;
    if (!this.editing) {
      handSize = this.handle.base.getSize();
      remSize = this.remove.base.getSize();
      baseSize = this.base.getSize();
      this.remove.base.setStyles({
        "right": -remSize.x,
        "top": (baseSize.y - remSize.y) / 2
      });
      this.handle.base.setStyles({
        "left": -handSize.x,
        "top": (baseSize.y - handSize.y) / 2
      });
      return this.parent();
    }
  }
});
/*
---

name: Iterable.List

description:

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.List

...
*/
Iterable.List = new Class({
  Extends: Core.Abstract,
  options: {
    'class': GDotUI.Theme.List['class']
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options['class']);
    this.sortable = new Sortables(null, {
      handle: '.list-handle'
    });
    this.editing = false;
    this.items = [];
    return this.items;
  },
  removeItem: function(li) {
    li.removeEvents('invoked', 'edit', 'delete');
    li.base.destroy();
    this.items.erase(li);
    return delete li;
  },
  removeAll: function() {
    this.selected = null;
    this.items.each((function() {
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
      (typeof (_a = this.selected) !== "undefined" && _a !== null) ? this.selected.base.removeClass('selected') : null;
      this.selected = item;
      this.selected.base.addClass('selected');
      return this.fireEvent('select', item);
    }
  },
  addItem: function(li) {
    this.items.push(li);
    this.base.grab(li);
    li.addEvent('invoked', (function(item) {
      this.select(item);
      return this.fireEvent('invoked', [item]);
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
toTheTop:function(item){
  //console.log(item);
  //@base.setStyle('top',@base.getPosition().y-item.base.getSize().y);
  @items.erase(item);
  @items.unshift(item);

},
update:function(){
  @items.each(function(item,i){
    item.base.dispose();
    @base.grab(item.base,'top');
  }.bind(this))
},
*/
/*
---

name: Core.Overlay

description: Abstract base class for Elements.

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
    this.parent(options);
    return this;
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
    (document.getElement('body')).grab(this.base);
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