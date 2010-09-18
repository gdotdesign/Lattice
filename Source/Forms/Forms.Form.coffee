###
---

name: Forms.Form

description: Class for creating forms from javascript objects.

license: MIT-style license.

requires: [Core.Abstract, Forms.Fieldset]

provides: Forms.Form

...
###
Forms.Form = new Class {
  Extends:Core.Abstract
  Binds:['success', 'faliure']
  options:{
    data: {}
  }
  initialize: (options) ->
    @fieldsets = []
    @parent options
  create: ->
    delete @base
    @base = new Element 'form'
    if @options.data?
      @options.data.each( ( (fs) ->
        @addFieldset(new Forms.Fieldset(fs))
      ).bind this )
    @extra=@options.extra;
    @useRequest=@options.useRequest;
    if @useRequest
      @request = new Request.JSON {url:@options.action, resetForm:false, method: @options.method }
      @request.addEvent 'success', @success
      @request.addEvent 'faliure', @faliure
    else
      @base.set 'action', @options.action
      @base.set 'method', @options.method
      
    @submit = new Element 'input', {type:'button', value:@options.submit}
    @base.grab @submit

    @validator = new Form.Validator @base, {serial:false}
    @validator.start();

    @submit.addEvent 'click', ( ->
      if @validator.validate()
        if @useRequest
          @send()
        else
          @fireEvent 'passed', @geatherdata()
      else
        @fireEvent 'failed', {message:'Validation failed'}
    ).bindWithEvent this
  addFieldset: (fieldset)->
    if @fieldsets.indexOf(fieldset) == -1
      @fieldsets.push fieldset
      @base.grab fieldset
  geatherdata: ->
    data = {}
    @base.getElements( 'select, input[type=text], input[type=password], textarea, input[type=radio]:checked, input[type=checkbox]:checked').each (item) ->
      data[item.get('name')] = if item.get('type')=="checkbox" then true else item.get('value')
    data
  send: ->
    @request.send {data: $extend(@geatherdata(), this.extra)}
  success: (data) ->
    @fireEvent 'success', data
  faliure: ->
    @fireEvent 'failed', {message: 'Request error!'}
}
