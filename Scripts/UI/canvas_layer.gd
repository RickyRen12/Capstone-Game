extends CanvasLayer

var coin_label: Label

func _ready():
	await get_tree().process_frame  # Wait until scene is fully ready

	coin_label = get_node_or_null("CoinLabel")
	if coin_label == null:
		print("❌ Error: CoinLabel node not found!")
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("❌ Error: Player not found in group!")
		return

	# Set initial coin value
	coin_label.text = str(player.currency_amt)

	# Update label when currency changes
	player.currency_gained.connect(func(_amount): coin_label.text = str(player.currency_amt))
