extends Node

var failures := 0
var game: Node
var manager: Node
const SCENE := "res://game/core/main_game.tscn"

func expect(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		push_error("FAIL: " + message)

func frames(count: int = 3) -> void:
	for i in range(count):
		await get_tree().process_frame

func click(button: Control) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = button.get_global_rect().get_center()
		event.global_position = event.position
		get_viewport().push_input(event, true)
		await frames()

func pointer(point: Vector2, touch: bool = false) -> void:
	for pressed in [true, false]:
		var event: InputEvent
		if touch:
			event = InputEventScreenTouch.new()
			event.index = 0
		else:
			event = InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		get_viewport().push_input(event, true)
		await frames()

func begin() -> void:
	manager.start_battle()
	await frames()

func fresh() -> void:
	get_tree().paused = false
	GameStatusServer.manager = null
	if is_instance_valid(game):
		game.queue_free()
		await frames()
	game = load(SCENE).instantiate()
	# Provide the initial-enemy fixture even when the production scene has none.
	if not game.has_node("Enemy"):
		var enemy: Node2D = load("res://game/aircraft/enemy/enemy.tscn").instantiate()
		enemy.name = "Enemy"
		enemy.position = Vector2(-400, -400)
		game.add_child(enemy)
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	await frames()
	manager = game.get_node("GameManager")

func _ready() -> void:
	await frames()
	await fresh()
	if "--capture" in OS.get_cmdline_user_args():
		await capture_menus()
		return
	var player: Player = game.get_node("Player")
	var gun: PlayerGun = player.get_node("Weapon/PlayerGun")
	var launcher: RocketLauncher = player.get_node("Weapon/RocketLauncher")
	var spawner: Node = game.get_node("EnemySpawner")
	var health := player.player_damage_component.health
	var bullets := gun.current_bullet
	var pos := player.position
	expect(GameStatusServer.state == GameStatusServer.BattleState.FREE_FLIGHT and not get_tree().paused, "load enters unpaused free flight")
	spawner._on_timer_timeout()
	player.take_damage(10)
	gun.fire()
	launcher.current_rocket_nb = 1
	launcher._launch_rocket(1.0, 3)
	GameStatusServer.record_kill()
	player.accelerate_component.burst_accel = true
	await get_tree().create_timer(0.15, true, false, true).timeout
	expect(player.position != pos and player.player_damage_component.health == health, "free flight moves and blocks damage")
	expect(gun.current_bullet < bullets and player.accelerate_component.progress_bar.value < player.accelerate_component.max_burst_accel_fuel, "free flight permits shooting and fuel consumption")
	expect(GameStatusServer.your_points == 0 and GameStatusServer.enemies_destroyed == 0 and manager.mission_panel.mission_timer.is_stopped(), "free flight has no scoring or mission clock")
	expect(spawner.living_count() == 0 and spawner.pending_count == 0 and spawner.get_node("Timer").is_stopped(), "free flight contains no enemies or spawns")
	var supply: SupplyPackage = load("res://game/world/pickups/supply.tscn").instantiate()
	game.add_child(supply)
	supply._on_area_2d_body_entered(player)
	expect(not supply.is_picked, "free flight cannot claim supplies")
	manager.pause_battle()
	var paused_pos := player.position
	await frames()
	expect(player.position != paused_pos and GameStatusServer.state == GameStatusServer.BattleState.PAUSED, "free flight pause keeps background moving")
	manager.resume_battle()
	expect(GameStatusServer.state == GameStatusServer.BattleState.FREE_FLIGHT, "pause resumes free flight rather than challenge")
	await pointer(Vector2(1000, 800))
	expect(not GameStatusServer.is_battle_active(), "outside prompt pointer does not start challenge")
	gun.reset_trigger()
	gun.current_bullet = 5
	launcher.current_rocket_nb = 1
	player.accelerate_component.progress_bar.value = 2
	player.player_damage_component.health = 10
	var old_projectiles: Array[Node] = []
	for child in game.get_children():
		if child is Bullet or child is SnakeRocket:
			old_projectiles.append(child)
	var before_position := player.global_position
	var before_forward := player.forward
	manager.start_battle()
	manager._begin_battle()
	expect(player.global_position == before_position and player.forward == before_forward, "challenge reset preserves position and heading")
	expect(gun.current_bullet == gun.max_bullet and launcher.current_rocket_nb == launcher.max_rocket_nb, "challenge reset restores all ammunition")
	expect(player.player_damage_component.health == health and player.accelerate_component.progress_bar.value == player.accelerate_component.max_burst_accel_fuel, "challenge reset restores life and fuel")
	expect(not gun.fire_on and not player.accelerate_component.burst_accel and player.engine_on, "challenge reset clears triggers and restores engine")
	await frames()
	var cleared := true
	for projectile in old_projectiles:
		if is_instance_valid(projectile):
			cleared = false
	expect(cleared, "practice projectiles are removed before enemies appear")
	expect(GameStatusServer.is_battle_active() and not manager.ready_to_start.visible and spawner.living_count() == 1, "challenge hides prompt and restores initial enemy")
	# Stop the second, already queued begin invocation from doing any reset.
	var remaining: float = manager.mission_panel.mission_timer.time_left
	manager.start_battle()
	expect(manager.mission_panel.mission_timer.time_left == remaining, "repeated start does not reset timer")
	var bgm_volume: float = manager.mission_panel.bgm_player.volume_db
	await click(manager._pause_button)
	expect(GameStatusServer.state == GameStatusServer.BattleState.PAUSED, "GUI pause button is clickable")
	expect(is_equal_approx(manager.mission_panel.bgm_player.volume_db, bgm_volume + linear_to_db(0.5)), "pause halves BGM amplitude")
	expect(manager._pause_blur.visible and manager._pause_blur.material != manager.result_menu.blur_background.material, "pause shows independent blur shader")
	expect(manager._pause_button is Button and manager.ready_to_start.visible and manager.ready_to_start.get_node("PanelContainer/TapHereToStart/Label").text == "Paused", "pause uses button and original top label")
	await get_tree().create_timer(0.9, true, false, true).timeout
	expect(not manager._pause_flash.is_running() and is_equal_approx(manager.ready_to_start.get_node("PanelContainer").modulate.a, 1.0), "paused label finishes two flashes and remains visible")
	await get_tree().create_timer(0.2, true, false, true).timeout
	expect(is_equal_approx(Engine.time_scale, 0.1) and not get_tree().paused, "pause settles at 0.1 background speed")
	expect(player.sfx_engine.bus == manager._result_audio_bus and player.sfx_engine.stream_paused, "pause silences engine after slowdown")
	var wind: AudioStreamPlayer = game.find_child("SFXWind", true, false)
	expect(wind.playing and not wind.stream_paused and wind.bus != manager._result_audio_bus, "ambient white noise continues during pause")
	await click(manager._pause_panel.get_child(0).get_child(1))
	expect(GameStatusServer.is_battle_active(), "GUI continue button resumes battle")
	expect(is_equal_approx(Engine.time_scale, 1.0) and is_equal_approx(manager.mission_panel.bgm_player.volume_db, bgm_volume), "continue restores speed and BGM volume")
	expect(manager._result_audio_bus.is_empty() and not player.sfx_engine.stream_paused, "continue restores scene audio routing")
	expect(not manager._pause_blur.visible, "resume removes pause blur")
	spawner.max_enemy_count = 2
	spawner._on_timer_timeout()
	spawner._on_timer_timeout()
	expect(spawner.pending_count == 1, "pending spawns reserve remaining slot")
	await frames()
	expect(spawner.living_count() == 2, "spawn batch respects cap")
	var enemy: Enemy = game.get_node("Enemy")
	enemy.die()
	enemy.die()
	expect(GameStatusServer.your_points == 100 and GameStatusServer.enemies_destroyed == 1, "duplicate enemy death scores once")
	expect(spawner.living_count() == 1, "crashing enemy releases living slot")
	spawner._on_timer_timeout()
	SpawnServer.spawn_player_reward()
	var child_count := game.get_child_count()
	gun.fire_on = true
	var old_joystick: Node = game.get_node("GameHUD/PlayerTouchControl/MoveJoystick")
	manager.pause_battle()
	expect(game.get_node("GameHUD/PlayerTouchControl/MoveJoystick") != old_joystick, "pause resets native touch capture")
	remaining = manager.mission_panel.mission_timer.time_left
	bullets = gun.current_bullet
	pos = player.position
	var rockets := launcher.current_rocket_nb
	await get_tree().create_timer(0.2, true, false, true).timeout
	expect(player.position != pos and manager.mission_panel.mission_timer.time_left == remaining, "pause moves background but freezes mission clock")
	expect(spawner.pending_count == 0 and spawner.living_count() == 1 and game.get_child_count() == child_count, "pause cancels deferred enemy and reward spawns")
	expect(gun.current_bullet == bullets and launcher.current_rocket_nb == rockets and not gun.fire_on, "pause freezes ammunition and clears trigger")
	manager.resume_battle()
	expect(not get_tree().paused and not gun.fire_on, "resume requires fresh firing input")
	GameFeel.hit_stop_long()
	manager.pause_battle()
	manager._result_slowdown.kill() # Isolate cancellation from the intentional pause tween.
	Engine.time_scale = 0.7
	await get_tree().create_timer(0.2, true, false, true).timeout
	expect(is_equal_approx(Engine.time_scale, 0.7), "cancelled hit-stop cannot change later time scale")
	GameFeel.cancel_hit_stop()
	manager.resume_battle()
	manager._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	expect(GameStatusServer.state == GameStatusServer.BattleState.PAUSED, "focus loss pauses battle")
	manager._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	expect(GameStatusServer.state == GameStatusServer.BattleState.PAUSED, "focus return requires explicit resume")
	manager.resume_battle()
	manager.mission_panel.mission_timer.timeout.emit()
	await frames()
	expect(not manager.result_snapshot.complete and manager.result_snapshot.reason == 2, "below target times out with correct reason")
	var snapshot: Dictionary = manager.result_snapshot.duplicate(true)
	gun.fire()
	launcher._launch_rocket()
	spawner._on_timer_timeout()
	GameStatusServer.record_kill()
	GameStatusServer.your_points += 500
	player.take_damage(1000)
	SpawnServer.spawn_player_reward()
	manager.finish_battle(1)
	await frames()
	expect(manager.result_snapshot == snapshot and GameStatusServer.your_points == snapshot.points, "finished results reject combat and scoring")
	expect(not get_tree().paused and Engine.time_scale > 0.9 and manager._result_audio_bus.is_empty() and gun.current_bullet == bullets and spawner.pending_count == 0, "result begins at normal speed with sound retained and weapons disabled")
	var result_position: Vector2 = player.position
	await get_tree().create_timer(0.2, true, false, true).timeout
	expect(player.position != result_position and manager.result_snapshot == snapshot, "result background keeps moving without changing snapshot")
	await get_tree().create_timer(0.3, true, false, true).timeout
	expect(absf(Engine.time_scale - 0.55) < 0.12, "slowdown reaches midpoint in real time")
	await get_tree().create_timer(0.6, true, false, true).timeout
	expect(is_equal_approx(Engine.time_scale, 0.1) and AudioServer.is_bus_mute(AudioServer.get_bus_index(manager._result_audio_bus)), "battle sound muted only after one-second slowdown")
	expect(manager.result_menu.win.bus == &"SFX" and manager.result_menu.lose.bus == &"SFX" and manager.mission_panel.bgm_player.bus != manager._result_audio_bus, "result sounds and music bypass battle mute")
	expect(wind.playing and not wind.stream_paused and wind.bus != manager._result_audio_bus, "ambient white noise continues during result")
	var late_audio := AudioStreamPlayer.new()
	game.add_child(late_audio)
	expect(late_audio.bus == manager._result_audio_bus, "new result audio is also muted")
	expect(game.get_node_or_null("GameSpeed") == null and game.get_node_or_null("GameHUD/PlayerTouchControl/ABXYButton/X2") == null, "release scene has no speed debug controls")

	var result_menu: Control = game.get_node("GameHUD/ResultMenu")
	expect(result_menu.find_children("*", "Button", true, false).is_empty(), "result has no visible action buttons")
	expect(not result_menu.retry_enabled, "result rejects retry before animation finishes")
	await pointer(Vector2(800, 700))
	expect(get_tree().current_scene == game, "early result click cannot restart")
	result_menu.animation_player.advance(2.0)
	await frames()
	expect(result_menu.retry_enabled, "retry becomes available after result animation")
	await pointer(Vector2(800, 700), true)
	await frames(5)
	expect(get_tree().current_scene.scene_file_path == "res://game/ui/menus/mission_select.tscn" and GameStatusServer.manager == null and Engine.time_scale == 1.0, "result screen tap returns to selection and clears battle")
	await fresh()
	await begin()
	GameStatusServer.your_points = manager.target_points
	manager.mission_panel.mission_timer.timeout.emit()
	await frames()
	expect(manager.result_snapshot.complete and manager.result_snapshot.rank == "C", "exact target succeeds with C rank")

	await fresh()
	await begin()
	GameStatusServer.your_points = 4500
	player = game.get_node("Player")
	player.take_damage(player.player_damage_component.max_health)
	manager.mission_panel.mission_timer.timeout.emit()
	await frames()
	expect(not manager.result_snapshot.complete and manager.result_snapshot.reason == 1, "death wins over same-frame timeout")

	await fresh()
	await begin()
	GameStatusServer.your_points = 4500
	manager.mission_panel.mission_timer.timeout.emit()
	player = game.get_node("Player")
	player.take_damage(player.player_damage_component.max_health)
	await frames()
	expect(not manager.result_snapshot.complete and manager.result_snapshot.reason == 1, "death wins when timeout callback arrives first")

	await fresh()
	await begin()
	manager.finish_battle(2)
	await frames()
	expect(manager.result_menu.lose.playing and manager.result_menu.lose.bus == &"SFX", "failure sound plays outside muted battle bus")
	await get_tree().create_timer(1.1, true, false, true).timeout
	expect(not manager.result_menu.retry_enabled, "result animation not accelerated by slowdown")
	await get_tree().create_timer(1.05, true, false, true).timeout
	expect(manager.result_menu.retry_enabled, "result animation finishes in normal real time")
	for to_menu in [false, true]:
		await fresh()
		await begin()
		manager.finish_battle(2)
		await frames()
		await get_tree().create_timer(0.2, true, false, true).timeout
		if to_menu:
			manager.return_to_menu()
		else:
			manager.retry_battle()
		expect(is_equal_approx(Engine.time_scale, 1.0), "navigation immediately cancels slowdown")
		await frames(5)
		game = get_tree().current_scene
		await get_tree().create_timer(1.1, true, false, true).timeout
		expect(is_equal_approx(Engine.time_scale, 1.0), "old slowdown callback cannot affect destination")
	await fresh()
	await begin()
	for i in range(5):
		GameFeel.cancel_hit_stop()
		manager.retry_battle()
		await frames(5)
		game = get_tree().current_scene
		manager = game.get_node("GameManager")
		expect(GameStatusServer.state == GameStatusServer.BattleState.FREE_FLIGHT and GameStatusServer.your_points == 0 and GameStatusServer.enemies_destroyed == 0 and is_equal_approx(Engine.time_scale, 1.0), "retry %d restores free flight and counters" % (i + 1))
		player = game.get_node("Player")
		expect(not player.is_dead and player.player_damage_component.health == player.player_damage_component.max_health, "retry %d restores health" % (i + 1))
		gun = player.get_node("Weapon/PlayerGun")
		launcher = player.get_node("Weapon/RocketLauncher")
		expect(gun.current_bullet == gun.max_bullet and launcher.current_rocket_nb == launcher.max_rocket_nb and player.accelerate_component.progress_bar.value == player.accelerate_component.max_burst_accel_fuel, "retry %d restores ammunition and fuel" % (i + 1))
		await begin()
		manager.pause_battle()
	manager.return_to_mission_select()
	await frames(5)
	expect(not get_tree().paused and GameStatusServer.manager == null and get_tree().current_scene.scene_file_path == "res://game/ui/menus/mission_select.tscn", "pause return clears battle and opens mission selection")
	await click(get_tree().current_scene.get_node("%StartMission"))
	await frames(5)
	expect(GameStatusServer.state == GameStatusServer.BattleState.FREE_FLIGHT and GameStatusServer.your_points == 0, "mission start enters free flight")
	game = get_tree().current_scene
	manager = game.get_node("GameManager")
	var prompt_point: Vector2 = manager.ready_to_start.get_node("PanelContainer").get_global_rect().get_center()
	await pointer(prompt_point, true)
	expect(GameStatusServer.is_battle_active(), "touching start prompt begins challenge")
	# Waypoint checks also use a fixture when the title loads an enemy-free scene.
	if not game.has_node("Enemy"):
		var enemy_fixture: Node = load("res://game/aircraft/enemy/enemy.tscn").instantiate()
		enemy_fixture.name = "Enemy"
		game.add_child(enemy_fixture)
	expect(not game.get_node("Player/Weapon/PlayerGun").fire_on, "start prompt touch does not start shooting")
	await test_supply_waypoints()
	await test_enemy_waypoints()

	get_tree().paused = false
	GameStatusServer.manager = null
	get_tree().current_scene.queue_free()
	await get_tree().create_timer(5.5, true, false, true).timeout
	print("Battle flow tests: %d failure(s)" % failures)
	get_tree().quit(1 if failures else 0)

func capture_menus() -> void:
	get_tree().paused = false
	GameStatusServer.manager = null
	game.queue_free()
	await frames()
	var title: Node = load("res://game/ui/menus/main_menu.tscn").instantiate()
	get_tree().root.add_child(title)
	get_tree().current_scene = title
	await frames()
	title.get_node("AnimationPlayer").advance(2.1)
	await get_tree().create_timer(0.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/private/tmp/dogfight-title.png")
	title._on_play_pressed()
	await frames(5)
	get_tree().current_scene._request_start()
	await frames(5)
	game = get_tree().current_scene
	if not game.has_node("GameManager"):
		push_error("FAIL: capture could not enter battle")
		get_tree().quit(1)
		return
	manager = game.get_node("GameManager")
	await get_tree().create_timer(0.4, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/private/tmp/dogfight-free-flight.png")
	await begin()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/private/tmp/dogfight-playing.png")
	manager.pause_battle()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/private/tmp/dogfight-paused.png")
	manager.resume_battle()
	manager.mission_panel.mission_timer.timeout.emit()
	await get_tree().create_timer(2.3, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/private/tmp/dogfight-result.png")
	get_tree().paused = false
	GameStatusServer.manager = null
	game.queue_free()
	await get_tree().create_timer(5.5, true, false, true).timeout
	get_tree().quit()

func test_supply_waypoints() -> void:
	# Freeze movement while inspecting screen-space bounds, including camera zoom.
	var current_manager: Node = game.get_node("GameManager")
	current_manager.pause_battle()
	var viewport_rect := get_viewport().get_visible_rect()
	for path in ["res://game/world/pickups/supply.tscn", "res://game/world/pickups/health_supply.tscn"]:
		var supply: SupplyPackage = load(path).instantiate()
		game.add_child(supply)
		var icon: WayPointIcon = supply.get_node("CanvasLayer/WayPointIcon")
		var inverse := supply.get_canvas_transform().affine_inverse()
		supply.global_position = inverse * viewport_rect.get_center()
		icon.update_target_visibility()
		expect(not icon.visible, "on-screen supply hides waypoint: " + path)
		supply.global_position = inverse * Vector2(viewport_rect.end.x + 300, viewport_rect.get_center().y)
		icon.update_target_visibility()
		expect(icon.visible, "off-screen supply shows waypoint: " + path)
		supply.global_position = inverse * Vector2(viewport_rect.end.x - 1, viewport_rect.get_center().y)
		icon.update_target_visibility()
		expect(not icon.visible, "partially visible supply hides waypoint: " + path)
		supply.global_position = inverse * Vector2(-300, viewport_rect.get_center().y)
		supply.is_picked = true
		icon.update_target_visibility()
		expect(not icon.visible, "claimed supply never shows waypoint: " + path)
		supply.queue_free()

func test_enemy_waypoints() -> void:
	var enemy: Enemy = game.get_node("Enemy")
	var icon: EnemyIndicator = enemy.get_node("CanvasLayer/EnemyIndicator")
	var camera: Camera2D = game.get_node("Player/Camera2D")
	for zoom in [Vector2.ONE, Vector2(0.5, 0.5)]:
		camera.zoom = zoom
		camera.force_update_scroll()
		var rect := get_viewport().get_visible_rect()
		var inverse := enemy.get_canvas_transform().affine_inverse()
		enemy.global_position = inverse * rect.get_center()
		icon.update_target_visibility()
		expect(not icon.visible, "on-screen enemy hides waypoint at zoom " + str(zoom))
		enemy.global_position = inverse * Vector2(rect.end.x + 300, rect.get_center().y)
		icon.update_target_visibility()
		expect(icon.visible, "off-screen enemy shows waypoint at zoom " + str(zoom))
		expect(rect.has_point(icon.get_global_transform_with_canvas() * icon._get_screen_pos(enemy)), "waypoint stays within viewport")
		enemy.global_position = inverse * Vector2(rect.end.x - 1, rect.get_center().y)
		icon.update_target_visibility()
		expect(not icon.visible, "partially visible enemy hides waypoint")
	enemy.is_dead = true
	icon.update_target_visibility()
	expect(not icon.visible, "dead enemy waypoint stays hidden")
	var target := Node2D.new()
	game.add_child(target)
	var generic: WayPointIcon = load("res://game/ui/hud/icons/way_point_icon.tscn").instantiate()
	game.get_node("GameHUD").add_child(generic)
	generic.target = target
	target.global_position = target.get_canvas_transform().affine_inverse() * get_viewport().get_visible_rect().get_center()
	generic.update_target_visibility()
	expect(not generic.visible, "waypoint without sprite uses target screen point")
	target.free()
	generic.update_target_visibility()
	expect(not generic.visible, "deleted target hides waypoint safely")
	generic.queue_free()
