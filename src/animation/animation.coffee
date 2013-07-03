_ = require "underscore"

{EventEmitter} = require "../eventemitter"
{AnimationRuntime} = require "./runtime"

AnimatorMap =
	linear: require("./animators/linear").LinearAnimator
	bezier: require("./animators/bezier").BezierAnimator
	spring: require("./animators/spring").SpringAnimator

# Create a new single animation runtime
DefaultAnimationRuntime = new AnimationRuntime

class Animation extends EventEmitter
	
	constructor: (args) ->
		_.extend @, args
		
		@_animators = []
	
	start: ->
		
		@stop()
		@view.animateStop()
		
		@view._currentAnimations.push @
		
		animatorInfo = @_parseCurve()
		
		for property, value of @properties
			@_animators.push new animatorInfo.animator \
				@, @view, property, @view[property], value, animatorInfo.options 
		
		for animator in @_animators
			DefaultAnimationRuntime.add animator
	
	stop: ->
		for animator in @_animators
			DefaultAnimationRuntime.remove animator
		
		@view._currentAnimations = _.without @view._currentAnimations, @
		
	_animatorEnd: (animator) ->
		
		@_animators = _.without animator
		
		if @_animators.length is 0
			@view._currentAnimations = _.without @view._currentAnimations, @
			
			@emit "end"
	
	_parseCurve: ->
		
		curve = parseCurve @curve
		
		Animator =  AnimatorMap[curve.prefix]
		Animator ?= AnimatorMap.linear
		
		curveOptions = {time: @time}
		
		if Animator is AnimatorMap.spring
			curveOptions =
				tension: curve.values[0]
				friction: curve.values[1]
				velocity: curve.values[2] / 100
		
		return {animator: Animator, options:curveOptions}
		
parseCurve = (a) ->

	# "spring(1, 2, 3)" -> {prefix: "spring", values:[1, 2, 3]}

	if not _.isString a
		return {prefix:"", values:[]}

	a = a.replace /\s+/g, ""
	
	if a.indexOf("(") is -1
		return {prefix:a, values:[]}
	
	prefix = a.split("(")[0]
	values = a.split("(")[1]
	
	values = values.replace ")", ""
	values = values.split ","
	values = values.map (i) -> parseFloat i
	
	return {prefix:prefix, values:values}
	
exports.Animation = Animation