Lights1 cloud_f3dlite_material_lights = gdSPDefLights1(
	0x7F, 0x7F, 0x7F,
	0xFF, 0xFF, 0xFF, 0x28, 0x28, 0x28);

Vtx cloud_Cone_mesh_layer_1_vtx_0[3] = {
	{{ {0, 0, -100}, 0, {752, 506}, {0, 127, 0, 255} }},
	{{ {-87, 0, 50}, 0, {539, 875}, {0, 127, 0, 255} }},
	{{ {87, 0, 50}, 0, {965, 875}, {0, 127, 0, 255} }},
};

Gfx cloud_Cone_mesh_layer_1_tri_0[] = {
	gsSPVertex(cloud_Cone_mesh_layer_1_vtx_0 + 0, 3, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSPEndDisplayList(),
};


Gfx mat_cloud_f3dlite_material[] = {
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsSPSetLights1(cloud_f3dlite_material_lights),
	gsSPEndDisplayList(),
};

Gfx cloud_Cone_mesh_layer_1[] = {
	gsSPDisplayList(mat_cloud_f3dlite_material),
	gsSPDisplayList(cloud_Cone_mesh_layer_1_tri_0),
	gsSPEndDisplayList(),
};

Gfx cloud_material_revert_render_settings[] = {
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

