extends Area3D
class_name ScaleArea

signal weight_updated
signal weight_goal_activated
signal weight_goal_deactivated

@onready var delay_timer: Timer = $WeightAssessmentDelay

@export_category("Goal")
@export_range(0, 100000000, 0.001) var goal_weight_min: float = 750.0
@export_range(0.001, 100000000, 0.001) var goal_weight_max: float = 1000.0

var current_weight: float = 0.0
var is_within_goal_range: bool = false
var has_contents_changed: bool = false

const assess_weight_after: float = 0.25

func set_goal_weight(minimum: float, maximum: float) -> void:
	goal_weight_min = minimum
	goal_weight_max = maximum
	#prints("goal between:", goal_weight_min, goal_weight_max)

func _ready() -> void:
	current_weight = 0
	assert(goal_weight_max > goal_weight_min, "Goal weight max must be greater than min (idiot)")

func _physics_process(_delta: float) -> void:
	if has_contents_changed:
		if delay_timer.time_left == 0:
			delay_timer.start(assess_weight_after)
		has_contents_changed = false

func sum_contents_weight() -> void:
	var weight_sum := 0.0
	for thing in get_overlapping_areas():
		if thing is WeightComponent:
			weight_sum += thing.weight
	update_current_weight(weight_sum)

func update_current_weight(new_weight: float) -> void:
	var was_within_range := test_weight(current_weight)
	current_weight = new_weight
	var is_within_range := test_weight(current_weight)
	#prints("weight",current_weight)
	if was_within_range and not is_within_range:
		weight_goal_deactivated.emit()
		is_within_goal_range = false
	elif not was_within_range and is_within_range:
		weight_goal_activated.emit()
		is_within_goal_range = true
	weight_updated.emit()

func test_weight(sample_weight: float) -> bool:
	return sample_weight >= goal_weight_min and sample_weight <= goal_weight_max

func _on_area_entered(area: Area3D) -> void:
	if area is WeightComponent:
		has_contents_changed = true

func _on_area_exited(area: Area3D) -> void:
	if area is WeightComponent:
		has_contents_changed = true

func _on_weight_assessment_delay_timeout() -> void:
	sum_contents_weight()
