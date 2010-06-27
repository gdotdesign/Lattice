Core.Icon=new Class({
  Extends:Core.Abstract,
  Implements:[Interfaces.Enabled,
              Interfaces.Controls],
  options:{
    image:null,
    text:""
  },
  initialize:function(options){
    this.parent(options);
    this.enabled=true;
  },
  create:function(){
    var clas=(this.options['class']==null?GDotUI.Theme.iconClass:this.options['class']);
    this.base.addClass(clas).set('text',this.options.text);
    if(this.options.image!=null)
      this.base.setStyle('background-image','url('+this.options.image+')');
    this.base.addEvent('click',function(e){
      if(this.enabled)
        this.fireEvent('invoked',this);
    }.bindWithEvent(this));
  }
});