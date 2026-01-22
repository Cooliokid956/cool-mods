Vtx effect_Cube_mesh_layer_5_vtx_0[4] = {
	{{ {50, 0, 50}, 0, {368, 240}, {255, 255, 255, 255} }},
	{{ {-50, 100, 50}, 0, {624, -16}, {255, 255, 255, 255} }},
	{{ {-50, 0, 50}, 0, {368, -16}, {255, 255, 255, 255} }},
	{{ {50, 100, 50}, 0, {624, 240}, {255, 255, 255, 255} }},
};

Gfx effect_Cube_mesh_layer_5_tri_0[] = {
	gsSPVertex(effect_Cube_mesh_layer_5_vtx_0 + 0, 4, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 3, 1, 0),
	gsSPEndDisplayList(),
};

Vtx effect_Cube_mesh_layer_5_vtx_1[12] = {
	{{ {-50, 0, 50}, 0, {368, 1008}, {255, 255, 255, 255} }},
	{{ {-50, 100, 50}, 0, {624, 1008}, {255, 255, 255, 255} }},
	{{ {-50, 100, -50}, 0, {624, 752}, {255, 255, 255, 255} }},
	{{ {-50, 0, -50}, 0, {368, 752}, {255, 255, 255, 255} }},
	{{ {50, 100, -50}, 0, {624, 496}, {255, 255, 255, 255} }},
	{{ {50, 0, -50}, 0, {368, 496}, {255, 255, 255, 255} }},
	{{ {50, 100, 50}, 0, {624, 240}, {255, 255, 255, 255} }},
	{{ {-50, 100, 50}, 0, {880, 240}, {255, 255, 255, 255} }},
	{{ {-50, 100, -50}, 0, {880, 496}, {255, 255, 255, 255} }},
	{{ {50, 0, 50}, 0, {368, 240}, {255, 255, 255, 255} }},
	{{ {-50, 0, -50}, 0, {112, 496}, {255, 255, 255, 255} }},
	{{ {-50, 0, 50}, 0, {112, 240}, {255, 255, 255, 255} }},
};

Gfx effect_Cube_mesh_layer_5_tri_1[] = {
	gsSPVertex(effect_Cube_mesh_layer_5_vtx_1 + 0, 12, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 2, 3, 0),
	gsSP1Triangle(3, 2, 4, 0),
	gsSP1Triangle(3, 4, 5, 0),
	gsSP1Triangle(5, 4, 6, 0),
	gsSP1Triangle(4, 7, 6, 0),
	gsSP1Triangle(4, 8, 7, 0),
	gsSP1Triangle(5, 6, 9, 0),
	gsSP1Triangle(10, 5, 9, 0),
	gsSP1Triangle(10, 9, 11, 0),
	gsSPEndDisplayList(),
};


Gfx mat_effect_white[] = {
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
	gsSPClearGeometryMode(G_SHADE | G_CULL_BACK | G_LIGHTING | G_SHADING_SMOOTH),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetPrimColor(0, 0, 255, 255, 255, 255),
	gsSPEndDisplayList(),
};

Gfx mat_revert_effect_white[] = {
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_SHADE | G_CULL_BACK | G_LIGHTING | G_SHADING_SMOOTH),
	gsSPEndDisplayList(),
};

Gfx mat_effect_black[] = {
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
	gsSPClearGeometryMode(G_SHADE | G_CULL_BACK | G_LIGHTING | G_SHADING_SMOOTH),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetPrimColor(0, 0, 0, 0, 0, 255),
	gsSPEndDisplayList(),
};

Gfx mat_revert_effect_black[] = {
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_SHADE | G_CULL_BACK | G_LIGHTING | G_SHADING_SMOOTH),
	gsSPEndDisplayList(),
};

Gfx effect_Cube_mesh_layer_5[] = {
	gsSPDisplayList(mat_effect_white),
	gsSPDisplayList(effect_Cube_mesh_layer_5_tri_0),
	gsSPDisplayList(mat_revert_effect_white),
	gsSPDisplayList(mat_effect_black),
	gsSPDisplayList(effect_Cube_mesh_layer_5_tri_1),
	gsSPDisplayList(mat_revert_effect_black),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

