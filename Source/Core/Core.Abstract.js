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
    this.base.eliminate('fn');
    return this;
  }
});