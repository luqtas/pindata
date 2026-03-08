extends Control

func _ready() -> void:
	# we set the focus and select the first item on the $$VBoxContainer/list
	# otherwise user needs to press down arrow
	$VBoxContainer/list.grab_focus()
	$VBoxContainer/list.select(2)
	load_data()

# why inside a folder? for Syncthing! otherwise we would need to mess
# with exclude.lists
var save_path = "user://save/data.save"

var last = []
func save_data():
	last.clear()
	last.append($VBoxContainer/list.get_item_text(0)) # last table at the app
	last.append($VBoxContainer/list.get_item_text(2)) # last user
	last.append(average) # was average activated?
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(tables)
	file.store_var(data)
	file.store_var(last)
func load_data():
	if FileAccess.file_exists(save_path):
		# file was found
		var file = FileAccess.open(save_path, FileAccess.READ)
		tables = file.get_var()
		data = file.get_var()
		last = file.get_var()
		$VBoxContainer/list.set_item_text(0, last.get(0)) # set last table app had
		$VBoxContainer/list.set_item_text(2, last.get(1)) # last user
		average = last.get(2) # toggles average
		$VBoxContainer/list.select(1) # set focus at score
		vertical = 1
		graph()
	else:
		# file was not found
		if !DirAccess.dir_exists_absolute('user://save'):
			DirAccess.make_dir_absolute('user://save')
func _exit_tree() -> void:
	save_data()
# Android stuff, as closing the app the way i do, doesn't run _exit_tree
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()
		get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		save_data()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_data()

var tables = []
var data = {}

func _input(event: InputEvent) -> void:
	# had to handle input this way as simulating ui_presses with buttons
	# didn't worked!
	if Input.is_action_pressed("ui_right"):
		cycle("right")
	elif Input.is_action_pressed("ui_left"):
		cycle("left")
	elif Input.is_action_pressed("ui_accept"):
		mods("accept")
	elif Input.is_action_pressed("ui_cancel"):
		mods("cancel")
	elif Input.is_action_pressed("ui_text_backspace"):
		mods("backspace")
	elif Input.is_action_pressed("ui_text_delete"):
		mods("delete")

