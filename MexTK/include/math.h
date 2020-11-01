#ifndef MEX_H_MATH
#define MEX_H_MATH

#include "structs.h"
#include "datatypes.h"

#define M_PI 3.14159265358979323846
#define M_1DEGREE 0.0174533

/*** Functions ***/

float atan(float in);
float atan2(float y, float x);
float sin(float x);
float cos(float x);
void MTXLookAt(Mtx *dest, Vec3 *eye, Vec3 *up, Vec3 *target);
void VECNormalize(Vec3 *src, Vec3 *dest);
void VECAdd(Vec3 *a, Vec3 *b, Vec3 *ab);
void VECSubtract(Vec3 *a, Vec3 *b, Vec3 *a_b);
void VECMultAndAdd(Vec3 *a, Vec3 *b);
float VECDotProduct(Vec3 *a, Vec3 *b);
void VECCrossProduct(Vec3 *a, Vec3 *b, Vec3 *axb);
void MTXQuat(Vec4 *dest, Mtx *m);
void HSD_MtxGetRotation(Mtx *m, Vec3 *dest);
void MatToQuat(Mtx *m, Vec3 *dest);
float sqrtf(float num);
void MTXRotRad(Mtx m, char axis, f32 rad);

#endif
