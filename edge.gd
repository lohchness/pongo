extends Area2D

signal point_scored

func _on_body_entered(body):
	if (body.get_name() == "ball"):
		point_scored.emit()
