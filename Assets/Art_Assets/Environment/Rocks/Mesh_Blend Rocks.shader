Shader "Custom/URP/MeshBlend_RockToRock_Lit_DBufferDecals"
{
    Properties
    {
        _BaseColor ("Base Color", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _HeightMap ("Height Map", 2D) = "gray" {}
        _RoughnessMap ("Roughness Map", 2D) = "gray" {}
        _AOMap ("Ambient Occlusion", 2D) = "white" {}

        _TextureTiling ("Texture Tiling", Float) = 1

        _HeightStrength ("Height Strength", Float) = 0.08
        _AOStrength ("AO Strength", Float) = 1
        _RoughnessStrength ("Roughness Strength", Float) = 1

        _NormalStrength ("Normal Strength", Range(0,2)) = 1

        _Saturation ("Saturation", Range(0,2)) = 1
        _Contrast ("Contrast", Range(0,2)) = 1
        _Brightness ("Brightness", Range(-1,1)) = 0

        _DitherStrength ("Dither Strength", Float) = 0.02
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
            "UniversalMaterialType"="Lit"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _FORWARD_PLUS
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fog

            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
                float2 lightmapUV : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
                float3 positionWS  : TEXCOORD0;
                float3 normalWS    : TEXCOORD1;
                float fogFactor    : TEXCOORD2;
                float2 lightmapUV  : TEXCOORD3;
                half3 vertexSH     : TEXCOORD4;
                float4 shadowCoord : TEXCOORD5;
                half3 vertexLight  : TEXCOORD6;
            };

            TEXTURE2D(_BaseColor);
            SAMPLER(sampler_BaseColor);

            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);

            TEXTURE2D(_HeightMap);
            SAMPLER(sampler_HeightMap);

            TEXTURE2D(_RoughnessMap);
            SAMPLER(sampler_RoughnessMap);

            TEXTURE2D(_AOMap);
            SAMPLER(sampler_AOMap);

            CBUFFER_START(UnityPerMaterial)
                float _TextureTiling;

                float _HeightStrength;
                float _AOStrength;
                float _RoughnessStrength;

                float _NormalStrength;

                float _Saturation;
                float _Contrast;
                float _Brightness;

                float _DitherStrength;
            CBUFFER_END

            float3 GetTriWeights(float3 n)
            {
                float3 w = abs(n);
                w = pow(w, 4.0);
                return w / max(w.x + w.y + w.z, 0.0001);
            }

            half4 SampleTri(TEXTURE2D_PARAM(tex, samp), float3 p, float3 w)
            {
                float2 uvX = p.zy * _TextureTiling;
                float2 uvY = p.xz * _TextureTiling;
                float2 uvZ = p.xy * _TextureTiling;

                half4 x = SAMPLE_TEXTURE2D(tex, samp, uvX);
                half4 y = SAMPLE_TEXTURE2D(tex, samp, uvY);
                half4 z = SAMPLE_TEXTURE2D(tex, samp, uvZ);

                return x * w.x + y * w.y + z * w.z;
            }

            float3 SampleTriNormalWS(TEXTURE2D_PARAM(tex, samp), float3 p, float3 normalWS, float3 w)
            {
                float2 uvX = p.zy * _TextureTiling;
                float2 uvY = p.xz * _TextureTiling;
                float2 uvZ = p.xy * _TextureTiling;

                float3 nX = UnpackNormalScale(SAMPLE_TEXTURE2D(tex, samp, uvX), _NormalStrength);
                float3 nY = UnpackNormalScale(SAMPLE_TEXTURE2D(tex, samp, uvY), _NormalStrength);
                float3 nZ = UnpackNormalScale(SAMPLE_TEXTURE2D(tex, samp, uvZ), _NormalStrength);

                float3 worldX = normalize(float3(nX.z, nX.y, nX.x));
                float3 worldY = normalize(float3(nY.x, nY.z, nY.y));
                float3 worldZ = normalize(float3(nZ.x, nZ.y, nZ.z));

                worldX.x *= sign(normalWS.x);
                worldY.y *= sign(normalWS.y);
                worldZ.z *= sign(normalWS.z);

                return normalize(worldX * w.x + worldY * w.y + worldZ * w.z);
            }

            float Dither(float2 screenUV)
            {
                return frac(sin(dot(screenUV, float2(12.9898, 78.233))) * 43758.5453);
            }

            float3 ApplyColorGrade(float3 col)
            {
                col += _Brightness;
                col = (col - 0.5) * _Contrast + 0.5;

                float luma = dot(col, float3(0.299, 0.587, 0.114));
                col = lerp(float3(luma, luma, luma), col, _Saturation);

                return saturate(col);
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                VertexPositionInputs pos = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs nor = GetVertexNormalInputs(IN.normalOS);

                OUT.positionCS = pos.positionCS;
                OUT.positionWS = pos.positionWS;
                OUT.normalWS = NormalizeNormalPerVertex(nor.normalWS);
                OUT.fogFactor = ComputeFogFactor(pos.positionCS.z);
                OUT.shadowCoord = GetShadowCoord(pos);
                OUT.vertexLight = VertexLighting(pos.positionWS, OUT.normalWS);

                OUTPUT_LIGHTMAP_UV(IN.lightmapUV, unity_LightmapST, OUT.lightmapUV);
                OUTPUT_SH(OUT.normalWS, OUT.vertexSH);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 baseNormalWS = normalize(IN.normalWS);
                float3 weights = GetTriWeights(baseNormalWS);

                half4 baseSample = SampleTri(
                    TEXTURE2D_ARGS(_BaseColor, sampler_BaseColor),
                    IN.positionWS,
                    weights
                );

                float height = SampleTri(
                    TEXTURE2D_ARGS(_HeightMap, sampler_HeightMap),
                    IN.positionWS,
                    weights
                ).r;

                float ao = SampleTri(
                    TEXTURE2D_ARGS(_AOMap, sampler_AOMap),
                    IN.positionWS,
                    weights
                ).r;

                float roughness = SampleTri(
                    TEXTURE2D_ARGS(_RoughnessMap, sampler_RoughnessMap),
                    IN.positionWS,
                    weights
                ).r;

                float3 normalWS = SampleTriNormalWS(
                    TEXTURE2D_ARGS(_NormalMap, sampler_NormalMap),
                    IN.positionWS,
                    baseNormalWS,
                    weights
                );

                float3 albedo = baseSample.rgb;

                albedo *= 1.0 + (height - 0.5) * _HeightStrength;

                ao = lerp(1.0, ao, _AOStrength);

                roughness = lerp(1.0, roughness, _RoughnessStrength);
                roughness = saturate(roughness);

                float smoothness = saturate(1.0 - roughness);

                float2 screenUV = GetNormalizedScreenSpaceUV(IN.positionCS);
                float noise = Dither(screenUV * 400.0);

                albedo += (noise - 0.5) * _DitherStrength;
                albedo = ApplyColorGrade(albedo);

                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = albedo;
                surfaceData.metallic = 0;
                surfaceData.specular = half3(0, 0, 0);
                surfaceData.smoothness = smoothness;
                surfaceData.normalTS = half3(0, 0, 1);
                surfaceData.emission = half3(0, 0, 0);
                surfaceData.occlusion = ao;
                surfaceData.alpha = 1;
                surfaceData.clearCoatMask = 0;
                surfaceData.clearCoatSmoothness = 0;

                InputData inputData = (InputData)0;
                inputData.positionWS = IN.positionWS;
                inputData.normalWS = normalWS;
                inputData.viewDirectionWS = SafeNormalize(GetCameraPositionWS() - IN.positionWS);
                inputData.shadowCoord = IN.shadowCoord;
                inputData.fogCoord = IN.fogFactor;
                inputData.vertexLighting = IN.vertexLight;
                inputData.bakedGI = SAMPLE_GI(IN.lightmapUV, IN.vertexSH, normalWS);
                inputData.normalizedScreenSpaceUV = screenUV;
                inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUV);

                #if defined(_DBUFFER)
                    ApplyDecalToSurfaceData(IN.positionCS, surfaceData, inputData);
                #endif

                half4 color = UniversalFragmentPBR(inputData, surfaceData);
                color.rgb = MixFog(color.rgb, IN.fogFactor);

                return color;
            }

            ENDHLSL
        }

        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/DepthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}