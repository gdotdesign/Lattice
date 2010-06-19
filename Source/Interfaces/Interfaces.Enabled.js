Interfaces={};
Interfaces.Enabled=new Class({
  enable:function(){
    this.enabled=true;
    this.base.removeClass('disabled');
  },
  disable:function(){
    this.enabled=false;
    this.base.addClass('disabled');
  }
})