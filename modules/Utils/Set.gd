class_name Set

var _elements: Array = []

func add(value: Variant) -> void:
	if _elements.has(value): return
	_elements.append(value)

func has(value: Variant) -> bool:
	return _elements.has(value)

func has_all(arr: Array[Variant]) -> bool:
	return arr.all(func(item): return self.has(item))

func erase(value: Variant) -> void:
	_elements.erase(value)

func erase_all() -> void:
	_elements.resize(0)

func size() -> int:
	return _elements.size()

func pop_front() -> Variant:
	return _elements.pop_front()
