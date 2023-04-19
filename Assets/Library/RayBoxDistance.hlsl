#ifndef RayBoxDis
#define RayBoxDis

float2 RayBoxDistance(float3 boundsMin, float3 boundsMax, float3 rayOrigin, float3 invRay) {
    float3 t0 = (boundsMin - rayOrigin) * invRay;
    float3 t1 = (boundsMax - rayOrigin) * invRay;
    float3 tmin = min(t0, t1);
    float3 tmax = max(t0, t1);

    float dstA = max(max(tmin.x, tmin.y), tmin.z);
    float dstB = min(tmax.x, min(tmax.y, tmax.z));

    float dstToBox = max(0, dstA);
    float dstInsideBox = max(0, dstB - dstToBox);

    return float2(dstToBox, dstInsideBox);
}

float RayBoxDistance(float3 boundsMin, float3 boundsMax, float3 rayOrigin, float3 ray, out float3 inPos, out float3 outPos) {
    float3 invRay = 1.0 / ray;

    float2 rayBoxDst = RayBoxDistance(boundsMin, boundsMax, rayOrigin, invRay);

    inPos = rayOrigin + ray * rayBoxDst.x;
    outPos = inPos + ray * rayBoxDst.y;

    if (rayBoxDst.x > 1)
        return 0;
        
    if (rayBoxDst.x + rayBoxDst.y > 1)
        outPos = rayOrigin + ray;

    if (rayBoxDst.y == 0)
        return 0;

    return 1;
}

#endif