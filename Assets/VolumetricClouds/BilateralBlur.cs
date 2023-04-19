using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class BilateralBlur {
    private RenderTexture tempRT0;
    private RenderTexture tempRT1;

    public void Blur(Material material, CommandBuffer cmd, RenderTexture target, int downsample, int iteration) {
        CreateResources(target, downsample);

        RenderTexture currentRT = tempRT0;
        RenderTexture nextRT = tempRT1;

        cmd.Blit(target, currentRT);

        for (int i = 0; i < iteration; i++) {
            cmd.Blit(currentRT, nextRT, material);

            RenderTexture swithRT = currentRT;
            currentRT = nextRT;
            nextRT = swithRT;
        }

        cmd.Blit(currentRT, target);
    }

    public void CreateResources(RenderTexture target, int downsample) {
        RenderTextureDescriptor descriptor = target.descriptor;
        descriptor.width /= downsample;
        descriptor.height /= downsample;

        if (tempRT0 != null && tempRT0.width == descriptor.width && tempRT0.height == descriptor.height) {
            return;
        }

        ReleaseResources();

        tempRT0 = RenderTexture.GetTemporary(descriptor);
        tempRT0.filterMode = FilterMode.Point;
        tempRT0.wrapMode = TextureWrapMode.Clamp;
        tempRT1 = RenderTexture.GetTemporary(descriptor);
        tempRT1.filterMode = FilterMode.Point;
        tempRT1.wrapMode = TextureWrapMode.Clamp;
    }

    public void ReleaseResources() {
        if (tempRT0 != null) {
            tempRT0.Release();
        }

        if (tempRT1 != null) {
            tempRT1.Release();
        }
    }
}