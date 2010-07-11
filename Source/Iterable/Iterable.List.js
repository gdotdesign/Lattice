/*
---

name: Iterable.List

description: 

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.List

...
*/
Iterable.List=new Class({
  Extends:Core.Abstract,
  options:{
    'class':GDotUI.Theme.List['class']
  },
  initialize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    this.sortable=new Sortables(null,{handle:'.list-handle'});
    //TODO Sortable Events
    this.editing=false;
    this.items=[];
  },
  removeItem:function(li){
    li.removeEvents('invoked','edit','delete');
    li.base.destroy();
    delete li;
  },
  removeAll:function(){
    this.items.each(function(item){
      this.removeItem(item);
      delete item;
      }.bind(this));
    delete this.items; this.items=[];
  },
  toggleEdit:function(){
    var bases=this.items.map(function(item){
        return item.base;
      })
    if(this.editing){
      this.sortable.removeItems(bases);
      this.items.each(function(item){item.toggleEdit()});
      this.editing=false;
    }else{
      this.sortable.addItems(bases);
      this.items.each(function(item){item.toggleEdit()});
      this.editing=true;
    }
  },
  select:function(item){
    if(this.selected!=null)
      this.selected.base.removeClass('selected');
    this.selected=item;
    this.selected.base.addClass('selected');
    this.fireEvent('select',item);
  },
  /*toTheTop:function(item){
    //console.log(item);
    //this.base.setStyle('top',this.base.getPosition().y-item.base.getSize().y);
    this.items.erase(item);
    this.items.unshift(item);
    
  },
  update:function(){
    this.items.each(function(item,i){
      item.base.dispose();
      this.base.grab(item.base,'top');
    }.bind(this))
  },*/
  addItem:function(li){
    this.items.push(li);
    this.base.grab(li.base);
    li.addEvent('invoked',function(item){
      this.select(item);
      this.fireEvent('invoked',[item]);
      }.bindWithEvent(this));
    li.addEvent('edit',function(){
      this.fireEvent('edit',arguments);
      }.bindWithEvent(this));
    li.addEvent('delete',function(){
      this.fireEvent('delete',arguments);
      }.bindWithEvent(this));
  }
  
})