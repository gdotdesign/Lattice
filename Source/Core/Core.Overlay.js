/*
---

name: Core.Overlay

description: Abstract base class for Elements.

license: MIT-style license.

requires: Core.Abstract

provides: Core.Overlay

...
*/
Core.Overlay=new Class({
  Extends:Core.Abstract,
  options:{
    'class':GDotUI.Theme.Overlay['class']
    },
  initialize:function(options){
    this.parent(options);  
  },
  create:function(){
    this.base.setStyles({
      "position":"fixed",
      "top":0,
      "left":0,
      "right":0,
      "bottom":0
      }).addClass(this.options['class']);
    this.base.setStyle('opacity',0);
    document.getElement('body').grab(this.base);
    this.base.addEventListener('webkitTransitionEnd',function(e){
      if(e.propertyName=="opacity"){
       if(this.base.getStyle('opacity')==0)
        this.base.setStyle('visiblity','hidden')
      }
    }.bindWithEvent(this))
  },
  hide:function(){
    this.base.setStyle('opacity',0);
  },
  show:function(){
    this.base.setStyle('visiblity','visible')
    this.base.setStyle('opacity',1);
  }
})