using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable]
public class VolumetricCloudsRenderPassSetting {
    public RenderPassEvent renderPassEvent;
    public int cloudDownSample = 2;
    public Material cloudRenderingMaterial;
    public Material bilateralBlurMaterial;
    public Material taaBlendMaterial;
    public Material finalBlendMaterial;
    public int bilateralBlurIteration = 0;
    public int bilateralBlurDownSample = 1;
}