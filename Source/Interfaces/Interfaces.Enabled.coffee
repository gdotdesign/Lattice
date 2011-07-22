define null, "Interfaces.Enabled", ->
  new Class
    _$Enabled: ->
      @addAttributes
        enabled:
          value: true
          setter: (value) ->
            if value
              if @children?
                @children.each (item) ->
                  if item.$attributes.enabled?
                    item.set 'enabled', true
              @base.removeClass 'disabled'
            else
              if @children?
                @children.each (item) ->
                  if item.$attributes.enabled?
                    item.set 'enabled', false
              @base.addClass 'disabled'
            value
