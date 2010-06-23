Core.Tip=new Class({
  Implements:[Events,
              Options],
  Binds:['onEnter','onLeave'],
  options:{
    text:"",
    location:{x:"left",y:"bottom"},
    offset:5
  },
  initialize:function(options){
    this.setOptions(options);
    this.createTip();
  },
  createTip:function(){
    this.tip=new Element('div').addClass(GDotUI.Theme.tipClass);
    this.tip.setStyle('position','absolute');
    this.tip.setStyle('z-index',GDotUI.Config.tipZindex);
    this.tip.set('html',this.options.text);
  },
  attach:function(item){
    if(this.attachedTo!=null)
        this.detach();
    item.base.addEvent('mouseenter',this.onEnter);
    item.base.addEvent('mouseleave',this.onLeave);
    this.attachedTo=item;
  },
  detach:function(){
    item.base.removeEvent('mouseenter',this.onEnter);
    item.base.removeEvent('mouseleave',this.onLeave);
    this.attachedTo=null;
  },
  onEnter:function(){
    if(this.attachedTo.enabled){
      this.showTip();
    }
  },
  onLeave:function(){
    if(this.attachedTo.enabled){
      this.hideTip();
    }
  },
  showTip:function(){
    var p=this.attachedTo.base.getPosition();
	var s=this.attachedTo.base.getSize();
	$(document).getElement('body').grab(this.tip);
	var s1=this.tip.measure(function(){
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
    this.tip.dispose();
  }
});