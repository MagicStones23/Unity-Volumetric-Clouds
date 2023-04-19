Shader "Tool/Skybox"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        [HDR] _MainColor ("MainColor", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Tags { "Queue"="Geometry" "LightMode"="UniversalForward" "RenderPipeline"="UniversalPipeline" }
    
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct VertexInput
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct VertexOutput
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
            };
            
            sampler2D _MainTex;
            float4 _MainColor;

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                return o;
            }
            
            float4 frag(VertexOutput i) : SV_Target
            {
                return _MainColor;
            }
            ENDHLSL            
        }
    }
}