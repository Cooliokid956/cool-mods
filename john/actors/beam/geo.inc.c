#include "src/game/envfx_snow.h"

const GeoLayout beam_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_BILLBOARD_WITH_PARAMS_AND_DL(LAYER_ALPHA, 0, 0, 0, beam_Bone_mesh_layer_4),
		GEO_DISPLAY_LIST(LAYER_ALPHA, beam_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
