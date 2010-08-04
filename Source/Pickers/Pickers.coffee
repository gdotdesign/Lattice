###
---

name: Pickers

description: Pickers for Data classes.

license: MIT-style license.

requires: [Core.Picker, Data.Color, Data.Number, Data.Text, Data.Date, Data.Time, Data.DateTime ]

provides: [Pickers.Base, Pickers.Color, Pickers.Number, Pickers.Text, Pickers.Time, Pickers.Date, Pickers.DateTime ] 

...
###
Pickers.Base: new Class {
  Implements:Options
  Delegates:{
    picker:['attach'
            'detach'
            'attachAndShow']
    data: ['setValue'
          'getValue']
  }
  options:{
    type:''
  }
  initialize: (options) ->
    @setOptions options
    @picker: new Core.Picker()
    @data: new Data[@options.type]()
    @picker.setContent @data
    @
}
Pickers.Color: new Pickers.Base {type:'Color'}
Pickers.Number: new Pickers.Base {type:'Number'}
Pickers.Time: new Pickers.Base {type:'Time'}
Pickers.Text: new Pickers.Base {type:'Text'}
Pickers.Date: new Pickers.Base {type:'Date'}
Pickers.DateTime: new Pickers.Base {type:'DateTime'}
Pickers.Table: new Pickers.Base {type:'Table'}
Pickers.Unit: new Pickers.Base {type:'Unit'}
Pickers.Select: new Pickers.Base {type:'Select'}
Pickers.List: new Pickers.Base {type:'List'}
