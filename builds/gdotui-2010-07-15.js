/*
---

name: GDotUI

description: 

license: MIT-style license.

requires: 

provides: GDotUI

...
*/
Class.Mutators.DCollection=function(items){
  var self=this;
  new Hash(items).each(function(fns, target) {
    $splat(fns).each(function(fn){
      self.prototype[fn]=function(){
        var args=arguments;
        this[target].each(function(item){
          item[fn].run(arguments,item);
        });
      };
    });
  });
};
Class.Mutators.Delegates = function(delegations) {
	var self = this;
	new Hash(delegations).each(function(delegates, target) {
		$splat(delegates).each(function(delegate) {
			self.prototype[delegate] = function() {
				var ret = this[target][delegate].apply(this[target], arguments);
				return (ret === this[target] ? this : ret);
			};
		});
	});
};
Interfaces={}
Core={}
Data={}
Iterable={}
Pickers={}
Selectors.Pseudo.disabled = function(){
  return (this.hasClass('disabled'));
};
Class.Singleton = new Class({

	initialize: function(classDefinition, options){
		var singletonClass = new Class(classDefinition);
		return new singletonClass(options);
	}

})
if(GDotUI==null)
  GDotUI={};
/*GDotUI=new Class.Singleton({
  Implements:[Events],
  initialize:function(){
    //this.loadTheme('../Themes/Blank/theme.js');
  },
  loadTheme:function(url){
    var uri=new URI(url);
    var local=new URI(window.location);

    //console.log();
    var themejs = Asset.javascript(url);
    themejs.addEvent('load',function(){
      var themecss= Asset.css(new URI(uri.get('directory')+GDotUI.Theme.css).toRelative(local.get('directory')));
      })
  }
  });*/
GDotUI.Config={
    tipZindex:100,
    floatZindex:0,
    cookieDuration:7*1000
}

/*
---

name: Interfaces.Mux

description: Runs function which names start with _$ after initialization. (Initialization for interfaces)

license: MIT-style license.

provides: Interfaces.Mux

...
*/
Interfaces.Mux=new Class({
  mux:function(){
    new Hash(this).each(function(value,key){
      if(key.test(/^_\$/) && $type(value)=="function"){
      value.run(null,this);
      }
    }.bind(this));
  }
  });

/*
---

name: Interfaces.Enabled

description: Provides enable and disable function to elements.

license: MIT-style license.

provides: Interfaces.Enabled

...
*/
Interfaces.Enabled=new Class({
  enable:function(){
    this.enabled=true;
    this.base.removeClass('disabled');
    this.fireEvent('enabled');
  },
  disable:function(){
    this.enabled=false;
    this.base.addClass('disabled');
    this.fireEvent('disabled');
  }
})

/*
---

name: Interfaces.Draggable

description: Porived dragging for elements that implements this.

license: MIT-style license.

requires: 

provides: [Interfaces.Draggable, Drag.Float]

...
*/
Drag.Float=new Class({
	Extends: Drag.Move,
	initialize:function(el,options){
		this.parent(el,options);
	},
	start: function(event) {
		if(this.options.target==event.target)
			this.parent(event);
	}
});
Interfaces.Draggable=new Class({
	Implements:Options,
	options:{
		draggable:false
	},
  _$Draggable:function(){
    if(this.options.draggable){
			if(this.handle==null){
				this.handle=this.base;
			}
			this.drag=new Drag.Float(this.base,{target:this.handle,handle:this.handle});
			this.drag.addEvent('drop',function(){
				this.fireEvent('dropped',this);
				}.bindWithEvent(this));
			}
  }
})

/*
---

name: Interfaces.Restoreable

description: 

license: MIT-style license.

requires: 

provides: Interfaces.Restoreable

...
*/
Interfaces.Restoreable=new Class({
    Impelments:[Options],
    options:{
        useCookie:true,
        cookieID:null
    },
    _$Restoreable:function(){
      //GDotUI.addEvent('init',this.loadPosition.bindWithEvent(this));
      this.addEvent('hide',function(){
        if($chk(this.options.cookieID)){
          if(this.options.useCookie){
            Cookie.write(this.options.cookieID+'.state','hidden',{duration:GDotUI.Config.cookieDuration});
          }else{
            window.localStorage.setItem(this.options.cookieID+'.state','hidden');
          }
        }
      }.bindWithEvent(this));
      this.addEvent('dropped',this.savePosition.bindWithEvent(this));
    },
    savePosition:function(){
      if($chk(this.options.cookieID)){
        var position=this.base.getPosition();
        var state=this.base.isVisible()?'visible':'hidden';
          if(this.options.useCookie){
            Cookie.write(this.options.cookieID+'.x',position.x,{duration:GDotUI.Config.cookieDuration});
            Cookie.write(this.options.cookieID+'.y',position.y,{duration:GDotUI.Config.cookieDuration});
            Cookie.write(this.options.cookieID+'.state',state,{duration:GDotUI.Config.cookieDuration});
          }else{
            window.localStorage.setItem(this.options.cookieID+'.x',position.x);
            window.localStorage.setItem(this.options.cookieID+'.y',position.y);
            window.localStorage.setItem(this.options.cookieID+'.state',state);
          }
      }
    },
    loadPosition:function(){
      if($chk(this.options.cookieID)){
        if(this.options.useCookie){
          this.base.setStyle('top',Cookie.read(this.options.cookieID+'.y')+"px");
          this.base.setStyle('left',Cookie.read(this.options.cookieID+'.x')+"px");
          if(Cookie.read(this.options.cookieID+'.state')=="hidden")
            this.hide();
        }else{
          this.base.setStyle('top',window.localStorage.getItem(this.options.cookieID+'.y')+"px");
          this.base.setStyle('left',window.localStorage.getItem(this.options.cookieID+'.x')+"px");
          if(window.localStorage.getItem(this.options.cookieID+'.state')=="hidden")
            this.hide();
        }
      }
    }
})

