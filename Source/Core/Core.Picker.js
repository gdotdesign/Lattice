Element.Events.outerClick = {
    
    base: 'click',
    
    condition: function(event){
        event.stopPropagation();
        return false;
    },
    
    onAdd: function(fn){
      window.addEvent('click', fn);
    },
    
    onRemove: function(fn){
      window.removeEvent('click', fn);
    }

};
Core.Picker=new Class({
  Extends:Core.Abstract,
  Binds:['show','hide'],
  options:{
    'class':GDotUI.Theme.Picker['class'],
    offset:GDotUI.Theme.Picker.offset
  },
  initialize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']).setStyle('position','absolute');
  },
  ready:function(){
    if(!this.base.hasChild(this.contentElement.base))
      this.base.grab(this.contentElement.base);
    winsize=window.getSize();
    asize=this.attachedTo.getSize();
    position=this.attachedTo.getPosition()
    size=this.base.getSize();
    offset=this.options.offset;
    x='';
    y='';
    if((position.x-size.x)<0){
      x='right';
      xpos=position.x+asize.x+offset;
    }
    if((position.x+size.x+asize.x)>(winsize.x)){
      x='left';
      xpos=position.x-size.x-offset;
    }
    if(!((position.x+size.x+asize.x)>(winsize.x)) && !((position.x-size.x)<0)){
      x='center';
      xpos=((position.x+asize.x/2)-(size.x/2));
    }
    if(position.y>(winsize.x/2)){
      y='up';
      ypos=position.y-size.y-offset;
    }else{
      y='down';
      if(x=='center')
        ypos=position.y+asize.y+offset;
      else
      ypos=position.y;
    }
    this.base.setStyle('left',xpos);
    this.base.setStyle('top',ypos);
  },
  attach:function(input){
    input.set('readonly',true);
    input.addEvent('click',this.show);
    this.contentElement.addEvent('change',function(value){
      this.attachedTo.set('value',value);
      this.attachedTo.fireEvent('change',value);
    }.bindWithEvent(this));
    this.attachedTo=input;
  },
  show:function(e){
    document.getElement('body').grab(this.base);
    this.attachedTo.addClass('picking');
    e.stop();
    this.base.addEvent('outerClick',this.hide);
  },
  hide:function(){
    if(this.base.isVisible()){
      this.attachedTo.removeClass('picking');
      this.base.dispose();
    }
  },
  setContent:function(element){
    this.contentElement=element;
  }
});