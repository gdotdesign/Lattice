Data.Abstract=new Class({
   Implements:[Events],
   initialize:function(){
      this.base=new Element('div');
      this.base.addEventListener('DOMNodeInsertedIntoDocument',function(){
         this.ready();
      }.bindWithEvent(this));
      this.create();
   },
   ready:function(){},
   create:function(){},
   setValue:function(){}
});