/*
---

name: Interfaces.Controls

description: 

license: MIT-style license.

requires: 

provides: Interfaces.Controls

...
*/
Interfaces.Controls=new Class({
   hide:function(){
      this.base.setStyle('opacity',0);
   },
   show:function(){
      this.base.setStyle('opacity',1);
   } 
})

/*
---

name: Core.Abstract

description:

license: MIT-style license.

requires: [Interfaces.Enabled, Interfaces.Controls]

provides: Core.Abstract

...
*/
Core.Abstract = new Class({
  Implements: [Events, Options, Interfaces.Mux],
  initialize: function(options) {
    var fn;
    this.setOptions(options);
    this.base = new Element('div');
    this.create();
    fn = this.ready.bindWithEvent(this);
    this.base.store('fn', fn);
    this.base.addEventListener('DOMNodeInsertedIntoDocument', fn, false);
    return this.mux();
  },
  create: function() {  },
  ready: function() {
    this.base.removeEventListener('DOMNodeInsertedIntoDocument', this.base.retrieve('fn', false));
    return this.base.eliminate('fn');
  }
});

/*
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, Interfaces.Enabled]

provides: Core.Icon

...
*/
Core.Icon=new Class({
  Extends:Core.Abstract,
  Implements:[Interfaces.Enabled,
              Interfaces.Controls],
  options:{
    image:null,
    text:"",
    'class':GDotUI.Theme.iconClass
  },
  initialize:function(options){
    this.parent(options);
    this.enabled=true;
  },
  create:function(){
    this.base.addClass(this.options['class'])
    if(this.options.image!=null)
    this.base.setStyle('background-image','url('+this.options.image+')');
    this.base.addEvent('click',function(e){
      if(this.enabled)
        this.fireEvent('invoked',this);
    }.bindWithEvent(this));
  }
});

/*
---

name: Core.IconGroup

description: Icon group with 4 types of layout.

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.IconGroup

...
*/
Core.IconGroup=new Class({
  Extends:Core.Abstract,
  Implements:Interfaces.Controls,
  options:{
    mode:"horizontal", // horizontal / vertical / circular / grid
    spacing: {x:20,y:20},
    startAngle:0, //degree
    radius:0, //degree
    degree:360 //degree
    },
  initialize:function(options){
    this.parent(options);
    this.icons=[];
  },
  create:function(){
    this.base.setStyle('position','relative');
  },
  addIcon:function(icon){
    if(this.icons.indexOf(icon)==-1){
      this.base.grab(icon.base);
      this.icons.push(icon);
    }
  },
  removeIcon:function(icon){
    if(this.icons.indexOf(icon)!=-1){
      icon.base.dispose();
      this.icons.push(icon);
    }
  },
  ready:function(){
    x=0;
    y=0;
    size={x:0,y:0};
    if(this.options.mode=="grid"){
      if(this.options.columns!=null){
        var rows=this.icons.length/this.options.columns;
        var columns=this.options.columns;
      }
      if(this.options.rows!=null){
        var rows=this.options.rows;
        var columns=Math.round(this.icons.length/this.options.rows);
      }
      this.icons.each(function(item,i){
        if(i%columns==0){
          y+=i==0?0:(item.base.getSize().y+this.options.spacing.y);
          x=0;
        }else{
          x+=i==0?x:(item.base.getSize().x+this.options.spacing.x);
        }
        item.base.setStyle('top',y);
        item.base.setStyle('left',x);
        item.base.setStyle('position','absolute');
      }.bind(this))
    }
    if(this.options.mode=="horizontal"){
      this.icons.each(function(item,i){
        x+=i==0?x:(item.base.getSize().x+this.options.spacing.x);
        y+=i==0?0:(this.options.spacing.y);
        item.base.setStyle('top',y);
        item.base.setStyle('left',x);
        item.base.setStyle('position','absolute');
      }.bind(this))
    }
    if(this.options.mode=="vertical"){
      this.icons.each(function(item,i){
        x+=i==0?0:(this.options.spacing.x);
        y+=i==0?y:(item.base.getSize().y+this.options.spacing.y);
        if(item.base.getSize().x > size.x)
          size.x=item.base.getSize().x;
        size.y=y+item.base.getSize().y;
        item.base.setStyle('top',y);
        item.base.setStyle('left',x);
        item.base.setStyle('position','absolute');
      }.bind(this))
      this.size=size;
    }
    if(this.options.mode=="circular"){
      var n=this.icons.length;
      var radius=this.options.radius;
      var ker=2*this.radius*Math.PI;
      var fok=((this.options.degree)/n);
      this.icons.each(function(item,i){
        if(i==0){
          var foks=this.options.startAngle*(Math.PI/180);
          x=-Math.round(radius*Math.cos(foks));
          y=Math.round(radius*Math.sin(foks));
        }else{
          x=-Math.round(radius*Math.cos(((fok*i)+this.options.startAngle)*(Math.PI/180)));
          y=Math.round(radius*Math.sin(((fok*i)+this.options.startAngle)*(Math.PI/180)));
        }
        item.base.setStyle('top',x);
        item.base.setStyle('left',y);
        item.base.setStyle('position','absolute');
      }.bind(this));
    }
  }
  });

/*
---

name: Core.Tip

description: Tip class.... (TODO Description)

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Tip

...
*/
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

