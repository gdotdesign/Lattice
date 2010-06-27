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
    Implements:[Options,
                Events,
                Interfaces.Mux],
    Delegates:{
        slider:['set','setRange']
    },
    options:{
        scrollBase:null,
        reset:false,
        mode:'vertical'
    },
    initialize:function(options){
      this.setOptions(options);
      this.create();
    },
    create:function(options){
      this.setOptions(options);
      this.base=new Element('div',{'class':GDotUI.Theme.Slider.barClass});
      this.knob=new Element('div',{'class':GDotUI.Theme.Slider.knobClass});
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
    init:function(){
      if(this.options.reset)
        this.slider=new ResetSlider(this.base,this.knob,{mode:this.options.mode,steps:this.options.steps,range:this.options.range});
      else
        this.slider=new Slider(this.base,this.knob,{mode:'vertical',steps:100});
      this.slider.addEvent('complete',function(step){
        this.fireEvent('complete',step);
      }.bindWithEvent(this));
      this.slider.addEvent('change',function(step){
        this.fireEvent('change',step);
        if(this.scrollBase!=null)
            this.scrollBase.scrollTop=(this.scrollBase.scrollHeight-this.scrollBase.getSize().y)/100*step;
      }.bindWithEvent(this));
    },
    hide:function(){
      this.base.setStyle('opacity',0);
    },
    show:function(){
      this.base.setStyle('opacity',1);
    }
})
