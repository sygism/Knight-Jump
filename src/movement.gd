extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 20
const MAXFALLSPEED = 350
const MAXSPEED = 200
const LONGJUMPFORCE = 600
const SHORTJUMPFORCE = 400
const ACCEL = 10
const BOUNCEFORCE = 200

var motion = Vector2()
export var stage = 0
var facing_right = true
var duration = 0
var jumping = false
var prev_falling = false
var fallen_time = 0
var falling_time = 0
var fallen = false
onready var _transition_rect := $Camera2D/ColorRect

func _ready():
	if stage == 1 or stage == 2:
		$Camera2D.limit_left = 916
		$Camera2D.limit_right = 1763
		$Camera2D.limit_top = -1755
	
func _physics_process(delta):
	
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
		
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	
	if is_on_floor() && fallen_time < 1.5 && falling_time > 1:
		motion.x = 0
		fallen = true
		if (facing_right):
			$AnimationPlayer.play("fallen_right")
		else:
			$AnimationPlayer.play("fallen_left")
		fallen_time += delta
	elif is_on_floor():
		jumping = false
		fallen = false
		fallen_time = 0
		falling_time = 0
		
	if Input.is_action_just_released("jump") && !jumping && !fallen && is_on_floor():
		jumping = true
		if duration > 0.5:
			motion.y = -LONGJUMPFORCE
			if facing_right:
				motion.x = 200
				$AnimationPlayer.play("jump_right")
			else:
				motion.x = -200
				$AnimationPlayer.play("jump_left")
		else:
			motion.y = -SHORTJUMPFORCE
			if facing_right:
				motion.x = 100
				$AnimationPlayer.play("jump_right")
			else:
				motion.x = -100
				$AnimationPlayer.play("jump_left")
		duration = 0
	if Input.is_action_pressed("jump") && !jumping && !fallen && is_on_floor():
		motion.x = 0
		duration += delta
		if facing_right:
			$AnimationPlayer.play("hold_jump_right")
		else:
			$AnimationPlayer.play("hold_jump_left")
	elif Input.is_action_pressed("right") && motion.y == GRAVITY && !fallen:
		motion.x += ACCEL
		$AnimationPlayer.play("run_right")
		facing_right = true
	elif Input.is_action_pressed("left") && motion.y == GRAVITY && !fallen:
		motion.x -= ACCEL
		$AnimationPlayer.play("run_left")
		facing_right = false
	elif (jumping && motion.y > 0 && !fallen) || (!is_on_floor() && motion.y > 0 && !fallen):
		if facing_right:
			$AnimationPlayer.play("falling_right");
		else:
			$AnimationPlayer.play("falling_left")
	elif !jumping && !fallen:
		motion.x = 0
		$AnimationPlayer.play("idle")

	
	motion = move_and_slide(motion, UP)
	var aux_motion = motion.y
	if is_on_wall() && jumping:
		motion = get_slide_collision(0).normal * BOUNCEFORCE
		motion.y = aux_motion
	if motion.y > 0:
		falling_time += delta
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "StaticBody2D":
			_on_portal(stage)


func _on_portal(stage):
	if stage == 0:
		_transition_rect.transition_to("res://stage1.tscn")
	elif stage == 1:
		_transition_rect.transition_to("res://stage2.tscn")
	else:
		_transition_rect.transition_to("res://game_over.tscn")
