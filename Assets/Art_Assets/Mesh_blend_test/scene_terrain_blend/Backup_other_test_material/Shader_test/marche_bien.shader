Shader "Custom/URP/RockTerrainBlend_UE_SEAMLESS"
{
    Properties
    {
        _RockTex ("Rock Albedo", 2D) = "white" {}
        _RockNormal ("Rock Normal", 2D) = "bump" {}

        _GroundTex ("Ground Texture", 2D) = "white" {}
        _GroundNormal ("Ground Normal", 2D) = "bump" {}

        _RockTiling ("Rock Tiling", Float) = 1
        _GroundTiling ("Ground Tiling", Float) = 1

        _TerrainHeight ("Terrain Height", Float) = 0
        _BlendDistance ("Blend Distance", Float) = 2

        _ContactSoftness ("Contact Softness", Float) = 2
        _SlopeStrength ("Slope Strength", Float) = 2

        _MossStrength ("Moss Strength", Float) = 0.6
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            TEXTURE2D(_RockTex);
            SAMPLER(sampler_RockTex);

            TEXTURE2D(_RockNormal);
            SAMPLER(sampler_RockNormal);

            TEXTURE2D(_GroundTex);
            SAMPLER(sampler_GroundTex);

            TEXTURE2D(_GroundNormal);
            SAMPLER(sampler_GroundNormal);

            float _RockTiling;
            float _GroundTiling;

            float _TerrainHeight;
            float _BlendDistance;
            float _ContactSoftness;
            float _SlopeStrength;
            float _MossStrength;

            Varyings vert(Attributes v)
            {
                Varyings o;

                float3 world = TransformObjectToWorld(v.positionOS.xyz);

                o.worldPos = world;
                o.worldNormal = TransformObjectToWorldNormal(v.normalOS);

                o.positionHCS = TransformWorldToHClip(world);

                o.uv = v.uv;

                return o;
            }

            float3 BlendNormals(float3 a, float3 b)
            {
                return normalize(a + b);
            }

            half4 frag(Varyings i) : SV_Target
            {
                float3 nWorld = normalize(i.worldNormal);

                // =========================
                // UVs
                // =========================

                float2 rockUV = i.uv * _RockTiling;
                float2 groundUV = i.uv * _GroundTiling;

                // =========================
                // TEXTURES
                // =========================

                float3 rock =
                    SAMPLE_TEXTURE2D(_RockTex, sampler_RockTex, rockUV).rgb;

                float3 ground =
                    SAMPLE_TEXTURE2D(_GroundTex, sampler_GroundTex, groundUV).rgb;

                float3 rockN =
                    UnpackNormal(SAMPLE_TEXTURE2D(_RockNormal, sampler_RockNormal, rockUV));

                float3 groundN =
                    UnpackNormal(SAMPLE_TEXTURE2D(_GroundNormal, sampler_GroundNormal, groundUV));

                // =========================
                // HEIGHT CONTACT (BASE)
                // =========================

                float dist =
                    abs(i.worldPos.y - _TerrainHeight);

                float baseBlend =
                    saturate(1.0 - dist / _BlendDistance);

                baseBlend =
                    smoothstep(0.0, 1.0, baseBlend);

                // =========================
                // 🔥 SEAMLESS FIX #1
                // soft intersection band (UE-style feathering)
                // =========================

                float contactBand =
                    1.0 - smoothstep(0.0, _ContactSoftness, dist);

                // =========================
                // 🔥 SEAMLESS FIX #2
                // slope tightening (prevents floating edges)
                // =========================

                float slope =
                    saturate(dot(nWorld, float3(0,1,0)));

                float slopeMask =
                    pow(slope, _SlopeStrength);

                // =========================
                // FINAL BLEND MASK
                // =========================

                float blend =
                    baseBlend * contactBand * slopeMask;

                blend = saturate(blend);

                // =========================
                // MOSSS
                // =========================

                ground = lerp(
                    ground,
                    float3(0.12,0.25,0.08),
                    blend * _MossStrength
                );

                // =========================
                // NORMAL BLEND
                // =========================

                float3 finalNormal =
                    BlendNormals(groundN, rockN * blend);

                // =========================
                // LIGHT
                // =========================

                float3 lightDir = normalize(float3(0.4,1,0.3));

                float NdotL =
                    saturate(dot(finalNormal, lightDir));

                float lighting =
                    NdotL * 0.8 + 0.2;

                // =========================
                // FINAL COLOR
                // =========================

                float3 col =
                    lerp(ground, rock, blend);

                col *= lighting;

                return float4(col,1);
            }

            ENDHLSL
        }
    }
}