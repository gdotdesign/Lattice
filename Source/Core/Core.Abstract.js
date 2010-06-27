Core.Abstract=new Class({
   Implements:[Events,
               Options,
               Interfaces.Mux],
    initialize:function(options){
		this.setOptions(options);
      this.base=new Element('div');
      this.create();
		this.base.addEventListener('DOMNodeInsertedIntoDocument',function(){
         this.ready();
      }.bindWithEvent(this));
      this.mux();
   },
   create:function(){},
   ready:function(){}
})