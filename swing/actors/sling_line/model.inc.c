Lights1 sling_line_f3dlite_material_lights = gdSPDefLights1(
	0x37, 0x0, 0x7F,
	0xFF, 0xFF, 0xFF, 0x28, 0x28, 0x28);

Vtx sling_line_2_line_mesh_layer_1_vtx_0[18] = {
	{{{0, 100, 0}, 0, {752, 506}, {0x00, 0x00, 0x81, 0xFF}}},
	{{{87, -50, 0}, 0, {965, 875}, {0x00, 0x00, 0x81, 0xFF}}},
	{{{-87, -50, 0}, 0, {539, 875}, {0x00, 0x00, 0x81, 0xFF}}},
	{{{87, -50, 100}, 0, {453, 875}, {0x00, 0x00, 0x7F, 0xFF}}},
	{{{0, 100, 100}, 0, {240, 506}, {0x00, 0x00, 0x7F, 0xFF}}},
	{{{-87, -50, 100}, 0, {27, 875}, {0x00, 0x00, 0x7F, 0xFF}}},
	{{{0, 100, 0}, 0, {1008, 496}, {0x6E, 0x3F, 0x00, 0xFF}}},
	{{{0, 100, 100}, 0, {1008, -16}, {0x6E, 0x3F, 0x00, 0xFF}}},
	{{{87, -50, 100}, 0, {667, -16}, {0x6E, 0x3F, 0x00, 0xFF}}},
	{{{87, -50, 0}, 0, {667, 496}, {0x6E, 0x3F, 0x00, 0xFF}}},
	{{{-87, -50, 0}, 0, {325, 496}, {0x92, 0x3F, 0x00, 0xFF}}},
	{{{0, 100, 100}, 0, {-16, -16}, {0x92, 0x3F, 0x00, 0xFF}}},
	{{{0, 100, 0}, 0, {-16, 496}, {0x92, 0x3F, 0x00, 0xFF}}},
	{{{-87, -50, 100}, 0, {325, -16}, {0x92, 0x3F, 0x00, 0xFF}}},
	{{{87, -50, 0}, 0, {667, 496}, {0x00, 0x81, 0x00, 0xFF}}},
	{{{87, -50, 100}, 0, {667, -16}, {0x00, 0x81, 0x00, 0xFF}}},
	{{{-87, -50, 100}, 0, {325, -16}, {0x00, 0x81, 0x00, 0xFF}}},
	{{{-87, -50, 0}, 0, {325, 496}, {0x00, 0x81, 0x00, 0xFF}}},
};

Gfx sling_line_2_line_mesh_layer_1_tri_0[] = {
	gsSPVertex(sling_line_2_line_mesh_layer_1_vtx_0 + 0, 18, 0),
	gsSP2Triangles(0, 1, 2, 0, 3, 4, 5, 0),
	gsSP2Triangles(6, 7, 8, 0, 6, 8, 9, 0),
	gsSP2Triangles(10, 11, 12, 0, 10, 13, 11, 0),
	gsSP2Triangles(14, 15, 16, 0, 14, 16, 17, 0),
	gsSPEndDisplayList(),
};


Gfx mat_sling_line_f3dlite_material[] = {
	gsSPLight(&sling_line_f3dlite_material_lights.l, 1),
    gsSPLight(&sling_line_f3dlite_material_lights.a, 2),
    gsSPCopyLightEXT(2, 15),
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsSPEndDisplayList(),
};

Gfx mat_revert_sling_line_f3dlite_material[] = {
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsSPEndDisplayList(),
};

Gfx sling_line_2_line_mesh_layer_1_with_revert[] = {
	gsSPDisplayList(mat_sling_line_f3dlite_material),
	gsSPDisplayList(sling_line_2_line_mesh_layer_1_tri_0),
	gsSPDisplayList(mat_revert_sling_line_f3dlite_material),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

