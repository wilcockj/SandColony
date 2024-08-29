extends Node3D

@export var nav_region: NavigationRegion3D


func rebake():
	nav_region.bake_navigation_mesh()
