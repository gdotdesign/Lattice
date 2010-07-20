Core: Abtract
=============

"Abstract" class for Core elements to extend upon.

### Implements
Interfaces.Mux

Method: create
--------------

Method: ready
--------------

How to use:
-------------------
### Syntax
  
	Core.Test = new Class({
		Extends: Core.Abstract(),
		options: {
			label: ''
		}
		initialize: function(options){
			this.parent(options);
		}
		create: function(){
		  
		}
	})
  
Initializes the class.