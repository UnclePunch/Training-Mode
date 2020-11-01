#ifndef MEX_H_INLINE
#define MEX_H_INLINE

#include "structs.h"
#include "fighter.h"
#include "obj.h"
#include "mex.h"
#include "datatypes.h"
#include "hsd.h"
#include "math.h"
#include "useful.h"

/*** Functions ***/

static float fabs(float x)
{
    if (x < 0)
    {
        return -x;
    }
    return x;
}

static int abs(int x)
{
    if (x < 0)
    {
        return -x;
    }
    return x;
}

static void enterKnockback(GOBJ *fighter, int angle, float mag)
{
    FighterData *fighter_data = ((FighterData *)fighter->userdata);

    // store damage variables
    fighter_data->dmg.force_applied = mag;
    fighter_data->dmg.kb_angle = angle;
    fighter_data->dmg.direction = fighter_data->facing_direction;
    fighter_data->dmg.damaged_hurtbox = 0;
    fighter_data->dmg.dealt = 0;
    fighter_data->dmg.collpos.X = fighter_data->phys.pos.X;
    fighter_data->dmg.collpos.Y = fighter_data->phys.pos.Y;
    fighter_data->dmg.collpos.Z = fighter_data->phys.pos.Z;

    Fighter_EnterDamageState(fighter, -1, 0);

    return;
}

static void null()
{
    return;
}

static void __attribute__((optimize("O0"))) PRIM_DRAW(PRIM *gx, float x, float y, float z, int color)
{
    AS_FLOAT(gx->data) = x;
    AS_FLOAT(gx->data) = y;
    AS_FLOAT(gx->data) = z;
    gx->data = color;
    return;
}

static void C_QUATMtx(Vec4 *r, Mtx m)
{
    /*---------------------------------------------------------------------------*
   Name:         QUATMtx

   Description:  Converts a matrix to a unit quaternion.

   Arguments:    r   - result quaternion
                m   - the matrix

   Returns:      NONE
    *---------------------------------------------------------------------------*/

    float tr, s;
    int i, j, k;
    int nxt[3] = {1, 2, 0};
    float q[3];

    tr = m[0][0] + m[1][1] + m[2][2];
    if (tr > 0.0f)
    {
        s = (float)sqrtf(tr + 1.0f);
        r->W = s * 0.5f;
        s = 0.5f / s;
        r->X = (m[1][2] - m[2][1]) * s;
        r->Y = (m[2][0] - m[0][2]) * s;
        r->Z = (m[0][1] - m[1][0]) * s;
    }
    else
    {
        i = 0;
        if (m[1][1] > m[0][0])
            i = 1;
        if (m[2][2] > m[i][i])
            i = 2;
        j = nxt[i];
        k = nxt[j];
        s = (float)sqrtf((m[i][i] - (m[j][j] + m[k][k])) + 1.0f);
        q[i] = s * 0.5f;

        if (s != 0.0f)
            s = 0.5f / s;

        r->W = (m[j][k] - m[k][j]) * s;
        q[j] = (m[i][j] + m[j][i]) * s;
        q[k] = (m[i][k] + m[k][i]) * s;

        r->X = q[0];
        r->Y = q[1];
        r->Z = q[2];
    }
}

static HSD_Pad *PadGet(int playerIndex, int padType)
{
    HSD_Pads *pads;

    // get the correct pad
    if (padType == PADGET_MASTER)
        pads = 0x804c1fac;
    else if (padType == PADGET_ENGINE)
        pads = 0x804c21cc;

    return (&pads->pad[playerIndex]);
}

static float lerp(Translation *anim, float currFrame)
{
    float prevFrame, prevPos, nextFrame, nextPos, amt;

    // get previous threshold
    int i = 0;
    prevFrame = anim[i].frame;
    prevPos = anim[i].value;
    nextFrame = anim[i + 1].frame;
    nextPos = anim[i + 1].value;
    while ((currFrame < prevFrame) | (currFrame > nextFrame))
    {
        i++;
        prevFrame = anim[i].frame;
        prevPos = anim[i].value;
        nextFrame = anim[i + 1].frame;
        nextPos = anim[i + 1].value;
    }

    // get amt
    amt = (currFrame - prevFrame) / (nextFrame - prevFrame);

    return amt * (nextPos - prevPos) + prevPos;
}

