#include "lab.h"

void OnCSSLoad(ArchiveInfo *archive)
{
    EventVars *event_vars = *event_vars_ptr;

    // get assets from this file
    Arch_ImportData *import_assets = File_GetSymbol(archive, "importData");

    // Create GOBJ
    GOBJ *button_gobj = GObj_Create(0, 7, 0);
    void *button_data = calloc(sizeof(MsgData));
    GObj_AddUserData(button_gobj, 4, HSD_Free, button_data);
    GObj_AddGXLink(button_gobj, GXLink_Common, 1, 128);
    GObj_AddProc(button_gobj, Button_Think, 0);
    JOBJ *button_jobj = JOBJ_LoadJoint(import_assets->import_button);
    GObj_AddObject(button_gobj, R13_U8(-0x3E55), button_jobj);

    // scale message jobj
    Vec3 *scale = &button_jobj->scale;

    // Create text object
    Text *button_text = Text_CreateText(0, 0);
    button_text->kerning = 1;
    button_text->align = 1;
    button_text->use_aspect = 1;
    button_text->scale.X = (scale->X * 0.01) * 3;
    button_text->scale.Y = (scale->Y * 0.01) * 3;
    button_text->trans.X = button_jobj->trans.X + (0 * (scale->X / 4.0));
    button_text->trans.Y = (button_jobj->trans.Y * -1) + (-1.6 * (scale->Y / 4.0));
    Text_AddSubtext(button_text, 0, 0, "Import");

    return;
}

void Button_Think(GOBJ *button_gobj)
{
    return;
}