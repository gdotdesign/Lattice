/*
---

name: Data.Date

description: 

license: MIT-style license.

requires: Data.Abstract

provides: Data.Date

...
*/
MooTools.lang.set('en-US', 'Date', {
    days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday','Sunday']
});
Data.Date=new Class({
  Extends:Data.Abstract,
  options:{
    'class':GDotUI.Theme.Date['class'],
    nextClass:GDotUI.Theme.Date.next,
    prevClass:GDotUI.Theme.Date.previous,
    titleClass:GDotUI.Theme.Date.title,
    format:GDotUI.Theme.Date.format
  },
  initialize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    
    this.next=new Core.Icon();
    this.next.base.addEvent('click',this.Next.bindWithEvent(this)).addClass(this.options.nextClass);
    this.prev=new Core.Icon();
    this.prev.base.addEvent('click',this.Prev.bindWithEvent(this)).addClass(this.options.prevClass);
    this.title=new Element('div').addClass(this.options.titleClass);
    this.wrapper=new Element('div')
    this.wrapper.adopt(this.prev.base,this.title,this.next.base);
    var days3=MooTools.lang.get('Date','days').map(function(item,i){
      return item.slice(0,2);
      })
    this.table=new HtmlTable({
      headers:days3,
      properties:{cellspacing:2}
      });
    for(var i=5;i>0;i--){
      this.table.push(['','','','','','','']);
    }
    this.base.adopt(this.wrapper,this.table);
    this.table.element.addEvent('click:relay(td)',this.select.bindWithEvent(this));
  },
  select:function(e){
    var day=e.target.get('text');
    if($chk(day)){
      this.date.setDate(Number(day));
      /*if($defined(this.selected))
        this.selected.removeClass('picked');
      e.target.addClass('picked');
      this.selected=e.target;*/
      this.setValue();
    }	
  },
  ready:function(){
    this.setValue(new Date());
    this.parent();
  },
  populate:function(start){
    var j=1;
    var days=this.date.get('lastdayofmonth');
    this.table.element.getElements('td').each(function(item,i){
      if((i+1)>=start && (i+1)<(days+start)){
        item.set('text',j);
        j++;
      }else
        item.set('text','');
    }.bind(this));
  },
  Next:function(){
    if(this.month==11){
			this.date.setMonth(0);
			this.date.setFullYear(this.date.getFullYear()+1);
		}
		else
			this.date.setMonth(this.date.getMonth()+1);
    this.setValue();
  },
  Prev:function(){
    if(this.month==0){
      this.date.setMonth(11);
      this.date.setFullYear(this.date.getFullYear()-1);
    }
    else
      this.date.setMonth(this.date.getMonth()-1);
    this.setValue();
  },
  setValue:function(date){
    if(date!=null){
      this.date=date;
    }
    var day=this.date.getDate();
    this.title.set('text',MooTools.lang.get('Date','months')[this.date.getMonth()]+" "+this.date.getFullYear() )
    this.populate(new Date(this.date.getFullYear(),this.date.getMonth(),1).getDay());
    $(this.table).getElements('td').each(function(item){
      if(item.hasClass('picked'))
        item.removeClass('picked')
      if(item.get('text')==day)
        item.addClass('picked');
    });
    this.fireEvent('change',this.date.format(this.options.format));
  }
});
Data.DateSlot=new Class({
  Extends:Data.Abstract,
  options:{
    'class':GDotUI.Theme.Date.Slot['class'],
    format:GDotUI.Theme.Date.format
  },
  initialize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    this.days=new Core.Slot();
    this.month=new Core.Slot();
    this.years=new Core.Slot();
    this.years.addEvent('change',function(item){
      this.date.setYear(item.value);
      this.setValue();
    }.bindWithEvent(this));
    this.month.addEvent('change',function(item){
      this.date.setMonth(item.value);
      this.setValue();
    }.bindWithEvent(this));
     this.days.addEvent('change',function(item){
      this.date.setDate(item.value);
      this.setValue();
    }.bindWithEvent(this));
    for(var i=0;i<30;i++){
      var item=new Iterable.ListItem({title:i+1});
      item.value=i+1;
      this.days.addItem(item);
    }
    for(var i=0;i<12;i++){
      var item=new Iterable.ListItem({title:i+1});
      item.value=i;
      this.month.addItem(item);
    }
    for(var i=1980;i<2012;i++){
      var item=new Iterable.ListItem({title:i});
      item.value=i;
      this.years.addItem(item);
    }
  },
  ready:function(){
    this.base.adopt(this.years.base,this.month.base,this.days.base);
    this.setValue(new Date());
    this.base.setStyle('height',this.days.base.getSize().y);
    $$(this.days.base,this.month.base,this.years.base).setStyles({'float':'left'});
    this.parent();
  },
  setValue:function(date){
    if(date!=null){
      this.date=date;
    }
    this.update();
    this.fireEvent('change',this.date.format(this.options.format));
  },
  update:function(){
    var cdays=this.date.get('lastdayofmonth');
    var listlength=this.days.list.items.length;
    if(cdays>listlength){
      for(var i=listlength+1;i<=cdays;i++){
        var item=new Iterable.ListItem({title:i});
        item.value=i;
        this.days.addItem(item);
      }
    }else if(cdays<listlength){
      for(var i=listlength;i>cdays;i--){
        this.days.list.removeItem(this.days.list.items[i-1]);
      }
    }
    this.days.select(this.days.list.items[this.date.getDate()-1]);
    this.month.select(this.month.list.items[this.date.getMonth()]);
    this.years.select(this.years.list.getItemFromTitle(this.date.getFullYear()));
    //this.years.select(this)
  }
});
Data.DateTime=new Class({
  Extends:Data.Abstract,
  options:{
    'class':GDotUI.Theme.Date.DateTime['class'],
    format:GDotUI.Theme.Date.DateTime.format
  },
  initialize:function(options){
    this.parent(options);
  },
  create:function(){
    this.base.addClass(this.options['class']);
    this.datea=new Data.DateSlot();
    this.time=new Data.Time();
  },
  ready:function(){
    this.base.adopt(this.datea.base,this.time.base);
    this.setValue(new Date());
    this.datea.addEvent('change',function(){
      this.date.setYear(this.datea.date.getFullYear());
      this.date.setMonth(this.datea.date.getMonth());
      this.date.setDate(this.datea.date.getDate());
      this.fireEvent('change',this.date.format(this.options.format));
    }.bindWithEvent(this));
    this.time.addEvent('change',function(){
      this.date.setHours(this.time.time.getHours());
      this.date.setMinutes(this.time.time.getMinutes());
      this.fireEvent('change',this.date.format(this.options.format));
    }.bindWithEvent(this))
    this.parent();
  },
  setValue:function(date){
    if(date!=null){
      this.date=date;
    }
    this.datea.setValue(this.date);
    this.time.setValue(this.date);
    this.fireEvent('change',this.date.format(this.options.format));
  }
});