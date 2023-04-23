extends Node2D

onready var _transition_rect := $ColorRect

func _on_TextureButton_pressed():
	_transition_rect.transition_to("res://scenes/main.tscn")
