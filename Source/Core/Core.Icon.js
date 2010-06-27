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
  show:function(){
    this.base.setStyle('opacity',1);
  },
  hide:function(){
    this.base.setStyle('opacity',0);
  },
  createDisplay:function(){
    var clas=(this.options['class']==null?GDotUI.Theme.iconClass:this.options['class']);
    this.base=new Element('div').addClass(clas).set('text',this.options.text);
    this.base.setStyle('background-image','url('+this.options.image+')');
    this.base.addEvent('click',function(e){
      if(this.enabled)
        this.fireEvent('invoked',this);
    }.bindWithEvent(this));
  }
});