var Loader, Stash, UnitList, mergeOneNew;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
Stash = (function() {
  function Stash(context, prefix, verbose) {
    if (prefix == null) {
      prefix = "";
    }
    if (verbose == null) {
      verbose = false;
    }
    this.$global = typeof window != "undefined" && window !== null ? window : exports;
    this.$units = {};
    this.$context = context;
    this.$stash = {};
    this.$prefix = prefix;
    this.verbose = verbose;
    if (prefix !== "" && typeof this.$prefix === 'string') {
      this.$prefix += ".";
    }
    this;
  }
  Stash.prototype.define = function(requires, name, obj) {
    if (requires == null) {
      requires = [];
    }
    name = this.$prefix + name;
    switch (typeof requires) {
      case "string":
        requires = [requires];
    }
    this.$units[name] = {
      content: obj,
      requires: requires
    };
    if (this.check(name)) {
      return this.load(name);
    } else {
      if (this.verbose) {
        console.log("Stashing:", name);
      }
      return this.$stash[name] = this.$units[name];
    }
  };
  Stash.prototype.checkStash = function() {
    var name, unit, _ref, _results;
    _ref = this.$stash;
    _results = [];
    for (name in _ref) {
      unit = _ref[name];
      _results.push(this.check(name) ? (delete this.$stash[name], this.load(name)) : void 0);
    }
    return _results;
  };
  Stash.prototype.check = function(name) {
    var context, end, last, path, req, segment, _i, _j, _len, _len2, _ref;
    _ref = this.$units[name].requires;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      req = _ref[_i];
      if (req.match(/^!/)) {
        context = this.$global;
        req = req.slice(1);
      } else {
        context = this.$context;
        if (req.match(/^@/)) {
          req = req.slice(1);
        } else {
          if (this.$prefix !== "") {
            req = this.$prefix + req;
          }
        }
      }
      path = req.split(/\./);
      end = path.pop();
      if (path.length === 0) {
        if (!(context[req] != null)) {
          return false;
        }
      } else {
        last = context;
        for (_j = 0, _len2 = path.length; _j < _len2; _j++) {
          segment = path[_j];
          if (last[segment] != null) {
            last = last[segment];
          } else {
            return false;
          }
        }
        if (!(last[end] != null)) {
          return false;
        }
      }
    }
    return true;
  };
  Stash.prototype.load = function(name) {
    var end, last, path, segment, _i, _len;
    if (this.check(name)) {
      path = name.split(/\./);
      end = path.pop();
      last = this.$context;
      for (_i = 0, _len = path.length; _i < _len; _i++) {
        segment = path[_i];
        if (last != null) {
          if (!last[segment]) {
            last[segment] = {};
          }
          last = last[segment];
        } else {
          if (!(this.$context[segment] != null)) {
            this.$context[segment] = {};
            last = this.$context[segment];
          }
        }
      }
      if (this.verbose) {
        console.log("Loading:", name);
      }
      switch (typeof this.$units[name].content) {
        case 'function':
          last[end] = this.$units[name].content.call(this.$context);
          break;
        default:
          last[end] = this.$units[name].content;
      }
      return this.checkStash();
    }
  };
  return Stash;
})();
Loader = new Stash(window, "", true);
window.define = Loader.define.bind(Loader);
define(["Groups.Abstract", "Interfaces.Enabled", "Interfaces.Size"], "Groups.Toggles", function() {
  return new Class({
    Extends: Groups.Abstract,
    Binds: ['change'],
    Implements: [Interfaces.Enabled, Interfaces.Size],
    Attributes: {
      "class": {
        value: Lattice.buildClass('toggle-group')
      },
      active: {
        setter: function(value, old) {
          if (!(old != null)) {
            value.set('state', true);
          } else {
            if (old !== value) {
              old.set('state', false);
            }
            value.set('state', true);
          }
          return value;
        }
      }
    },
    update: function() {
      var buttonwidth, last;
      buttonwidth = Math.floor(this.size / this.children.length);
      this.children.each(function(btn) {
        return btn.set('size', buttonwidth);
      });
      if (last = this.children.getLast()) {
        return last.set('size', this.size - buttonwidth * (this.children.length - 1));
      }
    },
    change: function(button, value) {
      if (button !== this.active) {
        if (button.state) {
          this.set('active', button);
          return this.fireEvent('change', button);
        }
      }
    },
    emptyItems: function() {
      this.children.each(function(child) {
        console.log(child);
        return child.removeEvents('invoked');
      }, this);
      return this.empty();
    },
    removeItem: function(item) {
      if (this.hasChild(item)) {
        item.removeEvents('invoked');
        this.parent(item);
      }
      return this.update();
    },
    addItem: function(item) {
      if (!this.hasChild(item)) {
        item.set('minSize', 0);
        item.addEvent('invoked', this.change);
        this.parent(item);
      }
      return this.update();
    }
  });
});
define(["Core.Abstract", "Interfaces.Children"], "Groups.Abstract", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: Interfaces.Children,
    addItem: function(el, where) {
      return this.addChild(el, where);
    },
    removeItem: function(el) {
      return this.removeChild(el);
    }
  });
});
define(["Groups.Abstract", "Interfaces.Controls", "Interfaces.Enabled"], "Groups.Icons", function() {
  return new Class({
    Extends: Groups.Abstract,
    Implements: [Interfaces.Controls, Interfaces.Enabled],
    Binds: ['delegate'],
    Attributes: {
      mode: {
        value: "horizontal",
        validator: function(value) {
          if (['horizontal', 'vertical', 'circular', 'grid', 'linear'].indexOf(value) > -1) {
            return true;
          } else {
            return false;
          }
        }
      },
      spacing: {
        value: {
          x: 0,
          y: 0
        },
        validator: function(value) {
          if (typeOf(value) === 'object') {
            if ((value.x != null) && (value.y != null)) {
              return true;
            } else {
              return false;
            }
          } else {
            return false;
          }
        }
      },
      startAngle: {
        value: 0,
        setter: function(value) {
          return Number.from(value);
        },
        validator: function(value) {
          var a;
          if ((a = Number.from(value)) != null) {
            return a >= 0 && a <= 360;
          } else {
            return false;
          }
        }
      },
      radius: {
        value: 0,
        setter: function(value) {
          return Number.from(value);
        },
        validator: function(value) {
          var a;
          return (a = Number.from(value)) != null;
        }
      },
      degree: {
        value: 360,
        setter: function(value) {
          return Number.from(value);
        },
        validator: function(value) {
          var a;
          if ((a = Number.from(value)) != null) {
            return a >= 0 && a <= 360;
          } else {
            return false;
          }
        }
      },
      rows: {
        value: 1,
        setter: function(value) {
          return Number.from(value);
        },
        validator: function(value) {
          var a;
          if ((a = Number.from(value)) != null) {
            return a > 0;
          } else {
            return false;
          }
        }
      },
      columns: {
        value: 1,
        setter: function(value) {
          return Number.from(value);
        },
        validator: function(value) {
          var a;
          if ((a = Number.from(value)) != null) {
            return a > 0;
          } else {
            return false;
          }
        }
      },
      "class": {
        value: Lattice.buildClass('icon-group')
      }
    },
    create: function() {
      return this.base.setStyle('position', 'relative');
    },
    delegate: function() {
      return this.fireEvent('invoked', arguments);
    },
    addItem: function(icon) {
      if (!this.hasChild(icon)) {
        icon.addEvent('invoked', this.delegate);
        this.parent(icon);
        return this.update();
      }
    },
    removeItem: function(icon) {
      if (this.hasChild(icon)) {
        icon.removeEvent('invoked', this.delegate);
        this.removeChild(icon);
        return this.update();
      }
    },
    ready: function() {
      return this.update();
    },
    update: function() {
      var columns, fok, icpos, ker, n, radius, rows, spacing, startAngle, x, y;
      if (this.children.length > 0 && (this.mode != null)) {
        x = 0;
        y = 0;
        this.size = {
          x: 0,
          y: 0
        };
        spacing = this.spacing;
        switch (this.mode) {
          case 'grid':
            if ((this.rows != null) && (this.columns != null)) {
              if (this.rows < this.columns) {
                rows = null;
                columns = this.columns;
              } else {
                columns = null;
                rows = this.rows;
              }
            }
            icpos = this.children.map(__bind(function(item, i) {
              if (rows != null) {
                if (i % rows === 0) {
                  y = 0;
                  x = i === 0 ? x : x + item.base.getSize().x + spacing.x;
                } else {
                  y = i === 0 ? y : y + item.base.getSize().y + spacing.y;
                }
              }
              if (columns != null) {
                if (i % columns === 0) {
                  x = 0;
                  y = i === 0 ? y : y + item.base.getSize().y + spacing.y;
                } else {
                  x = i === 0 ? x : x + item.base.getSize().x + spacing.x;
                }
              }
              this.size.x = x + item.base.getSize().x;
              this.size.y = y + item.base.getSize().y;
              return {
                x: x,
                y: y
              };
            }, this));
            break;
          case 'linear':
            icpos = this.children.map(__bind(function(item, i) {
              x = i === 0 ? x + x : x + spacing.x + item.base.getSize().x;
              y = i === 0 ? y + y : y + spacing.y + item.base.getSize().y;
              this.size.x = x + item.base.getSize().x;
              this.size.y = y + item.base.getSize().y;
              return {
                x: x,
                y: y
              };
            }, this));
            break;
          case 'horizontal':
            icpos = this.children.map(__bind(function(item, i) {
              x = i === 0 ? x + x : x + item.base.getSize().x + spacing.x;
              y = i === 0 ? y : y;
              this.size.x = x + item.base.getSize().x;
              this.size.y = item.base.getSize().y;
              return {
                x: x,
                y: y
              };
            }, this));
            break;
          case 'vertical':
            icpos = this.children.map(__bind(function(item, i) {
              x = i === 0 ? x : x;
              y = i === 0 ? y + y : y + item.base.getSize().y + spacing.y;
              this.size.x = item.base.getSize().x;
              this.size.y = y + item.base.getSize().y;
              return {
                x: x,
                y: y
              };
            }, this));
            break;
          case 'circular':
            n = this.children.length;
            radius = this.radius;
            startAngle = this.startAngle;
            ker = 2 * this.radius * Math.PI;
            fok = this.degree / n;
            icpos = this.children.map(function(item, i) {
              var foks;
              if (i === 0) {
                foks = startAngle * (Math.PI / 180);
                x = Math.round(radius * Math.sin(foks)) + radius / 2 + item.base.getSize().x;
                y = -Math.round(radius * Math.cos(foks)) + radius / 2 + item.base.getSize().y;
              } else {
                x = Math.round(radius * Math.sin(((fok * i) + startAngle) * (Math.PI / 180))) + radius / 2 + item.base.getSize().x;
                y = -Math.round(radius * Math.cos(((fok * i) + startAngle) * (Math.PI / 180))) + radius / 2 + item.base.getSize().y;
              }
              return {
                x: x,
                y: y
              };
            });
        }
        this.base.setStyles({
          width: this.size.x,
          height: this.size.y
        });
        return this.children.each(function(item, i) {
          item.setStyle('top', icpos[i].y);
          item.setStyle('left', icpos[i].x);
          return item.setStyle('position', 'absolute');
        });
      }
    }
  });
});
define(["Groups.Abstract", "Interfaces.Size"], "Groups.Lists", function() {
  return new Class({
    Extends: Groups.Abstract,
    Implements: [Interfaces.Size],
    Attributes: {
      "class": {
        value: Lattice.buildClass('list-group')
      }
    },
    create: function() {
      this.parent();
      return this.base.setStyle('position', 'relative');
    },
    update: function() {
      var cSize, lastSize, length;
      length = this.children.length;
      if (length > 0) {
        cSize = this.size / length;
        lastSize = Math.floor(this.size - (cSize * (length - 1)));
        this.children.each(function(child, i) {
          child.setStyle('position', 'absolute');
          child.setStyle('top', 0);
          child.setStyle('left', cSize * i - 1);
          return child.set('size', cSize);
        });
        return this.children.getLast().set('size', lastSize);
      }
    }
  });
});
define(["Core.Picker", "Data.Color", "Data.Number", "Data.Text", "Data.Date", "Data.Time", "Data.DateTime"], "Pickers.Base", function() {
  return new Class({
    Extends: Core.Picker,
    Delegates: {
      data: ['set']
    },
    Attributes: {
      type: {
        value: null
      }
    },
    show: function(e, auto) {
      if (this.data === void 0) {
        this.data = new Data[this.type]();
        this.set('content', this.data);
      }
      return this.parent(e, auto);
    }
  });
});
define("Pickers.Base", "Pickers.Color", function() {
  return new Pickers.Base({
    type: 'ColorWheel'
  });
});
define("Pickers.Base", "Pickers.Number", function() {
  return new Pickers.Base({
    type: 'Number'
  });
});
define("Pickers.Base", "Pickers.Time", function() {
  return new Pickers.Base({
    type: 'Time'
  });
});
define("Pickers.Base", "Pickers.Text", function() {
  return new Pickers.Base({
    type: 'Text'
  });
});
define("Pickers.Base", "Pickers.Date", function() {
  return new Pickers.Base({
    type: 'Date'
  });
});
define("Pickers.Base", "Pickers.DateTime", function() {
  return new Pickers.Base({
    type: 'DateTime'
  });
});
define("Pickers.Base", "Pickers.Table", function() {
  return new Pickers.Base({
    type: 'Table'
  });
});
define("Pickers.Base", "Pickers.Unit", function() {
  return new Pickers.Base({
    type: 'Unit'
  });
});
define("Pickers.Base", "Pickers.Select", function() {
  return new Pickers.Base({
    type: 'Select'
  });
});
define("Pickers.Base", "Pickers.List", function() {
  return new Pickers.Base({
    type: 'List'
  });
});
define(null, "Interfaces.Size", function() {
  return new Class({
    _$Size: function() {
      this.size = Number.from(Lattice.getCSS("." + (this.get('class')), 'width' || 0));
      this.minSize = Number.from(Lattice.getCSS("." + (this.get('class')), 'min-width' || 0));
      this.addAttribute('minSize', {
        value: null,
        setter: function(value, old) {
          this.base.setStyle('min-width', value);
          if (this.size < value) {
            this.set('size', value);
          }
          return value;
        }
      });
      return this.addAttribute('size', {
        value: null,
        setter: function(value, old) {
          var size;
          size = value < this.minSize ? this.minSize : value;
          this.base.setStyle('width', size);
          return size;
        }
      });
    }
  });
});
define(null, "Interfaces.Mux", function() {
  return new Class({
    mux: function() {
      return new Hash(this).each(function(value, key) {
        if (key.test(/^_\$/) && typeOf(value) === "function") {
          return value.attempt(null, this);
        }
      }, this);
    }
  });
});
define(null, "Interfaces.Children", function() {
  return new Class({
    _$Children: function() {
      return this.children = [];
    },
    hasChild: function(child) {
      if (this.children.indexOf(child) >= 0) {
        return true;
      } else {
        return false;
      }
    },
    adoptChildren: function() {
      var children;
      children = Array.from(arguments);
      return children.each(function(child) {
        return this.addChild(child);
      }, this);
    },
    addChild: function(el, where) {
      this.children.push(el);
      return this.base.grab(el, where);
    },
    removeChild: function(el) {
      if (this.children.contains(el)) {
        this.children.erase(el);
        document.id(el).dispose();
        return delete el;
      }
    },
    empty: function() {
      this.children.each(function(child) {
        return document.id(child).dispose();
      });
      return this.children.empty();
    }
  });
});
define(null, "Interfaces.Enabled", function() {
  return new Class({
    _$Enabled: function() {
      return this.addAttributes({
        enabled: {
          value: true,
          setter: function(value) {
            if (value) {
              if (this.children != null) {
                this.children.each(function(item) {
                  if (item.$attributes.enabled != null) {
                    return item.set('enabled', true);
                  }
                });
              }
              this.base.removeClass('disabled');
            } else {
              if (this.children != null) {
                this.children.each(function(item) {
                  if (item.$attributes.enabled != null) {
                    return item.set('enabled', false);
                  }
                });
              }
              this.base.addClass('disabled');
            }
            return value;
          }
        }
      });
    }
  });
});
define("!Drag.Move", "Drag.Float", function() {
  return new Class({
    Extends: Drag.Move,
    initialize: function(el, options) {
      return this.parent(el, options);
    },
    start: function(event) {
      if (this.options.target === event.target) {
        return this.parent(event);
      }
    }
  });
});
define("!Drag.Move", "Drag.Ghost", function() {
  return new Class({
    Extends: Drag.Move,
    options: {
      opacity: 0.65
    },
    pos: false,
    remove: '',
    start: function(event) {
      if (!event.rightClick) {
        this.droppables = $$(this.options.droppables);
        this.ghost();
        return this.parent(event);
      }
    },
    cancel: function(event) {
      if (event) {
        this.deghost();
      }
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
      if (this.options.pos && this.overed === null) {
        e.setStyles;
        ({
          'top': newpos.y,
          'left': newpos.x
        });
      }
      this.element.destroy();
      return this.element = e;
    }
  });
});
define(["Drag.Float", "Drag.Ghost"], "Interfaces.Draggable", function() {
  return new Class({
    Implements: Options,
    options: {
      draggable: false,
      ghost: false,
      removeClasses: ''
    },
    _$Draggable: function() {
      if (this.options.draggable) {
        if (this.handle === null) {
          this.handle = this.base;
        }
        if (this.options.ghost) {
          this.drag = new Drag.Ghost(this.base, {
            target: this.handle,
            handle: this.handle,
            remove: this.options.removeClasses,
            droppables: this.options.droppables,
            precalculate: true,
            pos: false
          });
        } else {
          this.drag = new Drag.Float(this.base, {
            target: this.handle,
            handle: this.handle
          });
        }
        return this.drag.addEvent('drop', __bind(function() {
          return this.fireEvent('dropped', arguments);
        }, this));
      }
    }
  });
});
define(null, "Interfaces.Controls", function() {
  return new Class({
    Implements: Interfaces.Enabled,
    show: function() {
      if (this.enabled) {
        return this.base.show();
      }
    },
    hide: function() {
      if (this.enabled) {
        return this.base.hide();
      }
    },
    toggle: function() {
      if (this.enabled) {
        return this.base.toggle();
      }
    }
  });
});
define(["Core.Abstract", "Interfaces.Children", "Interfaces.Size"], "Iterable.List", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: [Interfaces.Children, Interfaces.Size],
    Attributes: {
      "class": {
        value: Lattice.buildClass('list'),
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old);
          this.children.each(__bind(function(item) {
            if (item.base.hasClass(this.selectedClass)) {
              return item.base.removeClass(this.selectedClass);
            }
          }, this));
          this.set('selectedClass', "" + value + "-selected");
          this.set('selected', this.selected);
          return value;
        }
      },
      selectedClass: {
        value: Lattice.buildClass('list-selected')
      },
      selected: {
        getter: function() {
          return this.children.filter((function(item) {
            if (item.base.hasClass(this.selectedClass)) {
              return true;
            } else {
              return false;
            }
          }).bind(this))[0];
        },
        setter: function(value, old) {
          if (old) {
            old.base.removeClass(this.selectedClass);
          }
          if (value != null) {
            value.base.addClass(this.selectedClass);
          }
          return value;
        }
      }
    },
    getItemFromLabel: function(label) {
      var filtered;
      filtered = this.children.filter(function(item) {
        if (String.from(item.label).toLowerCase() === String(label).toLowerCase()) {
          return true;
        } else {
          return false;
        }
      });
      return filtered[0];
    },
    addItem: function(li) {
      this.addChild(li);
      li.addEvent('select', __bind(function(item, e) {
        return this.set('selected', item);
      }, this));
      return li.addEvent('invoked', __bind(function(item) {
        return this.fireEvent('invoked', arguments);
      }, this));
    },
    removeItem: function(li) {
      if (this.hasChild(li)) {
        li.removeEvents('select');
        li.removeEvents('invoked');
        return this.removeChild(li);
      }
    }
  });
});
define("Iterable.ListItem", "Iterable.MenuListItem", function() {
  return new Class({
    Extends: Iterable.ListItem,
    Attributes: {
      icon: {
        setter: function(value) {
          return this.iconEl.set('image', value);
        }
      },
      shortcut: {
        setter: function(value) {
          this.sc.set('text', value.toUpperCase());
          return value;
        }
      },
      "class": {
        value: Lattice.buildClass('menu-list-item')
      }
    },
    create: function() {
      this.parent();
      this.iconEl = new Core.Icon({
        "class": this.get('class') + '-icon'
      });
      this.sc = new Element('div');
      this.sc.setStyle('float', 'right');
      this.title.setStyle('float', 'left');
      this.iconEl.setStyle('float', 'left');
      this.base.grab(this.iconEl, 'top');
      return this.base.grab(this.sc);
    }
  });
});
define("Core.Abstract", "Iterable.ListItem", function() {
  return new Class({
    Extends: Core.Abstract,
    Attributes: {
      label: {
        value: '',
        setter: function(value) {
          this.title.set('text', value);
          return value;
        }
      },
      "class": {
        value: Lattice.buildClass('list-item'),
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old);
          this.title.replaceClass("" + value + "-title", "" + old + "-title");
          return value;
        }
      }
    },
    create: function() {
      this.title = new Element('div');
      this.base.grab(this.title);
      this.base.addEvent('click', __bind(function(e) {
        return this.fireEvent('select', [this, e]);
      }, this));
      return this.base.addEvent('click', __bind(function() {
        return this.fireEvent('invoked', this);
      }, this));
    }
  });
});
/*
---

name: Element.Extras

description: Extra functions and monkeypatches for moootols Element.

license: MIT-style license.

provides: Element.Extras

...
*/
Element.Properties.checked = {
  get: function() {
    if (this.getChecked != null) {
      return this.getChecked();
    }
  },
  set: function(value) {
    this.setAttribute('checked', value);
    if ((this.on != null) && (this.off != null)) {
      if (value) {
        return this.on();
      } else {
        return this.off();
      }
    }
  }
};
(function() {
  Number.implement({
    inRange: function(center, range) {
      if ((center - range < this && this < center + range)) {
        return true;
      } else {
        return false;
      }
    }
  });
  return Number.eval = function(string, size) {
    return Number.from(eval(String.from(string).replace(/(\d*)\%/g, function(match, str) {
      return (Number.from(str) / 100) * size;
    })));
  };
})();
(function() {
  return Color.implement({
    type: 'hex',
    alpha: 100,
    setType: function(type) {
      return this.type = type;
    },
    setAlpha: function(alpha) {
      return this.alpha = alpha;
    },
    hsvToHsl: function() {
      var h, hsl, l, s, v;
      h = this.hsb[0];
      s = this.hsb[1];
      v = this.hsb[2];
      l = (2 - s / 100) * v / 2;
      hsl = [h, s * v / (l < 50 ? l * 2 : 200 - l * 2), l];
      if (isNaN(hsl[1])) {
        hsl[1] = 0;
      }
      return hsl;
    },
    format: function(type) {
      if (type) {
        this.setType(type);
      }
      switch (this.type) {
        case "rgb":
          return String.from("rgb(" + this.rgb[0] + ", " + this.rgb[1] + ", " + this.rgb[2] + ")");
        case "rgba":
          return String.from("rgba(" + this.rgb[0] + ", " + this.rgb[1] + ", " + this.rgb[2] + ", " + (this.alpha / 100) + ")");
        case "hsl":
          this.hsl = this.hsvToHsl();
          return String.from("hsl(" + this.hsl[0] + ", " + (Math.round(this.hsl[1])) + "%, " + (Math.round(this.hsl[2])) + "%)");
        case "hsla":
          this.hsl = this.hsvToHsl();
          return String.from("hsla(" + this.hsl[0] + ", " + (Math.round(this.hsl[1])) + "%, " + (Math.round(this.hsl[2])) + "%, " + (this.alpha / 100) + ")");
        case "hex":
          return String.from(this.hex);
      }
    }
  });
})();
(function() {
  var oldPrototypeStart;
  oldPrototypeStart = Drag.prototype.start;
  return Drag.prototype.start = function() {
    window.fireEvent('outer');
    return oldPrototypeStart.run(arguments, this);
  };
})();
(function() {
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
  return Element.implement({
    replaceClass: function(newClass, oldClass) {
      this.removeClass(oldClass);
      return this.addClass(newClass);
    },
    oldGrab: Element.prototype.grab,
    oldInject: Element.prototype.inject,
    oldAdopt: Element.prototype.adopt,
    oldPosition: Element.prototype.position,
    position: function(options) {
      var asize, ofa, op, position, size, winscroll, winsize;
      if (options.relativeTo !== void 0) {
        op = {
          relativeTo: document.body,
          position: {
            x: 'center',
            y: 'center'
          }
        };
        options = Object.merge(op, options);
        winsize = window.getSize();
        winscroll = window.getScroll();
        asize = options.relativeTo.getSize();
        position = options.relativeTo.getPosition();
        size = this.getSize();
        if (options.position.x === 'auto') {
          if ((position.x + size.x + asize.x) > (winsize.x - winscroll.x)) {
            options.position.x = 'left';
          } else {
            options.position.x = 'right';
          }
        }
        if (options.position.y === 'auto') {
          if ((position.y + size.y + asize.y) > (winsize.y - winscroll.y)) {
            options.position.y = 'top';
          } else {
            options.position.y = 'bottom';
          }
        }
        ofa = {
          x: 0,
          y: 0
        };
        switch (options.position.x) {
          case 'center':
            if (options.position.y !== 'center') {
              ofa.x = -size.x / 2;
            }
            break;
          case 'left':
            ofa.x = -(options.offset + size.x);
            break;
          case 'right':
            ofa.x = options.offset;
        }
        switch (options.position.y) {
          case 'center':
            if (options.position.x !== 'center') {
              ofa.y = -size.y / 2;
            }
            break;
          case 'top':
            ofa.y = -(options.offset + size.y);
            break;
          case 'bottom':
            ofa.y = options.offset;
        }
        options.offset = ofa;
      } else {
        options.relativeTo = document.body;
        options.position = {
          x: 'center',
          y: 'center'
        };
        if (typeOf(options.offset !== 'object')) {
          options.offset = {
            x: 0,
            y: 0
          };
        }
      }
      return this.oldPosition.attempt(options, this);
    },
    removeTransition: function() {
      this.store('transition', this.getStyle('-webkit-transition-duration'));
      return this.setStyle('-webkit-transition-duration', '0');
    },
    addTransition: function() {
      this.setStyle('-webkit-transition-duration', this.retrieve('transition'));
      return this.eliminate('transition');
    },
    inTheDom: function() {
      if (this.parentNode) {
        if (this.parentNode.tagName.toLowerCase() === "html") {
          return true;
        } else {
          return $(this.parentNode).inTheDom;
        }
      } else {
        return false;
      }
    },
    grab: function(el, where) {
      var e;
      this.oldGrab.attempt(arguments, this);
      e = document.id(el);
      if (e.fireEvent != null) {
        e.fireEvent('addedToDom');
      }
      return this;
    },
    inject: function(el, where) {
      this.oldInject.attempt(arguments, this);
      this.fireEvent('addedToDom');
      return this;
    },
    adopt: function() {
      var elements;
      this.oldAdopt.attempt(arguments, this);
      elements = Array.flatten(arguments);
      elements.each(function(el) {
        var e;
        e = document.id(el);
        if (e.fireEvent != null) {
          return document.id(el).fireEvent('addedToDom');
        }
      });
      return this;
    }
  });
})();
/*
---
name: Class.Extras
description: Extra suff for Classes.

license: MIT-style

authors:
  - Kevin Valdek
  - Perrin Westrich
  - Maksim Horbachevsky
provides:
  - Class.Extras
...
*/
Class.Singleton = new Class({
  initialize: function(classDefinition, options) {
    var singletonClass;
    singletonClass = new Class(classDefinition);
    return new singletonClass(options);
  }
});
Class.Mutators.Delegates = function(delegations) {
  return new Hash(delegations).each(function(delegates, target) {
    return $splat(delegates).each(function(delegate) {
      return this.prototype[delegate] = function() {
        var ret;
        ret = this[target][delegate].apply(this[target], arguments);
        if (ret === this[target]) {
          return this;
        } else {
          return ret;
        }
      };
    }, this);
  }, this);
};
mergeOneNew = function(source, key, current) {
  switch (typeOf(current)) {
    case 'object':
      if (typeOf(source[key]) === 'object') {
        Object.mergeNew(source[key], current);
      } else {
        source[key] = Object.clone(current);
      }
      break;
    case 'array':
      source[key] = current.clone();
      break;
    case 'function':
      current.prototype.parent = source[key];
      source[key] = current;
      break;
    default:
      source[key] = current;
  }
  return source;
};
Object.extend({
  mergeNew: function(source, k, v) {
    var i, object, _ref;
    if (typeOf(k) === 'string') {
      return mergeOneNew(source, k, v);
    }
    for (i = 1, _ref = arguments.length - 1; (1 <= _ref ? i <= _ref : i >= _ref); (1 <= _ref ? i += 1 : i -= 1)) {
      object = arguments[i];
      Object.each(object, function(value, key) {
        return mergeOneNew(source, key, value);
      });
    }
    return source;
  }
});
define(null, "Class.Mutators.Attributes", function() {
  return function(attributes) {
    var $getter, $setter;
    $setter = attributes.$setter;
    $getter = attributes.$getter;
    if (this.prototype.$attributes) {
      attributes = Object.mergeNew(this.prototype.$attributes, attributes);
    }
    delete attributes.$setter;
    delete attributes.$getter;
    this.implement(new Events);
    return this.implement({
      $attributes: attributes,
      get: function(name) {
        var attr;
        attr = this.$attributes[name];
        if (attr) {
          if (attr.valueFn && !attr.initialized) {
            attr.initialized = true;
            attr.value = attr.valueFn.call(this);
          }
          if (attr.getter) {
            return attr.getter.call(this, attr.value);
          } else {
            return attr.value;
          }
        } else {
          if ($getter) {
            return $getter.call(this, name);
          } else {
            return;
          }
        }
      },
      set: function(name, value) {
        var attr, newVal, oldVal;
        attr = this.$attributes[name];
        if (attr) {
          if (!attr.readOnly) {
            oldVal = attr.value;
            if (!attr.validator || attr.validator.call(this, value)) {
              if (attr.setter) {
                newVal = attr.setter.call(this, value, oldVal, attr.setter);
              } else {
                newVal = value;
              }
              attr.value = newVal;
              this[name] = newVal;
              this.update();
              if (oldVal !== newVal) {
                this.fireEvent(name + 'Change', {
                  newVal: newVal,
                  oldVal: oldVal
                });
              }
              return newVal;
            }
          }
        } else if ($setter) {
          return $setter.call(this, name, value);
        }
      },
      setAttributes: function(attributes) {
        attributes = Object.merge({}, attributes);
        return Object.each(this.$attributes, function(value, name) {
          if (attributes[name] != null) {
            return this.set(name, attributes[name]);
          } else if (value.value != null) {
            return this.set(name, value.value);
          }
        }, this);
      },
      getAttributes: function() {
        attributes = {};
        $each(this.$attributes, function(value, name) {
          return attributes[name] = this.get(name);
        }, this);
        return attributes;
      },
      addAttributes: function(attributes) {
        return $each(attributes, function(value, name) {
          return this.addAttribute(name, value);
        }, this);
      },
      addAttribute: function(name, value) {
        this.$attributes[name] = value;
        return this;
      }
    });
  };
});
define(null, "Lattice", function() {
  return new Class.Singleton({
    Elements: [],
    Prefix: 'blender',
    Selectors: {},
    initialize: function() {
      Array.from(document.styleSheets).each(__bind(function(stylesheet) {
        if (stylesheet.cssRules != null) {
          return Array.from(stylesheet.cssRules).each(__bind(function(rule) {
            var exp, sel, sexp, _i, _len, _ref, _results;
            try {
              sexp = Slick.parse(rule.selectorText);
              _ref = sexp.expressions;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                exp = _ref[_i];
                _results.push(exp[0].pseudos === void 0 && exp[0].combinator === " " && exp[0].classList !== void 0 && exp.length === 1 ? exp[0].classList[0].test(new RegExp("^" + this.Prefix)) ? (sel = exp[0].classList.join('.'), this.Selectors[sel] === void 0 ? this.Selectors[sel] = {} : void 0, Array.from(rule.style).each(__bind(function(style) {
                  return this.Selectors[sel][style] = rule.style.getPropertyValue(style);
                }, this))) : void 0 : void 0);
              }
              return _results;
            } catch (e) {
              if (typeof console != "undefined" && console !== null) {
                if (console.log != null) {
                  return console.log(e);
                }
              }
            }
          }, this));
        }
      }, this));
      return this;
    },
    changePrefix: function(newPrefix) {
      this.Elements.each(__bind(function(el) {
        var a, cls;
        a = el["class"].split('-');
        cls = a.erase(a[0]).join('-');
        this.Prefix = newPrefix;
        return el.set('class', this.buildClass(cls));
      }, this));
      return null;
    },
    buildClass: function(cls) {
      return this.Prefix + "-" + cls;
    },
    getCSS: function(selector, property) {
      if (selector.test(/^\./)) {
        selector = selector.slice(1, selector.length);
      }
      if (this.Selectors[selector] != null) {
        return this.Selectors[selector][property] || null;
      }
    }
  });
});
define(["Data.Abstract", "Core.Slider"], "Data.Number", function() {
  return new Class({
    Extends: Core.Slider,
    Attributes: {
      "class": {
        value: Lattice.buildClass('number'),
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old, self.prototype.parent);
          this.textLabel.replaceClass("" + value + "-text", "" + old + "-text");
          return value;
        }
      },
      range: {
        value: 0
      },
      reset: {
        value: true
      },
      steps: {
        value: 100
      },
      label: {
        value: null
      }
    },
    create: function() {
      this.parent();
      this.textLabel = new Element("div");
      this.textLabel.setStyles({
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        top: 0
      });
      this.base.grab(this.textLabel);
      return this.addEvent('step', __bind(function(e) {
        return this.fireEvent('change', e);
      }, this));
    },
    update: function() {
      return this.textLabel.set('text', this.label != null ? this.label + " : " + this.value : this.value);
    }
  });
});
UnitList = {
  px: "px",
  '%': "%",
  em: "em",
  ex: "ex",
  gd: "gd",
  rem: "rem",
  vw: "vw",
  vh: "vh",
  vm: "vm",
  ch: "ch",
  "in": "in",
  mm: "mm",
  pt: "pt",
  pc: "pc",
  cm: "cm",
  deg: "deg",
  grad: "grad",
  rad: "rad",
  turn: "turn",
  s: "s",
  ms: "ms",
  Hz: "Hz",
  kHz: "kHz"
};
define(["Data.Abstract", "Data.Number", "Data.Select", "Interfaces.Children", "Interfaces.Enabled", "Interfaces.Size"], "Data.Unit", function() {
  return new Class({
    Extends: Data.Abstract,
    Implements: [Interfaces.Children, Interfaces.Enabled, Interfaces.Size],
    Binds: ['update'],
    Attributes: {
      "class": {
        value: Lattice.buildClass('unit')
      },
      value: {
        setter: function(value) {
          var match, unit;
          if (typeof value === 'string') {
            match = value.match(/(-?\d*)(.*)/);
            value = match[1];
            unit = match[2];
            this.sel.set('value', unit);
            return this.number.set('value', value);
          }
        },
        getter: function() {
          return String.from(this.number.value + this.sel.value);
        }
      }
    },
    update: function() {
      return this.fireEvent('change', String.from(this.number.value + this.sel.get('value')));
    },
    create: function() {
      this.addEvent('sizeChange', __bind(function() {
        return this.number.set('size', this.size - this.sel.get('size'));
      }, this));
      this.number = new Data.Number({
        range: [-50, 50],
        reset: true,
        steps: [100]
      });
      this.sel = new Data.Select({
        size: 80
      });
      Object.each(UnitList, __bind(function(item) {
        return this.sel.addItem(new Iterable.ListItem({
          label: item,
          removeable: false,
          draggable: false
        }));
      }, this));
      this.sel.set('value', 'px');
      this.number.addEvent('change', this.update);
      this.sel.addEvent('change', this.update);
      return this.adoptChildren(this.number, this.sel);
    },
    ready: function() {
      return this.set('size', this.size);
    }
  });
});
define(["Core.Slot", "Data.Abstract", "Iterable.ListItem", "Interfaces.Children", "Interfaces.Enabled"], "Data.DateTime", function() {
  return new Class({
    Extends: Data.Abstract,
    Implements: [Interfaces.Children, Interfaces.Enabled, Interfaces.Size],
    Attributes: {
      "class": {
        value: Lattice.buildClass('date-time')
      },
      value: {
        value: new Date(),
        setter: function(value) {
          this.value = value;
          this.updateSlots();
          return value;
        }
      },
      time: {
        readonly: true,
        value: true
      },
      date: {
        readonly: true,
        value: true
      }
    },
    create: function() {
      this.yearFrom = 1950;
      if (this.get('date')) {
        this.days = new Core.Slot();
        this.month = new Core.Slot();
        this.years = new Core.Slot();
      }
      if (this.get('time')) {
        this.hours = new Core.Slot();
        this.minutes = new Core.Slot();
      }
      this.populate();
      if (this.get('time')) {
        this.hours.addEvent('change', __bind(function(item) {
          this.value.set('hours', item.value);
          return this.update();
        }, this));
        this.minutes.addEvent('change', __bind(function(item) {
          this.value.set('minutes', item.value);
          return this.update();
        }, this));
      }
      if (this.get('date')) {
        this.years.addEvent('change', __bind(function(item) {
          this.value.set('year', item.value);
          return this.update();
        }, this));
        this.month.addEvent('change', __bind(function(item) {
          this.value.set('month', item.value);
          return this.update();
        }, this));
        this.days.addEvent('change', __bind(function(item) {
          this.value.set('date', item.value);
          return this.update();
        }, this));
      }
      return this;
    },
    populate: function() {
      var i, item, _results;
      if (this.get('time')) {
        i = 0;
        while (i < 24) {
          item = new Iterable.ListItem({
            label: (i < 10 ? '0' + i : i),
            removeable: false
          });
          item.value = i;
          this.hours.addItem(item);
          i++;
        }
        i = 0;
        while (i < 60) {
          item = new Iterable.ListItem({
            label: (i < 10 ? '0' + i : i),
            removeable: false
          });
          item.value = i;
          this.minutes.addItem(item);
          i++;
        }
      }
      if (this.get('date')) {
        i = 0;
        while (i < 30) {
          item = new Iterable.ListItem({
            label: (i < 10 ? '0' + i : i),
            removeable: false
          });
          item.value = i + 1;
          this.days.addItem(item);
          i++;
        }
        i = 0;
        while (i < 12) {
          item = new Iterable.ListItem({
            label: (i < 10 ? '0' + i : i),
            removeable: false
          });
          item.value = i;
          this.month.addItem(item);
          i++;
        }
        i = this.yearFrom;
        _results = [];
        while (i <= new Date().get('year')) {
          item = new Iterable.ListItem({
            label: i,
            removeable: false
          });
          item.value = i;
          this.years.addItem(item);
          _results.push(i++);
        }
        return _results;
      }
    },
    update: function() {
      var buttonwidth, last;
      this.fireEvent('change', this.value);
      buttonwidth = Math.floor(this.size / this.children.length);
      this.children.each(function(btn) {
        return btn.set('size', buttonwidth);
      });
      if (last = this.children.getLast()) {
        last.set('size', this.size - buttonwidth * (this.children.length - 1));
      }
      return this.updateSlots();
    },
    ready: function() {
      if (this.get('date')) {
        this.adoptChildren(this.years, this.month, this.days);
      }
      if (this.get('time')) {
        this.adoptChildren(this.hours, this.minutes);
      }
      return this.update();
    },
    updateSlots: function() {
      var cdays, i, item, listlength;
      if (this.get('date') && this.value) {
        cdays = this.value.get('lastdayofmonth');
        listlength = this.days.list.children.length;
        if (cdays > listlength) {
          i = listlength + 1;
          while (i <= cdays) {
            item = new Iterable.ListItem({
              label: i
            });
            item.value = i;
            this.days.addItem(item);
            i++;
          }
        } else if (cdays < listlength) {
          i = listlength;
          while (i > cdays) {
            this.days.list.removeItem(this.days.list.children[i - 1]);
            i--;
          }
        }
        this.days.list.set('selected', this.days.list.children[this.value.get('date') - 1]);
        this.month.list.set('selected', this.month.list.children[this.value.get('month')]);
        this.years.list.set('selected', this.years.list.getItemFromLabel(this.value.get('year')));
      }
      if (this.get('time') && this.value) {
        this.hours.list.set('selected', this.hours.list.children[this.value.get('hours')]);
        return this.minutes.list.set('selected', this.minutes.list.children[this.value.get('minutes')]);
      }
    }
  });
});
define("Data.DateTime", "Data.Time", function() {
  return new Class({
    Extends: Data.DateTime,
    Attributes: {
      "class": {
        value: Lattice.buildClass('time')
      },
      date: {
        value: false
      }
    }
  });
});
define("Data.DateTime", "Data.Date", function() {
  return new Class({
    Extends: Data.DateTime,
    Attributes: {
      "class": {
        value: Lattice.buildClass('date')
      },
      time: {
        value: false
      }
    }
  });
});
define(["Data.Abstract", "Data.Color", "Interfaces.Children", "Interfaces.Enabled", "Interfaces.Size"], "Data.ColorWheel", function() {
  return new Class({
    Extends: Data.Abstract,
    Implements: [Interfaces.Children, Interfaces.Enabled, Interfaces.Size],
    Attributes: {
      "class": {
        value: Lattice.buildClass('color')
      },
      value: {
        setter: function(value) {
          return this.colorData.set('value', value);
        }
      },
      wrapperClass: {
        value: 'wrapper',
        setter: function(value, old) {
          this.wrapper.replaceClass("" + this["class"] + "-" + value, "" + this["class"] + "-" + old);
          return value;
        }
      },
      knobClass: {
        value: 'xyknob',
        setter: function(value, old) {
          this.knob.replaceClass("" + this["class"] + "-" + value, "" + this["class"] + "-" + old);
          return value;
        }
      }
    },
    create: function() {
      this.hslacone = $(document.createElement('canvas'));
      this.background = $(document.createElement('canvas'));
      this.wrapper = new Element('div');
      this.knob = new Element('div');
      this.knob.setStyles({
        'position': 'absolute',
        'z-index': 1
      });
      this.colorData = new Data.Color();
      this.colorData.addEvent('change', __bind(function(e) {
        return this.fireEvent('change', e);
      }, this));
      this.base.adopt(this.wrapper);
      this.colorData.lightnessData.addEvent('change', __bind(function(step) {
        return this.hslacone.setStyle('opacity', step / 100);
      }, this));
      this.colorData.hueData.addEvent('change', __bind(function(value) {
        return this.positionKnob(value, this.colorData.get('saturation'));
      }, this));
      this.colorData.saturationData.addEvent('change', __bind(function(value) {
        return this.positionKnob(this.colorData.get('hue'), value);
      }, this));
      this.background.setStyles({
        'position': 'absolute',
        'z-index': 0
      });
      this.hslacone.setStyles({
        'position': 'absolute',
        'z-index': 1
      });
      this.xy = new Drag.Move(this.knob);
      this.xy.addEvent('beforeStart', __bind(function(el, e) {
        return this.lastPosition = el.getPosition(this.wrapper);
      }, this));
      this.xy.addEvent('drag', __bind(function(el, e) {
        var an, position, sat, x, y;
        if (this.enabled) {
          position = el.getPosition(this.wrapper);
          x = this.center.x - position.x - this.knobSize.x / 2;
          y = this.center.y - position.y - this.knobSize.y / 2;
          this.radius = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
          this.angle = Math.atan2(y, x);
          if (this.radius > this.halfWidth) {
            el.setStyle('top', -Math.sin(this.angle) * this.halfWidth - this.knobSize.y / 2 + this.center.y);
            el.setStyle('left', -Math.cos(this.angle) * this.halfWidth - this.knobSize.x / 2 + this.center.x);
            this.saturation = 100;
          } else {
            sat = Math.round(this.radius);
            this.saturation = Math.round((sat / this.halfWidth) * 100);
          }
          an = Math.round(this.angle * (180 / Math.PI));
          this.hue = an < 0 ? 180 - Math.abs(an) : 180 + an;
          this.colorData.set('hue', this.hue);
          return this.colorData.set('saturation', this.saturation);
        } else {
          return el.setPosition(this.lastPosition);
        }
      }, this));
      this.wrapper.adopt(this.background, this.hslacone, this.knob);
      return this.addChild(this.colorData);
    },
    drawHSLACone: function(width) {
      var ang, angle, c, c1, ctx, grad, i, w2, _ref, _results;
      ctx = this.background.getContext('2d');
      ctx.fillStyle = "#000";
      ctx.beginPath();
      ctx.arc(width / 2, width / 2, width / 2, 0, Math.PI * 2, true);
      ctx.closePath();
      ctx.fill();
      ctx = this.hslacone.getContext('2d');
      ctx.translate(width / 2, width / 2);
      w2 = -width / 2;
      ang = width / 50;
      angle = (1 / ang) * Math.PI / 180;
      i = 0;
      _results = [];
      for (i = 0, _ref = 360 * ang - 1; (0 <= _ref ? i <= _ref : i >= _ref); (0 <= _ref ? i += 1 : i -= 1)) {
        c = $HSB(360 + (i / ang), 100, 100);
        c1 = $HSB(360 + (i / ang), 0, 100);
        grad = ctx.createLinearGradient(0, 0, width / 2, 0);
        grad.addColorStop(0, c1.hex);
        grad.addColorStop(1, c.hex);
        ctx.strokeStyle = grad;
        ctx.beginPath();
        ctx.moveTo(0, 0);
        ctx.lineTo(width / 2, 0);
        ctx.stroke();
        _results.push(ctx.rotate(angle));
      }
      return _results;
    },
    update: function() {
      this.hslacone.set('width', this.size);
      this.hslacone.set('height', this.size);
      this.background.set('width', this.size);
      this.background.set('height', this.size);
      this.wrapper.setStyle('height', this.size);
      if (this.size > 0) {
        this.drawHSLACone(this.size);
      }
      this.colorData.set('size', this.size);
      this.knobSize = this.knob.getSize();
      this.halfWidth = this.size / 2;
      this.center = {
        x: this.halfWidth,
        y: this.halfWidth
      };
      return this.positionKnob(this.colorData.get('hue'), this.colorData.get('saturation'));
    },
    positionKnob: function(hue, saturation) {
      this.radius = saturation / 100 * this.halfWidth;
      this.angle = -((180 - hue) * (Math.PI / 180));
      this.knob.setStyle('top', -Math.sin(this.angle) * this.radius - this.knobSize.y / 2 + this.center.y);
      return this.knob.setStyle('left', -Math.cos(this.angle) * this.radius - this.knobSize.x / 2 + this.center.x);
    },
    ready: function() {
      return this.update();
    }
  });
});
define(["Data.Abstract", "Data.Number", "Buttons.Toggle", "Groups.Toggles", "Interfaces.Children", "Interfaces.Enabled", "Interfaces.Size"], "Data.Color", function() {
  return new Class({
    Extends: Data.Abstract,
    Binds: ['update'],
    Implements: [Interfaces.Children, Interfaces.Enabled, Interfaces.Size],
    Attributes: {
      "class": {
        value: Lattice.buildClass('color')
      },
      hue: {
        value: 0,
        setter: function(value) {
          this.hueData.set('value', value);
          return value;
        },
        getter: function() {
          return this.hueData.value;
        }
      },
      saturation: {
        value: 0,
        setter: function(value) {
          this.saturationData.set('value', value);
          return value;
        },
        getter: function() {
          return this.saturationData.value;
        }
      },
      lightness: {
        value: 100,
        setter: function(value) {
          this.lightnessData.set('value', value);
          return value;
        },
        getter: function() {
          return this.lightnessData.value;
        }
      },
      alpha: {
        value: 100,
        setter: function(value) {
          this.alphaData.set('value', value);
          return value;
        },
        getter: function() {
          return this.alphaData.value;
        }
      },
      type: {
        value: 'hex',
        setter: function(value) {
          this.col.children.each(function(item) {
            if (item.label === value) {
              return this.col.set('active', item);
            }
          }, this);
          return value;
        },
        getter: function() {
          if (this.col.active != null) {
            return this.col.active.label;
          }
        }
      },
      value: {
        value: new Color('#fff'),
        setter: function(value) {
          console.log(value.hsb[0], value.hsb[1], value.hsb[2]);
          this.set('hue', value.hsb[0]);
          this.set('saturation', value.hsb[1]);
          this.set('lightness', value.hsb[2]);
          this.set('type', value.type);
          return this.set('alpha', value.alpha);
        }
      }
    },
    ready: function() {
      return this.update();
    },
    update: function() {
      var alpha, hue, lightness, ret, saturation, type;
      hue = this.get('hue');
      saturation = this.get('saturation');
      lightness = this.get('lightness');
      type = this.get('type');
      alpha = this.get('alpha');
      if ((hue != null) && (saturation != null) && (lightness != null) && (type != null) && (alpha != null)) {
        ret = $HSB(hue, saturation, lightness);
        ret.setAlpha(alpha);
        ret.setType(type);
        return this.fireEvent('change', new Hash(ret));
      }
    },
    create: function() {
      this.addEvent('sizeChange', __bind(function() {
        this.hueData.set('size', this.size);
        this.saturationData.set('size', this.size);
        this.lightnessData.set('size', this.size);
        this.alphaData.set('size', this.size);
        return this.col.set('size', this.size);
      }, this));
      this.hueData = new Data.Number({
        range: [0, 360],
        reset: false,
        steps: 360,
        label: 'Hue'
      });
      this.saturationData = new Data.Number({
        range: [0, 100],
        reset: false,
        steps: 100,
        label: 'Saturation'
      });
      this.lightnessData = new Data.Number({
        range: [0, 100],
        reset: false,
        steps: 100,
        label: 'Value'
      });
      this.alphaData = new Data.Number({
        range: [0, 100],
        reset: false,
        steps: 100,
        label: 'Alpha'
      });
      this.col = new Groups.Toggles();
      ['rgb', 'rgba', 'hsl', 'hsla', 'hex'].each(__bind(function(item) {
        return this.col.addItem(new Buttons.Toggle({
          label: item
        }));
      }, this));
      this.hueData.addEvent('change', this.update);
      this.saturationData.addEvent('change', this.update);
      this.lightnessData.addEvent('change', this.update);
      this.alphaData.addEvent('change', this.update);
      this.col.addEvent('change', this.update);
      return this.adoptChildren(this.hueData, this.saturationData, this.lightnessData, this.alphaData, this.col);
    }
  });
});
define("Core.Abstract", "Data.Abstract", function() {
  return new Class({
    Extends: Core.Abstract,
    Attributes: {
      value: {
        value: null
      }
    }
  });
});
define(["Interfaces.Controls", "Interfaces.Children", "Interfaces.Enabled", "Interfaces.Size", "Core.Picker", "Iterable.List", "Data.Abstract", "Dialog.Prompt"], "Data.Select", function() {
  return new Class({
    Extends: Data.Abstract,
    Implements: [Interfaces.Controls, Interfaces.Children, Interfaces.Enabled, Interfaces.Size],
    Attributes: {
      "class": {
        value: Lattice.buildClass('select'),
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old);
          this.text.replaceClass("" + value + "-text", "" + old + "-text");
          this.removeIcon.set('class', value + "-remove");
          this.addIcon.set('class', value + "-add");
          this.list.set('class', value + "-list");
          return value;
        }
      },
      "default": {
        value: '',
        setter: function(value, old) {
          if (this.text.get('text') === (old || '')) {
            this.text.set('text', value);
          }
          return value;
        }
      },
      selected: {
        getter: function() {
          return this.list.get('selected');
        }
      },
      editable: {
        value: true,
        setter: function(value) {
          if (value) {
            this.adoptChildren(this.removeIcon, this.addIcon);
          } else {
            this.removeChild(this.removeIcon);
            this.removeChild(this.addIcon);
          }
          return value;
        }
      },
      value: {
        setter: function(value) {
          return this.list.set('selected', this.list.getItemFromLabel(value));
        },
        getter: function() {
          var li;
          li = this.list.get('selected');
          if (li != null) {
            return li.label;
          }
        }
      }
    },
    ready: function() {
      return this.set('size', this.size);
    },
    create: function() {
      this.addEvent('sizeChange', __bind(function() {
        return this.list.setStyle('width', this.size < this.minSize ? this.minSize : this.size);
      }, this));
      this.base.setStyle('position', 'relative');
      this.text = new Element('div');
      this.text.setStyles({
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        'z-index': 0,
        overflow: 'hidden'
      });
      this.text.addEvent('mousewheel', __bind(function(e) {
        var index;
        e.stop();
        index = this.list.items.indexOf(this.list.selected) + e.wheel;
        if (index < 0) {
          index = this.list.items.length - 1;
        }
        if (index === this.list.items.length) {
          index = 0;
        }
        return this.list.set('selected', this.list.items[index]);
      }, this));
      this.addIcon = new Core.Icon();
      this.addIcon.base.set('text', '+');
      this.removeIcon = new Core.Icon();
      this.removeIcon.base.set('text', '-');
      $$(this.addIcon.base, this.removeIcon.base).setStyles({
        'z-index': '1',
        'position': 'relative'
      });
      this.removeIcon.addEvent('invoked', __bind(function(el, e) {
        e.stop();
        if (this.enabled) {
          this.removeItem(this.list.get('selected'));
          return this.text.set('text', this["default"] || '');
        }
      }, this));
      this.addIcon.addEvent('invoked', __bind(function(el, e) {
        e.stop();
        if (this.enabled) {
          return this.prompt.show();
        }
      }, this));
      this.picker = new Core.Picker({
        offset: 0,
        position: {
          x: 'center',
          y: 'auto'
        }
      });
      this.picker.attach(this.base, false);
      this.base.addEvent('click', __bind(function(e) {
        if (this.enabled) {
          return this.picker.show(e);
        }
      }, this));
      this.list = new Iterable.List({
        "class": Lattice.buildClass('select-list')
      });
      this.picker.set('content', this.list);
      this.base.adopt(this.text);
      this.prompt = new Dialog.Prompt();
      this.prompt.set('label', 'Add item:');
      this.prompt.attach(this.base, false);
      this.prompt.addEvent('invoked', __bind(function(value) {
        var item;
        if (value) {
          item = new Iterable.ListItem({
            label: value,
            removeable: false,
            draggable: false
          });
          this.addItem(item);
          this.list.set('selected', item);
        }
        return this.prompt.hide(null, true);
      }, this));
      this.list.addEvent('selectedChange', __bind(function() {
        var item;
        item = this.list.selected;
        if (item != null) {
          this.text.set('text', item.label);
          this.fireEvent('change', item.label);
        } else {
          this.text.set('text', '');
        }
        return this.picker.hide(null, true);
      }, this));
      return this.update();
    },
    addItem: function(item) {
      return this.list.addItem(item);
    },
    removeItem: function(item) {
      return this.list.removeItem(item);
    }
  });
});
define(["Data.Abstract", "Interfaces.Size", "Interfaces.Enabled"], "Data.Text", function() {
  return new Class({
    Extends: Data.Abstract,
    Implements: [Interfaces.Size, Interfaces.Enabled],
    Binds: ['update'],
    Attributes: {
      "class": {
        value: Lattice.buildClass('textarea')
      },
      value: {
        setter: function(value) {
          this.text.set('value', value);
          return value;
        },
        getter: function() {
          return this.text.get('value');
        }
      }
    },
    update: function() {
      return this.text.setStyle('width', this.size - 10);
    },
    create: function() {
      this.text = new Element('textarea');
      this.addEvent('enabledChange', __bind(function(obj) {
        console.log(obj);
        if (obj.newVal) {
          return this.text.set('disabled', false);
        } else {
          return this.text.set('disabled', true);
        }
      }, this));
      this.base.grab(this.text);
      return this.text.addEvent('keyup', __bind(function() {
        this.set('value', this.get('value'));
        return this.fireEvent('change', this.get('value'));
      }, this));
    }
  });
});
define("Data.Abstract", "Data.Table", function() {
  return new Class({
    Extends: Data.Abstract,
    Binds: ['update'],
    Attributes: {
      "class": {
        value: Lattice.buildClass('table'),
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old);
          this.hremove.set('class', value + "-remove");
          this.hadd.set('class', value + "-add");
          this.vremove.set('class', value + "-remove");
          this.vadd.set('class', value + "-add");
          return value;
        }
      },
      value: {
        setter: function(value) {
          this.base.empty();
          value.each(function(it) {
            var tr;
            tr = new Element('tr');
            this.base.grab(tr);
            return it.each(function(v) {
              return tr.grab(new Element('td', {
                text: v
              }));
            }, this);
          }, this);
          this.fireEvent('change', this.get('value'));
          return value;
        },
        getter: function() {
          var ret, td, tr, tra, _i, _j, _len, _len2, _ref, _ref2;
          ret = [];
          _ref = this.base.children;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            tr = _ref[_i];
            tra = [];
            _ref2 = tr.children;
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              td = _ref2[_j];
              tra.push(td.get('text'));
            }
            ret.push(tra);
          }
          return ret;
        }
      }
    },
    create: function() {
      this.loc = {
        h: 0,
        v: 0
      };
      delete this.base;
      this.base = new Element('table');
      this.base.grab(new Element('tr').grab(new Element('td')));
      this.columns = 5;
      this.rows = 1;
      this.input = new Element('input');
      this.setupIcons();
      return this.setupEvents();
    },
    setupEvents: function() {
      this.hadd.addEvent('invoked', this.addColumn.bind(this));
      this.hremove.addEvent('invoked', this.removeColumn.bind(this));
      this.vadd.addEvent('invoked', this.addRow.bind(this));
      this.vremove.addEvent('invoked', this.removeRow.bind(this));
      this.icg1.base.addEvent('mouseenter', this.suspendIcons.bind(this));
      this.icg1.base.addEvent('mouseleave', this.hideIcons.bind(this));
      this.icg2.base.addEvent('mouseenter', this.suspendIcons.bind(this));
      this.icg2.base.addEvent('mouseleave', this.hideIcons.bind(this));
      this.base.addEvent('mouseleave', __bind(function(e) {
        this.id1 = this.icg1.hide.delay(400, this.icg1);
        return this.id2 = this.icg2.hide.delay(400, this.icg2);
      }, this));
      this.base.addEvent('mouseenter', __bind(function(e) {
        this.suspendIcons();
        this.icg1.show();
        return this.icg2.show();
      }, this));
      this.base.addEvent('mouseenter:relay(td)', __bind(function(e) {
        return this.positionIcons(e.target);
      }, this));
      this.input.addEvent('blur', __bind(function() {
        this.input.dispose();
        this.editTarget.set('text', this.input.get('value'));
        return this.fireEvent('change', this.get('value'));
      }, this));
      return this.base.addEvent('click:relay(td)', __bind(function(e) {
        var size;
        if (this.input.isVisible()) {
          this.input.dispose();
          this.editTarget.set('text', this.input.get('value'));
        }
        this.input.set('value', e.target.get('text'));
        size = e.target.getSize();
        this.input.setStyles({
          width: size.x,
          height: size.y
        });
        this.editTarget = e.target;
        e.target.set('text', '');
        e.target.grab(this.input);
        return this.input.focus();
      }, this));
    },
    positionIcons: function(target) {
      var pos, pos1, size, size2;
      pos = target.getPosition();
      pos1 = this.base.getPosition();
      size = this.icg1.base.getSize();
      size2 = this.base.getSize();
      this.icg1.setStyle('left', pos.x);
      this.icg1.setStyle('top', pos1.y - size.y);
      this.icg2.setStyle('top', pos.y);
      this.icg2.setStyle('left', pos1.x + size2.x);
      this.loc = this.getLocation(target);
      this.target = target;
      this.vremove.set('enabled', this.base.children.length > 1);
      return this.hremove.set('enabled', this.base.children[0].children.length > 1);
    },
    setupIcons: function() {
      this.icg1 = new Groups.Icons();
      this.icg2 = new Groups.Icons();
      this.hadd = new Core.Icon();
      this.hremove = new Core.Icon();
      this.vadd = new Core.Icon();
      this.vremove = new Core.Icon();
      this.hadd.base.set('text', '+');
      this.hremove.base.set('text', '-');
      this.vadd.base.set('text', '+');
      this.vremove.base.set('text', '-');
      this.icg1.addItem(this.hadd);
      this.icg1.addItem(this.hremove);
      this.icg2.addItem(this.vadd);
      this.icg2.addItem(this.vremove);
      this.icg1.setStyle('position', 'absolute');
      this.icg2.setStyle('position', 'absolute');
      document.body.adopt(this.icg1, this.icg2);
      return this.hideIcons();
    },
    suspendIcons: function() {
      if (this.id1 != null) {
        clearTimeout(this.id1);
        this.id1 = null;
      }
      if (this.id2 != null) {
        clearTimeout(this.id2);
        return this.id2 = null;
      }
    },
    hideIcons: function() {
      this.icg1.hide();
      return this.icg2.hide();
    },
    getLocation: function(td) {
      var children, i, ret, tr, _ref, _ref2;
      ret = {
        h: 0,
        v: 0
      };
      tr = td.getParent('tr');
      children = tr.getChildren();
      for (i = 0, _ref = children.length; (0 <= _ref ? i <= _ref : i >= _ref); (0 <= _ref ? i += 1 : i -= 1)) {
        if (td === children[i]) {
          ret.h = i;
        }
      }
      children = this.base.getChildren();
      for (i = 0, _ref2 = children.length; (0 <= _ref2 ? i <= _ref2 : i >= _ref2); (0 <= _ref2 ? i += 1 : i -= 1)) {
        if (tr === children[i]) {
          ret.v = i;
        }
      }
      return ret;
    },
    testHorizontal: function(where) {
      var w;
      if ((w = Number.from(where)) != null) {
        if (w < this.base.children[0].children.length && w > 0) {
          return this.loc.h = w - 1;
        }
      }
    },
    testVertical: function(where) {
      var w;
      if ((w = Number.from(where)) != null) {
        if (w < this.base.children.length && w > 0) {
          return this.loc.v = w - 1;
        }
      }
    },
    addRow: function(where) {
      var baseChildren, i, tr, trchildren, _ref;
      this.testVertical(where);
      tr = new Element('tr');
      baseChildren = this.base.children;
      trchildren = baseChildren[0].children;
      if (baseChildren.length > 0) {
        baseChildren[this.loc.v].grab(tr, 'before');
      } else {
        this.base.grab(tr);
      }
      for (i = 1, _ref = trchildren.length; (1 <= _ref ? i <= _ref : i >= _ref); (1 <= _ref ? i += 1 : i -= 1)) {
        tr.grab(new Element('td'));
      }
      this.positionIcons(this.base.children[this.loc.v].children[this.loc.h]);
      return this.fireEvent('change', this.get('value'));
    },
    addColumn: function(where) {
      var tr, _i, _len, _ref;
      this.testHorizontal(where);
      _ref = this.base.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tr = _ref[_i];
        tr.children[this.loc.h].grab(new Element('td'), 'before');
      }
      this.positionIcons(this.base.children[this.loc.v].children[this.loc.h]);
      return this.fireEvent('change', this.get('value'));
    },
    removeRow: function(where) {
      this.testVertical(where);
      if (this.base.children.length !== 1) {
        this.base.children[this.loc.v].destroy();
        if (this.base.children[this.loc.v] != null) {
          this.positionIcons(this.base.children[this.loc.v].children[this.loc.h]);
        } else {
          this.positionIcons(this.base.children[this.loc.v - 1].children[this.loc.h]);
        }
      }
      return this.fireEvent('change', this.get('value'));
    },
    removeColumn: function(where) {
      var tr, _i, _len, _ref;
      this.testHorizontal(where);
      if (this.base.children[0].children.length !== 1) {
        _ref = this.base.children;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          tr = _ref[_i];
          tr.children[this.loc.h].destroy();
        }
        if (this.base.children[this.loc.v].children[this.loc.h] != null) {
          this.positionIcons(this.base.children[this.loc.v].children[this.loc.h]);
        } else {
          this.positionIcons(this.base.children[this.loc.v].children[this.loc.h - 1]);
        }
      }
      return this.fireEvent('change', this.get('value'));
    }
  });
});
define(["Dialog.Abstract", "Buttons.Abstract"], "Dialog.Alert", function() {
  return new Class({
    Extends: Dialog.Abstract,
    Attributes: {
      "class": {
        value: Lattice.buildClass('dialog-alert'),
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old);
          this.labelDiv.replaceClass("" + value + "-label", "" + old + "-label");
          return value;
        }
      },
      label: {
        value: '',
        setter: function(value) {
          return this.labelDiv.set('text', value);
        }
      },
      buttonLabel: {
        value: 'Ok',
        setter: function(value) {
          return this.button.set('label', value);
        }
      }
    },
    update: function() {
      this.labelDiv.setStyle('width', this.size);
      this.button.set('size', this.size);
      return this.base.setStyle('width', 'auto');
    },
    create: function() {
      this.parent();
      this.labelDiv = new Element('div');
      this.button = new Buttons.Abstract();
      this.base.adopt(this.labelDiv, this.button);
      return this.button.addEvent('invoked', __bind(function(el, e) {
        this.fireEvent('invoked', [this, e]);
        return this.hide(e, true);
      }, this));
    }
  });
});
define(["Dialog.Abstract", "Buttons.Abstract", "Data.Text"], "Dialog.Prompt", function() {
  return new Class({
    Extends: Dialog.Abstract,
    Attributes: {
      "class": {
        value: Lattice.buildClass('dialog-prompt'),
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old);
          this.labelDiv.replaceClass("" + value + "-label", "" + old + "-label");
          return value;
        }
      },
      label: {
        value: '',
        setter: function(value) {
          return this.labelDiv.set('text', value);
        }
      },
      buttonLabel: {
        value: 'Ok',
        setter: function(value) {
          return this.button.set('label', value);
        }
      }
    },
    update: function() {
      this.labelDiv.setStyle('width', this.size);
      this.button.set('size', this.size);
      this.input.set('size', this.size);
      return this.base.setStyle('width', 'auto');
    },
    create: function() {
      this.parent();
      this.labelDiv = new Element('div');
      this.input = new Data.Text();
      this.button = new Buttons.Abstract();
      this.base.adopt(this.labelDiv, this.input, this.button);
      return this.button.addEvent('invoked', __bind(function(el, e) {
        this.fireEvent('invoked', this.input.get('value'));
        return this.hide(e, true);
      }, this));
    }
  });
});
define(["Dialog.Abstract", "Buttons.Abstract"], "Dialog.Confirm", function() {
  return new Class({
    Extends: Dialog.Abstract,
    Attributes: {
      "class": {
        value: Lattice.buildClass('dialog-confirm'),
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old);
          this.labelDiv.replaceClass("" + value + "-label", "" + old + "-label");
          return value;
        }
      },
      label: {
        value: '',
        setter: function(value) {
          return this.labelDiv.set('text', value);
        }
      },
      okLabel: {
        value: 'Ok',
        setter: function(value) {
          return this.okButton.set('label', value);
        }
      },
      cancelLabel: {
        value: 'Cancel',
        setter: function(value) {
          return this.cancelButton.set('label', value);
        }
      }
    },
    update: function() {
      var cancelsize, oksize;
      this.labelDiv.setStyle('width', this.size);
      this.okButton.set('size', this.size / 2);
      this.cancelButton.set('size', this.size / 2);
      oksize = this.okButton.getSize().x;
      cancelsize = this.cancelButton.getSize().x;
      return this.base.setStyle('width', oksize + cancelsize);
    },
    create: function() {
      this.parent();
      this.labelDiv = new Element('div');
      this.okButton = new Buttons.Abstract();
      this.cancelButton = new Buttons.Abstract();
      $$(this.okButton.base, this.cancelButton.base).setStyle('float', 'left');
      this.base.adopt(this.labelDiv, this.okButton, this.cancelButton, new Element('div', {
        style: "clear: both"
      }));
      this.okButton.addEvent('invoked', __bind(function(el, e) {
        this.fireEvent('invoked', [this, e]);
        return this.hide(e, true);
      }, this));
      return this.cancelButton.addEvent('invoked', __bind(function(el, e) {
        this.fireEvent('cancelled', [this, e]);
        return this.hide(e, true);
      }, this));
    }
  });
});
define(["Core.Abstract", "Buttons.Abstract"], "Dialog.Abstract", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: Interfaces.Size,
    Delegates: {
      picker: ['attach', 'detach']
    },
    Attributes: {
      "class": {
        value: ''
      },
      overlay: {
        value: false
      }
    },
    initialize: function(options) {
      return this.parent(options);
    },
    create: function() {
      this.picker = new Core.Picker();
      return this.overlayEl = new Core.Overlay();
    },
    show: function() {
      this.picker.set('content', this.base);
      this.picker.show(void 0, false);
      if (this.overlay) {
        return document.body.grab(this.overlayEl);
      }
    },
    hide: function(e, force) {
      if (force != null) {
        this.overlayEl.base.dispose();
        this.picker.hide(e, true);
      }
      if (e != null) {
        if (this.base.isVisible() && !this.base.hasChild(e.target) && e.target !== this.base) {
          this.overlayEl.base.dispose();
          return this.picker.hide(e);
        }
      }
    }
  });
});
define(["Core.Abstract", "Interfaces.Enabled", "Interfaces.Controls", "Interfaces.Size"], "Buttons.Abstract", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: [Interfaces.Controls, Interfaces.Enabled, Interfaces.Size],
    Attributes: {
      label: {
        value: '',
        setter: function(value) {
          this.base.set('text', value);
          return value;
        }
      },
      "class": {
        value: Lattice.buildClass('button')
      }
    },
    create: function() {
      return this.base.addEvent('click', __bind(function(e) {
        if (this.enabled) {
          return this.fireEvent('invoked', [this, e]);
        }
      }, this));
    }
  });
});
define("Buttons.Abstract", "Buttons.Toggle", function() {
  return new Class({
    Extends: Buttons.Abstract,
    Attributes: {
      state: {
        value: false,
        setter: function(value, old) {
          if (value) {
            this.base.addClass('pushed');
          } else {
            this.base.removeClass('pushed');
          }
          return value;
        },
        getter: function() {
          return this.base.hasClass('pushed');
        }
      },
      "class": {
        value: Lattice.buildClass('button-toggle')
      }
    },
    create: function() {
      this.addEvent('stateChange', function() {
        return this.fireEvent('invoked', [this, this.state]);
      });
      return this.base.addEvent('click', __bind(function() {
        if (this.enabled) {
          return this.set('state', this.state ? false : true);
        }
      }, this));
    }
  });
});
define("Buttons.Abstract", "Buttons.Key", function() {
  return new Class({
    Extends: Buttons.Abstract,
    Attributes: {
      "class": {
        value: Lattice.buildClass('button-key')
      }
    },
    getShortcut: function(e) {
      var modifiers, specialKey;
      this.specialMap = {
        '~': '`',
        '!': '1',
        '@': '2',
        '#': '3',
        '$': '4',
        '%': '5',
        '^': '6',
        '&': '7',
        '*': '8',
        '(': '9',
        ')': '0',
        '_': '-',
        '+': '=',
        '{': '[',
        '}': ']',
        '\\': '|',
        ':': ';',
        '"': '\'',
        '<': ',',
        '>': '.',
        '?': '/'
      };
      modifiers = '';
      if (e.control) {
        modifiers += 'ctrl ';
      }
      if (event.meta) {
        modifiers += 'meta ';
      }
      if (e.shift) {
        specialKey = this.specialMap[String.fromCharCode(e.code)];
        if (specialKey != null) {
          e.key = specialKey;
        }
        modifiers += 'shift ';
      }
      if (e.alt) {
        modifiers += 'alt ';
      }
      return modifiers + e.key;
    },
    create: function() {
      var stop;
      stop = function(e) {
        return e.stop();
      };
      return this.base.addEvent('click', __bind(function(e) {
        if (this.enabled) {
          this.set('label', 'Press any key!');
          this.base.addClass('active');
          window.addEvent('keydown', stop);
          return window.addEvent('keyup:once', __bind(function(e) {
            var shortcut;
            this.base.removeClass('active');
            shortcut = this.getShortcut(e).toUpperCase();
            if (shortcut !== "ESC") {
              this.set('label', shortcut);
              this.fireEvent('invoked', [this, shortcut]);
            }
            return window.removeEvent('keydown', stop);
          }, this));
        }
      }, this));
    }
  });
});
define(["Core.Abstract", "Interfaces.Enabled", "Interfaces.Size"], "Core.Slot", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: [Interfaces.Enabled, Interfaces.Size],
    Attributes: {
      "class": {
        value: Lattice.buildClass('slot')
      }
    },
    Binds: ['check', 'complete', 'update', 'mouseWheel'],
    Delegates: {
      'list': ['addItem', 'removeAll', 'removeItem']
    },
    create: function() {
      this.base.setStyle('overflow', 'hidden');
      this.base.setStyle('position', 'relative');
      this.overlay = new Element('div', {
        'text': ' '
      });
      this.overlay.addClass('over');
      this.overlay.addEvent('mousewheel', this.mouseWheel);
      this.overlay.setStyles({
        'position': 'absolute',
        'top': 0,
        'left': 0,
        'right': 0,
        'bottom': 0
      });
      this.list = new Iterable.List();
      this.list.base.addEvent('addedToDom', this.update);
      this.list.addEvent('selectedChange', __bind(function(item) {
        this.update();
        return this.fireEvent('change', item.newVal);
      }, this));
      this.list.setStyle('position', 'relative');
      this.list.setStyle('top', '0');
      this.drag = new Drag(this.list.base, {
        modifiers: {
          x: '',
          y: 'top'
        },
        handle: this.overlay
      });
      this.drag.addEvent('drag', this.check);
      this.drag.addEvent('beforeStart', __bind(function() {
        if (!this.enabled) {
          this.disabledTop = this.list.base.getStyle('top');
        }
        return this.list.base.removeTransition();
      }, this));
      return this.drag.addEvent('complete', __bind(function() {
        this.dragging = false;
        return this.update();
      }, this));
    },
    ready: function() {
      return this.base.adopt(this.list, this.overlay);
    },
    check: function(el, e) {
      var lastDistance, lastOne;
      if (this.enabled) {
        this.dragging = true;
        lastDistance = 1000;
        lastOne = null;
        return this.list.children.each(__bind(function(item, i) {
          var distance;
          distance = -item.base.getPosition(this.base).y + this.base.getSize().y / 2;
          if (distance < lastDistance && distance > 0 && distance < this.base.getSize().y / 2) {
            return this.list.set('selected', item);
          }
        }, this));
      } else {
        return el.setStyle('top', this.disabledTop);
      }
    },
    mouseWheel: function(e) {
      var index;
      if (this.enabled) {
        e.stop();
        if (this.list.selected != null) {
          index = this.list.children.indexOf(this.list.selected);
        } else {
          if (e.wheel === 1) {
            index = 0;
          } else {
            index = 1;
          }
        }
        if (index + e.wheel >= 0 && index + e.wheel < this.list.children.length) {
          this.list.set('selected', this.list.children[index + e.wheel]);
        }
        if (index + e.wheel < 0) {
          this.list.set('selected', this.list.children[this.list.children.length - 1]);
        }
        if (index + e.wheel > this.list.children.length - 1) {
          return this.list.set('selected', this.list.children[0]);
        }
      }
    },
    update: function() {
      if (!this.dragging) {
        this.list.base.addTransition();
        if (this.list.selected != null) {
          return this.list.setStyle('top', -this.list.selected.base.getPosition(this.list.base).y + this.base.getSize().y / 2 - this.list.selected.base.getSize().y / 2);
        }
      }
    }
  });
});
define(["Core.Abstract", "Interfaces.Enabled", "Interfaces.Controls"], "Core.Slider", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: [Interfaces.Controls, Interfaces.Enabled],
    Attributes: {
      "class": {
        value: Lattice.buildClass('slider'),
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old);
          this.progress.replaceClass("" + value + "-progress", "" + old + "-progress");
          return value;
        }
      },
      reset: {
        value: false
      },
      steps: {
        value: 100
      },
      range: {
        value: [0, 0]
      },
      mode: {
        value: 'horizontal',
        setter: function(value, old) {
          var size;
          this.base.removeClass(old);
          this.base.addClass(value);
          this.base.set('style', '');
          this.base.setStyle('position', 'relative');
          switch (value) {
            case 'horizontal':
              this.minSize = Number.from(Lattice.getCSS("." + this["class"] + ".horizontal", 'min-width'));
              this.modifier = 'width';
              this.drag.options.modifiers = {
                x: 'width',
                y: ''
              };
              this.drag.options.invert = false;
              if (!(this.size != null)) {
                size = Number.from(Lattice.getCSS("." + this["class"] + ".horizontal", 'width'));
              }
              this.set('size', size);
              this.progress.set('style', '');
              this.progress.setStyles({
                position: 'absolute',
                top: 0,
                bottom: 0,
                left: 0
              });
              break;
            case 'vertical':
              this.minSize = Number.from(Lattice.getCSS("." + this["class"] + ".vertical", 'min-height'));
              this.modifier = 'height';
              this.drag.options.modifiers = {
                x: '',
                y: 'height'
              };
              this.drag.options.invert = true;
              if (!(this.size != null)) {
                size = Number.from(Lattice.getCSS("." + this["class"] + ".vertical", 'height'));
              }
              this.set('size', size);
              this.progress.set('style', '');
              this.progress.setStyles({
                position: 'absolute',
                bottom: 0,
                left: 0,
                right: 0
              });
          }
          if (this.base.isVisible()) {
            this.set('value', this.value);
          }
          return value;
        }
      },
      value: {
        value: 0,
        setter: function(value) {
          var percent;
          value = Number.from(value);
          if (!this.reset) {
            percent = Math.round((value / this.steps) * 100);
            if (value < 0) {
              this.progress.setStyle(this.modifier, 0);
              value = 0;
            }
            if (this.value > this.steps) {
              this.progress.setStyle(this.modifier, this.size);
              value = this.steps;
            }
            if (!(value < 0) && !(value > this.steps)) {
              this.progress.setStyle(this.modifier, (percent / 100) * this.size);
            }
          }
          return value;
        },
        getter: function() {
          if (this.reset) {
            return this.value;
          } else {
            return Number.from(this.progress.getStyle(this.modifier)) / this.size * this.steps;
          }
        }
      },
      size: {
        setter: function(value, old) {
          if (!(value != null)) {
            value = old;
          }
          if (this.minSize > value) {
            value = this.minSize;
          }
          this.base.setStyle(this.modifier, value);
          this.progress.setStyle(this.modifier, this.reset ? value / 2 : this.value / this.steps * value);
          return value;
        }
      }
    },
    onDrag: function(el, e) {
      var offset, pos;
      if (this.enabled) {
        pos = Number.from(el.getStyle(this.modifier));
        offset = Math.round((pos / this.size) * this.steps) - this.lastpos;
        this.lastpos = Math.round((Number.from(el.getStyle(this.modifier)) / this.size) * this.steps);
        if (pos > this.size) {
          el.setStyle(this.modifier, this.size);
          pos = this.size;
        } else {
          if (this.reset) {
            this.value += offset;
          }
        }
        if (!this.reset) {
          this.value = Math.round((pos / this.size) * this.steps);
        }
        this.fireEvent('step', this.value);
        return this.update();
      } else {
        return el.setStyle(this.modifier, this.disabledTop);
      }
    },
    create: function() {
      this.progress = new Element("div");
      this.base.adopt(this.progress);
      this.drag = new Drag(this.progress, {
        handle: this.base
      });
      this.drag.addEvent('beforeStart', __bind(function(el, e) {
        this.lastpos = Math.round((Number.from(el.getStyle(this.modifier)) / this.size) * this.steps);
        if (!this.enabled) {
          return this.disabledTop = el.getStyle(this.modifier);
        }
      }, this));
      this.drag.addEvent('complete', __bind(function(el, e) {
        if (this.reset) {
          if (this.enabled) {
            el.setStyle(this.modifier, this.size / 2 + "px");
          }
        }
        return this.fireEvent('complete');
      }, this));
      this.drag.addEvent('drag', this.onDrag.bind(this));
      return this.base.addEvent('mousewheel', __bind(function(e) {
        e.stop();
        if (this.enabled) {
          this.set('value', this.value + Number.from(e.wheel));
          return this.fireEvent('step', this.value);
        }
      }, this));
    }
  });
});
define(["Core.Abstract", "Interfaces.Enabled", "Interfaces.Controls"], "Core.Icon", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: [Interfaces.Controls, Interfaces.Enabled],
    Attributes: {
      image: {
        setter: function(value) {
          this.setStyle('background-image', 'url(' + value + ')');
          return value;
        }
      },
      "class": {
        value: Lattice.buildClass('icon')
      }
    },
    create: function() {
      return this.base.addEvent('click', __bind(function(e) {
        if (this.enabled) {
          return this.fireEvent('invoked', [this, e]);
        }
      }, this));
    }
  });
});
define(["Core.Abstract", "Interfaces.Enabled", "Interfaces.Controls"], "Core.Picker", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: [Interfaces.Children, Interfaces.Enabled],
    Binds: ['show', 'hide', 'delegate'],
    Attributes: {
      "class": {
        value: Lattice.buildClass('picker')
      },
      offset: {
        value: 0,
        setter: function(value) {
          return value;
        }
      },
      position: {
        value: {
          x: 'auto',
          y: 'auto'
        },
        validator: function(value) {
          return (value.x != null) && (value.y != null);
        }
      },
      content: {
        value: null,
        setter: function(value, old) {
          if (old != null) {
            if (old["$events"]) {
              old.removeEvent('change', this.delegate);
            }
            this.removeChild(old);
          }
          this.addChild(value);
          if (value["$events"]) {
            value.addEvent('change', this.delegate);
          }
          return value;
        }
      },
      picking: {
        value: 'picking'
      }
    },
    create: function() {
      return this.base.setStyle('position', 'absolute');
    },
    ready: function() {
      return this.base.position({
        relativeTo: this.attachedTo,
        position: this.position,
        offset: this.offset
      });
    },
    attach: function(el, auto) {
      auto = auto != null ? auto : true;
      if (this.attachedTo != null) {
        this.detach();
      }
      this.attachedTo = el;
      if (auto) {
        return el.addEvent('click', this.show);
      }
    },
    detach: function() {
      if (this.attachedTo != null) {
        this.attachedTo.removeEvent('click', this.show);
        return this.attachedTo = null;
      }
    },
    delegate: function() {
      if (this.attachedTo != null) {
        return this.attachedTo.fireEvent('change', arguments);
      }
    },
    show: function(e, auto) {
      if (this.enabled) {
        auto = auto != null ? auto : true;
        document.body.grab(this.base);
        if (this.attachedTo != null) {
          this.attachedTo.addClass(this.picking);
        }
        if (e != null) {
          if (e.stop != null) {
            e.stop();
          }
        }
        if (auto) {
          return this.base.addEvent('outerClick', this.hide);
        }
      }
    },
    hide: function(e, force) {
      if (this.enabled) {
        if (force != null) {
          if (this.attachedTo != null) {
            this.attachedTo.removeClass(this.picking);
          }
          return this.base.dispose();
        } else if (e != null) {
          if (this.base.isVisible() && !this.base.hasChild(e.target)) {
            if (this.attachedTo != null) {
              this.attachedTo.removeClass(this.picking);
            }
            return this.base.dispose();
          }
        }
      }
    }
  });
});
define(["Core.Abstract", "Interfaces.Enabled", "Interfaces.Controls", "Interfaces.Size"], "Core.Toggler", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: [Interfaces.Enabled, Interfaces.Controls, Interfaces.Size],
    Attributes: {
      "class": {
        value: Lattice.buildClass('toggler'),
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old);
          this.onDiv.replaceClass("" + value + "-on", "" + old + "-on");
          this.offDiv.replaceClass("" + value + "-off", "" + old + "-off");
          this.separator.replaceClass("" + value + "-separator", "" + old + "-separator");
          return value;
        }
      },
      onLabel: {
        value: 'ON',
        setter: function(value) {
          return this.onDiv.set('text', value);
        }
      },
      offLabel: {
        value: 'OFF',
        setter: function(value) {
          return this.offDiv.set('text', value);
        }
      },
      checked: {
        value: true,
        setter: function(value) {
          this.fireEvent('invoked', [this, value]);
          return value;
        }
      }
    },
    update: function() {
      if (this.size) {
        $$(this.onDiv, this.offDiv, this.separator).setStyles({
          width: this.size / 2
        });
        this.base.setStyle('width', this.size);
      }
      if (this.checked) {
        this.separator.setStyle('left', this.size / 2);
      } else {
        this.separator.setStyle('left', 0);
      }
      return this.offDiv.setStyle('left', this.size / 2);
    },
    create: function() {
      this.base.setStyle('position', 'relative');
      this.onDiv = new Element('div');
      this.offDiv = new Element('div');
      this.separator = new Element('div', {
        html: '&nbsp;'
      });
      this.base.adopt(this.onDiv, this.offDiv, this.separator);
      $$(this.onDiv, this.offDiv, this.separator).setStyles({
        'position': 'absolute',
        'top': 0,
        'left': 0
      });
      return this.base.addEvent('click', __bind(function() {
        if (this.enabled) {
          if (this.checked) {
            return this.set('checked', false);
          } else {
            return this.set('checked', true);
          }
        }
      }, this));
    }
  });
});
define(["Core.Abstract", "Interfaces.Enabled", "Interfaces.Controls"], "Core.Overlay", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: [Interfaces.Controls, Interfaces.Enabled],
    Attributes: {
      "class": {
        value: Lattice.buildClass('overlay')
      },
      zindex: {
        value: 0,
        setter: function(value) {
          this.base.setStyle('z-index', value);
          return value;
        },
        validator: function(value) {
          return Number.from(value) !== null;
        }
      }
    },
    create: function() {
      this.base.setStyles({
        position: "fixed",
        top: 0,
        left: 0,
        right: 0,
        bottom: 0
      });
      return this.hide();
    }
  });
});
define(["Core.Abstract", "Interfaces.Enabled", "Interfaces.Size"], "Core.Checkbox", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: [Interfaces.Enabled, Interfaces.Size],
    Attributes: {
      "class": {
        value: Lattice.buildClass('checkbox'),
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old);
          this.sign.replaceClass("" + value + "-sign", "" + old + "-sign");
          return value;
        }
      },
      state: {
        value: true,
        setter: function(value, old) {
          if (value) {
            this.base.addClass('checked');
          } else {
            this.base.removeClass('checked');
          }
          if (value !== old) {
            this.fireEvent('invoked', [this, value]);
          }
          return value;
        }
      },
      label: {
        value: '',
        setter: function(value) {
          this.textNode.textContent = value;
          return value;
        }
      }
    },
    create: function() {
      this.sign = new Element('div');
      this.textNode = document.createTextNode('');
      this.base.adopt(this.sign, this.textNode);
      return this.base.addEvent('click', __bind(function() {
        if (this.enabled) {
          return this.set('state', this.state ? false : true);
        }
      }, this));
    }
  });
});
define(["Core.Abstract", "Interfaces.Enabled"], "Core.Tip", function() {
  return new Class({
    Extends: Core.Abstract,
    Implements: Interfaces.Enabled,
    Binds: ['enter', 'leave'],
    Attributes: {
      "class": {
        value: Lattice.buildClass('tip')
      },
      label: {
        value: '',
        setter: function(value) {
          return this.base.set('html', value);
        }
      },
      zindex: {
        value: 1,
        setter: function(value) {
          return this.base.setStyle('z-index', value);
        }
      },
      delay: {
        value: 0
      },
      location: {
        value: {
          x: 'center',
          y: 'center'
        }
      },
      offset: {
        value: 0
      }
    },
    create: function() {
      return this.base.setStyle('position', 'absolute');
    },
    attach: function(item) {
      if (this.attachedTo != null) {
        this.detach();
      }
      this.attachedTo = document.id(item);
      this.attachedTo.addEvent('mouseenter', this.enter);
      return this.attachedTo.addEvent('mouseleave', this.leave);
    },
    detach: function() {
      this.attachedTo.removeEvent('mouseenter', this.enter);
      this.attachedTo.removeEvent('mouseleave', this.leave);
      return this.attachedTo = null;
    },
    enter: function() {
      if (this.enabled) {
        this.over = true;
        return this.id = (function() {
          if (this.over) {
            return this.show();
          }
        }).bind(this).delay(this.delay);
      }
    },
    leave: function() {
      if (this.enabled) {
        if (this.id != null) {
          clearTimeout(this.id);
          this.id = null;
        }
        this.over = false;
        return this.hide();
      }
    },
    ready: function() {
      if (this.attachedTo != null) {
        return this.base.position({
          relativeTo: this.attachedTo,
          position: this.location,
          offset: this.offset
        });
      }
    },
    hide: function() {
      return this.base.dispose();
    },
    show: function() {
      return document.getElement('body').grab(this.base);
    }
  });
});
define(["Lattice", "Class.Mutators.Attributes", "Interfaces.Mux"], "Core.Abstract", function() {
  return new Class({
    Implements: [Events, Interfaces.Mux],
    Delegates: {
      base: ['setStyle', 'getStyle', 'setStyles', 'getStyles', 'dispose']
    },
    Attributes: {
      "class": {
        setter: function(value, old) {
          value = String.from(value);
          this.base.replaceClass(value, old);
          return value;
        }
      }
    },
    getSize: function() {
      var comp;
      comp = this.base.getComputedSize({
        styles: ['padding', 'border', 'margin']
      });
      return {
        x: comp.totalWidth,
        y: comp.totalHeight
      };
    },
    initialize: function(attributes) {
      this.base = new Element('div');
      this.base.addEvent('addedToDom', this.ready.bind(this));
      this.mux();
      this.create();
      this.setAttributes(attributes);
      Lattice.Elements.push(this);
      return this;
    },
    create: function() {},
    update: function() {},
    ready: function() {
      return this.base.removeEvents('addedToDom');
    },
    toElement: function() {
      return this.base;
    }
  });
});
define("Core.Slider", "Core.Scrollbar", function() {
  return new Class({
    Extends: Core.Slider,
    Attributes: {
      mode: {
        setter: function(value, old, self) {
          self.prototype.parent.call(this, value, old);
          switch (value) {
            case 'horizontal':
              this.smodif = 'left';
              this.drag.options.modifiers = {
                x: 'left',
                y: ''
              };
              break;
            case 'vertical':
              this.smodif = 'top';
              this.drag.options.modifiers = {
                x: '',
                y: 'top'
              };
              this.drag.options.invert = false;
          }
          return value;
        }
      },
      value: {
        getter: function() {
          var width;
          if (this.reset) {
            return this.value;
          } else {
            width = this.size - this.progressSize;
            return Number.from(this.progress.getStyle(this.smodif)) / width * this.steps;
          }
        },
        setter: function(value) {
          var percent, width;
          value = Number.from(value);
          width = this.size - this.progressSize;
          if (!this.reset) {
            percent = Math.round((value / this.steps) * 100);
            if (value < 0) {
              this.progress.setStyle(this.smodif, 0);
              value = 0;
            } else if (value > this.steps) {
              this.progress.setStyle(this.smodif, width);
              value = this.steps;
            } else if (!(value < 0) && !(value > this.steps)) {
              this.progress.setStyle(this.smodif, (percent / 100) * width);
            }
          }
          return value;
        }
      },
      size: {
        setter: function(value, old) {
          if (!(value != null)) {
            value = old;
          } else {
            value = Number.from(value);
          }
          if (this.minSize > value) {
            value = this.minSize;
          }
          this.base.setStyle(this.modifier, value);
          this.progress.setStyle(this.modifier, value * 0.7);
          this.progressSize = value * 0.7;
          return value;
        }
      }
    },
    create: function() {
      return this.parent();
    },
    onDrag: function(el, e) {
      var left, width;
      if (this.enabled) {
        left = Number.from(this.progress.getStyle(this.smodif));
        width = this.size - this.progressSize;
        if (left < this.size - this.progressSize) {
          this.value = left / width * this.steps;
        } else {
          el.setStyle(this.smodif, this.size - this.progressSize);
          this.value = this.steps;
        }
        if (left < 0) {
          el.setStyle(this.smodif, 0);
          this.value = 0;
        }
        return this.fireEvent('step', Math.round(this.value));
      } else {
        return this.set('value', this.value);
      }
    }
  });
});