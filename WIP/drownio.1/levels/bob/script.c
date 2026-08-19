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
	LOAD_MIO0(0xa, _wdw_skybox_mio0SegmentRomStart, _wdw_skybox_mio0SegmentRomEnd), 
	ALLOC_LEVEL_POOL(),
	MARIO(MODEL_MARIO, 0x00000001, bhvMario),

	/* Fast64 begin persistent block [level commands] */
	/* Fast64 end persistent block [level commands] */

	AREA(1, bob_area_1),
		WARP_NODE(0x0A, LEVEL_BOB, 0x01, 0x0A, WARP_NO_CHECKPOINT),
		WARP_NODE(0xF0, LEVEL_BOB, 0x01, 0x0A, WARP_NO_CHECKPOINT),
		WARP_NODE(0xF1, LEVEL_BOB, 0x01, 0x0A, WARP_NO_CHECKPOINT),
		MARIO_POS(0x01, 0, -6270, -3756, -11),
		OBJECT(E_MODEL_NONE, -11433, -3311, -649, 0, 90, 0, (1 << 24), id_bhvKoopOfTheQuick),
		OBJECT(E_MODEL_NONE, -9083, 77, -5148, 0, 0, 0, 0x00000000, id_bhvKoopRaceEndpoint),
		OBJECT(E_MODEL_NONE, -8910, -3311, -638, 0, 0, 0, 0x00000000, bhvHiddenRedCoinStar),
		OBJECT(E_MODEL_WOODEN_SIGNPOST, -7583, -4191, 365, 0, 150, 0, (000 << 16), id_bhvMessagePanel),
		OBJECT(E_MODEL_WOODEN_SIGNPOST, -9130, -3311, -902, 0, 90, 0, (001 << 16), id_bhvMessagePanel),
		OBJECT(E_MODEL_WOODEN_SIGNPOST, 2645, -3311, 3225, 0, -60, 0, (002 << 16), id_bhvMessagePanel),
		OBJECT(E_MODEL_WOODEN_SIGNPOST, -6252, -4213, -907, 0, 0, 0, (003 << 16), id_bhvMessagePanel),
		OBJECT(E_MODEL_WOODEN_SIGNPOST, -8685, -3311, -346, 0, -90, 0, (004 << 16), id_bhvMessagePanel),
		OBJECT(MODEL_NONE, -6270, -3756, -11, 0, 0, 0, 0x000A0000, bhvSpinAirborneWarp),
		TERRAIN(bob_area_1_collision),
		MACRO_OBJECTS(bob_area_1_macro_objs),
		SET_BACKGROUND_MUSIC(0x00, SEQ_LEVEL_KOOPA_ROAD),
		TERRAIN_TYPE(TERRAIN_STONE),
		/* Fast64 begin persistent block [area commands] */
		/* Fast64 end persistent block [area commands] */
	END_AREA(),

	FREE_LEVEL_POOL(),
	MARIO_POS(0x01, 0, -6270, -3756, -11),
	CALL(0, lvl_init_or_update),
	CALL_LOOP(1, lvl_init_or_update),
	CLEAR_LEVEL(),
	SLEEP_BEFORE_EXIT(1),
	EXIT(),
};
