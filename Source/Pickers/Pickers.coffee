###
---

name: Pickers

description: 

license: MIT-style license.

requires: [Core.Picker, Data.Color]

provides: [Pickers.Base, Pickers.Color, Pickers.Number, Pickers.Text]

...
###
Pickers.Base: new Class {
  Implements:Options
  Delegates:{
    picker:['attach'
            'detach']
  }
  options:{
    type:''
  }
  initialize: (options) ->
    @setOptions options
    @picker: new Core.Picker()
    @data: new Data[@options.type]()
    @picker.setContent @data
    this
}
Pickers.Color: new Pickers.Base {type:'Color'}
Pickers.Number: new Pickers.Base {type:'Number'}
Pickers.Time: new Pickers.Base {type:'Time'}
Pickers.Text: new Pickers.Base {type:'Text'}
Pickers.Date: new Pickers.Base {type:'Date'}
Pickers.DateTime: new Pickers.Base {type:'DateTime'}