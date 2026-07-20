class_name ClassicQuickDrawImageDecoder
extends RefCounted

# This decoder intentionally covers only the normalized PICT and cicn payloads that
# the Classic campaign contract can identify precisely. Other QuickDraw variants
# remain an explicit compatibility gap instead of being decoded heuristically.


static func decode(resource_type: String, bytes: PackedByteArray) -> Dictionary:
	match resource_type:
		"PICT":
			return _decode_normalized_pict(bytes)
		"cicn":
			return _decode_cicn(bytes)
		_:
			return _fail("Classic image resource type %s is not supported" % resource_type)


static func _decode_normalized_pict(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() < 84 or _u16(bytes, 10) != 0x0098:
		return _fail("PICT is not the normalized indexed PackBits form")
	var row_bytes_raw := _u16(bytes, 12)
	var row_bytes := row_bytes_raw & 0x3fff
	var top := _i16(bytes, 14)
	var left := _i16(bytes, 16)
	var bottom := _i16(bytes, 18)
	var right := _i16(bytes, 20)
	var width := right - left
	var height := bottom - top
	if (
		(row_bytes_raw & 0x8000) == 0
		or width <= 0
		or height <= 0
		or width > 2048
		or height > 2048
		or row_bytes != width
		or _u16(bytes, 38) != 0
		or _u16(bytes, 40) != 8
		or _u16(bytes, 42) != 1
		or _u16(bytes, 44) != 8
	):
		return _fail("PICT has unsupported normalized pixmap geometry")

	var color_table_offset := 58
	var color_count := _u16(bytes, color_table_offset + 6) + 1
	if color_count < 1 or color_count > 256:
		return _fail("PICT has an invalid color table")
	var data_offset := color_table_offset + 8 + color_count * 8 + 18
	if data_offset >= bytes.size():
		return _fail("PICT color table is truncated")
	var palette: Array[Color] = []
	palette.resize(color_count)
	palette.fill(Color.BLACK)
	var color_table_flags := _u16(bytes, color_table_offset + 4)
	for entry_index: int in color_count:
		var entry_offset := color_table_offset + 8 + entry_index * 8
		if entry_offset + 7 >= bytes.size():
			return _fail("PICT color table is truncated")
		var color_index := entry_index if (color_table_flags & 0x8000) != 0 \
			else _u16(bytes, entry_offset)
		if color_index < 0 or color_index >= palette.size():
			color_index = entry_index
		palette[color_index] = Color8(
			_u16(bytes, entry_offset + 2) >> 8,
			_u16(bytes, entry_offset + 4) >> 8,
			_u16(bytes, entry_offset + 6) >> 8,
			255
		)

	var rgba := PackedByteArray()
	rgba.resize(width * height * 4)
	var cursor := data_offset
	for y: int in height:
		var length_bytes := 2 if row_bytes > 250 else 1
		if cursor + length_bytes > bytes.size():
			return _fail("PICT pixel data ended before row %d" % y)
		var packed_length := _u16(bytes, cursor) if length_bytes == 2 else bytes[cursor]
		cursor += length_bytes
		if cursor + packed_length > bytes.size():
			return _fail("PICT PackBits row %d is truncated" % y)
		var row_result := _decode_packbits_row(bytes, cursor, packed_length, row_bytes)
		if str(row_result.get("status", "error")) != "ok":
			return row_result
		cursor += packed_length
		var row: PackedByteArray = row_result["bytes"]
		for x: int in width:
			var palette_index := int(row[x])
			var color := palette[palette_index] if palette_index < palette.size() \
				else Color.BLACK
			var output_offset := (y * width + x) * 4
			rgba[output_offset] = int(color.r8)
			rgba[output_offset + 1] = int(color.g8)
			rgba[output_offset + 2] = int(color.b8)
			rgba[output_offset + 3] = 255
	return {
		"status": "ok",
		"format": "normalized-pict-packbits-indexed-8",
		"image": Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, rgba),
	}


