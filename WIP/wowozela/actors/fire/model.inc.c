Gfx fire_fire_rgba32_aligner[] = {gsSPEndDisplayList()};
u8 fire_fire_rgba32[] = {
	#include "actors/fire/fire.rgba32.inc.c"
};

Vtx fire_Bone_mesh_layer_5_vtx_0[4] = {
	{{ {-100, -100, 0}, 0, {-16, 2032}, {255, 255, 255, 255} }},
	{{ {100, -100, 0}, 0, {2032, 2032}, {255, 255, 255, 255} }},
	{{ {100, 100, 0}, 0, {2032, -16}, {255, 255, 255, 255} }},
	{{ {-100, 100, 0}, 0, {-16, -16}, {255, 255, 255, 255} }},
};

Gfx fire_Bone_mesh_layer_5_tri_0[] = {
	gsSPVertex(fire_Bone_mesh_layer_5_vtx_0 + 0, 4, 0),
	gsSP2Triangles(0, 1, 2, 0, 0, 2, 3, 0),
	gsSPEndDisplayList(),
};


Gfx mat_fire_f3dlite_material[] = {
	gsSPGeometryMode(G_SHADE | G_CULL_BACK | G_LIGHTING | G_SHADING_SMOOTH, 0),
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, 0, 0, 0, TEXEL0, TEXEL0, 0, SHADE, 0, 0, 0, 0, TEXEL0),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_32b_LOAD_BLOCK, 1, fire_fire_rgba32),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_32b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 4095, 64),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_32b, 16, 0, 0, 0, G_TX_CLAMP | G_TX_NOMIRROR, 6, 0, G_TX_CLAMP | G_TX_NOMIRROR, 6, 0),
	gsDPSetTileSize(0, 0, 0, 252, 252),
	gsSPEndDisplayList(),
};

Gfx mat_revert_fire_f3dlite_material[] = {
	gsSPGeometryMode(0, G_SHADE | G_CULL_BACK | G_LIGHTING | G_SHADING_SMOOTH),
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsSPEndDisplayList(),
};

Gfx fire_Bone_mesh_layer_5[] = {
	gsSPDisplayList(mat_fire_f3dlite_material),
	gsSPDisplayList(fire_Bone_mesh_layer_5_tri_0),
	gsSPDisplayList(mat_revert_fire_f3dlite_material),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

