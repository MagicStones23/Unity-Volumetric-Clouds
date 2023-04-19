Shader "Tool/BilateralBlur"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}

        _BlurRadius("BlurRadius", Float) = 25
        _SpatialWeight("SpatialWeight", Float) = 10
        _TonalWeight("TonalWeight", Float) = 0.1
    }

    SubShader
    {
        Pass
        {
            Tags { "Queue"="Geometry" "LightMode"="UniversalForward" "RenderPipeline"="UniversalPipeline" }
    
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
            float4 _MainTex_TexelSize;

            float _BlurRadius;
            float _SpatialWeight;
            float _TonalWeight;

            #define TAU (PI * 2.0)

            float GaussianWeight(float d, float sigma) {
                return 1.0 / (sigma * sqrt(TAU)) * exp(-(d * d) / (2.0 * sigma * sigma));
            }

            float4 GaussianWeight(float4 d, float sigma) {
                return 1.0 / (sigma * sqrt(TAU)) * exp(-(d * d) / (2.0 * sigma * sigma));
            }

            float4 BilateralWeight(float2 currentUV, float2 centerUV, float4 currentColor, float4 centerColor) {
                float spacialDifference = length(centerUV - currentUV);
                float4 tonalDifference = centerColor - currentColor;
                return GaussianWeight(spacialDifference, _SpatialWeight) * GaussianWeight(tonalDifference, _TonalWeight);
            }

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                return o;
            }
            
            float4 frag(VertexOutput i) : SV_Target
            {
                float4 numerator = float4(0, 0, 0, 0);
                float4 denominator = float4(0, 0, 0, 0);

                float4 centerColor = tex2D(_MainTex, i.uv);

                for (int iii = -1; iii <= 1; iii++) {
                    for (int jjj = -1; jjj <= 1; jjj++) {
                        float2 offset = float2(iii, jjj) * _BlurRadius;

                        float2 currentUV = i.uv + offset * _MainTex_TexelSize.xy;
                        float4 currentColor = tex2D(_MainTex, currentUV);

                        float4 weight = BilateralWeight(currentUV, i.uv, currentColor, centerColor);
                        numerator += currentColor * weight;
                        denominator += weight;
                    }
                }

                return numerator / denominator;
            }
            ENDHLSL            
        }
    }
}