Data.Abstract=new Class({
   Implements:[Events,Options],
   options:{},
   initialize:function(options){
      this.setOptions();
      this.base=new Element('div');
      fn=this.ready.bindWithEvent(this);
      this.base.store('fn',fn);
      this.base.addEventListener('DOMNodeInsertedIntoDocument',fn);
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