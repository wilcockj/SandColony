class_name Inventory extends Node

var inventory: Dictionary = {}

func add_inventory_item(item: String):
	if !inventory.has(item):
		inventory[item] = 1
	else:
		inventory[item] += 1

func print_inventory():
	for key in inventory.keys():
		print(inventory[key])
		
func get_number_item(item: String):
	if inventory.has(item):
		return inventory[item]
	return 0
