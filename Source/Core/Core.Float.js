//Todo Option classes
Core.Float=new Class({
  Extends:Core.Abstract,
  Implements:[Interfaces.Draggable,
				  Interfaces.Restoreable],
  Binds:['resize','mouseEnter','mouseLeave','hide'],
  options:{
   'class':GDotUI.Theme.Float['class'],
	 overlay:false,
	 closeable:true,
	 resizeable:false,
	 editable:false
  },
  initialize:function(options){
	 this.parent(options);
	 this.showSilder=false;
  },
  ready:function(){
	 this.loadPosition();
	 this.base.grab(this.icons.base);
    this.base.grab(this.slider.base);
    //need positionControls();
    this.icons.base.setStyle('right',-6);
	 this.icons.base.setStyle('top',0);
	 this.slider.base.setStyle('right',-(this.slider.base.getSize().x)-6);
	 this.slider.base.setStyle('top',this.icons.size.y);
   this.parent();
  },
  create:function(){
    this.base.addClass(this.options['class']).setStyle('position','absolute').setPosition({x:0,y:0});
		this.base.toggleClass('inactive');
    this.content=new Element('div',{'class':GDotUI.Theme.Float.baseClass});

    this.handle=new Element('div',{'class':GDotUI.Theme.Float.handleClass});
    this.bottom=new Element('div',{'class':GDotUI.Theme.Float.bottomHandleClass});
    
    this.base.adopt(this.handle);
    this.base.adopt(this.content);
    
    this.slider=new Core.Slider({scrollBase:this.content});
	 this.slider.base.setStyle('position','absolute');
	 this.slider.addEvent('complete',function(){
		this.scrolling=false;
	 }.bindWithEvent(this));
	 this.slider.addEvent('change',function(){
		this.scrolling=true;
	 }.bindWithEvent(this));
    this.slider.hide();
    
    this.icons=new Core.IconGroup(GDotUI.Theme.Float.iconOptions);
    this.icons.base.setStyle('position','absolute');
    this.icons.base.addClass(GDotUI.Theme.Float.iconsClass);
    
    this.close=new Core.Icon({'class':GDotUI.Theme.Float.closeClass});
    this.close.addEvent('invoked',function(){
      this.hide();
    }.bindWithEvent(this));
		
    this.edit=new Core.Icon({'class':GDotUI.Theme.Float.editClass});
    this.edit.addEvent('invoked',function(){
			if(this.contentElement!=null)
				if(this.contentElement.toggleEdit!=null)
					this.contentElement.toggleEdit();	
      this.fireEvent('edit');
    }.bindWithEvent(this));
  
    if(this.options.closeable){
      this.icons.addIcon(this.close);
    }
    if(this.options.editable){
      this.icons.addIcon(this.edit);
    }
    
    this.icons.hide();

    if($chk(this.options.scrollBase))
      this.scrollBase=this.options.scrollBase;
    else
      this.scrollBase=this.content;
      
    this.scrollBase.setStyle('overflow','hidden');

    if(this.options.resizeable){
      this.base.grab(this.bottom);
      this.sizeDrag=new Drag(this.scrollBase,{handle:this.bottom,modifiers:{x:'',y:'height'}})
      this.sizeDrag.addEvent('drag',this.resize);
    }
    
    this.base.addEvent('mouseenter',this.mouseEnter)
    this.base.addEvent('mouseleave',this.mouseLeave)
  },
  mouseEnter:function(){
		this.base.toggleClass('active');
		this.base.toggleClass('inactive');
		$clear(this.iconsTimout);
		$clear(this.sliderTimout);
    if(this.showSlider)
      this.slider.show();
    this.icons.show();
    this.mouseisover=true;
  },
  mouseLeave:function(){
		this.base.toggleClass('active');
		this.base.toggleClass('inactive');
    if(!this.scrolling){
      if(this.showSlider)
				this.sliderTimout=this.slider.hide.delay(200,this.slider);
    this.iconsTimout=this.icons.hide.delay(200,this.icons);
    }
    this.mouseisover=false;
  },
  resize:function(){
    if(this.scrollBase.getScrollSize().y>this.scrollBase.getSize().y){
      if(!this.showSlider){
				this.showSlider=true;
				if(this.mouseisover)
					this.slider.show()
      }
    }else{
      if(this.showSlider){
				this.showSlider=false;
				this.slider.hide();
      }
    }
  },
  show:function(){
    if(!this.base.isVisible()){
      document.getElement('body').grab(this.base);
      if(this.options.overlay){
		  GDotUI.Misc.Overlay.show();
		  this.base.setStyle('z-index',801);
      }
    }
  },
  hide:function(){
    this.base.dispose();
  },
  toggle:function(el){
    if(this.base.isVisible())
      this.hide(el);
    else
      this.show(el);
  },
  setContent:function(element){
	this.contentElement=element;
    this.content.grab(element.base);
  },
  center:function(){
    this.base.position();
  }
});