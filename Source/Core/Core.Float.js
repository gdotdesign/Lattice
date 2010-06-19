Core.Float=new Class({
  Implements:[Events,Options],
  Binds:['firstShow','resize','mouseEnter','mouseLeave','restore','hide','savePosition'],
  options:{
	overlay:false,
	closeable:true,
	resizeable:false,
	cookieID:null,
	moveable:true,
	restoreable:false,
	editable:false,
        useCookie:false
  },
  initialize:function(options){
	this.setOptions(options);
	this.createDisplay();
	this.addEvent('show',this.firstShow);
	this.showSilder=false;
	if(this.options.restoreable){
          //to something Like GDotUI...
	  FE.addEvent('initUI',this.restore)
	}
  },
  firstShow:function(){
	if(this.options.resizeable){
	  this.slid=new Slider(this.bar,this.knob,{mode:'vertical',steps:100});
	  this.slid.addEvent('complete',function(){
	   this.scrolling=false;
	  }.bindWithEvent(this));
	  this.slid.addEvent('change',function(step){
		this.scrolling=true;
		this.scrollBase.scrollTop=(this.scrollBase.scrollHeight-this.scrollBase.getSize().y)/100*step;
	  }.bindWithEvent(this));
	  this.slid.attach();
	}
	this.removeEvent('show',this.firstShow);
  },
  restore:function(){
    var tmp=window.localStorage.getItem(this.options.cookieID+'.state');
    if(tmp=="visible")
      this.show();
  },
  savePosition:function(){
	if(this.wrapper.isVisible() && $chk(this.options.cookieID)){
	  var position=this.wrapper.getPosition();
	  /* Cookie for online */
	  if(this.options.useCookie){
	  Cookie.write(this.options.cookieID+'.x',position.x,{duration:Globals.cookieDuration});
	  Cookie.write(this.options.cookieID+'.y',position.y,{duration:Globals.cookieDuration});
          }else{
	  /* LocalStorage for offline*/
	  window.localStorage.setItem(this.options.cookieID+'.x',position.x);
	  window.localStorage.setItem(this.options.cookieID+'.y',position.y);
          }
	}
  },
  /**
   *  
   *  Loads the position of the panel from a cookie specified by the cookieID option.
   *  
   *
   **/
  loadPosition:function(){
	if($chk(this.options.cookieID)){
	  if($chk(window.localStorage.getItem(this.options.cookieID+'.y'))){
            if(this.options.useCookie){
                //cookie
            }else{
                this.wrapper.setStyle('top',window.localStorage.getItem(this.options.cookieID+'.y')+"px");
                this.wrapper.setStyle('left',window.localStorage.getItem(this.options.cookieID+'.x')+"px");
            }
	  }else{
	    this.wrapper.position('center');
	  }
	}else{
	  this.wrapper.position('center');
	}
  },
  /*
   
   ICON holder -> icons -> scrollbar
   
  */
  createDisplay:function(){
	this.wrapper=new Element('div',{'class':'float'});
	// The base element for the content
	this.base=new Element('div',{'class':''});
	// The "handle" for dragging the panel
	this.handle=new Element('div',{'class':'handle'});
        
	// Bottom handle for resizeing
	this.bottom=new Element('div',{'class':'bottom'});
	this.wrapper.adopt(this.handle);
	this.wrapper.adopt(this.base);
	// Slider bar and knob
	this.bar=new Element('div',{'class':'bar'});
	this.knob=new Element('div',{'class':'knob'});
	this.bar.grab(this.knob);
	// Close button
	this.close=new Element('div',{'class':'close'});
	this.wrapper.grab(this.bar);
	// If the float can be closed grab the button
	if(this.options.closeable){
	  this.wrapper.grab(this.close);
	}
	// If there is a different element then the base to scroll use that
	if($chk(this.options.scrollBase))
	  this.scrollBase=this.options.scrollBase;
	else
	  this.scrollBase=this.base;
	this.scrollBase.setStyle('overflow','hidden');
	// If the panel can be resized grab the bottom handle and set up resizeing
	if(this.options.resizeable){
	  this.wrapper.grab(this.bottom);
	  this.sizeDrag=new Drag(this.scrollBase,{handle:this.bottom,modifiers:{x:'',y:'height'}})
	  this.sizeDrag.addEvent('drag',this.resize);
	}
	// If the panel can be moved set up dragging
	if(this.options.moveable){
	  this.drag=new Drag.Float(this.wrapper,{target:this.handle,handle:this.handle});
	  this.drag.addEvent('beforeStart',function(e){console.log(e)})
	  this.drag.addEvent('drop',this.savePosition)
	}
	
	/**
	 *
	 * Now we need to show the controls when the cursor is over the panel.
	 * To do that we need to set the same events to the bar, close button, and the wrapper.
	 *
	 **/
	
	this.bar.setStyle('position','absolute');
	this.bar.setStyle('right',-17);
	this.bar.setStyle('top',this.options.editable?40:20);
	this.bar.setStyle('height',80);
	this.bar.set('tween',{link:'cancel'});
	this.bar.addEvent('mouseenter',this.mouseEnter)
	this.bar.addEvent('mouseleave',this.mouseLeave)
	this.bar.fade('hide');
	
	if(this.options.editable){
	  this.edit=new Element('div',{'class':'edit'});
	  this.wrapper.grab(this.edit);
	  this.edit.setStyle('position','absolute');
	  this.edit.setStyle('top',20);
	  this.edit.setStyle('right',-21);
	  this.edit.fade('hide');
	  this.edit.set('tween',{link:'cancel'});
	  this.edit.addEvent('mouseenter',this.mouseEnter)
	  this.edit.addEvent('mouseleave',this.mouseLeave)
	  this.edit.addEvent('click',function(){
	      this.fireEvent('toggleEdit');
	    }.bindWithEvent(this))
	}
	
	
	this.close.setStyle('position','absolute');
	this.close.setStyle('top',0);
	this.close.setStyle('right',-21);
	this.close.fade('hide');
	this.close.set('tween',{link:'cancel'});
	this.close.addEvent('mouseenter',this.mouseEnter)
	this.close.addEvent('mouseleave',this.mouseLeave)
	this.close.addEvent('click',this.hide);
	
	this.wrapper.addEvent('mouseenter',this.mouseEnter)
	this.wrapper.addEvent('mouseleave',this.mouseLeave)
	
  },
  /**
   *
   *  mouseEnter function to show the controls
   * 
   **/
  mouseEnter:function(){
	if(this.showSlider)
	  this.bar.fade('in');
	this.close.fade('in');
	if(this.options.editable)
	  this.edit.fade('in');
	this.mouseisover=true;
  },
  /**
   *
   *  mouseLeave function to hide the controls
   * 
   **/
  mouseLeave:function(){
	if(!this.scrolling){
	  if(this.showSlider)
		this.bar.fade('out');
	this.close.fade('out');
	if(this.options.editable)
	  this.edit.fade('out');
	}
	this.mouseisover=false;
  },
  /**
   *
   * Resize function to show and hide the scrollbar depending
   * on the size of the panel and the content whitin
   * 
   **/
  resize:function(){
	if(this.scrollBase.getScrollSize().y>this.scrollBase.getSize().y){
	  if(!this.showSlider){
		this.showSlider=true;
		if(this.mouseisover)
		  this.bar.fade('in');
	  }
	}else{
	  if(this.showSlider){
		this.showSlider=false;
		this.bar.fade('out');
	  }
	}
  },
  /**
   *
   * Shows the panel
   *
   **/ 
  show:function(){
	if(!this.wrapper.isVisible()){
	  document.getElement('body').grab(this.wrapper);
	  if(this.options.moveable){
		this.loadPosition();
	  }else{
		this.wrapper.position('center');
	  }
	  if(this.options.overlay){
		  Overlay.show();
		  this.wrapper.setStyle('z-index',801);
	  }
	}
	this.fireEvent('show');
	window.localStorage.setItem(this.options.cookieID+'.state','visible');
	if($chk(this.content))
	  this.content.fireEvent('show');
  },
  /**
   *
   * Hides the panel (disposing it from the DOM)
   *
   **/ 
  hide:function(){
	if(this.options.moveable){
	  this.savePosition();
	}
	if(this.options.overlay){
	  Overlay.hide();
	}
	window.localStorage.setItem(this.options.cookieID+'.state','hidden');
	this.close.get('tween').cancel().set('opacity',0);
	this.bar.get('tween').cancel().set('opacity',0);
	this.wrapper.dispose();
  },
  /**
   *
   * Toggles the panel (show or hide)
   *
   **/ 
  toggle:function(el){
	if(this.base.isVisible())
	  this.hide(el);
	else
	  this.show(el);
  },
  /**
   *
   * Sets the content of the panel
   * The element need to be a class that implements events
   * and have a base property containing an Element.
   *
   **/ 
  setContent:function(element){
	this.content=element;
	this.base.grab(element.base);
  },
  /**
   *
   * Centers the panel on the screen
   *
   **/ 
  center:function(){
	this.wrapper.position();
  },
  /**
   *
   * Maximizes the panel on the screen
   *
   **/ 
  maximize:function(){
	this.wrapper.setStyles({
	  'top':0,
	  'left':0,
	  'right':0,
	  'bottom':0
	})
  }
});