func mods(x):
	if $VBoxContainer/list.is_selected(0):
		if x == "accept" and !$line.visible:
			$line.virtual_keyboard_type = 0
			$line.show()
		elif x == "delete" and !$line.visible:
			if $VBoxContainer/list.get_item_text(0) == "table":
				return
			for n in data.keys().size():
				var z = data.keys()
				var y = z.get(n)
				data[y].erase($VBoxContainer/list.get_item_text(0))
			tables.erase($VBoxContainer/list.get_item_text(0))
			if tables.size() - 1 == -1:
				$VBoxContainer/list.set_item_text(0, "table")
			else:
				$VBoxContainer/list.set_item_text(0, tables.get(tables.size() - 1))
			save_data()
			graph()
		elif $line.visible:
			if x == "accept":
				# thanks for the whitespace checker
				# https://godotforums.org/d/35000-how-to-check-if-a-string-contains-only-whitespace-characters
				var ws = RegEx.new()
				ws.compile("\\s*")
				if $line.text.length() == ws.search($line.text).get_string(0).length():
					$line.hide()
					$line.clear()
					$VBoxContainer/list.grab_focus()
					return
				elif tables.has($line.text):
					$VBoxContainer/list.set_item_text(0, $line.text)
					$VBoxContainer/list.select(1)
					$line.hide()
					$line.clear()
					$VBoxContainer/list.grab_focus()
					graph()
					return
				else:
					$VBoxContainer/list.set_item_text(0, $line.text)
					tables.append($line.text)
					$line.hide()
					$line.clear()
					$VBoxContainer/list.grab_focus()
					save_data()
					graph()
			elif x == "cancel":
				$line.hide()
				$line.clear()
				$VBoxContainer/list.grab_focus()

	elif $VBoxContainer/list.is_selected(1):
		if $line.visible:
			if x == "accept":
				if data.keys() == [] or tables == []:
					$line.hide()
					$line.clear()
					$VBoxContainer/list.grab_focus()
					return
				if $line.text.is_valid_int():
					if !data[$VBoxContainer/list.get_item_text(2)].has($VBoxContainer/list.get_item_text(0)):
						data[$VBoxContainer/list.get_item_text(2)].get_or_add($VBoxContainer/list.get_item_text(0))
						data[$VBoxContainer/list.get_item_text(2)][$VBoxContainer/list.get_item_text(0)] = []
					data[$VBoxContainer/list.get_item_text(2)][$VBoxContainer/list.get_item_text(0)].append(int($line.text))
				elif $line.text == "":
					if average == false:
						average = true
					else:
						average = false
				$line.hide()
				$line.clear()
				$VBoxContainer/list.grab_focus()
				save_data()
				graph()
			elif x == "cancel":
				$line.hide()
				$line.clear()
				$VBoxContainer/list.grab_focus()
		elif x == "backspace":
			if data.keys() == []:
				return
			elif !data[$VBoxContainer/list.get_item_text(2)]:
				return
			elif data[$VBoxContainer/list.get_item_text(2)][$VBoxContainer/list.get_item_text(0)] == []:
				return
			data[$VBoxContainer/list.get_item_text(2)][$VBoxContainer/list.get_item_text(0)].erase(data[$VBoxContainer/list.get_item_text(2)][$VBoxContainer/list.get_item_text(0)].back())
			save_data()
			graph()
		elif x == "delete":
			if data.keys() == []:
				return
			elif !data[$VBoxContainer/list.get_item_text(2)]:
				return
			elif data[$VBoxContainer/list.get_item_text(2)][$VBoxContainer/list.get_item_text(0)] == []:
				return
			data[$VBoxContainer/list.get_item_text(2)][$VBoxContainer/list.get_item_text(0)] = []
			save_data()
			graph()
		elif !$line.visible:
			if x == "accept":
				$line.virtual_keyboard_type = 2
				$line.show()

	elif $VBoxContainer/list.is_selected(2):
		if x == "accept" and !$line.visible:
			$line.virtual_keyboard_type = 0
			$line.show()
		elif x == "delete":
			if !data.keys().has($VBoxContainer/list.get_item_text(2)):
				return
			data.erase($VBoxContainer/list.get_item_text(2))
			if data == {}:
				$VBoxContainer/list.set_item_text(2, "player")
			else:
				$VBoxContainer/list.set_item_text(2, data.keys().max())
			save_data()
			graph()
		elif $line.visible:
			if x == "accept":
				var ws = RegEx.new()
				ws.compile("\\s*")
				if $line.text.length() == ws.search($line.text).get_string(0).length():
					$line.hide()
					$VBoxContainer/list.grab_focus()
					return
				elif data.has($line.text):
					$VBoxContainer/list.set_item_text(2, $line.text)
					$VBoxContainer/list.select(1)
					$line.hide()
					$line.clear()
					$VBoxContainer/list.grab_focus()
					return
				$VBoxContainer/list.set_item_text(2, $line.text)
				data.get_or_add($VBoxContainer/list.get_item_text(2))
				data[$VBoxContainer/list.get_item_text(2)] = {}
				$line.hide()
				$line.clear()
				$VBoxContainer/list.grab_focus()
				save_data()
				graph()
			elif x == "cancel":
				$line.hide()
				$line.clear()
				$VBoxContainer/list.grab_focus()

func cycle(y):
	if !$line.visible:
		if $VBoxContainer/list.is_selected(0):
			if tables.size() == 0:
				return
			if tables.size() >= 1:
				var a = $VBoxContainer/list.get_item_text(0)
				var b = tables.find(a)
				if y == "right":
					b = b + 1
				elif y == "left":
					b = b - 1
				if b >= tables.size():
					$VBoxContainer/list.set_item_text(0, tables.get(0))
				elif b <= -1:
					$VBoxContainer/list.set_item_text(0, tables.back())
				else:
					$VBoxContainer/list.set_item_text(0, tables.get(b))
				graph()
		if $VBoxContainer/list.is_selected(2):
			if data.size() >= 1:
				var a = $VBoxContainer/list.get_item_text(2)
				var b = data.keys().find(a)
				if y == "right":
					b = b + 1
				elif y == "left":
					b = b - 1
				if b >= data.keys().size():
					$VBoxContainer/list.set_item_text(2, data.keys().get(0))
				elif b <= -1:
					$VBoxContainer/list.set_item_text(2, data.keys().back())
				else:
					$VBoxContainer/list.set_item_text(2, data.keys().get(b))

