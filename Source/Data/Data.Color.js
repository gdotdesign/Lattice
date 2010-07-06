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
    black:GDotUI.Theme.Color.black
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
    this.fireEvent('change',[this.colorData.hex.input.get('value')]);
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