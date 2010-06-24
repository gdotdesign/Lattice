Core={};
Core.Icon=new Class({
  Implements:[Events,
              Options,
              Interfaces.Mux,
              Interfaces.Draggable,
              Interfaces.Enabled
              ],
  options:{
    image:"",
    text:""
  },
  initialize:function(options){
    this.setOptions(options);
    this.createDisplay();
    this.enabled=true;
    this.mux();
  },
  createDisplay:function(){
    this.base=new Element('div').addClass(GDotUI.Theme.iconClass).set('text',this.options.text);
    this.base.setStyle('background-image','url('+this.options.image+')');
    this.base.addEvent('click',function(e){
      if(this.enabled)
        this.fireEvent('invoked',this);
    }.bindWithEvent(this));
  }
});