/*
---

name: Core.Slider

description: 

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls]

provides: [Core.Slider, ResetSlider]

...
*/
ResetSlider=new Class({
	Extends:Slider,
	initialize:function(element, knob, options){
		this.parent(element, knob, options);
	},
	setRange:function(range){
		this.min = $chk(range[0]) ? range[0] : 0;
		this.max = $chk(range[1]) ? range[1] : this.options.steps;
		this.range = this.max - this.min;
		this.steps = this.options.steps || this.full;
		this.stepSize = Math.abs(this.range) / this.steps;
		this.stepWidth = this.stepSize * this.full / Math.abs(this.range) ;
	}
})
Class.Mutators.Delegates = function(delegations) {
	var self = this;
	new Hash(delegations).each(function(delegates, target) {
		$splat(delegates).each(function(delegate) {
			self.prototype[delegate] = function() {
				var ret = this[target][delegate].apply(this[target], arguments);
				return (ret === this[target] ? this : ret);
			};
		});
	});
};
Core.Slider=new Class({
    Extends:Core.Abstract,
    Implements:[Interfaces.Controls],
    Delegates:{
        slider:['set','setRange']
    },
    options:{
        scrollBase:null,
        reset:false,
        mode:'vertical',
				'class':GDotUI.Theme.Slider.barClass,
				'knob':GDotUI.Theme.Slider.knobClass
    },
    initialize:function(options){
      this.parent(options);
    },
    create:function(options){
      this.base.addClass(this.options['class']);
      this.knob=new Element('div').addClass(this.options.knob);
      if(this.options.mode=="vertical"){
        this.base.setStyles({
          'width':GDotUI.Theme.Slider.width,
          'height':GDotUI.Theme.Slider.length
        })
        this.knob.setStyles({
          'width':GDotUI.Theme.Slider.width,
          'height':GDotUI.Theme.Slider.width*2
        })
      }else{
        this.base.setStyles({
          'width':GDotUI.Theme.Slider.length,
          'height':GDotUI.Theme.Slider.width
        })
        this.knob.setStyles({
          'width':GDotUI.Theme.Slider.width*2,
          'height':GDotUI.Theme.Slider.width
        })
      }
      this.scrollBase=this.options.scrollBase;
      this.base.grab(this.knob);
    },
    ready:function(){
      if(this.options.reset){
        this.slider=new ResetSlider(this.base,this.knob,{mode:this.options.mode,steps:this.options.steps,range:this.options.range});
        this.slider.set(0);
      }else
        this.slider=new Slider(this.base,this.knob,{mode:'vertical',steps:100});
      this.slider.addEvent('complete',function(step){
				 this.fireEvent('complete',step+'');
      }.bindWithEvent(this));
      this.slider.addEvent('change',function(step){
				if(typeof(step)=='object')
					step=0;
        this.fireEvent('change',step+'');
        if(this.scrollBase!=null)
            this.scrollBase.scrollTop=(this.scrollBase.scrollHeight-this.scrollBase.getSize().y)/100*step;
      }.bindWithEvent(this));
			this.parent();
    }
})


/*
---

name: Core.Float

description: 

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Draggable, Interfaces.Restoreable, Core.Slider]

provides: Core.Float

...
*/
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

/*
---

name: Core.Button

description: 

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Enabled, Interfaces.Controls]

provides: Core.Button

...
*/
Core.Button=new Class({
   Extends:Core.Abstract,
   Implements:[Interfaces.Enabled,
               Interfaces.Controls],
   options:{
      image:'',
      text:'',
      'calss':GDotUI.Theme.button['class']
   },
   initialize:function(options){
      this.parent(options);
   },
   create:function(){
      delete this.base;
      this.base=new Element('button');
      this.base.addClass(this.options['class']).set('text',this.options.text);
      this.icon=new Core.Icon({image:this.options.image});
      this.base.addEvent('click',function(){
         if(this.enabled)
            this.fireEvent('invoked');
      }.bindWithEvent(this))
   },
   ready:function(){
      this.base.grab(this.icon.base);
      this.icon.base.setStyle('float','left');
      this.parent();
   }
})

/*
---

name: Core.Picker

description: 

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Picker

...
*/
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
    //input.set('readonly',true);
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

Core.Slot=new Class({
  Extends:Core.Abstract,
  Binds:['check','complete'],
  Delegates:{
    'list':['addItem','removeAll','select']
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
    this.list.addEvent('select',function(item){
      this.update();
      this.fireEvent('change',item);
    }.bindWithEvent(this))
    this.base.adopt(this.list.base,this.overlay);
  },
  check:function(el,e){
    this.dragging=true;
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
      e.stop();
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
      }
      if(index+e.wheel<0){
        this.list.select(this.list.items[this.list.items.length-1]);
      }
      if(index+e.wheel>this.list.items.length-1){
        this.list.select(this.list.items[0]);
      }
    }.bindWithEvent(this));
    this.drag=new Drag(this.list.base,{modifiers:{x:'',y:'top'},handle:this.overlay});
    this.drag.addEvent('drag',this.check);
    this.drag.addEvent('beforeStart',function(){
      this.list.base.setStyle('-webkit-transition-duration','0s');
    }.bindWithEvent(this));
    this.drag.addEvent('complete',function(){
      this.dragging=false;
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
    if(!this.dragging){
      this.list.base.setStyle('-webkit-transition-duration','0.3s');
      if(this.list.selected!=null){
        this.list.base.setStyle('top',-this.list.selected.base.getPosition(this.list.base).y+this.base.getSize().y/2-this.list.selected.base.getSize().y/2)
      }
    }
  }
});

/*
---

name: Data.Abstract

description: 

license: MIT-style license.

requires: 

provides: Data.Abstract

...
*/
Data.Abstract=new Class({
   Implements:[Events,Options],
   options:{},
   initialize:function(options){
      this.setOptions();
      this.base=new Element('div');
      fn=this.ready.bindWithEvent(this);
      this.base.store('fn',fn);
      this.base.addEventListener('DOMNodeInsertedIntoDocument',fn,false);
      this.create();
   },
   ready:function(){
      this.base.removeEventListener('DOMNodeInsertedIntoDocument',this.base.retrieve('fn'),false);
      this.base.eliminate('fn');
   },
   create:function(){},
   setValue:function(){},
   getValue:function(){}
});

