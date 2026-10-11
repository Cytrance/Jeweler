extends RefCounted
const Snapshot = preload("res://scripts/save_snapshot.gd")
const MAX_BYTES := 1048576

static func read_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > MAX_BYTES:
		return {}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK or not Snapshot.valid(json.data):
		return {}
	return json.data

static func load_slot(path: String) -> Dictionary:
	var data := read_file(path)
	if not data.is_empty():
		return {"data": data, "message": "Continue your saved business."}
	data = read_file(path + ".bak")
	if not data.is_empty():
		return {"data": data, "message": "Recovered the previous save. Your latest progress may be missing."}
	var exists := FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak")
	return {"data": {}, "message": "The save could not be read. It has not been changed. Start a new game only if you want to replace it." if exists else "A small apartment. A hundred credits. A sparkling ambition."}

static func write_text(path: String, content: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(content)
	file.flush()
	var error := file.get_error()
	file.close()
	return error

static func write_slot(path: String, data: Dictionary) -> Error:
	if not Snapshot.valid(data):
		return ERR_INVALID_DATA
	var text := JSON.stringify(data, "\t", true, true)
	if text.to_utf8_buffer().size() > MAX_BYTES:
		return ERR_OUT_OF_MEMORY
	var error := write_text(path + ".tmp", text)
	if error != OK:
		return error
	# Keep a known-valid previous snapshot; never replace it with a corrupt primary.
	if not read_file(path).is_empty():
		error = write_text(path + ".bak.tmp", FileAccess.get_file_as_string(path))
		if error != OK:
			return error
		error = DirAccess.rename_absolute(path + ".bak.tmp", path + ".bak")
		if error != OK:
			return error
	# The old primary remains intact until the complete temporary file is renamed.
	return DirAccess.rename_absolute(path + ".tmp", path)
