const Collision cloud_collision[] = {
	COL_INIT(),
	COL_VERTEX_INIT(3),
	COL_VERTEX(0, 0, -100),
	COL_VERTEX(-87, 0, 50),
	COL_VERTEX(87, 0, 50),
	COL_TRI_INIT(SURFACE_SLIPPERY, 1),
	COL_TRI(0, 1, 2),
	COL_TRI_STOP(),
	COL_END()
};
