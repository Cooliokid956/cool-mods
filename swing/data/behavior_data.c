const BehaviorScript bhvSlingEnd[] = {
    BEGIN(OBJ_LIST_DEFAULT),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    SCALE(0, 0),
    SET_INT(oHealth, 100),
    BEGIN_LOOP(),
        CALL_NATIVE(bhv_sling_end_loop),
    END_LOOP(),
};

const BehaviorScript bhvSlingLine[] = {
    BEGIN(OBJ_LIST_DEFAULT),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    SCALE(0, 0),
    SET_INT(oHealth, 100),
    BEGIN_LOOP(),
        CALL_NATIVE(bhv_sling_line_loop),
    END_LOOP(),
};
