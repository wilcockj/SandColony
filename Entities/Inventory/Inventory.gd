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
		
func get_inventory_string():
	var inventory_str = ""
	for key in inventory.keys():
		inventory_str += key + ":" + str(get_number_item(key))
		inventory_str += "\n"
	return inventory_str
		
func get_number_item(item: String):
	if inventory.has(item):
		return inventory[item]
	return 0

func get_total_all_items():
	var sum = 0
	for key in inventory.keys():
		sum = get_number_item(key)
	return sum
