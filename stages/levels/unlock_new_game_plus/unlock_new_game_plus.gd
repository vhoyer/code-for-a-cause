extends CutsceneMamaKidnapped

func prompt_new_game_plus() -> bool:
	return await GlobalModal.prompt(tr("You've unlocked new game plus, load your save file again to play it"))


func prompt_new_game_plus_plus() -> bool:
	return await GlobalModal.prompt(tr("You've unlocked new game plus plus, load your save file again to play it"))
