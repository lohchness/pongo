extends Area2D

func _enter_tree():
	add_to_group("buffs") # Need to add this to the Groups tab as well

func _on_body_entered(body):
	queue_free()
