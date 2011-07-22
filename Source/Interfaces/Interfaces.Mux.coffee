define null, "Interfaces.Mux", ->
  new Class
    mux: ->
      new Hash(@).each (value,key) ->
        if key.test(/^_\$/) and typeOf(value) is "function"
          value.attempt null, @
      , @
