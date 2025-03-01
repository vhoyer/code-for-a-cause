class_name Util

static func find_custom(arr: Array, finder: Callable, start_at: int = 0) -> int:
	for index in arr.slice(start_at).size():
		var item = arr[index]
		if finder.call(item):
			return index
	
	return -1

static func remove_children(node: Node):
	for child in node.get_children():
		node.remove_child(child)

static func to_token_name(original: String) -> String:
	return original.to_lower()\
		.replace('!', '')\
		.replace('.', '')\
		.replace(' ', '_')
