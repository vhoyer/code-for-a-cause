extends StateTween
class_name StateTweenWindowBorderless

func reset(target: Node = null) -> void:
	super(target)
	target.get_window().borderless = true

func enter(tween: Tween) -> Tween:
	super(tween)
	
	tween.tween_callback(func():
		target.get_window().borderless = false)
	
	return tween

func exit(tween: Tween) -> Tween:
	super(tween)
	
	tween.tween_callback(func():
		target.get_window().borderless = true)
	
	return tween
