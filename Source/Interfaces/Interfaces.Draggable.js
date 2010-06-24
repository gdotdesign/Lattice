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
  _$Draggable:function(){
    if(this.options.moveable){
      if(this.handle==null){
        this.handle=this.base;
      }
      this.drag=new Drag.Float(this.base,{target:this.handle,handle:this.handle});
      this.drag.addEvent('drop',function(){
        this.fireEvent('dropped',this);
        }.bindWithEvent(this));
    }
  },
})