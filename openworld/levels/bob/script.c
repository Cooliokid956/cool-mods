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
#include "levels/bob/header.h"

/* Fast64 begin persistent block [scripts] */
/* Fast64 end persistent block [scripts] */

const LevelScript level_bob_entry[] = {
	INIT_LEVEL(),
	LOAD_MIO0(0x7, _bob_segment_7SegmentRomStart, _bob_segment_7SegmentRomEnd), 
	LOAD_MIO0(0xa, _water_skybox_mio0SegmentRomStart, _water_skybox_mio0SegmentRomEnd), 
	ALLOC_LEVEL_POOL(),
	MARIO(MODEL_MARIO, 0x00000001, bhvMario),

	/* Fast64 begin persistent block [level commands] */
	/* Fast64 end persistent block [level commands] */

	AREA(1, bob_area_1),
		OBJECT(MODEL_NONE, 0, 0, 0, 0, 0, 0, 0, id_bhvCollisionObject),
		OBJECT(MODEL_NONE, -5838, -459, 15059, 0, 0, 0, (0xA << 16), bhvHardAirKnockBackWarp),
		OBJECT(MODEL_NONE, -65535, 0, -65535, 0, 0, 0, 1, id_bhvVisualObject),
		OBJECT(MODEL_NONE, 0, 0, -65535, 0, 0, 0, 2, id_bhvVisualObject),
		OBJECT(MODEL_NONE, 65535, 0, -65535, 0, 0, 0, 3, id_bhvVisualObject),
		OBJECT(MODEL_NONE, -65535, 0, 0, 0, 0, 0, 4, id_bhvVisualObject),
		OBJECT(MODEL_NONE, 0, 0, 0, 0, 0, 0, 5, id_bhvVisualObject),
		OBJECT(MODEL_NONE, 65535, 0, 0, 0, 0, 0, 6, id_bhvVisualObject),
		OBJECT(MODEL_NONE, -65535, 0, 65535, 0, 0, 0, 7, id_bhvVisualObject),
		OBJECT(MODEL_NONE, 0, 0, 65535, 0, 0, 0, 8, id_bhvVisualObject),
		OBJECT(MODEL_NONE, 65535, 0, 65535, 0, 0, 0, 9, id_bhvVisualObject),
		TERRAIN(bob_area_1_collision),
		MACRO_OBJECTS(bob_area_1_macro_objs),
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
