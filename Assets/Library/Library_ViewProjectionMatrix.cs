using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public partial class Library {
    public static Matrix4x4 GetViewProjectionMatrix(Camera cam) {
        return GL.GetGPUProjectionMatrix(cam.projectionMatrix, false) * cam.worldToCameraMatrix;
    }

    public static Matrix4x4 GetInverseViewProjectionMatrix(Camera cam) {
        return cam.cameraToWorldMatrix * GL.GetGPUProjectionMatrix(cam.projectionMatrix, false).inverse;
    }
}