var average = false
var avgt = 10
func graph():
	if  data == {}:
		return
	elif !data[$VBoxContainer/list.get_item_text(2)]:
		return
	else:
		for n in data.keys().size():
			var player = data.keys().get(n)
			if data[player].has($VBoxContainer/list.get_item_text(0)):
				$VBoxContainer/graph.show()
				break
			else:
				if n == (data.keys().size() - 1):
					$VBoxContainer/graph.hide()
					return
				continue
	var chart_scene: PackedScene = load("res://addons/easy_charts/control_charts/chart.tscn")
	var chart: Chart = chart_scene.instantiate()
	add_child(chart)
	chart.reparent($VBoxContainer/graph)
	chart.queue_redraw()
	var draws: Array[Function] = []
	var color = Color(1.0, 1.0, 1.0, 1.0)
	for n in data.keys().size():
		var player = data.keys().get(n)
		if !data[player].has($VBoxContainer/list.get_item_text(0)):
			continue
		var score = data[player][$VBoxContainer/list.get_item_text(0)]
		if score == []:
			score = [0]
			
		elif average == true:
			if avgt < int(score.size()):
				var i = int(score.size() / avgt)
				var ii = 0
				var iii = []
				var avg = score.duplicate(true)
				for o in avgt:
					for oo in i:
						ii = ii + avg.get(0)
						avg.remove_at(0)
					iii.append(ii/i)
					ii = 0
				score = iii

		var gp = []
		for o in score.size():
			gp.append(o + 1)
		if n == 0:
			color = Color("ff0000")
		elif n == 1:
			color = Color("0000ff")
		elif n == 2:
			color = Color("ffa500")
		elif n == 3:
			color = Color("00ff00")
		elif n == 4:
			color = Color("ee82ee")
		elif n == 5:
			color = Color("ffff00")
		elif n == 6:
			color = Color("4b0082")
		else:
			color = Color("000000ff")
		var draw = Function.new(
			gp,
			score,
			player,
			{type = Function.Type.LINE, marker = Function.Marker.CIRCLE, color = color}
		)
		draws.append(draw)
	var chart_properties := ChartProperties.new()
	#chart_properties.x_label = "games played"
	#chart_properties.y_label = "score"
	chart_properties.show_legend = true
	chart.y_labels_function = func(value: int): return str(add_commas_to_number(value))
	chart.x_labels_function = func(value: float): return str(int(value))
	chart.plot(draws, chart_properties)

func add_commas_to_number(input_number : int) -> String:
	# from https://www.reddit.com/r/godot/comments/9iw4ie/printing_integers_with_commas_as_thousands/
	# (thanks) sillysniper18 comment,
	var number_as_string : String = str(input_number)
	var output_string : String = ""
	var last_index : int = number_as_string.length() - 1
	#For each digit in the number...
	for index in range(number_as_string.length()):
		#add that digit to the output string, and then...
		output_string = output_string + number_as_string.substr(index,1)
		#if the index is at the thousandths, millions, billionths place, etc.
		#i.e. where you would put a comma, then insert a comma after that digit.
		if (last_index - index) % 3 == 0 and index != last_index:
			output_string = output_string + " "
	return output_string

func _on_line_draw() -> void:
	$line.grab_focus()

# arrows
var vertical = 2
func _on_up_pressed() -> void:
	vertical = vertical - 1
	if vertical <= -1:
		vertical = 2
		$VBoxContainer/list.select(2)
	else:
		$VBoxContainer/list.select(vertical)
func _on_down_pressed() -> void:
	vertical = vertical + 1
	if vertical >= 3:
		vertical = 0
		$VBoxContainer/list.select(0)
	else:
		$VBoxContainer/list.select(vertical)
func _on_right_pressed() -> void:
	cycle("right")
func _on_left_pressed() -> void:
	cycle("left")

# mods
func _on_enter_pressed() -> void:
	mods("accept")
func _on_delete_pressed() -> void:
	if $mods/lock.button_pressed:
		mods("delete")
func _on_redo_pressed() -> void:
	if $mods/lock.button_pressed:
		mods("backspace")
