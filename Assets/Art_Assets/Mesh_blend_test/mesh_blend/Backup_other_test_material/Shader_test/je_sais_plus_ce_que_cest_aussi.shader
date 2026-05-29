Shader "Custom/URP/RockTerrainBlend_FINAL"
{
    Properties
    {
        _RockTex ("Rock Albedo", 2D) = "white" {}
        _RockNormal ("Rock Normal", 2D) = "bump" {}
        _RockHeight ("Rock Height", 2D) = "gray" {}
        _RockAO ("Rock AO", 2D) = "white" {}

        _TerrainTex ("Terrain Albedo", 2D) = "white" {}
        _TerrainNormal ("Terrain Normal", 2D) = "bump" {}
        _TerrainAO ("Terrain AO", 2D) = "white" {}

        _TerrainHeight ("Terrain Height", Float) = 0
        _BlendDistance ("Blend Distance", Float) = 1
        _Tiling ("Terrain Tiling", Float) = 0.1

        _HeightStrength ("Height Strength", Float) = 0.1
        _AOStrength ("AO Strength", Float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            // 🪨 ROCK
            TEXTURE2D(_RockTex);
            SAMPLER(sampler_RockTex);

            TEXTURE2D(_RockNormal);
            SAMPLER(sampler_RockNormal);

            TEXTURE2D(_RockHeight);
            SAMPLER(sampler_RockHeight);

            TEXTURE2D(_RockAO);
            SAMPLER(sampler_RockAO);

            // 🌱 TERRAIN
            TEXTURE2D(_TerrainTex);
            SAMPLER(sampler_TerrainTex);

            TEXTURE2D(_TerrainNormal);
            SAMPLER(sampler_TerrainNormal);

            TEXTURE2D(_TerrainAO);
            SAMPLER(sampler_TerrainAO);

            float _TerrainHeight;
            float _BlendDistance;
            float _Tiling;
            float _HeightStrength;
            float _AOStrength;

            // ---------------- VERTEX ----------------

            Varyings vert (Attributes v)
            {
                Varyings o;

                float3 world = TransformObjectToWorld(v.positionOS.xyz);

                o.worldPos = world;
                o.worldNormal = TransformObjectToWorldNormal(v.normalOS);

                o.positionHCS = TransformWorldToHClip(world);
                o.uv = v.uv;

                return o;
            }

            // ---------------- FRAGMENT ----------------

            half4 frag (Varyings i) : SV_Target
            {
                // 🌍 terrain UV (world projection)
                float2 terrainUV = i.worldPos.xz * _Tiling;

                // 🪨 ROCK DATA
                half4 rock = SAMPLE_TEXTURE2D(_RockTex, sampler_RockTex, i.uv);

                float rockAO = SAMPLE_TEXTURE2D(_RockAO, sampler_RockAO, i.uv).r;

                float rockHeight = SAMPLE_TEXTURE2D(_RockHeight, sampler_RockHeight, i.uv).r;

                float3 rockN = UnpackNormal(
                    SAMPLE_TEXTURE2D(_RockNormal, sampler_RockNormal, i.uv)
                );

                // 🌱 TERRAIN DATA
                half4 terrain = SAMPLE_TEXTURE2D(_TerrainTex, sampler_TerrainTex, terrainUV);

                float terrainAO = SAMPLE_TEXTURE2D(_TerrainAO, sampler_TerrainAO, terrainUV).r;

                float3 terrainN = UnpackNormal(
                    SAMPLE_TEXTURE2D(_TerrainNormal, sampler_TerrainNormal, terrainUV)
                );

                // 📏 HEIGHT BLEND
                float heightBlend = saturate(
                    (i.worldPos.y - _TerrainHeight) / _BlendDistance
                );

                // ⛰️ SLOPE BLEND
                float slope = saturate(dot(i.worldNormal, float3(0,1,0)));
                float blend = smoothstep(0.3, 1.0, slope) * heightBlend;

                // 🌄 height detail (fake relief)
                float heightOffset = (rockHeight - 0.5) * _HeightStrength;
                rock.rgb *= (1.0 + heightOffset);

                // 🌑 AO blending
                float ao = lerp(terrainAO, rockAO, blend);
                ao = lerp(1.0, ao, _AOStrength);

                // 🎯 NORMAL BLEND (URP SAFE)
                float3 finalNormal = normalize(lerp(terrainN, rockN, blend));

                // 💡 simple lighting (URP-safe)
                float light = saturate(dot(finalNormal, float3(0,1,0))) * 0.5 + 0.5;

                // 🎨 COLOR BLEND
                half4 col = lerp(terrain, rock, blend);

                col.rgb *= ao;
                col.rgb *= light;

                return col;
            }

            ENDHLSL
        }
    }
}