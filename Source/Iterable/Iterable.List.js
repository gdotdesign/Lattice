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
    delete li;
  },
  removeAll:function(){
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
  addItem:function(li){
    this.items.push(li);
    this.base.grab(li.base);
    li.addEvent('invoked',function(item){
      this.fireEvent('invoked',[item,e]);
      }.bindWithEvent(this));
    li.addEvent('edit',function(){
      this.fireEvent('edit',arguments);
      }.bindWithEvent(this));
    li.addEvent('delete',function(){
      this.fireEvent('delete',arguments);
      }.bindWithEvent(this));
  }
  
})