/*
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, Interfaces.Enabled]

provides: Core.Icon

...
*/
Core.Icon=new Class({
  Extends:Core.Abstract,
  Implements:[Interfaces.Enabled,
              Interfaces.Controls],
  options:{
    image:null,
    text:"",
    'class':GDotUI.Theme.iconClass
  },
  initialize:function(options){
    this.parent(options);
    this.enabled=true;
  },
  create:function(){
    this.base.addClass(this.options['class'])
    if(this.options.image!=null)
      this.base.setStyle('background-image','url('+this.options.image+')');
    this.base.addEvent('click',function(e){
      if(this.enabled)
        this.fireEvent('invoked',this);
    }.bindWithEvent(this));
  }
});