/*
---

name: Interfaces.Controls

description: 

license: MIT-style license.

requires: 

provides: Interfaces.Controls

...
*/
Interfaces.Controls=new Class({
   hide:function(){
      this.base.setStyle('opacity',0);
   },
   show:function(){
      this.base.setStyle('opacity',1);
   } 
})