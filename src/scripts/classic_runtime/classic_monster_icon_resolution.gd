class_name ClassicMonsterIconResolution
extends RefCounted

# Exact cicn inventory from the stock Realmz 7.1.2/8.x Family Jewels fork.
# Monster records can also target optional Gems files, so an ID absent here is
# unresolved unless the campaign bundle carries both facing resources.
const FAMILY_JEWELS_CICN_RANGES: Array[Vector2i] = [
	Vector2i(-223, -212),
	Vector2i(-209, -200),
	Vector2i(-195, -164),
	Vector2i(-99, -90),
	Vector2i(-83, -83),
	Vector2i(-79, -50),
	Vector2i(-47, -25),
	Vector2i(-19, -15),
	Vector2i(-11, -11),
	Vector2i(-5, 14),
	Vector2i(18, 40),
	Vector2i(50, 78),
	Vector2i(82, 85),
	Vector2i(89, 95),
	Vector2i(128, 140),
	Vector2i(142, 156),
	Vector2i(159, 186),
	Vector2i(379, 461),
	Vector2i(464, 470),
	Vector2i(472, 473),
	Vector2i(475, 475),
	Vector2i(478, 478),
	Vector2i(481, 483),
	Vector2i(485, 496),
	Vector2i(500, 520),
	Vector2i(522, 524),
	Vector2i(527, 527),
	Vector2i(530, 535),
	Vector2i(537, 566),
	Vector2i(568, 569),
	Vector2i(572, 572),
	Vector2i(575, 591),
	Vector2i(600, 608),
	Vector2i(612, 619),
	Vector2i(692, 769),
	Vector2i(772, 778),
	Vector2i(780, 781),
	Vector2i(783, 783),
	Vector2i(786, 786),
	Vector2i(789, 791),
	Vector2i(793, 804),
	Vector2i(808, 824),
	Vector2i(1000, 1004),
	Vector2i(2000, 2003),
	Vector2i(2005, 2005),
	Vector2i(2011, 2019),
	Vector2i(2201, 2206),
	Vector2i(6100, 6116),
	Vector2i(6119, 6124),
	Vector2i(6126, 6133),
	Vector2i(6137, 6140),
	Vector2i(6144, 6146),
	Vector2i(6153, 6153),
	Vector2i(6156, 6156),
	Vector2i(6159, 6159),
	Vector2i(6162, 6165),
	Vector2i(6176, 6177),
	Vector2i(6181, 6187),
	Vector2i(6189, 6211),
	Vector2i(6213, 6213),
	Vector2i(6220, 6230),
	Vector2i(6300, 6301),
	Vector2i(7002, 7002),
	Vector2i(10000, 10017),
	Vector2i(10210, 10215),
	Vector2i(12000, 12127),
	Vector2i(13300, 13300),
	Vector2i(13303, 13303),
	Vector2i(13305, 13307),
	Vector2i(13400, 13400),
	Vector2i(13403, 13403),
	Vector2i(13405, 13407),
	Vector2i(14000, 14063),
	Vector2i(26178, 26185),
	Vector2i(31004, 31005),
	Vector2i(31009, 31037),
]
const FACING_OFFSET := 308


static func resolve(icon_id: int, icon_catalog: Variant = []) -> Dictionary:
	var paired_id := icon_id + FACING_OFFSET
	if icon_id == 0:
		return {
			"baseIconId": icon_id,
			"pairedIconId": paired_id,
			"lookup": "GetCIcon(base), GetCIcon(base + 308)",
			"status": "no-icon-reference",
			"source": "monster-record",
		}
	var base_record := _catalog_record(icon_catalog, icon_id)
	var paired_record := _catalog_record(icon_catalog, paired_id)
	var base_runtime := _has_runtime_image(base_record)
	var paired_runtime := _has_runtime_image(paired_record)
	var base_campaign := not base_record.is_empty()
	var paired_campaign := not paired_record.is_empty()
	var base_stock := family_jewels_has(icon_id)
	var paired_stock := family_jewels_has(paired_id)
	var base_present := base_campaign or base_stock
	var paired_present := paired_campaign or paired_stock
	var result := {
		"baseIconId": icon_id,
		"pairedIconId": paired_id,
		"lookup": "GetCIcon(base), GetCIcon(base + 308)",
		"baseResourceSource": _resource_source(base_campaign, base_stock),
		"pairedResourceSource": _resource_source(paired_campaign, paired_stock),
		"baseRuntimeMediaPresent": base_runtime,
		"pairedRuntimeMediaPresent": paired_runtime,
	}
	if base_runtime and paired_runtime:
		result.merge({
			"status": "campaign-runtime-media",
			"source": "campaign-resource-fork",
			"baseRuntimeMediaPath": str(base_record["runtimeMedia"].get("path", "")),
			"pairedRuntimeMediaPath": str(paired_record["runtimeMedia"].get("path", "")),
			"baseRuntimeMediaSha256": str(base_record["runtimeMedia"].get("sha256", "")),
			"pairedRuntimeMediaSha256": str(paired_record["runtimeMedia"].get("sha256", "")),
		})
	elif not base_campaign and not paired_campaign and base_stock and paired_stock:
		result.merge({
			"status": "stock-family-jewels-pair",
			"source": "The Family Jewels",
		})
	elif base_present and paired_present:
		result.merge({
			"status": "classic-resource-pair-runtime-media-incomplete",
			"source": "loaded Classic resource chain",
		})
	elif base_present or paired_present:
		result.merge({
			"status": "incomplete-classic-resource-pair",
			"source": "loaded Classic resource chain",
		})
	else:
		result.merge({
			"status": "unresolved-external-classic-resource",
			"source": "optional Classic resource chain",
		})
	return result


static func _resource_source(campaign_present: bool, stock_present: bool) -> String:
	if campaign_present and stock_present:
		return "campaign-and-family-jewels"
	if campaign_present:
		return "campaign-resource-fork"
	if stock_present:
		return "The Family Jewels"
	return "unresolved"


static func family_jewels_has(resource_id: int) -> bool:
	for id_range: Vector2i in FAMILY_JEWELS_CICN_RANGES:
		if resource_id >= id_range.x and resource_id <= id_range.y:
			return true
	return false


static func _catalog_record(icon_catalog: Variant, resource_id: int) -> Dictionary:
	if not (icon_catalog is Array):
		return {}
	for record_value: Variant in icon_catalog:
		if (
			record_value is Dictionary
			and int(record_value.get("resourceId", 0)) == resource_id
		):
			return record_value
	return {}


static func _has_runtime_image(record: Dictionary) -> bool:
	var runtime_media: Variant = record.get("runtimeMedia", {})
	return (
		runtime_media is Dictionary
		and str(runtime_media.get("mediaType", "")).to_lower().begins_with("image/")
		and not str(runtime_media.get("path", "")).strip_edges().is_empty()
	)
