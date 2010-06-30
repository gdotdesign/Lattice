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
     this.remove.base.setStyle('position','absolute');
     this.handle.base.setStyle('position','absolute');
     this.title=new Element('div').addClass(GDotUI.Theme.ListItem.title).set('text','list item 1');
     this.subtitle=new Element('div').addClass(GDotUI.Theme.ListItem.subTitle).set('text','subtitles 1');;
     this.base.adopt(this.title,this.subtitle);
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
      this.base.setStyle('padding-left',0);
      this.base.setStyle('padding-right',0);
      this.editing=false;
    }else{
      this.remove.base.setStyle('right',0);
      this.handle.base.setStyle('left',0);
      this.base.setStyle('padding-left',this.handle.base.getSize().x);
      this.base.setStyle('padding-right',this.remove.base.getSize().x);
      this.editing=true;
    }
  },
  ready:function(){
    this.base.grab(this.remove.base);
    this.base.grab(this.handle.base);
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
  }
})