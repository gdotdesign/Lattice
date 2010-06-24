Interfaces.Enabled=new Class({
  enable:function(){
    this.enabled=true;
    this.base.removeClass('disabled');
    this.fireEvent('enabled');
  },
  disable:function(){
    this.enabled=false;
    this.base.addClass('disabled');
    this.fireEvent('disabled');
  }
})