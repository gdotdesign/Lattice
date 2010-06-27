// TO Interfacse.Tip
Core.Tip=new Class({
  Extends:Core.Abstract,
  Binds:['enter','leave'],
  options:{
    text:"",
    location:{x:"left",y:"bottom"},
    offset:5
  },
  initialize:function(options){
    this.parent(options);
    this.create();
  },
  createTip:function(){
    this.base.addClass(GDotUI.Theme.tipClass);
    this.base.setStyle('position','absolute');
    this.base.setStyle('z-index',GDotUI.Config.tipZindex);
    this.base.set('html',this.options.text);
  },
  attach:function(item){
    if(this.attachedTo!=null)
        this.detach();
    item.base.addEvent('mouseenter',this.enter);
    item.base.addEvent('mouseleave',this.leave);
    this.attachedTo=item;
  },
  detach:function(){
    item.base.removeEvent('mouseenter',this.enter);
    item.base.removeEvent('mouseleave',this.leave);
    this.attachedTo=null;
  },
  enter:function(){
    if(this.attachedTo.enabled){
      this.showTip();
    }
  },
  leave:function(){
    if(this.attachedTo.enabled){
      this.hideTip();
    }
  },
  showTip:function(){
    var p=this.attachedTo.base.getPosition();
	var s=this.attachedTo.base.getSize();
	$(document).getElement('body').grab(this.base);
	var s1=this.base.measure(function(){
	  return this.getSize();
        });
    switch(this.options.location.x){
      case "left":
        this.tip.setStyle('left',p.x+(s.x+this.options.offset));
      break;
      case "right":
        this.tip.setStyle('left',p.x+(s.x+this.options.offset));
      break;
      case "center":
        this.tip.setStyle('left',p.x-s1.x/2+s.x/2);
      break;
    }
    switch(this.options.location.y){
      case "top":
        this.tip.setStyle('top',p.y-(s.y+this.options.offset));
      break;
      case "bottom":
        this.tip.setStyle('top',p.y+(s.y+this.options.offset));
      break;
      case "center":
        this.tip.setStyle('top',p.y-s1.y/2+s.y/2);
      break;
    }
  },
  hideTip:function(){
    this.base.dispose();
  }
});