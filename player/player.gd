extends CharacterBody2D

# The hierarchal state machine and states
var hsm: LimboHSM
var default_state: LimboState
var launch_state: LimboState
var death_state: LimboState

# Variables defining several transitions
const LAUNCH: String = "Launch" # Default => Launch
const RELEASE: String = "Release" # Launch => Default
const DEATH: String = "Death" # ANY => Death
const RESPAWN: String = "Respawn" # Death => Normal

@export_category("Nodes")
@export var hitbox: Area2D
@export var launch_anchor: Node2D
@export var launch_arrow: Sprite2D
@export var cooldown_bar: TextureProgressBar

@export_category("Params")
@export var launch_power: float = 3000.0
@export var cooldown_duration: float = 1.0
@export var gravity: float = 3000.0
@export var bounce_strength: float = 0.9

var cooldown_time: float = 0.0
var launch_dir: Vector2 = Vector2.UP

func _ready():
	_init_state_machine()
	hitbox.body_entered.connect(on_hitbox_body_entered)
	
	LevelManager.load_first_level()

func _init_state_machine():
	hsm = LimboHSM.new()
	add_child(hsm)
	
	default_state = LimboState.new()
	default_state.call_on_update(default_update)
	hsm.add_child(default_state)
	
	launch_state = LimboState.new()
	launch_state.call_on_enter(launch_enter)
	launch_state.call_on_update(launch_update)
	launch_state.call_on_exit(launch_exit)
	hsm.add_child(launch_state)
	
	death_state = LimboState.new()
	hsm.add_child(death_state)
	
	hsm.add_transition(default_state, launch_state, LAUNCH)
	hsm.add_transition(launch_state, default_state, RELEASE)
	hsm.add_transition(hsm.ANYSTATE, death_state, DEATH)
	hsm.add_transition(death_state, default_state, RESPAWN)
	
	hsm.initial_state = default_state
	
	hsm.initialize(self)
	hsm.set_active(true)

func default_update(delta: float):
	velocity.y += gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * bounce_strength
	
	cooldown_time -= delta
	cooldown_bar.value = cooldown_time / cooldown_duration
	
	if Input.is_action_just_pressed("launch") && cooldown_time <= 0:
		hsm.dispatch(LAUNCH)
		cooldown_time = cooldown_duration

func launch_enter():
	cooldown_bar.hide()
	launch_arrow.show()

func launch_update(delta: float):
	velocity = lerp(velocity, Vector2.ZERO, 0.1)
	move_and_slide()
	
	var mouse_pos = get_global_mouse_position()
	launch_anchor.look_at(mouse_pos)
	launch_dir = (mouse_pos - global_position).normalized()
	
	if Input.is_action_just_released("launch"):
		hsm.dispatch(RELEASE)

func launch_exit():
	velocity = launch_dir * launch_power
	cooldown_bar.show()
	launch_arrow.hide()

func on_hitbox_body_entered(body: Node2D):
	if body.is_in_group("goal"):
		global_position = Vector2.ZERO
		velocity = Vector2.ZERO
		LevelManager.next_level()
		print("Next Level")
