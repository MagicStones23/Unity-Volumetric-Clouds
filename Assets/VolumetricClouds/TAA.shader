Shader "Tutorial/TAA"
{
    Properties
    {
        _PreviousCloudColor ("PreviousCloudColor", 2D) = "white" {}
        _CurrentCloudColor ("CurrentCloudColor", 2D) = "white" {}
        _BlendSpeed ("BlendSpeed", Range(0, 1)) = 0.05
    }
    SubShader
    {
        Pass
        {
            Tags { "Queue"="Opaque" "RenderPipeline"="UniversalPipeline" "LightMode"="UniversalForward" }

            ZWrite Off
            ZTest Always

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            int _HasCameraChanged;
            sampler2D _CurrentCameraTarget0;
            sampler2D _CurrentCameraTarget1;
            sampler2D _CurrentCloudColor;
            sampler2D _PreviousCameraTarget0;
            sampler2D _PreviousCloudColor;
            float4x4 _PreviousCameraVP;
            float _BlendSpeed;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 currentTarget0 = tex2D(_CurrentCameraTarget0, i.uv);
                float4 currentTarget1 = tex2D(_CurrentCameraTarget1, i.uv);

                float3 cloudPos = currentTarget0.xyz;
                float3 cloudMotionVector = currentTarget1.xyz;

                float blend = _BlendSpeed;
                float4 previousScreenUV = float4(i.uv, 0, 0);

                if(_HasCameraChanged) {
                    previousScreenUV = float4(cloudPos - cloudMotionVector, 1);
                    previousScreenUV = mul(_PreviousCameraVP, previousScreenUV);
                    previousScreenUV.xyz /= previousScreenUV.w;
                    previousScreenUV.xy = (previousScreenUV.xy + 1) / 2;

                    if(previousScreenUV.x < 0 || previousScreenUV.x > 1 || previousScreenUV.y < 0 || previousScreenUV.y > 1) {
                        blend = 1;
                    }
                
                    float4 previousTarget0 = tex2D(_PreviousCameraTarget0, previousScreenUV);
                    float3 previousCloudPos = previousTarget0.xyz;
                    
                    if(distance(cloudPos, previousCloudPos) > 1) {
                        blend = 1;
                    }
                }

                float4 previousColor = tex2D(_PreviousCloudColor, previousScreenUV);
                float4 currentColor = tex2D(_CurrentCloudColor, i.uv);
                float4 finalColor = lerp(previousColor, currentColor, blend);
                return finalColor;
            }
            ENDHLSL
        }
    }
}