Core.Slot=new Class({
  Extends:Core.Abstract,
  Binds:['check','complete'],
  Delegates:{
    'list':['addItem']
  },
  options:{
    'class':GDotUI.Theme.Slot['class']
  },
  initilaize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    this.overlay=new Element('div',{'text':' '}).addClass('over');
    this.list=new Iterable.List();
    
    this.base.adopt(this.list.base,this.overlay);
  },
  check:function(el,e){
    var lastDistance=1000;
    var lastOne=null;
    this.list.items.each(function(item,i){
      distance=-item.base.getPosition(this.base).y+(this.base.getSize().y/2)
     if(distance<lastDistance && distance>0 && distance<(this.base.getSize().y/2)){
      this.list.select(item);
     }
     
    }.bind(this));
  },
  ready:function(){
    this.parent();
    this.base.setStyle('overflow','hidden');
    this.base.setStyle('position','relative');
    this.list.base.setStyle('position','absolute');
    this.list.base.setStyle('top','0');
    this.base.setStyle('width',this.list.base.getSize().x);
    this.overlay.setStyle('width',this.base.getSize().x);
    this.overlay.addEvent('mousewheel',function(e){
      if(this.list.selected!=null){
        var index=this.list.items.indexOf(this.list.selected);
      }else{
        if(e.wheel==1)
          var index=0;
        else
          var index=1;
      }
      if(index+e.wheel>=0 && index+e.wheel<this.list.items.length){
        this.list.select(this.list.items[index+e.wheel]);
        this.update();
      }
    }.bindWithEvent(this));
    this.drag=new Drag(this.list.base,{modifiers:{x:'',y:'top'},handle:this.overlay});
    this.drag.addEvent('drag',this.check);
    this.drag.addEvent('beforeStart',function(){
      this.list.base.setStyle('-webkit-transition-duration','0s');
    }.bindWithEvent(this));
    this.drag.addEvent('complete',function(){
      this.update();
      /*if(this.list.base.getPosition(this.base).y>0){
        this.list.base.setStyle('top',0);
      }
      if((this.list.base.getPosition().y+this.list.base.getSize().y)<(this.base.getPosition().y+this.base.getSize().y)){
        this.list.base.setStyle('top',-(this.list.base.getSize().y-this.base.getSize().y));
      }*/
    }.bindWithEvent(this));
  },
  update:function(){
    this.list.base.setStyle('-webkit-transition-duration','0.3s');
    if(this.list.selected!=null){
      this.list.base.setStyle('top',-this.list.selected.base.getPosition(this.list.base).y+this.base.getSize().y/2-this.list.selected.base.getSize().y/2)
    }
  }
});