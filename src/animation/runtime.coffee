_ = require "underscore"

requestAnimationFrame = 
	window.requestAnimationFrame or \
	window.mozRequestAnimationFrame or \
	window.webkitRequestAnimationFrame or \
	window.msRequestAnimationFrame

cancelRequestAnimationFrame = 
	window.cancelRequestAnimationFrame or \
	window.mozCancelRequestAnimationFrame or \
	window.webkitCancelRequestAnimationFrame or \
	window.msCancelRequestAnimationFrame

AnimationCSSProperties =
	height: "px"
	width: "px"
	opacity: ""

AnimationCSSPropertiesKeys = _.keys AnimationCSSProperties

class AnimationRuntime
	
	# DefaultProperties: {fps: 60}
	
	constructor: ->
		@_running = false
		@_animators = []

	add: (animator) ->
		@_animators.push animator
		@_rebuildAnimatingViews()
		#@_start()
		
		utils.delay 0, => @_start()
	
	remove: (animator) ->
		animator._end()
		@_animators = _.without @_animators, animator
		@_rebuildAnimatingViews()
	
	_start: ->
		return if @_running is true	
		@_running = true
		@_tick()
	
	_stop: ->
		@_running = false
		
		if @_animationFrame
			cancelRequestAnimationFrame @_animationFrame
	
	_getTime: -> 
		# Date.now()
		window.performance.now()
		
	_tick: (time) =>
		
		time = @_getTime()
		
		# The request animation loop
		
		if @_animators.length is 0
			return @_stop()
		
		# @_animationFrame = requestAnimationFrame @_tick
		
		for id, info of @_animatingViews
			@_tickView info, time
		
		@_animationFrame = requestAnimationFrame @_tick
		# setTimeout @_tick, 1/120 #/
		
	_tickView: (info, time) ->
		
		# This updates every view on an animation frame
		# This code better be fast.
		
		updatedMatrix = info.view._matrix
		updatedStyle  = {}
		
		# Update the css values for each of the animators on this view
		for animator in info.animators
			
			animator._startTime ?= time
			timeDelta = time - animator._startTime
			
			# Calculate the next value from the animator
			value = animator.valueForTime timeDelta
			
			if animator.property in AnimationCSSPropertiesKeys
				# Handle css properties separate and add the unit
				unit = AnimationCSSProperties[animator.property]
				updatedStyle[animator.property] = "#{utils.round value, 5}#{unit}"
			else
				# Css transform properties can just be added to the matrix
				updatedMatrix[animator.property] = value

			# See if this specific animator is done
			if timeDelta > animator.duration()
				@remove animator
				continue
		
		# Set both the new css and update the matrix
		updatedStyle["-webkit-transform"] = updatedMatrix.matrix().toString()
		
		# console.log "tick #{time} #{info.view.name}"
		# 
		# for k, v of updatedStyle
		# 	console.log "  #{k} -> #{v}"
		
		info.view.style = updatedStyle
		
	_rebuildAnimatingViews: ->
	
		@_animatingViews = {}

		@_animators.map (animator) =>
			
			@_animatingViews[animator.view.id] ?=
				view: animator.view
				animators: []
			
			@_animatingViews[animator.view.id].animators.push animator
			
exports.AnimationRuntime = AnimationRuntime
