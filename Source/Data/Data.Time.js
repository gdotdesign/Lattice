/*
---

name: Data.Time

description: 

license: MIT-style license.

requires: Data.Abstract

provides: Data.Time

...
*/
Data.Time=new Class({
  Extends:Data.Abstract,
  options:{
    'class':GDotUI.Theme.Date.Time['class']
  },
  initilaize:function(options){
    this.parent(options);
  },
  create:function(){
    this.time=new Date();
    this.base.addClass(this.options['class']);
    this.hourList=new Core.Slot();
    this.minuteList=new Core.Slot();
    this.hourList.addEvent('change',function(item){
      this.time.setHours(item.value);
      this.fireEvent('change',this.time.format('%H:%M'));
    }.bindWithEvent(this));
    this.minuteList.addEvent('change',function(item){
      this.time.setMinutes(item.value);
      this.fireEvent('change',this.time.format('%H:%M'));
    }.bindWithEvent(this));
    for(var i=0;i<24;i++){
      var item=new Iterable.ListItem({title:i});
      item.value=i;
     this.hourList.addItem(item);
    }
    for(var i=0;i<60;i++){
      var item=new Iterable.ListItem({title:i<10?'0'+i:i});
      item.value=i;
      this.minuteList.addItem(item);
    }
    this.base.adopt(this.hourList.base,this.minuteList.base);
  },
  ready:function(){
    $$(this.hourList.base,this.minuteList.base).setStyles({'float':'left'});
    this.base.setStyle('height',this.hourList.base.getSize().y);
    this.parent();
  }
  })