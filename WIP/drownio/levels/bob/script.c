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
		MARIO_POS(0x01, 0, -5170, -3756, -11),
		OBJECT(E_MODEL_NONE, -7983, 77, -5148, 0, 0, 0, 0x00000000, id_bhvKoopRaceEndpoint),
		OBJECT(E_MODEL_WOODEN_SIGNPOST, -6483, -4191, 365, 0, 150, 0, (000 << 16), id_bhvMessagePanel),
		OBJECT(E_MODEL_WOODEN_SIGNPOST, -8030, -3311, -902, 0, 90, 0, (001 << 16), id_bhvMessagePanel),
		OBJECT(E_MODEL_WOODEN_SIGNPOST, 3746, -3311, 3226, 0, -60, 0, (002 << 16), id_bhvMessagePanel),
		OBJECT(E_MODEL_WOODEN_SIGNPOST, -5151, -4213, -269, 0, 0, 0, (003 << 16), id_bhvMessagePanel),
		OBJECT(E_MODEL_WOODEN_SIGNPOST, -7585, -3311, -346, 0, -90, 0, (004 << 16), id_bhvMessagePanel),
		OBJECT(E_MODEL_WOODEN_SIGNPOST, -5154, -4213, 255, 0, -180, 0, (005 << 16), id_bhvMessagePanel),
		OBJECT(E_MODEL_STAR, -7359, 4026, 231, 0, 0, 0, (0 << 24), id_bhvStar),
		OBJECT(E_MODEL_NONE, -10333, -3311, -649, 0, 90, 0, (1 << 24), id_bhvKoopOfTheQuick),
		OBJECT(E_MODEL_STAR, 11, 4642, -5929, 0, 0, 0, (2 << 24), id_bhvStar),
		OBJECT(E_MODEL_NONE, -7810, -3311, -638, 0, 0, 0, (3 << 24), id_bhvHiddenRedCoinStar),
		OBJECT(E_MODEL_STAR, 20152, -1835, -22561, 0, 0, 0, (4 << 24), id_bhvStar),
		OBJECT(E_MODEL_STAR, -24596, -3036, 20152, 0, 0, 0, (4 << 24), id_bhvStar),
		OBJECT(MODEL_NONE, -5170, -3756, -11, 0, 0, 0, (0xA << 16), bhvSpinAirborneWarp),
		TERRAIN(bob_area_1_collision),
		MACRO_OBJECTS(bob_area_1_macro_objs),
		SET_BACKGROUND_MUSIC(0x00, SEQ_LEVEL_KOOPA_ROAD),
		TERRAIN_TYPE(TERRAIN_STONE),
		/* Fast64 begin persistent block [area commands] */
		/* Fast64 end persistent block [area commands] */
	END_AREA(),

	FREE_LEVEL_POOL(),
	MARIO_POS(0x01, 0, -5170, -3756, -11),
	CALL(0, lvl_init_or_update),
	CALL_LOOP(1, lvl_init_or_update),
	CLEAR_LEVEL(),
	SLEEP_BEFORE_EXIT(1),
	EXIT(),
};
