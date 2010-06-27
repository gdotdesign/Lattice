Core.Slider=new Class({
    Implements:[Options,
                Events,
                Interfaces.Mux],
    options:{
        scrollBase:null
    },
    initialize:function(options){
      this.setOptions(options);
      this.create();
    },
    create:function(){
      this.base=new Element('div',{'class':GDotUI.Theme.Slider.barClass}).setStyle('position','absolute');
      this.knob=new Element('div',{'class':GDotUI.Theme.Slider.knobClass});
      this.scrollBase=this.options.scrollBase;
      this.base.grab(this.knob);
    },
    init:function(){
      this.slider=new Slider(this.base,this.knob,{mode:'vertical',steps:100});
      this.slider.addEvent('complete',function(){
        this.fireEvent('complete');
      }.bindWithEvent(this));
      this.slider.addEvent('change',function(step){
        this.fireEvent('change');
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