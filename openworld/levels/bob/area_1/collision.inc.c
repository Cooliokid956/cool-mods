const Collision bob_area_1_collision[] = {
    COL_INIT(),
    COL_VERTEX_INIT(9),

    // center
    COL_VERTEX(0, -11000, 0),

    // corners
    COL_VERTEX(32767, -11000, 32767), // top right       1
    COL_VERTEX(-32768, -11000, 32767), // top left       2
    COL_VERTEX(32767, -11000, -32768), // bottom right   3
    COL_VERTEX(-32768, -11000, -32768), // bottom left   4
    
    // midpoints
    COL_VERTEX(0, -11000, 32767), // top     5
    COL_VERTEX(0, -11000, -32768), // bottom 6
    COL_VERTEX(32767, -11000, 0), // right   7
    COL_VERTEX(-32768, -11000, 0), // left   8

    COL_TRI_INIT(SURFACE_DEFAULT, 8),
    COL_TRI(0, 5, 7), // top    right   tri
    COL_TRI(1, 7, 5), // top    right   corner
    COL_TRI(0, 8, 5), // top    left    tri
    COL_TRI(2, 5, 8), // top    left    corner
    COL_TRI(0, 7, 6), // bottom right   tri
    COL_TRI(3, 6, 7), // bottom right   corner
    COL_TRI(0, 6, 8), // bottom left    tri
    COL_TRI(4, 8, 6), // bottom left    corner
    COL_TRI_STOP(),
    COL_END(),
};