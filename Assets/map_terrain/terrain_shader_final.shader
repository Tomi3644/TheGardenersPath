Shader "Custom/URP/Mesh Terrain 4 Layer Lit HSB DBuffer Decals"
{
    Properties
    {
        [Header(Mask)]
        _Control("Mask", 2D) = "white" {}

        [Toggle(_LEGACY_COLOR_MASK)]
        _LegacyColorMask(
            "Use RGB Color Mask Red Yellow Green Blue",
            Float
        ) = 1

        _ColorMaskSoftness(
            "Color Mask Softness",
            Range(0.01, 1)
        ) = 0.45

        _HeightBlend(
            "Height Blend",
            Range(0.001, 1)
        ) = 0.25

        _HeightStrength(
            "Height Strength",
            Range(0, 2)
        ) = 1


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
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "UniversalMaterialType" = "Lit"
        }


        Pass
        {
            Name "ForwardLit"

            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Back
            ZWrite On
            ZTest LEqual


            HLSLPROGRAM

            #pragma target 4.5
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature_local _LEGACY_COLOR_MASK

            // Variantes exclusives de l’ombre principale.
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN

            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            // Ombres douces URP / Unity 6.
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH

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
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS   : TEXCOORD1;
                float4 tangentWS  : TEXCOORD2;
                float2 uv         : TEXCOORD3;
                float fogFactor   : TEXCOORD4;
                float2 lightmapUV : TEXCOORD5;
                half3 vertexSH    : TEXCOORD6;

                // Requis spécifiquement pour les Screen Space Shadows.
                float4 screenPos : TEXCOORD7;

                half3 vertexLight : TEXCOORD8;
            };


            TEXTURE2D(_Control);
            SAMPLER(sampler_Control);


            TEXTURE2D(_StoneBase);
            SAMPLER(sampler_StoneBase);
            TEXTURE2D(_StoneNormal);
            TEXTURE2D(_StoneRoughness);
            TEXTURE2D(_StoneHeight);
            TEXTURE2D(_StoneAO);


            TEXTURE2D(_DirtBase);
            SAMPLER(sampler_DirtBase);
            TEXTURE2D(_DirtNormal);
            TEXTURE2D(_DirtRoughness);
            TEXTURE2D(_DirtHeight);
            TEXTURE2D(_DirtAO);


            TEXTURE2D(_GrassBase);
            SAMPLER(sampler_GrassBase);
            TEXTURE2D(_GrassNormal);
            TEXTURE2D(_GrassRoughness);
            TEXTURE2D(_GrassHeight);
            TEXTURE2D(_GrassAO);


            TEXTURE2D(_MossBase);
            SAMPLER(sampler_MossBase);
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


            float2 LayerUV(
                float2 uv,
                float4 tilingOffset
            )
            {
                return
                    uv * tilingOffset.xy +
                    tilingOffset.zw;
            }


            float3 SafeNormalizeOr(
                float3 value,
                float3 fallbackValue
            )
            {
                float lengthSquared =
                    dot(value, value);

                if (lengthSquared <= 0.000001)
                {
                    return fallbackValue;
                }

                return value * rsqrt(lengthSquared);
            }


            float4 NormalizeWeights(float4 weights)
            {
                weights = max(weights, 0.0);

                float sum = dot(
                    weights,
                    float4(1.0, 1.0, 1.0, 1.0)
                );

                if (sum <= 0.00001)
                {
                    return float4(
                        1.0,
                        0.0,
                        0.0,
                        0.0
                    );
                }

                return weights / sum;
            }


            float ColorMaskWeight(
                float3 color,
                float3 target
            )
            {
                float difference =
                    distance(color, target);

                return saturate(
                    1.0 -
                    difference /
                    max(_ColorMaskSoftness, 0.0001)
                );
            }


            float4 GetLayerWeights(float4 mask)
            {
                #if defined(_LEGACY_COLOR_MASK)

                    float3 color =
                        mask.rgb;

                    float4 weights = float4(
                        ColorMaskWeight(
                            color,
                            float3(1.0, 0.0, 0.0)
                        ),

                        ColorMaskWeight(
                            color,
                            float3(1.0, 1.0, 0.0)
                        ),

                        ColorMaskWeight(
                            color,
                            float3(0.0, 1.0, 0.0)
                        ),

                        ColorMaskWeight(
                            color,
                            float3(0.0, 0.0, 1.0)
                        )
                    );

                    float weightSum = dot(
                        weights,
                        float4(1.0, 1.0, 1.0, 1.0)
                    );

                    if (weightSum <= 0.00001)
                    {
                        float4 distances = float4(
                            distance(
                                color,
                                float3(1.0, 0.0, 0.0)
                            ),

                            distance(
                                color,
                                float3(1.0, 1.0, 0.0)
                            ),

                            distance(
                                color,
                                float3(0.0, 1.0, 0.0)
                            ),

                            distance(
                                color,
                                float3(0.0, 0.0, 1.0)
                            )
                        );

                        float minimumDistance = min(
                            min(
                                distances.x,
                                distances.y
                            ),

                            min(
                                distances.z,
                                distances.w
                            )
                        );

                        weights =
                            1.0 -
                            step(
                                minimumDistance + 0.00001,
                                distances
                            );
                    }

                    return NormalizeWeights(weights);

                #else

                    return NormalizeWeights(
                        float4(
                            mask.r,
                            mask.a,
                            mask.g,
                            mask.b
                        )
                    );

                #endif
            }


            float4 ApplyHeightBlend(
                float4 weights,
                float4 heights
            )
            {
                heights *=
                    _HeightStrength;

                float4 heightValues =
                    heights +
                    weights;

                float maximumHeight = max(
                    max(
                        heightValues.x,
                        heightValues.y
                    ),

                    max(
                        heightValues.z,
                        heightValues.w
                    )
                );

                float4 blend = saturate(
                    (
                        heightValues -
                        maximumHeight +
                        _HeightBlend
                    ) /
                    max(
                        _HeightBlend,
                        0.0001
                    )
                );

                weights *=
                    blend;

                return
                    NormalizeWeights(weights);
            }


            float3 RGBToHSV(float3 color)
            {
                float4 K = float4(
                    0.0,
                    -1.0 / 3.0,
                    2.0 / 3.0,
                    -1.0
                );

                float4 p = lerp(
                    float4(
                        color.bg,
                        K.wz
                    ),

                    float4(
                        color.gb,
                        K.xy
                    ),

                    step(
                        color.b,
                        color.g
                    )
                );

                float4 q = lerp(
                    float4(
                        p.xyw,
                        color.r
                    ),

                    float4(
                        color.r,
                        p.yzx
                    ),

                    step(
                        p.x,
                        color.r
                    )
                );

                float difference =
                    q.x -
                    min(
                        q.w,
                        q.y
                    );

                float epsilon =
                    1e-10;

                return float3(
                    abs(
                        q.z +
                        (
                            q.w -
                            q.y
                        ) /
                        (
                            6.0 *
                            difference +
                            epsilon
                        )
                    ),

                    difference /
                    (
                        q.x +
                        epsilon
                    ),

                    q.x
                );
            }


            float3 HSVToRGB(float3 color)
            {
                float4 K = float4(
                    1.0,
                    2.0 / 3.0,
                    1.0 / 3.0,
                    3.0
                );

                float3 p = abs(
                    frac(
                        color.xxx +
                        K.xyz
                    ) *
                    6.0 -
                    K.www
                );

                return
                    color.z *
                    lerp(
                        K.xxx,
                        saturate(
                            p -
                            K.xxx
                        ),
                        color.y
                    );
            }


            float3 ApplyHSB(
                float3 color,
                float4 hsb
            )
            {
                float3 hsv =
                    RGBToHSV(
                        saturate(color)
                    );

                hsv.x =
                    frac(
                        hsv.x +
                        hsb.x
                    );

                hsv.y =
                    saturate(
                        hsv.y *
                        hsb.y
                    );

                hsv.z =
                    max(
                        0.0,
                        hsv.z *
                        hsb.z
                    );

                return
                    HSVToRGB(hsv);
            }


            float3 BlendNormalTS(
                float4 weights,
                float2 uvStone,
                float2 uvDirt,
                float2 uvGrass,
                float2 uvMoss
            )
            {
                float3 stoneNormal =
                    UnpackNormalScale(
                        SAMPLE_TEXTURE2D(
                            _StoneNormal,
                            sampler_StoneBase,
                            uvStone
                        ),
                        _NormalScale
                    );

                float3 dirtNormal =
                    UnpackNormalScale(
                        SAMPLE_TEXTURE2D(
                            _DirtNormal,
                            sampler_DirtBase,
                            uvDirt
                        ),
                        _NormalScale
                    );

                float3 grassNormal =
                    UnpackNormalScale(
                        SAMPLE_TEXTURE2D(
                            _GrassNormal,
                            sampler_GrassBase,
                            uvGrass
                        ),
                        _NormalScale
                    );

                float3 mossNormal =
                    UnpackNormalScale(
                        SAMPLE_TEXTURE2D(
                            _MossNormal,
                            sampler_MossBase,
                            uvMoss
                        ),
                        _NormalScale
                    );

                float3 blendedNormal =
                    stoneNormal * weights.x +
                    dirtNormal  * weights.y +
                    grassNormal * weights.z +
                    mossNormal  * weights.w;

                return SafeNormalizeOr(
                    blendedNormal,
                    float3(0.0, 0.0, 1.0)
                );
            }


            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs =
                    GetVertexPositionInputs(
                        input.positionOS.xyz
                    );

                VertexNormalInputs normalInputs =
                    GetVertexNormalInputs(
                        input.normalOS,
                        input.tangentOS
                    );

                output.positionCS =
                    positionInputs.positionCS;

                output.positionWS =
                    positionInputs.positionWS;

                output.normalWS =
                    NormalizeNormalPerVertex(
                        normalInputs.normalWS
                    );

                output.tangentWS = float4(
                    NormalizeNormalPerVertex(
                        normalInputs.tangentWS
                    ),

                    input.tangentOS.w *
                    GetOddNegativeScale()
                );

                output.uv =
                    TRANSFORM_TEX(
                        input.uv,
                        _Control
                    );

                output.fogFactor =
                    ComputeFogFactor(
                        positionInputs.positionCS.z
                    );

                /*
                 * Important :
                 * la position écran est calculée au vertex avec la vraie
                 * position clip-space, puis interpolée correctement.
                 */
                output.screenPos =
                    ComputeScreenPos(
                        positionInputs.positionCS
                    );

                output.vertexLight =
                    VertexLighting(
                        positionInputs.positionWS,
                        output.normalWS
                    );

                OUTPUT_LIGHTMAP_UV(
                    input.lightmapUV,
                    unity_LightmapST,
                    output.lightmapUV
                );

                OUTPUT_SH(
                    output.normalWS,
                    output.vertexSH
                );

                return output;
            }


            half4 frag(Varyings input) : SV_Target
            {
                float2 uvStone =
                    LayerUV(
                        input.uv,
                        _StoneTilingOffset
                    );

                float2 uvDirt =
                    LayerUV(
                        input.uv,
                        _DirtTilingOffset
                    );

                float2 uvGrass =
                    LayerUV(
                        input.uv,
                        _GrassTilingOffset
                    );

                float2 uvMoss =
                    LayerUV(
                        input.uv,
                        _MossTilingOffset
                    );


                float4 mask =
                    SAMPLE_TEXTURE2D(
                        _Control,
                        sampler_Control,
                        input.uv
                    );

                float4 weights =
                    GetLayerWeights(mask);


                float stoneHeight =
                    SAMPLE_TEXTURE2D(
                        _StoneHeight,
                        sampler_StoneBase,
                        uvStone
                    ).r;

                float dirtHeight =
                    SAMPLE_TEXTURE2D(
                        _DirtHeight,
                        sampler_DirtBase,
                        uvDirt
                    ).r;

                float grassHeight =
                    SAMPLE_TEXTURE2D(
                        _GrassHeight,
                        sampler_GrassBase,
                        uvGrass
                    ).r;

                float mossHeight =
                    SAMPLE_TEXTURE2D(
                        _MossHeight,
                        sampler_MossBase,
                        uvMoss
                    ).r;


                weights =
                    ApplyHeightBlend(
                        weights,
                        float4(
                            stoneHeight,
                            dirtHeight,
                            grassHeight,
                            mossHeight
                        )
                    );


                float3 stoneColor =
                    SAMPLE_TEXTURE2D(
                        _StoneBase,
                        sampler_StoneBase,
                        uvStone
                    ).rgb;

                float3 dirtColor =
                    SAMPLE_TEXTURE2D(
                        _DirtBase,
                        sampler_DirtBase,
                        uvDirt
                    ).rgb;

                float3 grassColor =
                    SAMPLE_TEXTURE2D(
                        _GrassBase,
                        sampler_GrassBase,
                        uvGrass
                    ).rgb;

                float3 mossColor =
                    SAMPLE_TEXTURE2D(
                        _MossBase,
                        sampler_MossBase,
                        uvMoss
                    ).rgb;


                stoneColor =
                    ApplyHSB(
                        stoneColor,
                        _StoneHSB
                    );

                dirtColor =
                    ApplyHSB(
                        dirtColor,
                        _DirtHSB
                    );

                grassColor =
                    ApplyHSB(
                        grassColor,
                        _GrassHSB
                    );

                mossColor =
                    ApplyHSB(
                        mossColor,
                        _MossHSB
                    );


                half3 albedo =
                    stoneColor * weights.x +
                    dirtColor  * weights.y +
                    grassColor * weights.z +
                    mossColor  * weights.w;


                float roughness =
                    SAMPLE_TEXTURE2D(
                        _StoneRoughness,
                        sampler_StoneBase,
                        uvStone
                    ).r * weights.x +

                    SAMPLE_TEXTURE2D(
                        _DirtRoughness,
                        sampler_DirtBase,
                        uvDirt
                    ).r * weights.y +

                    SAMPLE_TEXTURE2D(
                        _GrassRoughness,
                        sampler_GrassBase,
                        uvGrass
                    ).r * weights.z +

                    SAMPLE_TEXTURE2D(
                        _MossRoughness,
                        sampler_MossBase,
                        uvMoss
                    ).r * weights.w;


                roughness =
                    saturate(
                        roughness *
                        _RoughnessStrength
                    );


                half smoothness =
                    saturate(
                        1.0 -
                        roughness
                    );


                float ambientOcclusion =
                    SAMPLE_TEXTURE2D(
                        _StoneAO,
                        sampler_StoneBase,
                        uvStone
                    ).r * weights.x +

                    SAMPLE_TEXTURE2D(
                        _DirtAO,
                        sampler_DirtBase,
                        uvDirt
                    ).r * weights.y +

                    SAMPLE_TEXTURE2D(
                        _GrassAO,
                        sampler_GrassBase,
                        uvGrass
                    ).r * weights.z +

                    SAMPLE_TEXTURE2D(
                        _MossAO,
                        sampler_MossBase,
                        uvMoss
                    ).r * weights.w;


                ambientOcclusion =
                    saturate(
                        lerp(
                            1.0,
                            saturate(ambientOcclusion),
                            _AOStrength
                        )
                    );


                float3 normalTS =
                    BlendNormalTS(
                        weights,
                        uvStone,
                        uvDirt,
                        uvGrass,
                        uvMoss
                    );


                float3 geometricNormalWS =
                    SafeNormalizeOr(
                        input.normalWS,
                        float3(0.0, 1.0, 0.0)
                    );


                float3 tangentWS =
                    input.tangentWS.xyz -
                    geometricNormalWS *
                    dot(
                        geometricNormalWS,
                        input.tangentWS.xyz
                    );


                float tangentLengthSquared =
                    dot(
                        tangentWS,
                        tangentWS
                    );


                if (tangentLengthSquared <= 0.000001)
                {
                    float3 referenceAxis =
                        abs(geometricNormalWS.y) < 0.999
                        ? float3(0.0, 1.0, 0.0)
                        : float3(1.0, 0.0, 0.0);

                    tangentWS =
                        SafeNormalizeOr(
                            cross(
                                referenceAxis,
                                geometricNormalWS
                            ),

                            float3(1.0, 0.0, 0.0)
                        );
                }
                else
                {
                    tangentWS *=
                        rsqrt(
                            tangentLengthSquared
                        );
                }


                float3 bitangentWS =
                    SafeNormalizeOr(
                        cross(
                            geometricNormalWS,
                            tangentWS
                        ),

                        float3(0.0, 0.0, 1.0)
                    ) *
                    input.tangentWS.w;


                float3 normalWS =
                    SafeNormalizeOr(
                        tangentWS * normalTS.x +
                        bitangentWS * normalTS.y +
                        geometricNormalWS * normalTS.z,

                        geometricNormalWS
                    );


                SurfaceData surfaceData =
                    (SurfaceData)0;


                surfaceData.albedo =
                    albedo;

                surfaceData.metallic =
                    0.0;

                surfaceData.specular =
                    half3(
                        0.0,
                        0.0,
                        0.0
                    );

                surfaceData.smoothness =
                    smoothness;

                surfaceData.normalTS =
                    normalTS;

                surfaceData.emission =
                    half3(
                        0.0,
                        0.0,
                        0.0
                    );

                surfaceData.occlusion =
                    ambientOcclusion;

                surfaceData.alpha =
                    1.0;

                surfaceData.clearCoatMask =
                    0.0;

                surfaceData.clearCoatSmoothness =
                    0.0;


                InputData inputData =
                    (InputData)0;


                inputData.positionWS =
                    input.positionWS;

                inputData.normalWS =
                    normalWS;

                inputData.viewDirectionWS =
                    SafeNormalize(
                        GetCameraPositionWS() -
                        input.positionWS
                    );


                /*
                 * Correction principale :
                 *
                 * Screen Space Shadows :
                 * utilise la position écran interpolée.
                 *
                 * Shadow maps / cascades :
                 * calcule la coordonnée par pixel depuis positionWS.
                 *
                 * Cela empêche les zones sombres de se dessiner
                 * en fonction de la caméra ou des gros triangles.
                 */
                #if defined(_MAIN_LIGHT_SHADOWS_SCREEN)

                    inputData.shadowCoord =
                        input.screenPos;

                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)

                    inputData.shadowCoord =
                        TransformWorldToShadowCoord(
                            input.positionWS
                        );

                #else

                    inputData.shadowCoord =
                        float4(
                            0.0,
                            0.0,
                            0.0,
                            0.0
                        );

                #endif


                inputData.fogCoord =
                    input.fogFactor;

                inputData.vertexLighting =
                    input.vertexLight;

                inputData.bakedGI =
                    SAMPLE_GI(
                        input.lightmapUV,
                        input.vertexSH,
                        normalWS
                    );

                inputData.normalizedScreenSpaceUV =
                    GetNormalizedScreenSpaceUV(
                        input.positionCS
                    );

                inputData.shadowMask =
                    SAMPLE_SHADOWMASK(
                        input.lightmapUV
                    );


                #if defined(_DBUFFER_MRT1) || defined(_DBUFFER_MRT2) || defined(_DBUFFER_MRT3)

                    ApplyDecalToSurfaceData(
                        input.positionCS,
                        surfaceData,
                        inputData
                    );

                #endif


                half4 color =
                    UniversalFragmentPBR(
                        inputData,
                        surfaceData
                    );


                color.rgb =
                    MixFog(
                        color.rgb,
                        input.fogFactor
                    );


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