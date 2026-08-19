// The template display list.
// Some values are placeholders that will be filled during the custom GEO ASM function.
Gfx shape_template_dl[] = {
/* [00] */ gsSPGeometryMode(0, 0),
/* [01] */ gsDPSetCombineMode(G_CC_DECALRGBA, G_CC_DECALRGBA),
/*![02]!*/ gsDPSetTexturePersp(G_TP_NONE),
/* [03] */ gsSPTexture(0xFFFF, 0xFFFF, 0, G_TX_RENDERTILE, G_ON),
/* [04] */ gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_32b_LOAD_BLOCK, 1, NULL),
/* [05] */ gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_32b_LOAD_BLOCK, 0, 0, G_TX_LOADTILE, 0 , G_TX_WRAP, 0, G_TX_NOLOD, G_TX_WRAP, 0, G_TX_NOLOD),
/* [06] */ gsDPLoadSync(),
/* [07] */ gsDPLoadBlock(G_TX_LOADTILE, 0, 0, 0, 0),
/* [08] */ gsDPPipeSync(),
/* [09] */ gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_32b, 128, 0, G_TX_RENDERTILE, 0, G_TX_WRAP, 0, G_TX_NOLOD, G_TX_WRAP, 0, G_TX_NOLOD),
/* [10] */ gsDPSetTileSize(G_TX_RENDERTILE, 0, 0, 511 << G_TEXTURE_IMAGE_FRAC, 511 << G_TEXTURE_IMAGE_FRAC),
/* [11] */ gsSPVertex(NULL, 0, 0),
/* [12] */ gsSPDisplayList(NULL),
/* [13] */ gsSPTexture(0xFFFF, 0xFFFF, 0, G_TX_RENDERTILE, G_OFF),
/* [14] */ gsDPSetCombineMode(G_CC_SHADE, G_CC_SHADE),
/* [15] */ gsDPSetTexturePersp(G_TP_PERSP),
/* [16] */ gsSPGeometryMode(G_TEXTURE_GEN, G_LIGHTING | G_CULL_BACK),
/* [17] */ gsSPEndDisplayList(),
};
