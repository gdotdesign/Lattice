/*
---

name: Data.Color

description: 

license: MIT-style license.

requires: Data.Abstract

provides: Data.Color

...
*/
Data.Color.Controls.Field=new Class({
    initialize:function(label){
      this.base=new Element('dl');
      this.input=new Element('input',{type:'text',readonly:true});
      this.label=new Element('label',{text:label+": "});
      this.dt=new Element('dt').grab(this.label);
      this.dd=new Element('dd').grab(this.input);
      this.base.adopt(this.dt,this.dd);
    }
});