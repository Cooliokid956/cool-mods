const GeoLayout sling_end_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_SCALE(LAYER_OPAQUE, 65536),
		GEO_OPEN_NODE(),
			GEO_ASM(0, geo_mario_set_player_colors),
			GEO_DISPLAY_LIST(LAYER_OPAQUE, sling_end_sphere_mesh_layer_1_with_revert),
		GEO_CLOSE_NODE(),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
