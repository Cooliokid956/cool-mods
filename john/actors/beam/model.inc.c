Gfx beam_beam_rgba16_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 beam_beam_rgba16_rgba16[] = {
	#include "actors/beam/beam_rgba16.rgba16.inc.c"
};

Vtx beam_Bone_mesh_layer_4_vtx_0[4] = {
	{{ {-100, -100, 0}, 0, {0, 2048}, {255, 255, 255, 255} }},
	{{ {100, -100, 0}, 0, {2048, 2048}, {255, 255, 255, 255} }},
	{{ {100, 100, 0}, 0, {2048, 0}, {255, 255, 255, 255} }},
	{{ {-100, 100, 0}, 0, {0, 0}, {255, 255, 255, 255} }},
};

Gfx beam_Bone_mesh_layer_4_tri_0[] = {
	gsSPVertex(beam_Bone_mesh_layer_4_vtx_0 + 0, 4, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 2, 3, 0),
	gsSPEndDisplayList(),
};


Gfx mat_beam_f3dlite_material[] = {
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, TEXEL0, 0, 0, 0, TEXEL0, 0, 0, 0, TEXEL0, 0, 0, 0, TEXEL0),
	gsSPClearGeometryMode(G_SHADE | G_CULL_BACK | G_LIGHTING | G_SHADING_SMOOTH),
	gsDPSetTextureFilter(G_TF_POINT),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, beam_beam_rgba16_rgba16),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 4095, 128),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 16, 0, 0, 0, G_TX_CLAMP | G_TX_NOMIRROR, 6, 0, G_TX_CLAMP | G_TX_NOMIRROR, 6, 0),
	gsDPSetTileSize(0, 0, 0, 252, 252),
	gsSPEndDisplayList(),
};

Gfx mat_revert_beam_f3dlite_material[] = {
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_SHADE | G_CULL_BACK | G_LIGHTING | G_SHADING_SMOOTH),
	gsDPSetTextureFilter(G_TF_BILERP),
	gsSPEndDisplayList(),
};

Gfx beam_Bone_mesh_layer_4[] = {
	gsSPDisplayList(mat_beam_f3dlite_material),
	gsSPDisplayList(beam_Bone_mesh_layer_4_tri_0),
	gsSPDisplayList(mat_revert_beam_f3dlite_material),
	gsSPEndDisplayList(),
};

Gfx beam_material_revert_render_settings[] = {
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

