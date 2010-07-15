###
---

name: Core.Slider

description: 

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls]

provides: [Core.Slider, ResetSlider]

...
###
ResetSlider: new Class {
	Extends:Slider
	initialize: (element, knob, options) ->
		@parent(element, knob, options)
	setRange: (range) ->
		@min = $chk(range[0]) ? range[0] : 0;
		@max = $chk(range[1]) ? range[1] : @.steps;
		@range = @max - @min;
		@steps = @options.steps || @full;
		@stepSize = Math.abs(@range) / @steps;
		@stepWidth = @stepSize * @full / Math.abs(@range) ;
}
Class.Mutators.Delegates: (delegations) ->
	self = this;
	(new Hash delegations).each (delegates, target) ->
		($splat delegates).each (delegate) ->
			self.prototype[delegate]: ->
				ret: @[target][delegate].apply @[target], arguments
				if ret == @[target] then this else ret
Core.Slider: new Class {
  Extends:Core.Abstract
  Implements:[Interfaces.Controls]
  Delegates:{ slider:[
    'set'
    'setRange'
  ]}
  options:{
    scrollBase: null
    reset: off
    mode: 'vertical'
    class: GDotUI.Theme.Slider.barClass
    knob: GDotUI.Theme.Slider.knobClass
  }
  initialize: (options) ->
    @parent(options)
    this
  create: ->
    @base.addClass @options.class
    @knob: (new Element 'div').addClass @options.knob
    if @options.mode=="vertical"
      @base.setStyles {
        'width':GDotUI.Theme.Slider.width
        'height':GDotUI.Theme.Slider.length
      } 
      @knob.setStyles {
        'width':GDotUI.Theme.Slider.width
        'height':GDotUI.Theme.Slider.width*2
      }
    else
      @base.setStyles {
        'width':GDotUI.Theme.Slider.length
        'height':GDotUI.Theme.Slider.width
      }
      @knob.setStyles {
        'width':GDotUI.Theme.Slider.width*2
        'height':GDotUI.Theme.Slider.width
      }
    @scrollBase=@options.scrollBase
    @base.grab @knob
    ready: ->
      if @options.reset
        @slider: new ResetSlider @base, @knob, {mode:@options.mode
                                                steps:@options.steps
                                                range:@options.range}
        @slider.set 0
      else
        @slider=new Slider @base, @knob, {mode:@this.options.mode
                                          steps:100}
      @slider.addEvent 'complete', ((step) ->
        @fireEvent 'complete', step+''
      ).bindWithEvent this
      @slider.addEvent 'change', ((step)->
        if typeof(step) == 'object'
          step=0;
        @fireEvent 'change', step+''
        if @scrollBase != null
            @scrollBase.scrollTop: (@scrollBase.scrollHeight-@scrollBase.getSize().y)/100*step
      ).bindWithEvent this
      @parent()
}
