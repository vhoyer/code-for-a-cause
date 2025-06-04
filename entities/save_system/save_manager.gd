# class_name SaveManager
extends Node

var data: SaveData = SaveDataEmpty.new()


func load_data(_data: SaveData) -> void:
	data = _data if _data else SaveDataEmpty.new()
