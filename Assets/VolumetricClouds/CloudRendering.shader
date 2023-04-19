Shader "Tutorial/CloudRendering"
{
    Properties
    {
        _BaseColor ("BaseColor", Color) = (1, 1, 1, 1)

        _LightPower ("LightPower", Float) = 1

        _RimColor0 ("RimColor0", Color) = (1, 1, 1, 1)
        _RimPower0 ("RimPower0", Float) = 4

        _DarkColor ("DarkColor", Color) = (0, 0, 0, 1)
        _DarkPower ("DarkPower", Float) = 4

        _ForwardScatteringPower ("ForwardScatteringPower", Float) = 1
    }
    SubShader
    {
        Pass
        {
            Tags { "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" "LightMode"="UniversalForward" }

            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct VertexInput
            {
                float4 vertex : POSITION;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            float4 _BaseColor;

            float _LightPower;

            float4 _RimColor0;
            float _RimPower0;
            
            float4 _DarkColor;
            float _DarkPower;

            float _ForwardScatteringPower;

            float3 _LightDir;
            float4 _LightColor;
            sampler2D _CurrentCameraTarget0;
            sampler2D _CurrentCameraTarget1;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;

                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.screenPos = o.vertex;
                #if UNITY_UV_STARTS_AT_TOP
                o.screenPos.y *= -1;
                #endif

                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                i.screenPos.xyz /= i.screenPos.w;
                float2 screenUV = i.screenPos.xy;
                screenUV = (screenUV + 1) / 2;

                float4 renderRT0 = tex2D(_CurrentCameraTarget0, screenUV);
                float4 renderRT1 = tex2D(_CurrentCameraTarget1, screenUV);

                float cloudDensity = renderRT0.a;
                float3 cloudPos = renderRT0.xyz;
                float lightIntensity = renderRT1.a;

                lightIntensity = pow(lightIntensity, _LightPower);

                float4 rimColor0 = _RimColor0 * pow(lightIntensity, _RimPower0) * 2;

                float4 darkColor = lerp(1, _DarkColor, pow(1 - lightIntensity, _DarkPower));

                float3 viewDir = normalize(cloudPos - _WorldSpaceCameraPos.xyz);

                float forwardScattering = saturate(dot(viewDir, _LightDir));
                forwardScattering = pow(forwardScattering, _ForwardScatteringPower);

                float4 color = _BaseColor;
                color.rgb *= lerp(0, 1, lightIntensity);
                color.rgb += rimColor0.rgb;
                color.rgb *= darkColor;
                color.rgb += _LightColor.rgb * forwardScattering;
                color.a = cloudDensity;
                
                return color;
            }
            ENDHLSL
        }
    }
}