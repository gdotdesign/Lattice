Data.Number=new Class({
  Extends:Data.Abstract,
  initialize:function(){
    this.parent();
  },
  create:function(){
    this.text=new Element('input',{'type':'text'});
    this.text.set('value',0).setStyle('width',GDotUI.Theme.Slider.length);
    this.slider=new Core.Slider({reset:true,range:[-100,100],steps:200,mode:'horizontal'});
  },
  ready:function(){
    this.base.adopt(this.text,this.slider.base);
    this.slider.addEvent('complete',function(step){
      this.slider.setRange([step-100,Number(step)+100])
      this.slider.set(step);
      }.bindWithEvent(this));
    this.slider.addEvent('change',function(step){
      if(typeof(step)=='object'){
        this.text.set('value',0);
      }else
      this.text.set('value',step);
      this.fireEvent('numberChange',step);
      }.bindWithEvent(this));
    this.text.addEvent('change',function(){
      var step=Number(this.text.get('value'));
      this.slider.setRange([step-100,Number(step)+100])
      this.slider.set(step);
    }.bindWithEvent(this));
    this.text.addEvent('mousewheel',function(e){
      this.slider.set(Number(this.text.get('value'))+e.wheel);
    }.bindWithEvent(this));
  },
  setValue:function(step){
    this.slider.setRange([step-100,Number(step)+100])
    this.slider.set(step);
    
  }
});