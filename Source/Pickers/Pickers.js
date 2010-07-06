/*
---

name: Pickers

description: 

license: MIT-style license.

requires: [Core.Picker, Data.Color]

provides: [Pickers.Base, Pickers.Color, Pickers.Number, Pickers.Text]

...
*/
Pickers.Base=new Class({
	Implements:Options,
  Delegates:{
	picker:['attach','detach']
  },
	options:{
		type:''
	},
  initialize:function(options){
		this.setOptions(options);
    this.picker=new Core.Picker();
    this.data=new Data[this.options.type]();
    this.picker.setContent(this.data);
  }
});
Pickers.Color=new Pickers.Base({type:'Color'});
Pickers.Number=new Pickers.Base({type:'Number'});
Pickers.Text=new Pickers.Base({type:'Text'});