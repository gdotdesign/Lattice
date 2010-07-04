Core.Abstract=new Class({
   Implements:[Events,
               Options,
               Interfaces.Mux],
   initialize:function(options){
      this.setOptions(options);
      this.base=new Element('div');
      this.create();
      fn=this.ready.bindWithEvent(this);
      this.base.store('fn',fn);
      this.base.addEventListener('DOMNodeInsertedIntoDocument',fn);
      this.mux();
   },
   create:function(){},
   ready:function(){
      this.base.removeEventListener('DOMNodeInsertedIntoDocument',this.base.retrieve('fn'),false);
      this.base.eliminate('fn');
   }
})