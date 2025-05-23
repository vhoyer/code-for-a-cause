@tool
extends HWheelPickerButton

func _ready() -> void:
	self.clear_items()
	for locale in TranslationServer.get_loaded_locales():
		self.add_item(locale, { 'locale': locale })
		

func _item_selected(index: int) -> void:
	var locale = self.get_item_metadata(index).get('locale', 'en')
	SettingsManager.set_language(locale)
