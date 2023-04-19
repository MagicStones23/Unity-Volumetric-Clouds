Shader "Tutorial/CloudMarching"
{
    Properties
    {
        _BlueNoise ("BlueNoise", 2D) = "black" {}
        _BlueNoiseScale ("BlueNoiseScale", Range(0, 6)) = 1

        [NoScaleOffset] _HeightCurveA ("HeightCurveA", 2D) = "white" {}
        [NoScaleOffset] _HeightCurveB ("HeightCurveB", 2D) = "white" {}

        [NoScaleOffset] _Noise2Da ("Noise2Da", 2D) = "white" {}
        _Noise2DaTile ("Noise2DaTile", Vector) = (1, 1, 1, 1)
        _Noise2DaSpeed ("Noise2DaSpeed", Vector) = (0, 0, 0, 0)

        [NoScaleOffset] _Noise2Db ("Noise2Db", 2D) = "white" {}
        _Noise2DbTile ("Noise2DbTile", Vector) = (1, 1, 1, 1)

        [NoScaleOffset] _Noise3Da ("Noise3Da", 3D) = "white" {}
        _Noise3DaTile ("Noise3DaTile", Vector) = (1, 1, 1, 1)
        _Noise3DaSpeed ("Noise3DaSpeed", Vector) = (0, 0, 0, 0)
     
        [NoScaleOffset] _Noise3Db ("Noise3Db", 3D) = "white" {}
        _Noise3DbTile ("Noise3DbTile", Vector) = (1, 1, 1, 1)

        _NoiseCullThreshold ("NoiseCullThreshold", Range(0, 1)) = 0

        _DensityScale ("DensityScale", Range(0, 6)) = 1
        _DensityStepLength ("DensityStepLength", Range(0, 3)) = 0.25
        _DensityIteration ("DensityIteration", Range(1, 256)) = 8
     
        _LightScale ("LightScale", Range(0, 6)) = 1
        _LightStepLength ("LightStepLength", Range(0, 3)) = 0.25
        _LightIteration ("LightIteration", Range(1, 64)) = 8
        
        [NoScaleOffset] _LightAttenuationCurve ("LightAttenuationCurve", 2D) = "white" {}

        _CloudEstimatePosLerp ("CloudEstimatePosLerp", Range(0, 1)) = 0
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Library/RayBoxDistance.hlsl"

            struct VertexInput
            {
                float4 vertex : POSITION;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            struct FragmentOutput
            {
                float4 color0 : SV_Target0;
                float4 color1 : SV_Target1;
            };

            sampler2D _BlueNoise;
            float4 _BlueNoise_ST;
            float _BlueNoiseScale;

            sampler2D _HeightCurveA;
            sampler2D _HeightCurveB;

            sampler2D _Noise2Da;
            float4 _Noise2DaTile;
            float4 _Noise2DaSpeed;

            sampler2D _Noise2Db;
            float4 _Noise2DbTile;

            sampler3D _Noise3Da;
            float4 _Noise3DaTile;
            float4 _Noise3DaSpeed;

            sampler3D _Noise3Db;
            float4 _Noise3DbTile;

            float _NoiseCullThreshold;

            float _DensityScale;
            float _DensityStepLength;
            int _DensityIteration;

            float _LightScale;
            float _LightStepLength;
            int _LightIteration;
            sampler2D _LightAttenuationCurve;

            float _CloudEstimatePosLerp;

            float3 _LightDir;
            float3 _BoundMin;
            float3 _BoundMax;

            bool IsOutOfBound(float3 worldPos) {
                if(worldPos.x > _BoundMax.x || worldPos.x < _BoundMin.x)
                    return true;

                if(worldPos.y > _BoundMax.y || worldPos.y < _BoundMin.y)
                    return true;

                if(worldPos.z > _BoundMax.z || worldPos.z < _BoundMin.z)
                    return true;

                return false;
            }

            float SampleNoiseDensity(float3 worldPos) {
                float noise = 0;

                float4 heightCurveUV = 0;
                heightCurveUV.x = (worldPos.y - _BoundMin.y) / (_BoundMax.y - _BoundMin.y);
                float heightCurveA = tex2Dlod(_HeightCurveA, heightCurveUV);
                float heightCurveB = tex2Dlod(_HeightCurveB, heightCurveUV);

                float4 noise2DbUV = float4(worldPos.xz, 0, 0);
                noise2DbUV.xy *= _Noise2DbTile.xy * _Noise2DbTile.w;
                float noise2Db = tex2Dlod(_Noise2Db, noise2DbUV);

                float heightCurve = lerp(heightCurveA, heightCurveB, noise2Db);

                if(heightCurve == 0) {
                    return 0;
                }

                float4 noise2DaUV = float4(worldPos.xz, 0, 0);
                noise2DaUV.xy += _Noise2DaSpeed.xy * _Time.y;
                noise2DaUV.xy *= _Noise2DaTile.xy * _Noise2DaTile.w;
                noise += tex2Dlod(_Noise2Da, noise2DaUV) * 0.55;

                float4 noise3DaUV = float4(worldPos, 0);
                noise3DaUV.xyz += _Noise3DaSpeed.xyz * _Time.y;
                noise3DaUV.xyz *= _Noise3DaTile.xyz * _Noise3DaTile.w;
                noise += tex3Dlod(_Noise3Da, noise3DaUV) * 0.25;

                float4 noise3DbUV = float4(worldPos * _Noise3DbTile.xyz * _Noise3DbTile.w, 0);
                noise += tex3Dlod(_Noise3Db, noise3DbUV) * 0.2;

                noise *= heightCurve;

                if(noise < _NoiseCullThreshold) {
                    noise = 0;
                }

                return noise;
            }

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;

                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.screenPos = o.vertex;
                #if UNITY_UV_STARTS_AT_TOP
                o.screenPos.y *= -1;
                #endif

                return o;
            }

            FragmentOutput frag (VertexOutput i)
            {
                i.screenPos.xyz /= i.screenPos.w;
                float2 screenUV = i.screenPos.xy;
                screenUV = (screenUV + 1) / 2;

                float2 blueNoiseUV = (screenUV + _Time.yy * 11.1) * _BlueNoise_ST.xy;
                float blueNoise = tex2D(_BlueNoise, blueNoiseUV);

                float3 rayStart = i.worldPos;
                float3 rayDir = normalize(i.worldPos - _WorldSpaceCameraPos.xyz);

                float3 inPos;
                float3 outPos;
                RayBoxDistance(_BoundMin, _BoundMax, rayStart, rayDir * 1000, inPos, outPos);

                float cloudDensity = 0;
                float lightIntensity = 0;
                float volumetricLightIntensity = 0;
                float3 cloudStartPos = -999999;
                float3 cloudEndPos = -999999;

                float maxDensityLength = distance(inPos, outPos);

                for(int iii = 0; iii < _DensityIteration; iii++) {
                    float densityLength = (iii + blueNoise * _BlueNoiseScale) * _DensityStepLength;
                    if(densityLength > maxDensityLength) {
                        break;
                    }
                    
                    float3 densityStepPos = inPos + rayDir * densityLength;
                    
                    if(IsOutOfBound(densityStepPos)){
                        break;
                    }

                    float stepCloudDensity = SampleNoiseDensity(densityStepPos) * _DensityScale;
                    if(stepCloudDensity == 0){
                        continue;
                    }

                    if(cloudDensity == 0) {
                        cloudStartPos = densityStepPos;
                    }

                    cloudEndPos = densityStepPos;
                    cloudDensity = saturate(cloudDensity + stepCloudDensity);
                    
                    float depth = 0;
                    for(int jjj = 0; jjj < _LightIteration; jjj++) {
                        if(lightIntensity >= 1)
                            break;

                        float lightLength = (jjj + blueNoise * _BlueNoiseScale) * _LightStepLength;
                        
                        float3 lightMarchPos = densityStepPos + _LightDir * lightLength;
                        if(IsOutOfBound(lightMarchPos)) 
                            break;

                        depth += SampleNoiseDensity(lightMarchPos);
                    }

                    depth /= _LightIteration;

                    float lightInAttenuation = tex2Dlod(_LightAttenuationCurve, float4(depth, 0, 0, 0)); 
                    float lightOutAttenuation = tex2Dlod(_LightAttenuationCurve, float4(cloudDensity, 0, 0, 0)); 
                    lightOutAttenuation = pow(lightOutAttenuation, 2);
                    lightIntensity += lightInAttenuation * lightOutAttenuation * _LightScale;
                    lightIntensity = saturate(lightIntensity);

                    if(cloudDensity >= 1)
                        break;
                }

                float3 cloudEstimatePos = lerp(cloudStartPos, cloudEndPos, _CloudEstimatePosLerp);
                float3 cloudEstimateMotionVector = (_Noise3DaSpeed + float3(_Noise2DaSpeed.x, 0, _Noise2DaSpeed.y)) * _Time.y;

                FragmentOutput output = (FragmentOutput)0;
                output.color0 = float4(cloudEstimatePos, cloudDensity);
                output.color1 = float4(cloudEstimateMotionVector, lightIntensity);

                return output;
            }
            ENDHLSL
        }
    }
}