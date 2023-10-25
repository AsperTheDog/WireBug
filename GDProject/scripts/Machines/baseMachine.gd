extends Node
class_name Machine

enum Dir {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

var pos: Vector2i
var world: World
var rot: Dir
var power: int = -1


func _init(world: World, pos: Vector2i, rot: Dir):
	self.world = world
	self.pos = pos
	self.rot = rot
	world.requestUpdate(0, pos)


func isEqual(other: Machine) -> bool:
	return other.getType() == getType() and other.pos == pos and other.rot == rot


func update():
	pass


func getPower(dir: Dir):
	pass


func interact():
	pass


func getType() -> World.MachineType:
	return World.MachineType.NONE


func getTileAtLayer(layer: World.Layer) -> World.TileInfo:
	return World.TileInfo.new()


static func getPhantomTileAtPos(world: World, layer: World.Layer, pos: Vector2i, rot: Dir) -> World.TileInfo:
	return World.TileInfo.new()
