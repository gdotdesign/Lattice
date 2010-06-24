Interfaces.Mux=new Class({
  mux:function(){
    new Hash(this).each(function(value,key){
      if(key.test(/^_\$/) && $type(value)=="function"){
      value.run(null,this);
      }
    }.bind(this));
    new Hash(this).each(function(value,key){
      if(key.test(/^__\$/) && $type(value)=="function"){
      value.run(null,this);
      }
    }.bind(this));
  }
  });