Shader "Custom/URP/Mesh Terrain 4 Layer Lit HSB DBuffer Decals"
{
    Properties
    {
        [Header(Mask)]
        _Control("Mask", 2D) = "white" {}
        [Toggle(_LEGACY_COLOR_MASK)] _LegacyColorMask("Use RGB Color Mask Red Yellow Green Blue", Float) = 1
        _ColorMaskSoftness("Color Mask Softness", Range(0.01, 1)) = 0.45
        _HeightBlend("Height Blend", Range(0.001, 1)) = 0.25
        _HeightStrength("Height Strength", Range(0, 2)) = 1

        [Header(Stone Red)]
        _StoneBase("Stone Base Color", 2D) = "white" {}
        _StoneNormal("Stone Normal", 2D) = "bump" {}
        _StoneRoughness("Stone Roughness", 2D) = "white" {}
        _StoneHeight("Stone Height", 2D) = "black" {}
        _StoneAO("Stone AO", 2D) = "white" {}
        _StoneTilingOffset("Stone Tiling Offset", Vector) = (8,8,0,0)
        _StoneHSB("Stone HSB", Vector) = (0,1,1,0)

        [Header(Dirt Yellow)]
        _DirtBase("Dirt Base Color", 2D) = "white" {}
        _DirtNormal("Dirt Normal", 2D) = "bump" {}
        _DirtRoughness("Dirt Roughness", 2D) = "white" {}
        _DirtHeight("Dirt Height", 2D) = "black" {}
        _DirtAO("Dirt AO", 2D) = "white" {}
        _DirtTilingOffset("Dirt Tiling Offset", Vector) = (8,8,0,0)
        _DirtHSB("Dirt HSB", Vector) = (0,1,1,0)

        [Header(Grass Green)]
        _GrassBase("Grass Base Color", 2D) = "white" {}
        _GrassNormal("Grass Normal", 2D) = "bump" {}
        _GrassRoughness("Grass Roughness", 2D) = "white" {}
        _GrassHeight("Grass Height", 2D) = "black" {}
        _GrassAO("Grass AO", 2D) = "white" {}
        _GrassTilingOffset("Grass Tiling Offset", Vector) = (8,8,0,0)
        _GrassHSB("Grass HSB", Vector) = (0,1,1,0)

        [Header(Moss Blue)]
        _MossBase("Moss Base Color", 2D) = "white" {}
        _MossNormal("Moss Normal", 2D) = "bump" {}
        _MossRoughness("Moss Roughness", 2D) = "white" {}
        _MossHeight("Moss Height", 2D) = "black" {}
        _MossAO("Moss AO", 2D) = "white" {}
        _MossTilingOffset("Moss Tiling Offset", Vector) = (8,8,0,0)
        _MossHSB("Moss HSB", Vector) = (0,1,1,0)

        [Header(Global)]
        _NormalScale("Normal Scale", Range(0,2)) = 1
        _RoughnessStrength("Roughness Strength", Range(0,2)) = 1
        _AOStrength("AO Strength", Range(0,4)) = 1
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

            #pragma shader_feature_local _LEGACY_COLOR_MASK

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
                float4 tangentOS  : TANGENT;
                float2 uv         : TEXCOORD0;
                float2 lightmapUV : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
                float3 positionWS  : TEXCOORD0;
                float3 normalWS    : TEXCOORD1;
                float4 tangentWS   : TEXCOORD2;
                float2 uv          : TEXCOORD3;
                float fogFactor    : TEXCOORD4;
                float2 lightmapUV  : TEXCOORD5;
                half3 vertexSH     : TEXCOORD6;
                float4 shadowCoord : TEXCOORD7;
                half3 vertexLight  : TEXCOORD8;
            };

            TEXTURE2D(_Control);
            SAMPLER(sampler_Control);

            TEXTURE2D(_StoneBase); SAMPLER(sampler_StoneBase);
            TEXTURE2D(_StoneNormal);
            TEXTURE2D(_StoneRoughness);
            TEXTURE2D(_StoneHeight);
            TEXTURE2D(_StoneAO);

            TEXTURE2D(_DirtBase);
            TEXTURE2D(_DirtNormal);
            TEXTURE2D(_DirtRoughness);
            TEXTURE2D(_DirtHeight);
            TEXTURE2D(_DirtAO);

            TEXTURE2D(_GrassBase);
            TEXTURE2D(_GrassNormal);
            TEXTURE2D(_GrassRoughness);
            TEXTURE2D(_GrassHeight);
            TEXTURE2D(_GrassAO);

            TEXTURE2D(_MossBase);
            TEXTURE2D(_MossNormal);
            TEXTURE2D(_MossRoughness);
            TEXTURE2D(_MossHeight);
            TEXTURE2D(_MossAO);

            CBUFFER_START(UnityPerMaterial)
                float4 _Control_ST;

                float _ColorMaskSoftness;
                float _HeightBlend;
                float _HeightStrength;

                float4 _StoneTilingOffset;
                float4 _DirtTilingOffset;
                float4 _GrassTilingOffset;
                float4 _MossTilingOffset;

                float4 _StoneHSB;
                float4 _DirtHSB;
                float4 _GrassHSB;
                float4 _MossHSB;

                float _NormalScale;
                float _RoughnessStrength;
                float _AOStrength;
            CBUFFER_END

            float2 LayerUV(float2 uv, float4 tilingOffset)
            {
                return uv * tilingOffset.xy + tilingOffset.zw;
            }

            float4 NormalizeWeights(float4 w)
            {
                w = max(w, 0.0);
                return w / max(dot(w, 1.0), 0.0001);
            }

            float ColorMaskWeight(float3 color, float3 target)
            {
                float d = distance(color, target);
                return saturate(1.0 - d / max(_ColorMaskSoftness, 0.0001));
            }

            float4 GetLayerWeights(float4 mask)
            {
                #if defined(_LEGACY_COLOR_MASK)
                    float3 c = mask.rgb;

                    float stone = ColorMaskWeight(c, float3(1,0,0));
                    float dirt  = ColorMaskWeight(c, float3(1,1,0));
                    float grass = ColorMaskWeight(c, float3(0,1,0));
                    float moss  = ColorMaskWeight(c, float3(0,0,1));

                    return NormalizeWeights(float4(stone, dirt, grass, moss));
                #else
                    return NormalizeWeights(float4(mask.r, mask.a, mask.g, mask.b));
                #endif
            }

            float4 ApplyHeightBlend(float4 weights, float4 heights)
            {
                heights *= _HeightStrength;

                float4 h = heights + weights;
                float maxH = max(max(h.x, h.y), max(h.z, h.w));

                float4 blend = saturate((h - maxH + _HeightBlend) / max(_HeightBlend, 0.0001));

                weights *= blend;
                return NormalizeWeights(weights);
            }

            float3 RGBToHSV(float3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

                float d = q.x - min(q.w, q.y);
                float e = 1e-10;

                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            float3 HSVToRGB(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }

            float3 ApplyHSB(float3 color, float4 hsb)
            {
                float3 hsv = RGBToHSV(saturate(color));

                hsv.x = frac(hsv.x + hsb.x);
                hsv.y = saturate(hsv.y * hsb.y);
                hsv.z = max(0.0, hsv.z * hsb.z);

                return HSVToRGB(hsv);
            }

            float3 BlendNormalTS(float4 w, float2 uvStone, float2 uvDirt, float2 uvGrass, float2 uvMoss)
            {
                float3 n0 = UnpackNormalScale(SAMPLE_TEXTURE2D(_StoneNormal, sampler_StoneBase, uvStone), _NormalScale);
                float3 n1 = UnpackNormalScale(SAMPLE_TEXTURE2D(_DirtNormal,  sampler_StoneBase, uvDirt),  _NormalScale);
                float3 n2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_GrassNormal, sampler_StoneBase, uvGrass), _NormalScale);
                float3 n3 = UnpackNormalScale(SAMPLE_TEXTURE2D(_MossNormal,  sampler_StoneBase, uvMoss),  _NormalScale);

                return normalize(n0 * w.x + n1 * w.y + n2 * w.z + n3 * w.w);
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                VertexPositionInputs pos = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs nor = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);

                OUT.positionCS = pos.positionCS;
                OUT.positionWS = pos.positionWS;
                OUT.normalWS = NormalizeNormalPerVertex(nor.normalWS);
                OUT.tangentWS = float4(NormalizeNormalPerVertex(nor.tangentWS), IN.tangentOS.w * GetOddNegativeScale());
                OUT.uv = TRANSFORM_TEX(IN.uv, _Control);
                OUT.fogFactor = ComputeFogFactor(pos.positionCS.z);
                OUT.shadowCoord = GetShadowCoord(pos);
                OUT.vertexLight = VertexLighting(pos.positionWS, OUT.normalWS);

                OUTPUT_LIGHTMAP_UV(IN.lightmapUV, unity_LightmapST, OUT.lightmapUV);
                OUTPUT_SH(OUT.normalWS, OUT.vertexSH);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 uvStone = LayerUV(IN.uv, _StoneTilingOffset);
                float2 uvDirt  = LayerUV(IN.uv, _DirtTilingOffset);
                float2 uvGrass = LayerUV(IN.uv, _GrassTilingOffset);
                float2 uvMoss  = LayerUV(IN.uv, _MossTilingOffset);

                float4 mask = SAMPLE_TEXTURE2D(_Control, sampler_Control, IN.uv);
                float4 weights = GetLayerWeights(mask);

                float h0 = SAMPLE_TEXTURE2D(_StoneHeight, sampler_StoneBase, uvStone).r;
                float h1 = SAMPLE_TEXTURE2D(_DirtHeight,  sampler_StoneBase, uvDirt).r;
                float h2 = SAMPLE_TEXTURE2D(_GrassHeight, sampler_StoneBase, uvGrass).r;
                float h3 = SAMPLE_TEXTURE2D(_MossHeight,  sampler_StoneBase, uvMoss).r;

                weights = ApplyHeightBlend(weights, float4(h0, h1, h2, h3));

                float3 c0 = SAMPLE_TEXTURE2D(_StoneBase, sampler_StoneBase, uvStone).rgb;
                float3 c1 = SAMPLE_TEXTURE2D(_DirtBase,  sampler_StoneBase, uvDirt).rgb;
                float3 c2 = SAMPLE_TEXTURE2D(_GrassBase, sampler_StoneBase, uvGrass).rgb;
                float3 c3 = SAMPLE_TEXTURE2D(_MossBase,  sampler_StoneBase, uvMoss).rgb;

                c0 = ApplyHSB(c0, _StoneHSB);
                c1 = ApplyHSB(c1, _DirtHSB);
                c2 = ApplyHSB(c2, _GrassHSB);
                c3 = ApplyHSB(c3, _MossHSB);

                half3 albedo =
                    c0 * weights.x +
                    c1 * weights.y +
                    c2 * weights.z +
                    c3 * weights.w;

                float roughness =
                    SAMPLE_TEXTURE2D(_StoneRoughness, sampler_StoneBase, uvStone).r * weights.x +
                    SAMPLE_TEXTURE2D(_DirtRoughness,  sampler_StoneBase, uvDirt).r  * weights.y +
                    SAMPLE_TEXTURE2D(_GrassRoughness, sampler_StoneBase, uvGrass).r * weights.z +
                    SAMPLE_TEXTURE2D(_MossRoughness,  sampler_StoneBase, uvMoss).r  * weights.w;

                roughness = saturate(roughness * _RoughnessStrength);
                half smoothness = saturate(1.0 - roughness);

                float ao =
                    SAMPLE_TEXTURE2D(_StoneAO, sampler_StoneBase, uvStone).r * weights.x +
                    SAMPLE_TEXTURE2D(_DirtAO,  sampler_StoneBase, uvDirt).r  * weights.y +
                    SAMPLE_TEXTURE2D(_GrassAO, sampler_StoneBase, uvGrass).r * weights.z +
                    SAMPLE_TEXTURE2D(_MossAO,  sampler_StoneBase, uvMoss).r  * weights.w;

                ao = lerp(1.0, ao, _AOStrength);

                float3 normalTS = BlendNormalTS(weights, uvStone, uvDirt, uvGrass, uvMoss);

                float3 normalWS = normalize(IN.normalWS);
                float3 tangentWS = normalize(IN.tangentWS.xyz);
                float3 bitangentWS = normalize(cross(normalWS, tangentWS)) * IN.tangentWS.w;

                normalWS = normalize(
                    tangentWS   * normalTS.x +
                    bitangentWS * normalTS.y +
                    normalWS    * normalTS.z
                );

                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = albedo;
                surfaceData.metallic = 0;
                surfaceData.specular = half3(0,0,0);
                surfaceData.smoothness = smoothness;
                surfaceData.normalTS = normalTS;
                surfaceData.emission = half3(0,0,0);
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
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.positionCS);
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