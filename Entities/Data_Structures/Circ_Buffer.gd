class_name Circular_Buffer extends Node

var buff_size = 5
var buffer: Array = []
var buffer_idx = 0
var buffer_init: bool = false

func _init(size):
	buff_size = size
	
func add_item(item):
	if buffer.size() == buff_size:
		buffer[buffer_idx] = item
	else:
		buffer.append(item)
		
	if buffer_idx == buff_size - 1:
		buffer_init = true
	buffer_idx = wrapi(buffer_idx + 1, 0, buff_size)
	
func buff_saturated():
	return buffer_init
	
func all(callable):
	return buffer.all(callable)