/*
---

name: Data.Text

description: 

license: MIT-style license.

requires: Data.Abstract

provides: Data.Text

...
*/
Data.Text=new Class({
  Implements:Events,
  initialize:function(){
    this.base=new Element('div');
    this.text=new Element('textarea');
    this.base.grab(this.text);
    this.addEvent('show',function(){
      this.text.focus();
      }.bindWithEvent(this));
    this.text.addEvent('keyup',function(e){
      this.fireEvent('change',this.text.get('value'));
    }.bindWithEvent(this))
  },
  setValue:function(text){
    this.text.set('value',text);
  }
});

/*
---

name: Data.Number

description: 

license: MIT-style license.

requires: Data.Abstract

provides: Data.Number

...
*/
Data.Number=new Class({
  Extends:Data.Abstract,
  options:{
    'class':GDotUI.Theme.Number['class']
  },
  initialize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    this.text=new Element('input',{'type':'text'});
    this.text.set('value',0).setStyle('width',GDotUI.Theme.Slider.length);
    this.slider=new Core.Slider({reset:true,range:[-100,100],steps:200,mode:'vertical'});
  },
  ready:function(){
    this.slider.knob.grab(this.text);
    this.base.adopt(this.slider.base);
    this.slider.knob.addEvent('click',function(){
      this.text.focus(); 
    }.bindWithEvent(this))
    this.slider.addEvent('complete',function(step){
      this.slider.setRange([step-100,Number(step)+100])
      this.slider.set(step);
      }.bindWithEvent(this));
    this.slider.addEvent('change',function(step){
      if(typeof(step)=='object'){
        this.text.set('value',0);
      }else
      this.text.set('value',step);
      this.fireEvent('change',step);
      }.bindWithEvent(this));
    this.text.addEvent('change',function(){
      var step=Number(this.text.get('value'));
      this.slider.setRange([step-100,Number(step)+100])
      this.slider.set(step);
    }.bindWithEvent(this));
    this.text.addEvent('mousewheel',function(e){
      this.slider.set(Number(this.text.get('value'))+e.wheel);
    }.bindWithEvent(this));
    this.parent();
  },
  setValue:function(step){
    this.slider.setRange([step-100,Number(step)+100])
    this.slider.set(step);
  }
});

