extends Control

var character : Character :
	set(new_character):
		character = new_character
		%Preview.texture = character.texture
