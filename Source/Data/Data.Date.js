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
    days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday','Sunday'],
});
Data.Date=new Class({
  Extends:Data.Abstract,
  options:{
    'class':GDotUI.Theme.Date['class'],
    nextClass:GDotUI.Theme.Date.next,
    prevClass:GDotUI.Theme.Date.previous,
    titleClass:GDotUI.Theme.Date.title
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
    this.setValue(new Date());
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
    this.fireEvent('change',this.date.format());
  }
});