/*
---

name: Data.Color

description: 

license: MIT-style license.

requires: Data.Abstract

provides: Data.Color

...
*/
Field = new Class({
    Extends: Drag.Move,
    Implements: [Class.Occlude, Class.Binds],
    Binds: ['containerClicked'],
    options: {
      
        setOnClick: true,
        initialStep: false,
        x: [0, 1, false],
        y: [0, 1, false]

    },
    initialize: function(field, knob, options){
        var field = $(field);
        
        if(this.occlude('xy-field', field)) return this.occluded;
        
        this.container = field; //We do this because we need it when attach is called.
        
        $defined(options) ? (options.container = field) : options = {container: field};
        this.setOptions(options);
        this.parent($(knob), options);
        
        this.calculateLimit();
        
        if(!this.options.initialStep) this.options.initialStep = {x: this.options.x[0], y: this.options.y[0]};
        this.set(this.options.initialStep)
    },
    calculateLimit: function(){
      this.limit = this.parent();
      this.calculateStepFactor();
      return this.limit;
    },
    calculateStepFactor: function(){
        this.offset = {
            x: this.limit.x[0] + this.element.getStyle('margin-left').toInt() - this.container.offsetLeft,
            y: this.limit.y[0] + this.element.getStyle('margin-top').toInt() - this.container.offsetTop
        };
        
        var movableWidth = this.limit.x[1] - this.limit.x[0];
        var movableHeight = this.limit.y[1] - this.limit.y[0];
        
        if(this.options.x[2] === false) this.options.x[2] = movableWidth;
        if(this.options.y[2] === false) this.options.y[2] = movableHeight;
        
        var steps = {x: (this.options.x[2] - this.options.x[0])/this.options.x[1],
                     y: (this.options.y[2] - this.options.y[0])/this.options.y[1]};
   
        
        this.stepFactor = {
            x: movableWidth/steps.x,
            y: movableHeight/steps.y
        };
    },
    containerClicked: function(e){
        if(e.target == this.element) return;
        e.stop();
        var containerPosition = this.container.getPosition();
        var position = {
            x: e.page.x - containerPosition.x + this.element.getStyle('margin-left').toInt(),
            y: e.page.y - containerPosition.y + this.element.getStyle('margin-top').toInt()
        }
        this.set(this.toSteps(position));
        return e;
    },
    toSteps: function(position){
        var steps = {x: (position.x - this.offset.x)/this.stepFactor.x * this.options.x[1],
                     y: (position.y - this.offset.y)/this.stepFactor.y * this.options.y[1]};
        
        steps.x = Math.round(steps.x - steps.x % this.options.x[1]) + this.options.x[0];
        steps.y = Math.round(steps.y - steps.y % this.options.y[1]) + this.options.y[0];
        return steps;
    },
    toPosition: function(steps){
    	var position = {};
        var xmin = (this.options.x[2] - this.options.x[0]) < 0 ? Math.min : Math.max;
        var xmax = (this.options.x[2] - this.options.x[0]) < 0 ? Math.max : Math.min;
        
        var ymin = (this.options.y[2] - this.options.y[0]) < 0 ? Math.max : Math.min;
        var ymax = (this.options.y[2] - this.options.y[0]) < 0 ? Math.min : Math.max;
        
        position.x = (this.stepFactor.x * (xmax(xmin(steps.x, this.options.x[0]), this.options.x[2]) - this.options.x[0]) + this.offset.x) / this.options.x[1] + this.container.offsetLeft;
        position.y = (this.stepFactor.y * (ymin(ymax(steps.y, this.options.y[0]), this.options.y[2]) - this.options.y[0]) + this.offset.y) / this.options.y[1] + this.container.offsetTop;
        return position
    },
    toElement: function(){
      return this.container;  
    },
    stop: function(event){
        var position = this.get();
        this.fireEvent('complete', position);
        this.fireEvent('change', position);
        return this.parent(false);
    },
    drag: function(event){
        var position = this.get();
        this.fireEvent('tick', position);
        this.fireEvent('change', position);
        return this.parent(event);
    },
    set: function(steps){
        var position = this.toPosition(steps)
        this.element.setPosition(position);
        this.fireEvent('change', this.get());
    },
    get: function(){
        return this.toSteps(this.element.getPosition(this.container));
    },
    attach: function(){
        if(this.options.setOnClick) this.container.addEvent('click', this.containerClicked);
        this.parent();
    },
    detach: function(){
        if(this.options.setOnClick) this.container.removeEvent('click', this.containerClicked);
        this.parent();
    }
});
Data.Color=new Class({
  Extends:Data.Abstract,
  options:{
    'class':GDotUI.Theme.Color['class'],
    'sb':GDotUI.Theme.Color.sb,
    'hue':GDotUI.Theme.Color.hue,
    'wrapper':GDotUI.Theme.Color.wrapper,
    white:GDotUI.Theme.Color.white,
    black:GDotUI.Theme.Color.black,
    format:GDotUI.Theme.Color.format
  },
  initialize:function(options){
    this.parent();
  },
  create:function(){
    this.base.addClass(this.options['class']);
    /** SB Start**/
    this.wrapper=new Element('div').addClass(this.options.wrapper);;
    this.white=new Element('div').addClass(this.options.white);
    this.black=new Element('div').addClass(this.options.black);
    this.color=new Element('div').addClass(this.options.sb);
   
    this.xyKnob=new Element('div').set('id','xyknob');
    this.xyKnob.setStyles({
      'position':'absolute',
      'top':0,
      'left':0
      });
    
    this.wrapper.adopt(this.color,this.white,this.black,this.xyKnob);
    /** SB END **/
    /** Hue Start **/
    this.color_linear=new Element('div').addClass(this.options.hue);
    this.colorKnob=new Element('div',{'id':'knob'});
    this.color_linear.grab(this.colorKnob);
    /** Hue End **/
    
   
    this.colorData=new Data.Color.Controls();
     this.base.adopt(this.wrapper,this.color_linear,this.colorData.base);
  },
  ready:function(){
    var sbSize=this.color.getSize();
    this.wrapper.setStyles({
      width:sbSize.x,
      height:sbSize.y,
      'position':'relative',
      'float':'left'
      })
    $$(this.white,this.black,this.color).setStyles({
      'position':'absolute',
      'top':0,
      'left':0,
      'width':'inherit',
      'height':'inherit'
      })
    this.color_linear.setStyles({
      height:sbSize.y,
      width:sbSize.x/11.25,
      'float':'left'
	  });
    this.colorKnob.setStyles({
      height:(sbSize.y/11.25+8)/2.8,
      width:sbSize.x/11.25+8
	  });
    this.colorKnob.setStyle('left',(this.color_linear.getSize().x-this.colorKnob.getSize().x)/2)
    this.xy=new Field(this.black,this.xyKnob,{setOnClick:true, x:[0,1,100],y:[0,1,100]});
    this.slide=new Slider(this.color_linear,this.colorKnob,{mode:'vertical',steps:360});
    this.slide.addEvent('change',function(step){
      if(typeof(step)=="object")
        step=0;
      this.bgColor=this.bgColor.setHue(step);
      var colr=new $HSB(this.bgColor.hsb[0],100,100);
      this.color.setStyle('background-color',colr);
      this.setColor();
    }.bindWithEvent(this));
    this.xy.addEvent('tick',this.change.bindWithEvent(this));
    this.xy.addEvent('change',this.change.bindWithEvent(this));
    this.setValue(this.value?this.value:'#fff');
  },
  setValue:function(hex){
    this.bgColor=new Color(hex);
    this.slide.set(this.bgColor.hsb[0]);
	  this.xy.set({x:this.bgColor.hsb[1],y:100-this.bgColor.hsb[2]});
    this.saturation=this.bgColor.hsb[1];
    this.brightness=(100-this.bgColor.hsb[2]);
    this.hue=this.bgColor.hsb[0];
    this.setColor();
  },
  setColor:function(){
    this.finalColor=this.bgColor.setSaturation(this.saturation).setBrightness(100-this.brightness);
    this.colorData.setValue(this.finalColor);
    var ret='';
    if(this.options.format=="hsl"){
        ret=this.colorData.hsb.input.get('value');
    }else if(this.options.format=="rgb"){
        ret=this.colorData.rgb.input.get('value');
    }else{
        ret=this.colorData.hex.input.get('value');
    }
    this.fireEvent('change',[ret]);
    this.value=this.finalColor;
  },
  change:function(pos){
    this.saturation=pos.x;
    this.brightness=pos.y;
    this.setColor();
  }
})
Data.Color.Controls=new Class({
    Extends:Data.Abstract,
    options:{
        'class':GDotUI.Theme.Color.controls['class'],
        'format':GDotUI.Theme.Color.controls.format,
        colorBox:GDotUI.Theme.Color.controls.colorBox
    },
    initialize:function(options){
        this.parent(options);
    },
    create:function(){
        this.base.addClass(this.options['class']);
        
        this.left=new Element('div').setStyles({'float':'left'});
        this.red=new Data.Color.Controls.Field('R');
        this.green=new Data.Color.Controls.Field('G');
        this.blue=new Data.Color.Controls.Field('B');
        this.left.adopt(this.red.base,this.green.base,this.blue.base);
        
        this.right=new Element('div');
        this.right.setStyles({'float':'left'});
        this.hue=new Data.Color.Controls.Field('H');
        this.saturation=new Data.Color.Controls.Field('S');
        this.brightness=new Data.Color.Controls.Field('B');
        this.right.adopt(this.hue.base,this.saturation.base,this.brightness.base);
        
        this.color=new Element('div').setStyles({'float':'left'}).addClass(this.options.colorBox);;
        
        this.format=new Element('div').setStyles({'float':'left'}).addClass(this.options.format);
        this.hex=new Data.Color.Controls.Field('Hex');
        this.rgb=new Data.Color.Controls.Field('RGB');
        this.hsb=new Data.Color.Controls.Field('HSL');
        this.format.adopt(this.hex.base,this.rgb.base,this.hsb.base);
        
        this.base.adopt(this.left,this.right,this.color,new Element('div').setStyle('clear','both'),this.format);
    },
    setValue:function(color){
        this.color.setStyle('background-color',color);
        this.red.input.set('value',color.rgb[0]);
        this.green.input.set('value',color.rgb[1]);
        this.blue.input.set('value',color.rgb[2]);
        this.rgb.input.set('value',"rgb("+(color.rgb[0])+", "+(color.rgb[1])+", "+(color.rgb[2])+")");
        this.hue.input.set('value',color.hsb[0]);
        this.saturation.input.set('value',color.hsb[1]);
        this.brightness.input.set('value',color.hsb[2]);
        this.hsb.input.set('value',"hsl("+(color.hsb[0])+", "+(color.hsb[1])+"%, "+(color.hsb[2])+"%)");
        this.hex.input.set('value',"#"+color.hex.slice(1,7));
    }
})
//to be replaced by Form.Field
Data.Color.Controls.Field=new Class({
    initialize:function(label){
      this.base=new Element('dl');
      this.input=new Element('input',{type:'text',readonly:true});
      this.label=new Element('label',{text:label+": "});
      this.dt=new Element('dt').grab(this.label);
      this.dd=new Element('dd').grab(this.input);
      this.base.adopt(this.dt,this.dd);
    }
});

