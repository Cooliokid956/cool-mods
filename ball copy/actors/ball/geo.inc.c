#include "src/game/envfx_snow.h"

const GeoLayout ball_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, ball_Cube_mesh_layer_1),
		GEO_DISPLAY_LIST(LAYER_FORCE, ball_Cube_mesh_layer_0),
		GEO_DISPLAY_LIST(LAYER_FORCE, ball_material_revert_render_settings),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, ball_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
