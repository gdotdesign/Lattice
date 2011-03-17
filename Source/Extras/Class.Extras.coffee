###
---
name: Class.Extras
description: Extra suff for Classes.

license: MIT-style

authors:
  - Kevin Valdek
  - Perrin Westrich
  - Maksim Horbachevsky
provides:
  - Class.Delegates
  - Class.Attributes
...
###
Class.Mutators.Delegates = (delegations) ->
	self = @
	new Hash(delegations).each (delegates, target) ->
		$splat(delegates).each (delegate) ->
			self.prototype[delegate] = ->
				ret = @[target][delegate].apply @[target], arguments
				if ret is @[target] then @ else ret

Class.Mutators.Attributes = (attributes) ->
    
    $setter = attributes.$setter
    $getter = attributes.$getter
    
    delete attributes.$setter
    delete attributes.$getter

    @implement new Events

    @implement {
      $attributes: attributes
      get: (name) ->
        attr = @$attributes[name]
        if attr 
          if attr.valueFn && !attr.initialized
            attr.initialized = true
            attr.value = attr.valueFn.call @
          if attr.getter
            return attr.getter.call @, attr.value
          else
            return attr.value
        else
          return if $getter then $getter.call(@, name) else undefined

      set: (name, value) ->
          attr = @$attributes[name]
          if attr
            if !attr.readOnly
              oldVal = attr.value
              if !attr.validator or attr.validator.call(@, value)
                if attr.setter
                  newVal = attr.setter.call @, value
                else
                  newVal = value             
                attr.value = newVal
                @fireEvent name + 'Change', { newVal: newVal, oldVal: oldVal }
          else if $setter
            $setter.call @, name, value

      setAttributes: (attributes) ->
        $each(attributes, (value, name) ->
          @set name, value
        , @)

      getAttributes: () ->
        attributes = {}
        $each(@$attributes, (value, name) ->
          attributes[name] = @get(name)
        , @)
        attributes

      addAttributes: (attributes) ->
        $each(attributes, (value, name) ->
            @addAttribute(name, value)
        , @)

      addAttribute: (name, value) ->
        @$attributes[name] = value
        @
  }
