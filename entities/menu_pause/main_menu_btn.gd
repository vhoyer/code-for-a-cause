extends StageChangerBaseButton

func _pressed() -> void:
	SaveManager.data.consolidate_memory()
	super()
