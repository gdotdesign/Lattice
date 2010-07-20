Core: Abtract
=============

"Abstract" class for Core elements to extend upon.

### Implements
Interfaces.Mux

Method: Create
--------------
An empty function which shoud be overriden.   
This is used to create the U.I. element.   
The base property can be overriden like this:   

	create: function(){
		delete this.base;
		this.base = new Element('input');
	}

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