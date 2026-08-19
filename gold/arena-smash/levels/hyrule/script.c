#include <ultra64.h>
#include "sm64.h"
#include "behavior_data.h"
#include "model_ids.h"
#include "seq_ids.h"
#include "dialog_ids.h"
#include "segment_symbols.h"
#include "level_commands.h"

#include "game/level_update.h"

#include "levels/scripts.h"


/* Fast64 begin persistent block [includes] */
/* Fast64 end persistent block [includes] */

#include "make_const_nonconst.h"
#include "levels/hyrule/header.h"

/* Fast64 begin persistent block [scripts] */
/* Fast64 end persistent block [scripts] */

const LevelScript level_hyrule_entry[] = {
	INIT_LEVEL(),
	LOAD_MIO0(0x7, _hyrule_segment_7SegmentRomStart, _hyrule_segment_7SegmentRomEnd), 
	LOAD_MIO0(0xa, _water_skybox_mio0SegmentRomStart, _water_skybox_mio0SegmentRomEnd), 
	ALLOC_LEVEL_POOL(),
	MARIO(MODEL_MARIO, 0x00000001, bhvMario),

	/* Fast64 begin persistent block [level commands] */
	/* Fast64 end persistent block [level commands] */

	AREA(1, hyrule_area_1),
		OBJECT(MODEL_NONE, 43, 1656, -25, 0, 90, 0, (0x00 << 24), id_bhvArenaFlag),
		OBJECT(MODEL_NONE, 43, 1401, -25, 0, -90, 0, 0x00000000, id_bhvArenaKoth),
		OBJECT(MODEL_NONE, -501, 890, 0, 0, 0, 0, (10 << 16), bhvSpinAirborneWarp),
		OBJECT(MODEL_NONE, -466, 567, 0, 0, 0, 0, (1 << 24), id_bhvArenaSpawn),
		OBJECT(MODEL_NONE, 288, 1162, -25, 0, 0, 0, (1 << 24), id_bhvArenaSpawn),
		OBJECT(MODEL_NONE, 42, 823, -25, 0, 0, 0, (1 << 24), id_bhvArenaSpawn),
		OBJECT(MODEL_NONE, 1317, 161, 0, 0, 0, 0, (1 << 24), id_bhvArenaSpawn),
		OBJECT(MODEL_NONE, 43, 1502, -25, 0, 0, 0, (1 << 24), id_bhvArenaSpawn),
		OBJECT(MODEL_NONE, 1317, 889, 0, 0, 0, 0, (1 << 24), id_bhvArenaSpawn),
		TERRAIN(hyrule_area_1_collision),
		MACRO_OBJECTS(hyrule_area_1_macro_objs),
		SET_BACKGROUND_MUSIC(0x00, SEQ_LEVEL_GRASS),
		TERRAIN_TYPE(TERRAIN_GRASS),
		/* Fast64 begin persistent block [area commands] */
		/* Fast64 end persistent block [area commands] */
	END_AREA(),

	FREE_LEVEL_POOL(),
	MARIO_POS(1, 0, 0, 0, 0),
	CALL(0, lvl_init_or_update),
	CALL_LOOP(1, lvl_init_or_update),
	CLEAR_LEVEL(),
	SLEEP_BEFORE_EXIT(1),
	EXIT(),
};
