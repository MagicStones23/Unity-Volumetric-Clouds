using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using static UnityEditor.MaterialProperty;

public class VolumetricCloudsRenderFeature : ScriptableRendererFeature {
    public VolumetricCloudsRenderPassSetting setting;

    private VolumetricCloudsRenderPass pass;

    public override void Create() {

    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData) {
        if (renderingData.cameraData.camera.name != "Main Camera")
            return;

        if (pass == null)
            pass = new VolumetricCloudsRenderPass(setting);

        renderer.EnqueuePass(pass);
    }
}