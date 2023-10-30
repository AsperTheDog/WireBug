class_name Component extends Object

enum Type {
	NONE,
	WIRE,
	CROSSING,
	GENERATOR,
	REPEATER,
	NEGATOR,
	COMPARATOR,
	FLICKER,
	SLOGGER
}

signal update(comp: Component, power: int)
signal resetting(comp: Component)
signal deleted


class Connection:
	signal powersChanged

	var power: int = 0
	var sources: Dictionary = {}
			
	var maxSource: Component = null
	
	func resetSources() -> void:
		for source in sources:
			source.update.disconnect(sourceUpdate)
			source.resetting.disconnect(deleteSource)
		sources.clear()
		recalculatePower()

	func deleteSource(source: Component) -> void:
		if source not in sources: return
		source.update.disconnect(sourceUpdate)
		source.resetting.disconnect(deleteSource)
		sources.erase(source)
		recalculatePower()

	func registerSource(source: Component, distance: int, currentPow: int) -> void:
		if source not in sources:
			source.update.connect(sourceUpdate)
			source.resetting.connect(deleteSource)
		elif sources[source].x <= distance: return
		sources[source] = Vector2i(distance, max(0, currentPow - distance))
		recalculatePower()
	
	func sourceUpdate(source: Component, sourcePow: int) -> void:
		sources[source].y = max(0, sourcePow - sources[source].x)
		recalculatePower()
	
	func recalculatePower() -> void:
		var newPower = 0
		for source in sources:
			var data: Vector2i = sources[source]
			if data.y >= newPower:
				newPower = data.y
				maxSource = source
		if power != newPower:
			power = newPower
			powersChanged.emit()
	
	func _to_string() -> String:
		var str: String = "Sources: "
		for source in sources:
			str += str(source.pos) + " -> " + str(sources[source]) + " | "
		return str


var inputs: Array[Connection] = []
var pos: Vector2i
var rot: int


func _init(pos: Vector2i, rot: int) -> void:
	self.pos = pos
	self.rot = rot


func die():
	deleted.emit()
	propagateRegenRequest()


func getConnectionID(dir: int) -> int:
	return -1


func isConnectedAt(dir: int) -> bool:
	return false


func getNeighbors() -> Array[Component]:
	return [null, null, null, null]


func registerConnection(source: Component, side: int, distance: int, currentPow: int) -> bool:
	var connID = getConnectionID(side)
	if connID == -1: return false
	inputs[connID].registerSource(source, distance, currentPow)
	return true


func updateTileAtLayer(layer: World.Layer):
	pass


func onNeighborChanged(dir: int):
	pass


func getType() -> Type:
	return Type.NONE


func isEqual(other: Component):
	return other.getType() == getType() and other.pos == pos and other.rot == rot


func isEqualToNew():
	return rot == Game.placingRotation


func propagateRegenRequest():
	for input in inputs:
		for source in input.sources:
			source.requestRegen()


func interact():
	pass