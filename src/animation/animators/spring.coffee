{Animator} = require "./animator"
{Spring} = require "../../curves/spring"


memo = {}

hash = (obj) ->
	console.log obj
	JSON.stringify obj
	
memoize = (func) ->
	(arg) ->
		
		h = hash arg
		
		console.log "memo", memo 
		
		if not memo[h]
			memo[h] = func arg
		else
			console.log "CACHED"
		memo[h]

_springValues = (options) ->
	
	spring = new Spring options
	
	result = {}
	result.frames = spring.all()
	result.frames.push 1
	result.duration = result.frames.length * 1/60 * 1000 #/
	
	result

springValues = memoize _springValues
	

class SpringAnimator extends Animator
	
	constructor: (options) ->
		super
		
		@options.speed = 1/120
		
		sv = springValues @options
		
		@_frames = sv.frames
		@_duration = sv.duration
		
		console.log "frames: #{@_frames.length}"

	_valueForTime: (time) =>
		frameIndex = parseInt(time/ ((1/60) * 1000)) #/
		@_frames[frameIndex]
		
	duration: -> @_duration

exports.SpringAnimator = SpringAnimator