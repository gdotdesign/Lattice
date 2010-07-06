/*
---

name: Data.Text

description: 

license: MIT-style license.

requires: Data.Abstract

provides: Data.Text

...
*/
Data.Text=new Class({
  Implements:Events,
  initialize:function(){
    this.base=new Element('div');
    this.text=new Element('textarea');
    this.base.grab(this.text);
    this.addEvent('show',function(){
      this.text.focus();
      }.bindWithEvent(this));
    this.text.addEvent('keyup',function(e){
      this.fireEvent('change',this.text.get('value'));
    }.bindWithEvent(this))
  },
  setValue:function(text){
    this.text.set('value',text);
  }
});