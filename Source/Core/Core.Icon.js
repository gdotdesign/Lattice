Core={};
Core.Icon=new Class({
  Implements:[Events,
              Options,
              Interfaces.Enabled],
  options:{
    tip:"",
    tipClass:"",
    tipLocation:"",
    image:""
  },
  initialize:function(options){
    this.setOptions(options);
    this.createDisplay();
    if(this.options.tip!="")
      this.createTip();
  },
  createDisplay:function(){
    this.base=new Element('div').addClass(GDotUI.Theme.iconClass);
    this.base.setStyle('background-image','url('+this.options.image+')');
    this.base.addEvent('click',function(e){
      if(this.enabled)
        this.fireEvent('invoked',this);
    }.bindWithEvent(this));
  },
  createTip:function(){
    this.tip=new Element('div').addClass(this.options.tipClass);
    this.tip.setStyle('position','absolute');
    this.tip.setStyle('z-index',GDotUI.Config.tipZindex);
    this.tip.set('html',this.options.tip);
  }
  //showtip hidetip etc...
});