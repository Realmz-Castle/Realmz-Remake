extends AStarGrid2D
class_name SpecificAstar2D

# defines a graph for a certain kind of character (small,big,flyer, swimmer, idk)

#https://docs.godotengine.org/en/stable/classes/class_astar.html#class-astar-method-connect-points
#https://docs.godotengine.org/en/stable/classes/class_astar2d.html
#https://github.com/godotengine/godot/blob/master/core/math/a_star.cpp

var crea_size : Vector2 = Vector2.ONE  #size of the creature that navigates it

const DIRECTIONS : Array = [Vector2( 0, 1), Vector2( 0,-1),
							Vector2( 1, 0), Vector2(-1, 0),
							Vector2(-1,-1), Vector2(-1, 1),
							Vector2( 1,-1), Vector2( 1, 1)]

var blocked_tiles : Dictionary = {} # id : array of ids that connected to it

#var last_generated_path : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func generate_graph(mapdata : Array, swimmer : bool, flyer : bool, big : bool) :
	blocked_tiles.clear()
	#voidset_point_solid(id: Vector2i, solid: bool = true)
	#voidset_point_weight_scale(id: Vector2i, weight_scale: float)
	var map_size_x : int = mapdata[0].size()
	var map_size_y : int = mapdata.size()
	region = Rect2i(0, 0, map_size_x, map_size_y)
	update()

	var x : int = 0
	var y : int = 0
	var pos : Vector2i = Vector2i.ZERO
	for l in mapdata :
		x = 0
		# ts is an array of tile dicts, a  "tile stack"
		for ts in l :
			var weight : float = get_tilestack_cost(ts, swimmer, flyer, big)
			pos = Vector2i(y,x)
#			print("ASTAR : tile at "+str(pos)+" is "+ts[0]["name"]+" and weight "+str(weight))
#			set_point_solid(pos, weight<0)
			if weight>=0 :
				specific_set_point_weight_scale(pos, weight)
			else :
				specific_set_point_weight_scale(pos, 1000000)
			x += 1
		y += 1

#@override    void set_point_weight_scale(id: Vector2i, weight_scale: float)
func specific_set_point_weight_scale(pos : Vector2i, weight_scale: float) :
	#● Vector2 get_point_position(id: Vector2i) const
	#● float get_point_weight_scale(id: Vector2i) const
	#first , we dont want to mes with points outsid the region
	var region_end : Vector2i = region.end
	for cx in range(crea_size.x) :
		for cy in range(crea_size.y) :
			if pos.x+cx<region_end.x and pos.y+cy<region_end.y :
				var bpos : Vector2i =  pos+Vector2i(cx,cy)
				var prev_weight : float = get_point_weight_scale(bpos)
				set_point_weight_scale(pos+Vector2i(cx,cy), max(weight_scale,prev_weight))
	

func get_tilestack_cost(ts : Array, swimmer : bool, flyer : bool, big : bool) -> float :
	#returns -1 if not walkable, else the movement cost
	if ts.is_empty() :
		return false
	var stacksize : int = ts.size()
	var mov_cost : int = 0
	for i  in range(stacksize) :
		var tdict : Dictionary = ts[stacksize-i-1]
		var iswalkable : bool = tdict['wall'] == 0
		iswalkable = iswalkable and (tdict['water']==0 or (tdict['water']!=0 and swimmer))
		iswalkable = iswalkable and ( (tdict['swall']==0) or  (tdict['swall']!=0 and (flyer or big)) )
#		if tdict["time"] > 20 :
#			return -1
#		if tdict["name"]=="Big_tree_top_4" :
#			iswalkable = false
#			print("ASTAR : Big_tree_top_4 walkable = "+str(iswalkable))

		if not iswalkable :
			return -1
		mov_cost += tdict['time']

	return mov_cost

func block_pos(pos : Vector2i) :
	blocked_tiles[pos] = true
	set_point_solid(pos, true)

func clear_pos(pos : Vector2i) :
	if blocked_tiles.has(pos) :
		blocked_tiles.erase(pos)
		set_point_solid(pos, false)

func clear_all_pos() :
	for pos in blocked_tiles :
		set_point_solid(pos, false)
	blocked_tiles.clear()

func update_blocked_by_creas(creas_array : Array, active_crea : Creature) :
	clear_all_pos()
	for c in creas_array :
		if c==active_crea :
			continue
		for x in range(c.size.x) :
			for y in range(c.size.y) :
				for cx in range(crea_size.x) :
					for cy in range(crea_size.y) :
						#print("MyAstar2D update_blocked_by_creas : "+c.name+' '+str(c.position) + str(Vector2(x,y)) + str(Vector2(cx,cy)))
						block_pos(c.position + Vector2(x,y) - Vector2(cx,cy))
				

#func generate_graph_part(topleft: Vector2, botrigt : Vector2, data : Array, also_disconnect : bool = false) :
#	var start  = Time.get_ticks_msec()
#	print("MYASTAR2D GENERATE GRAPH")


#func _notification(what):
#	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
#		self.free()