/*
---

name: Data.Date

description: 

license: MIT-style license.

requires: Data.Abstract

provides: Data.Date

...
*/
MooTools.lang.set('en-US', 'Date', {
    days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday','Sunday']
});
Data.Date=new Class({
  Extends:Data.Abstract,
  options:{
    'class':GDotUI.Theme.Date['class'],
    nextClass:GDotUI.Theme.Date.next,
    prevClass:GDotUI.Theme.Date.previous,
    titleClass:GDotUI.Theme.Date.title,
    format:GDotUI.Theme.Date.format
  },
  initialize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    
    this.next=new Core.Icon();
    this.next.base.addEvent('click',this.Next.bindWithEvent(this)).addClass(this.options.nextClass);
    this.prev=new Core.Icon();
    this.prev.base.addEvent('click',this.Prev.bindWithEvent(this)).addClass(this.options.prevClass);
    this.title=new Element('div').addClass(this.options.titleClass);
    this.wrapper=new Element('div')
    this.wrapper.adopt(this.prev.base,this.title,this.next.base);
    var days3=MooTools.lang.get('Date','days').map(function(item,i){
      return item.slice(0,2);
      })
    this.table=new HtmlTable({
      headers:days3,
      properties:{cellspacing:2}
      });
    for(var i=5;i>0;i--){
      this.table.push(['','','','','','','']);
    }
    this.base.adopt(this.wrapper,this.table);
    this.table.element.addEvent('click:relay(td)',this.select.bindWithEvent(this));
  },
  select:function(e){
    var day=e.target.get('text');
    if($chk(day)){
      this.date.setDate(Number(day));
      /*if($defined(this.selected))
        this.selected.removeClass('picked');
      e.target.addClass('picked');
      this.selected=e.target;*/
      this.setValue();
    }	
  },
  ready:function(){
    this.setValue(new Date());
    this.parent();
  },
  populate:function(start){
    var j=1;
    var days=this.date.get('lastdayofmonth');
    this.table.element.getElements('td').each(function(item,i){
      if((i+1)>=start && (i+1)<(days+start)){
        item.set('text',j);
        j++;
      }else
        item.set('text','');
    }.bind(this));
  },
  Next:function(){
    if(this.month==11){
			this.date.setMonth(0);
			this.date.setFullYear(this.date.getFullYear()+1);
		}
		else
			this.date.setMonth(this.date.getMonth()+1);
    this.setValue();
  },
  Prev:function(){
    if(this.month==0){
      this.date.setMonth(11);
      this.date.setFullYear(this.date.getFullYear()-1);
    }
    else
      this.date.setMonth(this.date.getMonth()-1);
    this.setValue();
  },
  setValue:function(date){
    if(date!=null){
      this.date=date;
    }
    var day=this.date.getDate();
    this.title.set('text',MooTools.lang.get('Date','months')[this.date.getMonth()]+" "+this.date.getFullYear() )
    this.populate(new Date(this.date.getFullYear(),this.date.getMonth(),1).getDay());
    $(this.table).getElements('td').each(function(item){
      if(item.hasClass('picked'))
        item.removeClass('picked')
      if(item.get('text')==day)
        item.addClass('picked');
    });
    this.fireEvent('change',this.date.format(this.options.format));
  }
});
Data.DateSlot=new Class({
  Extends:Data.Abstract,
  options:{
    'class':GDotUI.Theme.Date.Slot['class'],
    format:GDotUI.Theme.Date.format
  },
  initialize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    this.days=new Core.Slot();
    this.month=new Core.Slot();
    this.years=new Core.Slot();
    this.years.addEvent('change',function(item){
      this.date.setYear(item.value);
      this.setValue();
    }.bindWithEvent(this));
    this.month.addEvent('change',function(item){
      this.date.setMonth(item.value);
      this.setValue();
    }.bindWithEvent(this));
     this.days.addEvent('change',function(item){
      this.date.setDate(item.value);
      this.setValue();
    }.bindWithEvent(this));
    for(var i=0;i<30;i++){
      var item=new Iterable.ListItem({title:i+1});
      item.value=i+1;
      this.days.addItem(item);
    }
    for(var i=0;i<12;i++){
      var item=new Iterable.ListItem({title:i+1});
      item.value=i;
      this.month.addItem(item);
    }
    for(var i=1980;i<2012;i++){
      var item=new Iterable.ListItem({title:i});
      item.value=i;
      this.years.addItem(item);
    }
  },
  ready:function(){
    this.base.adopt(this.years.base,this.month.base,this.days.base);
    this.setValue(new Date());
    this.base.setStyle('height',this.days.base.getSize().y);
    $$(this.days.base,this.month.base,this.years.base).setStyles({'float':'left'});
    this.parent();
  },
  setValue:function(date){
    if(date!=null){
      this.date=date;
    }
    this.update();
    this.fireEvent('change',this.date.format(this.options.format));
  },
  update:function(){
    var cdays=this.date.get('lastdayofmonth');
    var listlength=this.days.list.items.length;
    if(cdays>listlength){
      for(var i=listlength+1;i<=cdays;i++){
        var item=new Iterable.ListItem({title:i});
        item.value=i;
        this.days.addItem(item);
      }
    }else if(cdays<listlength){
      for(var i=listlength;i>cdays;i--){
        this.days.list.removeItem(this.days.list.items[i-1]);
      }
    }
    this.days.select(this.days.list.items[this.date.getDate()-1]);
    this.month.select(this.month.list.items[this.date.getMonth()]);
    this.years.select(this.years.list.getItemFromTitle(this.date.getFullYear()));
    //this.years.select(this)
  }
});
Data.DateTime=new Class({
  Extends:Data.Abstract,
  options:{
    'class':GDotUI.Theme.Date.DateTime['class'],
    format:GDotUI.Theme.Date.DateTime.format
  },
  initialize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    this.datea=new Data.DateSlot();
    this.time=new Data.Time();
  },
  ready:function(){
    this.base.adopt(this.datea.base,this.time.base);
    this.setValue(new Date());
    this.datea.addEvent('change',function(){
      this.date.setYear(this.datea.date.getFullYear());
      this.date.setMonth(this.datea.date.getMonth());
      this.date.setDate(this.datea.date.getDate());
      this.fireEvent('change',this.date.format(this.options.format));
    }.bindWithEvent(this));
    this.time.addEvent('change',function(){
      this.date.setHours(this.time.time.getHours());
      this.date.setMinutes(this.time.time.getMinutes());
      this.fireEvent('change',this.date.format(this.options.format));
    }.bindWithEvent(this))
    this.parent();
  },
  setValue:function(date){
    if(date!=null){
      this.date=date;
    }
    this.datea.setValue(this.date);
    this.time.setValue(this.date);
    this.fireEvent('change',this.date.format(this.options.format));
  }
});

