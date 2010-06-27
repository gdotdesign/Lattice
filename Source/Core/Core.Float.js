Core.Float=new Class({
  Implements:[Events,
	      Options,
	      Interfaces.Draggable,
	      Interfaces.Mux],
  Binds:['firstShow','resize','mouseEnter','mouseLeave','hide'],
  options:{
	overlay:false,
	closeable:true,
	resizeable:false,
	moveable:true,
	restoreable:false,
	editable:false
  },
  initialize:function(options){
	this.setOptions(options);
	this.createDisplay();
	this.mux();
	this.addEvent('show',this.firstShow);
	this.showSilder=false;
  },
  firstShow:function(){
    //need positionControls();
    this.icons.base.setPosition({x:this.base.getSize().x+5, y:0});
    this.icons.positionIcons();
    this.slider.base.setPosition({x:this.base.getSize().x+5, y:this.icons.size.y+5})
    if(this.options.resizeable){
      this.slider.init();
      this.slider.addEvent('complete',function(){
	this.scrolling=false;
      }.bindWithEvent(this));
      this.slider.addEvent('change',function(){
	this.scrolling=true;
      }.bindWithEvent(this));
    }
    this.removeEvent('show',this.firstShow);
  },
  
  createDisplay:function(){
    this.base=new Element('div',{'class':GDotUI.Theme.Float['class']}).setStyle('position','absolute').setPosition({x:0,y:0});
    
    this.base.setStyles({width:250})
    
    this.content=new Element('div',{'class':GDotUI.Theme.Float.baseClass});

    this.handle=new Element('div',{'class':GDotUI.Theme.Float.handleClass});
    this.bottom=new Element('div',{'class':GDotUI.Theme.Float.bottomHandleClass});
    
    this.base.adopt(this.handle);
    this.base.adopt(this.content);
    
    this.slider=new Core.Slider({scrollBase:this.content});
    this.slider.hide();
    
    this.icons=new Core.IconGroup(GDotUI.Theme.Float.iconOptions);
    this.icons.base.setStyle('position','absolute');
    this.icons.base.addClass(GDotUI.Theme.Float.iconsClass);
    
    this.base.grab(this.icons.base);
    this.base.grab(this.slider.base);
    
    this.close=new Core.Icon({'class':GDotUI.Theme.Float.closeClass});
    this.close.addEvent('invoked',function(){
      this.hide();
    }.bindWithEvent(this));
    this.edit=new Core.Icon({'class':GDotUI.Theme.Float.editClass});
    this.edit.addEvent('invoked',function(){
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
    if(this.showSlider)
      this.slider.show();
    this.icons.show();
    this.mouseisover=true;
  },

  mouseLeave:function(){
    if(!this.scrolling){
      if(this.showSlider)
	this.slider.hide();
    this.icons.hide();
    }
    this.mouseisover=false;
  },

  resize:function(){
    if(this.scrollBase.getScrollSize().y>this.scrollBase.getSize().y){
      if(!this.showSlider){
	this.showSlider=true;
	if(this.mouseisover)
	  this.slider.show();
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
	Overlay.show();
	this.base.setStyle('z-index',801);
      }
    }
    this.fireEvent('show');
  },

  hide:function(){
    if(this.options.overlay){
      Overlay.hide();
    }
    window.localStorage.setItem(this.options.cookieID+'.state','hidden');
    this.icons.hide();
    this.slider.hide();
    this.base.dispose();
  },

  toggle:function(el){
    if(this.base.isVisible())
      this.hide(el);
    else
      this.show(el);
  },

  setContent:function(element){
    this.content.grab(element.base);
  },
  center:function(){
    this.base.position();
  },
  maximize:function(){
    this.base.setStyles({
      'top':0,
      'left':0,
      'right':0,
      'bottom':0
    })
  }
});