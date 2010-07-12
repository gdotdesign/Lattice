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
    'class':GDotUI.Theme.Date.Time['class'],
    format:GDotUI.Theme.Date.Time.format
  },
  initilaize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    this.hourList=new Core.Slot();
    this.minuteList=new Core.Slot();
    this.hourList.addEvent('change',function(item){
      this.time.setHours(item.value);
      this.setValue();
    }.bindWithEvent(this));
    this.minuteList.addEvent('change',function(item){
      this.time.setMinutes(item.value);
      this.setValue();
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
  },
  setValue:function(date){
    if(date!=null){
      this.time=date;
    }
    this.hourList.select(this.hourList.list.items[this.time.getHours()]);
    this.minuteList.select(this.minuteList.list.items[this.time.getMinutes()]);
    this.fireEvent('change',this.time.format(this.options.format));
  },
  ready:function(){
    this.base.adopt(this.hourList.base,this.minuteList.base);
    $$(this.hourList.base,this.minuteList.base).setStyles({'float':'left'});
    this.base.setStyle('height',this.hourList.base.getSize().y);
    this.setValue(new Date());
    this.parent();
  }
  })