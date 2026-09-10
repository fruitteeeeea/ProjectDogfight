extends Resource
class_name FlightParams

@export var max_speed: float = 800.0
@export var acceleration: float = 1200.0
@export var deceleration: float = 1000.0

@export var turn_speed: float = 4.0          # 插值/角速度
@export var max_turn_angle: float = 30.0     # 可选：限制转向角

@export var drag: float = 0.1                 # 空气阻力感
