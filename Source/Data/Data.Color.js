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
    'width':GDotUI.Theme.Color.width,
    'height':GDotUI.Theme.Color.height
  },
  initialize:function(options){
    this.parent();
  },
  create:function(){
    this.base.addClass(this.options['class']);
    /** SB Start**/
    this.wrapper=new Element('div');
    this.wrapper.setStyles({
      width:this.options.width,
      height:this.options.height,
      'position':'relative',
      'float':'left'
      })
    this.white=new Element('div').set('id','white');
    this.black=new Element('div').set('id','black');
    this.color=new Element('div').set('id','color');
    this.xyKnob=new Element('div').set('id','xyknob');
    this.xyKnob.setStyles({
      'position':'absolute',
      'top':0,
      'left':0
      });
    $$(this.white,this.black,this.color).setStyles({
      'position':'absolute',
      'top':0,
      'left':0,
      'width':'inherit',
      'height':'inherit'
      })
    this.wrapper.adopt(this.color,this.white,this.black,this.xyKnob);
    /** SB END **/
    /** Hue Start **/
    this.color_linear=new Element('div',{'id':'color_linear'});
    this.color_linear.setStyles({
      height:this.options.height,
      width:this.options.width/11.25,
      'float':'left'
	  });
    this.colorKnob=new Element('div',{'id':'knob'});
    this.colorKnob.setStyles({
      height:(this.options.width/11.25+8)/2.8,
      width:this.options.width/11.25+8,
      left:-4
	  });
    this.color_linear.grab(this.colorKnob);
    /** Hue End **/
    this.inputs=new Element('div');
	
	this.leftWrap=new Element('div');
	this.leftWrap.setStyles({'float':'left',
                           width:this.options.width*0.74});
	this.rDiv=new Element('div',{'id':'red',text:'R:'});
	this.r=new Element('input',{'type':'text'});
	this.rDiv.grab(this.r);
	this.gDiv=new Element('div',{'id':'green',text:'G:'});
	this.g=new Element('input');
	this.gDiv.grab(this.g);
	this.bDiv=new Element('div',{'id':'blue',text:'B:'});
	this.b=new Element('input');
	this.bDiv.grab(this.b);
	this.leftWrap.adopt(this.rDiv,this.gDiv,this.bDiv);
	
	this.rightWrap=new Element('div');
	this.rightWrap.setStyles({'float':'right',
                           width:this.options.width*0.74});
	this.hDiv=new Element('div',{'id':'hue',text:'H:'});
	this.h=new Element('input');
	this.hDiv.grab(this.h);
	this.sDiv=new Element('div',{'id':'strat',text:'S:'});
	this.s=new Element('input');
	this.sDiv.grab(this.s);
	this.brDiv=new Element('div',{'id':'bright',text:'L:'});
	this.br=new Element('input');
	this.brDiv.grab(this.br);
	this.rightWrap.adopt(this.hDiv,this.sDiv,this.brDiv);
	this.hex=new Element('input');
  this.rgb=new Element('input');
  this.hsb=new Element('input');
	this.leftWrap.adopt(this.hex,this.rgb,this.hsb);
	this.col=new Element('input',{'id':'color'});
  this.rightWrap.grab(this.col);
	this.inputs.adopt(this.leftWrap,this.rightWrap);
	this.inputs.setStyles({
	  height:this.options.height,
	  width:this.options.width*1.5,
	  margin:this.options.margin,
	  'float':'left'
	  })
    this.base.adopt(this.wrapper,this.color_linear,this.inputs);
    
  },
  ready:function(){
    //this.color.setStyle('background-color',this.bgColor);
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
    this.setValue('#fff');
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
    this.col.setStyle('background-color',this.finalColor);
    this.r.set('value',this.finalColor.rgb[0]);
    this.g.set('value',this.finalColor.rgb[1]);
    this.b.set('value',this.finalColor.rgb[2]);
    this.rgb.set('value',"rgb("+(this.finalColor.rgb[0])+", "+(this.finalColor.rgb[1])+", "+(this.finalColor.rgb[2])+")");
    this.h.set('value',this.finalColor.hsb[0]);
    this.s.set('value',this.finalColor.hsb[1]);
    this.br.set('value',this.finalColor.hsb[2]);
    this.hsb.set('value',"hsl("+(this.finalColor.hsb[0])+", "+(this.finalColor.hsb[1])+"%, "+(this.finalColor.hsb[2])+"%)");
    this.hex.set('value',this.finalColor.hex.slice(1,7));
    this.fireEvent('colorChange',[this.finalColor]);
  },
  change:function(pos){
    this.saturation=pos.x;
    this.brightness=pos.y;
    this.setColor();
  }
})