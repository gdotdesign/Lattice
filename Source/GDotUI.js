Class.Mutators.DCollection=function(items){
  var self=this;
  new Hash(items).each(function(fns, target) {
    $splat(fns).each(function(fn){
      self.prototype[fn]=function(){
        var args=arguments;
        this[target].each(function(item){
          item[fn].run(arguments,item);
        });
      };
    });
  });
};
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
Interfaces={}
Core={}
Data={}
Iterable={}
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
   // this.fireEvent('init');
  }
  });
GDotUI.Config={
    tipZindex:100,
    floatZindex:0,
    cookieDuration:7*1000
}