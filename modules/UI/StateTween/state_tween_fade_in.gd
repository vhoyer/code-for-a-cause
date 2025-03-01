extends StateTween
class_name StateTweenFadeIn

@export var tween_duration: float = 0.3
@export var min_alpha: float = 0.0
@export var set_visibility: bool = true

func reset(target: Node = null) -> void:
	super(target)
	assert(target is CanvasItem, 'Error: StateTweenFadeIn should only be used on CanvasItem nodes')
	set_modulate_alpha(min_alpha)

func enter(tween: Tween) -> Tween:
	if !self.target: return
	super(tween)
	tween.tween_method(set_modulate_alpha, self.target.modulate.a, 1, tween_duration)
	
	return tween

func exit(tween: Tween) -> Tween:
	if !self.target: return
	super(tween)
	tween.tween_method(set_modulate_alpha, self.target.modulate.a, min_alpha, tween_duration)
	
	return tween

func set_modulate_alpha(value: float) -> void:
	if set_visibility:
		self.target.visible = value != 0.0
	self.target.modulate.a = value
