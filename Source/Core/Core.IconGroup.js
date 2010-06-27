Core.IconGroup=new Class({
  Implements:[Events,
              Options,
              Interfaces.Mux],
  options:{
    mode:"horizontal", // horizontal / vertical / circular / grid
    spacing: {x:20,y:20},
    startAngle:0, //degree
    radius:0, //degree
    degree:360 //degree
    },
  initialize:function(options){
    this.setOptions(options);
    this.icons=[];
    this.base=new Element('div').setStyle('position','relative');
    this.mux();
  },
  addIcon:function(icon){
    if(this.icons.indexOf(icon)==-1){
      this.base.grab(icon.base);
      this.icons.push(icon);
    }
  },
  removeIcon:function(icon){
    if(this.icons.indexOf(icon)!=-1){
      icon.base.dispose();
      this.icons.push(icon);
    }
  },
  show:function(){
    this.base.setStyle('opacity',1);
  },
  hide:function(){
    this.base.setStyle('opacity',0);
  },
  positionIcons:function(){
    x=0;
    y=0;
    size={x:0,y:0};
    if(this.options.mode=="grid"){
      if(this.options.columns!=null){
        var rows=this.icons.length/this.options.columns;
        var columns=this.options.columns;
      }
      if(this.options.rows!=null){
        var rows=this.options.rows;
        var columns=Math.round(this.icons.length/this.options.rows);
      }
      this.icons.each(function(item,i){
        if(i%columns==0){
          y+=i==0?0:(item.base.getSize().y+this.options.spacing.y);
          x=0;
        }else{
          x+=i==0?x:(item.base.getSize().x+this.options.spacing.x);
        }
        item.base.setStyle('top',y);
        item.base.setStyle('left',x);
        item.base.setStyle('position','absolute');
      }.bind(this))
    }
    if(this.options.mode=="horizontal"){
      this.icons.each(function(item,i){
        x+=i==0?x:(item.base.getSize().x+this.options.spacing.x);
        y+=i==0?0:(this.options.spacing.y);
        item.base.setStyle('top',y);
        item.base.setStyle('left',x);
        item.base.setStyle('position','absolute');
      }.bind(this))
    }
    if(this.options.mode=="vertical"){
      this.icons.each(function(item,i){
        x+=i==0?0:(this.options.spacing.x);
        y+=i==0?y:(item.base.getSize().y+this.options.spacing.y);
        if(item.base.getSize().x > size.x)
          size.x=item.base.getSize().x;
        size.y=y+item.base.getSize().y;
        item.base.setStyle('top',y);
        item.base.setStyle('left',x);
        item.base.setStyle('position','absolute');
      }.bind(this))
      this.size=size;
    }
    if(this.options.mode=="circular"){
      var n=this.icons.length;
      var radius=this.options.radius;
      var ker=2*this.radius*Math.PI;
      var fok=((this.options.degree)/n);
      this.icons.each(function(item,i){
        if(i==0){
          var foks=this.options.startAngle*(Math.PI/180);
          x=-Math.round(radius*Math.cos(foks));
          y=Math.round(radius*Math.sin(foks));
        }else{
          x=-Math.round(radius*Math.cos(((fok*i)+this.options.startAngle)*(Math.PI/180)));
          y=Math.round(radius*Math.sin(((fok*i)+this.options.startAngle)*(Math.PI/180)));
        }
        item.base.setStyle('top',x);
        item.base.setStyle('left',y);
        item.base.setStyle('position','absolute');
      }.bind(this));
    }
  },
  });