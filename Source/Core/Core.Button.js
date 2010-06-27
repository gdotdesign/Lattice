Core.Button=new Class({
   Extends:Core.Abstract,
   Implements:[Interfaces.Enabled,
               Interfaces.Controls],
   options:{
      image:'',
      text:''
   },
   initialize:function(options){
      this.parent(options);
   },
   create:function(){
      delete this.base;
      this.base=new Element('button');
      this.base.addClass(GDotUI.Theme.button['class']).set('text',this.options.text);
      this.icon=new Core.Icon({image:this.options.image});
      this.base.addEvent('click',function(){
         if(this.enabled)
            this.fireEvent('invoked');
      }.bindWithEvent(this))
   },
   ready:function(){
      this.base.grab(this.icon.base);
      this.icon.base.setStyle('float','left');
   }
})