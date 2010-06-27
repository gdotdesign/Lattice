Interfaces={}
Core={}
Data={}
Selectors.Pseudo.disabled = function(){
  return (this.hasClass('disabled'));
};
Class.Singleton = new Class({

	initialize: function(classDefinition, options){
		var singletonClass = new Class(classDefinition);
		return new singletonClass(options);
	}

})
GDotUI=new Class.Singleton({
  Implements:[Events],
  initialize:function(){
  },
  init:function(){
    this.fireEvent('init');
  }
  });
GDotUI.Config={
    tipZindex:100,
    floatZindex:0,
    cookieDuration:7*1000
}