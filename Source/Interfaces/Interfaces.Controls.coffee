define null, "Interfaces.Controls", -> 
  new Class
    Implements: Interfaces.Enabled
    show: ->
      if @enabled
        @base.show()
    hide: ->
      if @enabled
        @base.hide()
    toggle: ->
      if @enabled
        @base.toggle()
