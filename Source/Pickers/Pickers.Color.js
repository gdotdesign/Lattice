Pickers.Color=new Class.Singleton({
  Delegates:{
	picker:['attach','detach']
  },
  initialize:function(){
    this.picker=new Core.Picker();
    this.data=new Data.Color();
    this.picker.setContent(this.data);
  }
});
Pickers.Number=new Class.Singleton({
  Delegates:{
	picker:['attach','detach']
  },
  initialize:function(){
    this.picker=new Core.Picker();
    this.data=new Data.Number();
    this.picker.setContent(this.data);
  }
});
Pickers.Text=new Class.Singleton({
  Delegates:{
	picker:['attach','detach']
  },
  initialize:function(){
    this.picker=new Core.Picker();
    this.data=new Data.Text();
    this.picker.setContent(this.data);
  }
});