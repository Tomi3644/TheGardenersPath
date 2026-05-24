Shader "Custom/URP/RockTerrainBlend_SEAMLESS"
{
    Properties
    {
        _RockTex ("Rock Albedo", 2D) = "white" {}
        _RockNormal ("Rock Normal", 2D) = "bump" {}
        _RockHeight ("Rock Height", 2D) = "gray" {}
        _RockAO ("Rock AO", 2D) = "white" {}

        _TerrainTex ("Terrain Albedo", 2D) = "white" {}
        _TerrainNormal ("Terrain Normal", 2D) = "bump" {}
        _TerrainHeightMap ("Terrain Height", 2D) = "gray" {}
        _TerrainAO ("Terrain AO", 2D) = "white" {}

        _TerrainHeight ("Terrain World Height", Float) = 0
        _BlendDistance ("Blend Distance", Float) = 2

        _RockTiling ("Rock Tiling", Float) = 1
        _TerrainTiling ("Terrain Tiling", Float) = 0.1

        _HeightStrength ("Height Strength", Float) = 0.08
        _AOStrength ("AO Strength", Float) = 1.0

        _DitherStrength ("Dither Strength", Float) = 0.15
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // =====================================================
            // STRUCTS
            // =====================================================

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
                float4 screenPos : TEXCOORD3;
            };

            // =====================================================
            // TEXTURES
            // =====================================================

            TEXTURE2D(_RockTex); SAMPLER(sampler_RockTex);
            TEXTURE2D(_RockNormal); SAMPLER(sampler_RockNormal);
            TEXTURE2D(_RockHeight); SAMPLER(sampler_RockHeight);
            TEXTURE2D(_RockAO); SAMPLER(sampler_RockAO);

            TEXTURE2D(_TerrainTex); SAMPLER(sampler_TerrainTex);
            TEXTURE2D(_TerrainNormal); SAMPLER(sampler_TerrainNormal);
            TEXTURE2D(_TerrainHeightMap); SAMPLER(sampler_TerrainHeightMap);
            TEXTURE2D(_TerrainAO); SAMPLER(sampler_TerrainAO);

            // =====================================================
            // PARAMS
            // =====================================================

            float _TerrainHeight;
            float _BlendDistance;

            float _RockTiling;
            float _TerrainTiling;

            float _HeightStrength;
            float _AOStrength;

            float _DitherStrength;

            // =====================================================
            // RNM (UNREAL NORMAL BLENDING)
            // =====================================================

            float3 BlendRNM(float3 n1, float3 n2, float blendFactor)
            {
                n2 = lerp(float3(0,0,1), n2, blendFactor);

                float3 t = n1 + float3(0,0,1);
                float3 u = n2 * float3(-1,-1,1);

                return normalize((t / t.z) * dot(t, u) - u);
            }

            // =====================================================
            // DITHER NOISE (SCREEN SPACE)
            // =====================================================

            float Dither(float2 screenPos)
            {
                return frac(
                    sin(dot(screenPos, float2(12.9898,78.233)))
                    * 43758.5453
                );
            }

            // =====================================================
            // TRIPLANAR
            // =====================================================

            float3 GetTriWeights(float3 n)
            {
                float3 w = abs(n);
                w = pow(w, 4);
                return w / max(w.x + w.y + w.z, 0.0001);
            }

            half4 SampleTri(TEXTURE2D_PARAM(tex, samp), float3 p, float3 w, float t)
            {
                float2 x = p.zy * t;
                float2 y = p.xz * t;
                float2 z = p.xy * t;

                return SAMPLE_TEXTURE2D(tex, samp, x) * w.x +
                       SAMPLE_TEXTURE2D(tex, samp, y) * w.y +
                       SAMPLE_TEXTURE2D(tex, samp, z) * w.z;
            }

            float3 SampleTriN(TEXTURE2D_PARAM(tex, samp), float3 p, float3 w, float t)
            {
                float2 x = p.zy * t;
                float2 y = p.xz * t;
                float2 z = p.xy * t;

                float3 nx = UnpackNormal(SAMPLE_TEXTURE2D(tex, samp, x));
                float3 ny = UnpackNormal(SAMPLE_TEXTURE2D(tex, samp, y));
                float3 nz = UnpackNormal(SAMPLE_TEXTURE2D(tex, samp, z));

                return normalize(nx*w.x + ny*w.y + nz*w.z);
            }

            // =====================================================
            // VERTEX
            // =====================================================

            Varyings vert(Attributes v)
            {
                Varyings o;

                float3 world = TransformObjectToWorld(v.positionOS.xyz);

                o.worldPos = world;
                o.worldNormal = TransformObjectToWorldNormal(v.normalOS);

                o.positionHCS = TransformWorldToHClip(world);

                o.uv = v.uv;

                o.screenPos = o.positionHCS;

                return o;
            }

            // =====================================================
            // FRAGMENT
            // =====================================================

            half4 frag(Varyings i) : SV_Target
            {
                float3 nWorld = normalize(i.worldNormal);

                // =================================================
                // TRIPLANAR WEIGHTS
                // =================================================

                float3 w = GetTriWeights(nWorld);

                // =================================================
                // ROCK DATA (TRIPLANAR)
                // =================================================

                half4 rock = SampleTri(TEXTURE2D_ARGS(_RockTex, sampler_RockTex), i.worldPos, w, _RockTiling);

                float3 rockN = SampleTriN(TEXTURE2D_ARGS(_RockNormal, sampler_RockNormal), i.worldPos, w, _RockTiling);

                float rockAO = SampleTri(TEXTURE2D_ARGS(_RockAO, sampler_RockAO), i.worldPos, w, _RockTiling).r;

                float rockH = SampleTri(TEXTURE2D_ARGS(_RockHeight, sampler_RockHeight), i.worldPos, w, _RockTiling).r;

                // =================================================
                // TERRAIN DATA
                // =================================================

                float2 tUV = i.worldPos.xz * _TerrainTiling;

                half4 terrain = SAMPLE_TEXTURE2D(_TerrainTex, sampler_TerrainTex, tUV);

                float3 terrainN = UnpackNormal(SAMPLE_TEXTURE2D(_TerrainNormal, sampler_TerrainNormal, tUV));

                float terrainAO = SAMPLE_TEXTURE2D(_TerrainAO, sampler_TerrainAO, tUV).r;

                float terrainH = SAMPLE_TEXTURE2D(_TerrainHeightMap, sampler_TerrainHeightMap, tUV).r;

                // =================================================
                // HEIGHT BLEND (WORLD + DETAIL)
                // =================================================

                float hBlend = saturate((i.worldPos.y - _TerrainHeight) / _BlendDistance);

                float slope = saturate(dot(nWorld, float3(0,1,0)));

                float blend = pow(saturate(hBlend * smoothstep(0.25,1,slope)), 2.5);

                // =================================================
                // HEIGHT DETAIL
                // =================================================

                rock.rgb *= (1 + (rockH - 0.5) * _HeightStrength);
                terrain.rgb *= (1 + (terrainH - 0.5) * _HeightStrength);

                // =================================================
                // AO
                // =================================================

                float ao = lerp(terrainAO, rockAO, blend);
                ao = lerp(1, ao, _AOStrength);

                // =================================================
                // NORMAL (RNM)
                // =================================================

                float3 finalN = BlendRNM(terrainN, rockN, blend);

                // =================================================
                // LIGHT
                // =================================================

                float3 lightDir = normalize(float3(0.4,1,0.3));

                float light = saturate(dot(finalN, lightDir)) * 0.8 + 0.2;

                // =================================================
                // COLOR BLEND
                // =================================================

                half4 col = lerp(terrain, rock, blend);

                col.rgb *= ao;
                col.rgb *= light;

                // =================================================
                // DITHER BLEND (IMPORTANT FIX SEAM)
                // =================================================

                float2 screenUV = i.screenPos.xy / i.screenPos.w;

                float noise = Dither(screenUV * 400);

                col.rgb += (noise - 0.5) * _DitherStrength * blend;

                return col;
            }

            ENDHLSL
        }
    }
}