static float JOBJ_GetAnimFrame(JOBJ *joint)
{
    // check for AOBJ in jobj
    JOBJ *jobj;
    jobj = joint;
    while (jobj != 0)
    {
        if (jobj->aobj != 0)
        {
            return jobj->aobj->curr_frame;
        }

        // check for AOBJ in dobj
        DOBJ *dobj;
        dobj = jobj->dobj;
        while (dobj != 0)
        {
            if (dobj->aobj != 0)
            {
                return dobj->aobj->curr_frame;
            }

            // check for AOBJ in mobj
            MOBJ *mobj;
            mobj = dobj->mobj;
            if (mobj->aobj != 0)
            {
                return mobj->aobj->curr_frame;
            }

            // check for AOBJ in tobj
            TOBJ *tobj;
            tobj = mobj->tobj;
            while (tobj != 0)
            {
                if (tobj->aobj != 0)
                {
                    return tobj->aobj->curr_frame;
                }
                tobj = tobj->next;
            }

            dobj = dobj->next;
        }

        jobj = jobj->child;
    }

    // no aobj found, return -1
    return -1;
}

static AOBJ *JOBJ_GetFirstAOBJ(JOBJ *jobj)
{
    // check for AOBJ in this jobj

    if (jobj->aobj != 0)
    {
        return jobj->aobj;
    }
    // check for AOBJ in dobj
    DOBJ *dobj;
    dobj = jobj->dobj;
    while (dobj != 0)
    {
        if (dobj->aobj != 0)
        {
            return dobj->aobj;
        }

        // check for AOBJ in mobj
        MOBJ *mobj;
        mobj = dobj->mobj;
        if (mobj->aobj != 0)
        {
            return mobj->aobj;
        }

        // check for AOBJ in tobj
        TOBJ *tobj;
        tobj = mobj->tobj;
        while (tobj != 0)
        {
            if (tobj->aobj != 0)
            {
                return tobj->aobj;
            }
            tobj = tobj->next;
        }

        dobj = dobj->next;
    }

    // this jobj doesnt have an aobj, check the child
    if (jobj->child != 0)
    {
        AOBJ *aobj = JOBJ_GetFirstAOBJ(jobj->child);
        if (aobj != 0)
            return aobj;
    }

    // child did not have an aobj, check the sibling
    if (jobj->sibling != 0)
    {
        AOBJ *aobj = JOBJ_GetFirstAOBJ(jobj->sibling);
        if (aobj != 0)
            return aobj;
    }

    // no aobj found, return 0
    return 0;
}

static AOBJ *JOBJ_GetJointAOBJ(JOBJ *jobj)
{
    // check for AOBJ in this jobj

    if (jobj->aobj != 0)
    {
        return jobj->aobj;
    }

    // this jobj doesnt have an aobj, check the child
    if (jobj->child != 0)
    {
        AOBJ *aobj = JOBJ_GetJointAOBJ(jobj->child);
        if (aobj != 0)
            return aobj;
    }

    // child did not have an aobj, check the sibling
    if (jobj->sibling != 0)
    {
        AOBJ *aobj = JOBJ_GetJointAOBJ(jobj->sibling);
        if (aobj != 0)
            return aobj;
    }

    // no aobj found, return 0
    return 0;
}

static DOBJ *JOBJ_GetDObjChild(JOBJ *joint, int dobj_index)
{

    int count = 0;
    DOBJ *dobj = joint->dobj;

    while (count < dobj_index)
    {
        if (dobj->next == 0)
            assert("dobj not found!");

        else
            dobj = dobj->next;

        count++;
    }

    return dobj;
}

static float Math_Vec2Angle(Vec2 *a, Vec2 *b)
{
    // get angle
    // float angle = atan((b->Y - a->Y) / (b->X - a->X));
    float angle = atan2((b->Y - a->Y), (b->X - a->X));

    /*
    //Ensure above 0 and below 6.28319
    while (angle < 0)
    {
        angle += M_PI;
    }
    while (angle > M_PI * 2)
    {
        angle -= M_PI;
    }
    */

    return angle;
}

static float Math_Vec2Distance(Vec2 *a, Vec2 *b)
{
    return sqrtf(pow((a->X - b->X), 2) + pow((a->Y - b->Y), 2));
}

static float Math_Vec3Distance(Vec3 *a, Vec3 *b)
{
    return sqrtf(pow((a->X - b->X), 2) + pow((a->Y - b->Y), 2));
}

#endif
