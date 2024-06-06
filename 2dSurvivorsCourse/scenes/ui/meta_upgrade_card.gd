extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var purchase_button: Button = %PurchaseButton
@onready var progress_label: Label = %ProgressLabel
@onready var count_label: Label = %"CountLabel"

var upgrade: MetaUpgrade

func _ready():
	purchase_button.pressed.connect(on_purchase_pressed)

func set_meta_upgrade(upgrade: MetaUpgrade):
	self.upgrade = upgrade
	name_label.text = upgrade.title
	description_label.text = upgrade.description
	update_progress()

func update_progress():
	# grab the current quantity
	var current_quantity = 0
	if MetaProgression.save_data["meta_upgrades"].has([upgrade.id]):
		current_quantity = MetaProgression.save_data["meta_upgrades"][upgrade.id]["quantity"]
	# check if it is maxxed
	var is_maxed = current_quantity >= upgrade.max_quantity
	# grab the currency
	var currency = max(MetaProgression.save_data["meta_upgrade_currency"],0)
	var percent =  currency / upgrade.experience_cost
	percent = min(percent, 1)
	progress_bar.value = percent
	purchase_button.disabled = percent < 1 || is_maxed
	if is_maxed: 
		purchase_button.text = "Maximum Acquired"

	progress_label.text = str(currency)+ "/" + str(upgrade.experience_cost)
	count_label.text = "x%d" % current_quantity
	
	
func select_card():
	await $AnimationPlayer.animation_finished
	
	
func on_purchase_pressed():
	if upgrade == null:
		return
	MetaProgression.add_meta_upgrade(upgrade)
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade.experience_cost
	MetaProgression.save()
	get_tree().call_group("meta_upgrade_card", "update_progress")
	$AnimationPlayer.play("selected")
	
	
