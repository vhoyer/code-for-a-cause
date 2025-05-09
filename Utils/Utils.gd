class_name Util


static func remove_children(node: Node):
	var free_me_later = []
	for child in node.get_children():
		node.remove_child(child)
		free_me_later.push_back(child)

	await node.get_tree().process_frame

	for child: Node in free_me_later:
		child.queue_free()

static func to_token_name(original: String) -> String:
	return original.to_lower()\
		.replace('!', '')\
		.replace('.', '')\
		.replace('(', '')\
		.replace(')', '')\
		.replace(' ', '_')
