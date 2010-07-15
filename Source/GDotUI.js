/*
---

name: GDotUI

description: 

license: MIT-style license.

requires: 

provides: GDotUI

...
*/
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

Interfaces={}
Core={}
Data={}
Iterable={}
Pickers={}
Selectors.Pseudo.disabled = function(){
  return (this.hasClass('disabled'));
};
Class.Singleton = new Class({

	initialize: function(classDefinition, options){
		var singletonClass = new Class(classDefinition);
		return new singletonClass(options);
	}

})
if(GDotUI==null)
  GDotUI={};
/*GDotUI=new Class.Singleton({
  Implements:[Events],
  initialize:function(){
    //this.loadTheme('../Themes/Blank/theme.js');
  },
  loadTheme:function(url){
    var uri=new URI(url);
    var local=new URI(window.location);

    //console.log();
    var themejs = Asset.javascript(url);
    themejs.addEvent('load',function(){
      var themecss= Asset.css(new URI(uri.get('directory')+GDotUI.Theme.css).toRelative(local.get('directory')));
      })
  }
  });*/
GDotUI.Config={
    tipZindex:100,
    floatZindex:0,
    cookieDuration:7*1000
}