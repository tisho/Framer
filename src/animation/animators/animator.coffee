class Animator
	
	constructor: (@animation, @view, @property, @valueA, @valueB, @options) ->
		
	_end: ->
		@animation?._animatorEnd()
	
	valueForTime: (time) =>
		
		if time > @duration()
			time = @duration()
		
		if time < 0
			time = 0
		
		# Convert the value from 0:1 to the requested values
		value1 = @_valueForTime(time)
		value2 = (value1 * (@valueB - @valueA)) + @valueA
		
		# console.log "#{utils.round time, 2} #{value1} -> #{value2}"
		# console.log "Animator #{@property} #{time} #{value1} #{value2}"
		
		return value2

	_valueForTime: (time) ->
		throw Error "Not Implemented"

exports.Animator = Animator
