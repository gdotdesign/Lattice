define ["Core.Picker","Data.Color","Data.Number","Data.Text","Data.Date","Data.Time","Data.DateTime"], "Pickers.Base", ->
  new Class
    Extends: Core.Picker
    Delegates:
      data: ['set']
    Attributes:
      type:
        value: null
    show: (e,auto) ->
      if @data is undefined
        @data = new Data[@type]()
        @set 'content', @data
      @parent e, auto
define "Pickers.Base", "Pickers.Color", -> new Pickers.Base {type:'ColorWheel'}
define "Pickers.Base", "Pickers.Number", -> new Pickers.Base {type:'Number'}
define "Pickers.Base", "Pickers.Time", -> new Pickers.Base {type:'Time'}
define "Pickers.Base", "Pickers.Text", -> new Pickers.Base {type:'Text'}
define "Pickers.Base", "Pickers.Date", -> new Pickers.Base {type:'Date'}
define "Pickers.Base", "Pickers.DateTime", -> new Pickers.Base {type:'DateTime'}
define "Pickers.Base", "Pickers.Table", -> new Pickers.Base {type:'Table'}
define "Pickers.Base", "Pickers.Unit", -> new Pickers.Base {type:'Unit'}
define "Pickers.Base", "Pickers.Select", -> new Pickers.Base {type:'Select'}
define "Pickers.Base", "Pickers.List", -> new Pickers.Base {type:'List'}
