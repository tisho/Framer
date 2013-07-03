{Animator} = require "./animator"

class LinearAnimator extends Animator
	
	constructor: ->
		super
		@_duration = @options.time or 1000
	
	_valueForTime: (time) =>
		1 / @_duration * time
		
	duration: -> @_duration

exports.LinearAnimator = LinearAnimator