/*
---

name: Data.Time

description: 

license: MIT-style license.

requires: Data.Abstract

provides: Data.Time

...
*/
Data.Time=new Class({
  Extends:Data.Abstract,
  options:{
    'class':GDotUI.Theme.Date.Time['class'],
    format:GDotUI.Theme.Date.Time.format
  },
  initilaize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    this.hourList=new Core.Slot();
    this.minuteList=new Core.Slot();
    this.hourList.addEvent('change',function(item){
      this.time.setHours(item.value);
      this.setValue();
    }.bindWithEvent(this));
    this.minuteList.addEvent('change',function(item){
      this.time.setMinutes(item.value);
      this.setValue();
    }.bindWithEvent(this));
    for(var i=0;i<24;i++){
      var item=new Iterable.ListItem({title:i});
      item.value=i;
     this.hourList.addItem(item);
    }
    for(var i=0;i<60;i++){
      var item=new Iterable.ListItem({title:i<10?'0'+i:i});
      item.value=i;
      this.minuteList.addItem(item);
    }
  },
  setValue:function(date){
    if(date!=null){
      this.time=date;
    }
    this.hourList.select(this.hourList.list.items[this.time.getHours()]);
    this.minuteList.select(this.minuteList.list.items[this.time.getMinutes()]);
    this.fireEvent('change',this.time.format(this.options.format));
  },
  ready:function(){
    this.base.adopt(this.hourList.base,this.minuteList.base);
    $$(this.hourList.base,this.minuteList.base).setStyles({'float':'left'});
    this.base.setStyle('height',this.hourList.base.getSize().y);
    this.setValue(new Date());
    this.parent();
  }
  })

/*
---

name: Iterable.ListItem

description: 

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

...
*/
Iterable.ListItem=new Class({
  Extends:Core.Abstract,
  options:{
     'class':GDotUI.Theme.ListItem['class'],
     title:'',
     subtitle:''
  },
  initialize:function(options){
     this.parent(options);
     this.enabled=true;
  },
  create:function(){
     this.base.addClass(this.options['class']).setStyle('position','relative');;
     this.remove=new Core.Icon({image:GDotUI.Theme.Icons.remove});
     this.handle=new Core.Icon({image:GDotUI.Theme.Icons.handleVertical});
     this.handle.base.addClass('list-handle');
     this.remove.base.setStyle('position','absolute');
     this.handle.base.setStyle('position','absolute');
     this.title=new Element('div').addClass(GDotUI.Theme.ListItem.title).set('text',this.options.title);
     this.subtitle=new Element('div').addClass(GDotUI.Theme.ListItem.subTitle).set('text',this.options.subtitle);
     this.base.adopt(this.title,this.subtitle);
     this.base.grab(this.remove.base);
     this.base.grab(this.handle.base);
     //Invoked
     this.base.addEvent('click',function(){
        if(this.enabled)
           this.fireEvent('invoked',this);
     }.bindWithEvent(this));
     //Edit
     this.base.addEvent('dblclick',function(){
       if(this.enabled){
         if(this.editing){
           this.fireEvent('edit',this);
         }
       }
     }.bindWithEvent(this));
  },
  toggleEdit:function(){
    if(this.editing){
      this.remove.base.setStyle('right',-this.remove.base.getSize().x);
      this.handle.base.setStyle('left',-this.handle.base.getSize().x);
      this.base.setStyle('padding-left',this.base.retrieve('padding-left:old'));
      this.base.setStyle('padding-right',this.base.retrieve('padding-right:old'));
      this.editing=false;
    }else{
      this.remove.base.setStyle('right',GDotUI.Theme.ListItem.iconOffset);
      this.handle.base.setStyle('left',GDotUI.Theme.ListItem.iconOffset);
      this.base.store('padding-left:old',this.base.getStyle('padding-left'))
      this.base.store('padding-right:old',this.base.getStyle('padding-left'))
      this.base.setStyle('padding-left',Number(this.base.getStyle('padding-left').slice(0,-2))+this.handle.base.getSize().x);
      this.base.setStyle('padding-right',Number(this.base.getStyle('padding-right').slice(0,-2))+this.remove.base.getSize().x);
      this.editing=true;
    }
  },
  ready:function(){
    if(!this.editing){
      var handSize=this.handle.base.getSize();
      var remSize=this.remove.base.getSize();
      var baseSize=this.base.getSize();
      this.remove.base.setStyles({
        "right":-remSize.x,
        "top":(baseSize.y-remSize.y)/2
        })
      this.handle.base.setStyles({
        "left":-handSize.x,
        "top":(baseSize.y-handSize.y)/2
        })
      this.parent();
    }
  }
})

