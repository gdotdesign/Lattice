/*
---

name: Data.Abstract

description: 

license: MIT-style license.

requires: 

provides: Data.Abstract

...
*/
Data.Abstract=new Class({
   Implements:[Events,Options],
   options:{},
   initialize:function(options){
      this.setOptions();
      this.base=new Element('div');
      fn=this.ready.bindWithEvent(this);
      this.base.store('fn',fn);
      this.base.addEventListener('DOMNodeInsertedIntoDocument',fn,false);
      this.create();
   },
   ready:function(){
      this.base.removeEventListener('DOMNodeInsertedIntoDocument',this.base.retrieve('fn'),false);
      this.base.eliminate('fn');
   },
   create:function(){},
   setValue:function(){},
   getValue:function(){}
});