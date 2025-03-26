extends Node

@export var pipe_scene : PackedScene


var game_running : bool
var game_over : bool
var scroll
var score
const SCROLL_SPEED : int = 5
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 50
const PIPE_RANGE : int = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	#reset variables
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$ScoreLabel.text = "SCORE: " + str(score)
	$GameOver.hide()
	$Start.show()
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	#generate starting pipes
	generate_pipes()
	$Bird.reset()
	
func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Bird.flying:
						$Bird.flap()
						check_top()

func start_game():
	$sfx_startgame.play()
	$Start.hide()
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	#start pipe timer
	$PipeTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		#reset scroll
		if scroll >= screen_size.x:
			scroll = 0
		#move ground node
		$Ground.position.x = -scroll
		#move pipes
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED


func _on_pipe_timer_timeout():
	generate_pipes()
	
func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2  + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)
	
func scored():
	score += 1
	$ScoreLabel.text = "SCORE: " + str(score)
	$Bird.change_size()

func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()
		$GameOver.show()
		
func stop_game():
	if game_over:
		return
	
	$sfx_stopgame.play()
	$PipeTimer.stop()
	$GameOver.show()
	$Bird.flying = false
	game_running = false
	game_over = true	
	
	
	
func bird_hit():
	$Bird.falling = true
	stop_game()

func _on_ground_hit():
	$Bird.falling = false
	stop_game()

func _on_game_over_restart():
	new_game()


func _on_button_pressed() -> void:
	pass # Replace with function body.


func _on_button_play() -> void:
	pass # Replace with function body.


		