/*
---

name: Iterable.List

description: 

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.List

...
*/
Iterable.List=new Class({
  Extends:Core.Abstract,
  options:{
    'class':GDotUI.Theme.List['class']
  },
  initialize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    this.sortable=new Sortables(null,{handle:'.list-handle'});
    //TODO Sortable Events
    this.editing=false;
    this.items=[];
  },
  removeItem:function(li){
    li.removeEvents('invoked','edit','delete');
    li.base.destroy();
    this.items.erase(li);
    delete li;
  },
  removeAll:function(){
    this.selected=null;
    this.items.each(function(item){
      this.removeItem(item);
      delete item;
      }.bind(this));
    delete this.items; this.items=[];
  },
  toggleEdit:function(){
    var bases=this.items.map(function(item){
        return item.base;
      })
    if(this.editing){
      this.sortable.removeItems(bases);
      this.items.each(function(item){item.toggleEdit()});
      this.editing=false;
    }else{
      this.sortable.addItems(bases);
      this.items.each(function(item){item.toggleEdit()});
      this.editing=true;
    }
  },
  getItemFromTitle:function(title){
    return this.items.filter(function(item){
      if(item.title.get('text')==title)
        return true
      else return false;
    })[0];
  },
  select:function(item){
    if(this.selected!=item){
      if(this.selected!=null)
        this.selected.base.removeClass('selected');
      this.selected=item;
      this.selected.base.addClass('selected');
      this.fireEvent('select',item);
    }
  },
  /*toTheTop:function(item){
    //console.log(item);
    //this.base.setStyle('top',this.base.getPosition().y-item.base.getSize().y);
    this.items.erase(item);
    this.items.unshift(item);
    
  },
  update:function(){
    this.items.each(function(item,i){
      item.base.dispose();
      this.base.grab(item.base,'top');
    }.bind(this))
  },*/
  addItem:function(li){
    this.items.push(li);
    this.base.grab(li.base);
    li.addEvent('invoked',function(item){
      this.select(item);
      this.fireEvent('invoked',[item]);
      }.bindWithEvent(this));
    li.addEvent('edit',function(){
      this.fireEvent('edit',arguments);
      }.bindWithEvent(this));
    li.addEvent('delete',function(){
      this.fireEvent('delete',arguments);
      }.bindWithEvent(this));
  }
  
})

/*
---

name: Pickers

description: 

license: MIT-style license.

requires: [Core.Picker, Data.Color]

provides: [Pickers.Base, Pickers.Color, Pickers.Number, Pickers.Text]

...
*/
Pickers.Base=new Class({
	Implements:Options,
  Delegates:{
	picker:['attach','detach']
  },
	options:{
		type:''
	},
  initialize:function(options){
		this.setOptions(options);
    this.picker=new Core.Picker();
    this.data=new Data[this.options.type]();
    this.picker.setContent(this.data);
  }
});
Pickers.Color=new Pickers.Base({type:'Color'});
Pickers.Number=new Pickers.Base({type:'Number'});
Pickers.Text=new Pickers.Base({type:'Text'});
Pickers.Date=new Pickers.Base({type:'Date'});
Pickers.DateSlot=new Pickers.Base({type:'DateSlot'});
Pickers.DateTime=new Pickers.Base({type:'DateTime'});
Pickers.Time=new Pickers.Base({type:'Time'});

/*
---

name: Core.Overlay

description: Abstract base class for Elements.

license: MIT-style license.

requires: Core.Abstract

provides: Core.Overlay

...
*/
Core.Overlay=new Class({
  Extends:Core.Abstract,
  options:{
    'class':GDotUI.Theme.Overlay['class']
    },
  initialize:function(options){
    this.parent(options);  
  },
  create:function(){
    this.base.setStyles({
      "position":"fixed",
      "top":0,
      "left":0,
      "right":0,
      "bottom":0
      }).addClass(this.options['class']);
    this.base.setStyle('opacity',0);
    document.getElement('body').grab(this.base);
    this.base.addEventListener('webkitTransitionEnd',function(e){
      if(e.propertyName=="opacity"){
       if(this.base.getStyle('opacity')==0)
        this.base.setStyle('visiblity','hidden')
      }
    }.bindWithEvent(this))
  },
  hide:function(){
    this.base.setStyle('opacity',0);
  },
  show:function(){
    this.base.setStyle('visiblity','visible')
    this.base.setStyle('opacity',1);
  }
})
