Iterable.ListItem=new Class({
  Extends:Core.Abstract,
  options:{
     'class':GDotUI.Theme.ListItem['class'],
     title:'',
     subtitle:''
  },
  initialize:function(options){
     this.parent(options);
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
           this.fireEvent('invoked');
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