static func _decode_cicn(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() < 82:
		return _fail("cicn resource is truncated")
	var row_bytes := _u16(bytes, 4) & 0x3fff
	var top := _i16(bytes, 6)
	var left := _i16(bytes, 8)
	var bottom := _i16(bytes, 10)
	var right := _i16(bytes, 12)
	var width := right - left
	var height := bottom - top
	var mask_row_bytes := _u16(bytes, 54) & 0x3fff
	var mask_height := _i16(bytes, 60) - _i16(bytes, 56)
	var bitmap_row_bytes := _u16(bytes, 68) & 0x3fff
	var bitmap_height := _i16(bytes, 74) - _i16(bytes, 70)
	if (
		width <= 0
		or height <= 0
		or width > 512
		or height > 512
		or row_bytes < width
		or _u16(bytes, 32) != 8
		or mask_row_bytes < ((width + 7) >> 3)
		or mask_height != height
		or bitmap_row_bytes < ((width + 7) >> 3)
		or bitmap_height != height
	):
		return _fail("cicn has unsupported canonical geometry")
	var mask_offset := 82
	var bitmap_offset := mask_offset + mask_row_bytes * mask_height
	var color_table_offset := bitmap_offset + bitmap_row_bytes * bitmap_height
	if color_table_offset + 8 > bytes.size():
		return _fail("cicn color table is truncated")
	var color_count := _u16(bytes, color_table_offset + 6) + 1
	var pixel_data_offset := color_table_offset + 8 + color_count * 8
	if (
		color_count < 1
		or color_count > 256
		or pixel_data_offset + row_bytes * height > bytes.size()
	):
		return _fail("cicn pixel data is truncated")
	var palette: Array[Color] = []
	palette.resize(color_count)
	palette.fill(Color.BLACK)
	var color_table_flags := _u16(bytes, color_table_offset + 4)
	for entry_index: int in color_count:
		var entry_offset := color_table_offset + 8 + entry_index * 8
		var color_index := entry_index if (color_table_flags & 0x8000) != 0 \
			else _u16(bytes, entry_offset)
		if color_index < 0 or color_index >= palette.size():
			color_index = entry_index
		palette[color_index] = Color8(
			_u16(bytes, entry_offset + 2) >> 8,
			_u16(bytes, entry_offset + 4) >> 8,
			_u16(bytes, entry_offset + 6) >> 8,
			255
		)

	var rgba := PackedByteArray()
	rgba.resize(width * height * 4)
	for y: int in height:
		for x: int in width:
			var palette_index := int(bytes[pixel_data_offset + y * row_bytes + x])
			var color := palette[palette_index] if palette_index < palette.size() \
				else Color.BLACK
			var mask_byte := bytes[mask_offset + y * mask_row_bytes + (x >> 3)]
			var alpha := 255 if ((mask_byte >> (7 - (x % 8))) & 1) != 0 else 0
			var output_offset := (y * width + x) * 4
			rgba[output_offset] = int(color.r8)
			rgba[output_offset + 1] = int(color.g8)
			rgba[output_offset + 2] = int(color.b8)
			rgba[output_offset + 3] = alpha
	return {
		"status": "ok",
		"format": "canonical-cicn-indexed-8",
		"image": Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, rgba),
	}


static func _decode_packbits_row(
	bytes: PackedByteArray,
	offset: int,
	packed_length: int,
	expected_length: int
) -> Dictionary:
	var output := PackedByteArray()
	output.resize(expected_length)
	var cursor := offset
	var end := offset + packed_length
	var output_cursor := 0
	while cursor < end and output_cursor < expected_length:
		var header := int(bytes[cursor])
		cursor += 1
		if header <= 127:
			var literal_count := header + 1
			if cursor + literal_count > end or output_cursor + literal_count > expected_length:
				return _fail("PICT PackBits literal exceeds its row")
			for index: int in literal_count:
				output[output_cursor + index] = bytes[cursor + index]
			cursor += literal_count
			output_cursor += literal_count
		elif header >= 129:
			var repeat_count := 257 - header
			if cursor >= end or output_cursor + repeat_count > expected_length:
				return _fail("PICT PackBits run exceeds its row")
			var value := bytes[cursor]
			cursor += 1
			for index: int in repeat_count:
				output[output_cursor + index] = value
			output_cursor += repeat_count
	if output_cursor != expected_length:
		return _fail("PICT PackBits row has the wrong decoded length")
	return {"status": "ok", "bytes": output}


static func _u16(bytes: PackedByteArray, offset: int) -> int:
	if offset < 0 or offset + 1 >= bytes.size():
		return -1
	return (int(bytes[offset]) << 8) | int(bytes[offset + 1])


static func _i16(bytes: PackedByteArray, offset: int) -> int:
	var value := _u16(bytes, offset)
	return value - 0x10000 if value >= 0x8000 else value


static func _fail(message: String) -> Dictionary:
	return {"status": "error", "message": message}
