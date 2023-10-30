class_name Wire extends Component

# key is UP, RIGHT, DOWN, LEFT. Encoded in binary
# value is Coords.x, Coords.y, AltID. Stored as Vector3i
# gradient is (AltID + 15) - power
var wireLayout: Dictionary = {
	0b0000: Vector3i(1, 0, 0),
	0b0001: Vector3i(2, 0, 32),
	0b0010: Vector3i(2, 0, 48),
	0b0011: Vector3i(4, 0, 48),
	0b0100: Vector3i(2, 0, 0),
	0b0101: Vector3i(3, 0, 0),
	0b0110: Vector3i(4, 0, 0),
	0b0111: Vector3i(5, 0, 48),
	0b1000: Vector3i(2, 0, 16),
	0b1001: Vector3i(4, 0, 32),
	0b1010: Vector3i(3, 0, 16),
	0b1011: Vector3i(5, 0, 32),
	0b1100: Vector3i(4, 0, 16),
	0b1101: Vector3i(5, 0, 16),
	0b1110: Vector3i(5, 0, 0),
	0b1111: Vector3i(0, 0, 0)
}

var power: int = 0
var maxInput: int = 0


func _init(pos: Vector2i, rot: int) -> void:
	self.pos = pos
	self.rot = rot
	for side in Side.ALL:
		self.inputs.append(Connection.new())
		self.inputs.back().powersChanged.connect(onPowerUpdate.bind(side))


func getConnectionID(dir: int) -> int:
	return Side.opposite[dir]


func isConnectedAt(dir: int) -> bool:
	return true


func getNeighbors() -> Array[Component]:
	var neighbors: Array[Component] = [null, null, null, null]
	for side in Side.ALL:
		var currentTile = Game.world.getTileAt(pos + Side.vectors[side])
		var currentSideID = currentTile.getConnectionID(Side.opposite[side]) if currentTile != null else -1
		if currentSideID != -1: 
			neighbors[side] = currentTile
	return neighbors


func updateTileAtLayer(layer: World.Layer):
	if layer != World.Layer.REDSTONE1: return
	var code := 0
	for side in Side.ALL:
		var conn = Game.world.isTileConnectedAt(pos + Side.vectors[side], Side.opposite[side])
		if conn: code += 1 << side
	var tilePos = wireLayout[code]
	Game.world.set_cell(layer, pos, 2, Vector2i(tilePos.x, tilePos.y), tilePos.z + 15 - power)


func calculatePowerInput():
	power = 0
	for input in self.inputs.size():
		if inputs[input].power > power:
			power = inputs[input].power
			maxInput = input


func onPowerUpdate(id :int):
	if maxInput != id and inputs[id].power <= power: return
	var prevPower = power
	calculatePowerInput()
	if prevPower == power: return
	Game.world.updateTextures(World.Layer.REDSTONE1, self.pos)


func onNeighborChanged(side: int):
	if Game.world.isTileConnectedAt(pos + Side.vectors[side], Side.opposite[side]):
		Game.world.updateTextures(World.Layer.REDSTONE1, self.pos)
		propagateRegenRequest()


func getType() -> Type:
	return Type.WIRE


func isEqual(other: Component):
	return other.getType() == getType() and other.pos == pos


func isEqualToNew():
	return true
