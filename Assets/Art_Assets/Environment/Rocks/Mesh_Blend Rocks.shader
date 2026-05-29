Shader "Custom/URP/MeshBlend_RockToRock_UEStyle_FIXED"
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
        }

        Pass
        {
            Name "ForwardLit"

            Tags
            {
                "LightMode"="UniversalForward"
            }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;

                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;

                float4 shadowCoord : TEXCOORD2;

                float4 screenPos : TEXCOORD3;
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

            float _TextureTiling;

            float _HeightStrength;
            float _AOStrength;
            float _RoughnessStrength;

            float _NormalStrength;

            float _Saturation;
            float _Contrast;
            float _Brightness;

            float _DitherStrength;

            // =====================================
            // TRIPLANAR
            // =====================================

            float3 GetTriWeights(float3 n)
            {
                float3 w = abs(n);

                w = pow(w, 4);

                return w / max(w.x + w.y + w.z, 0.0001);
            }

            half4 SampleTri(TEXTURE2D_PARAM(tex, samp), float3 p, float3 w)
            {
                float2 x = p.zy * _TextureTiling;
                float2 y = p.xz * _TextureTiling;
                float2 z = p.xy * _TextureTiling;

                half4 cx = SAMPLE_TEXTURE2D(tex, samp, x);
                half4 cy = SAMPLE_TEXTURE2D(tex, samp, y);
                half4 cz = SAMPLE_TEXTURE2D(tex, samp, z);

                return
                    cx * w.x +
                    cy * w.y +
                    cz * w.z;
            }

            float3 SampleTriNormal(TEXTURE2D_PARAM(tex, samp), float3 p, float3 w)
            {
                float2 x = p.zy * _TextureTiling;
                float2 y = p.xz * _TextureTiling;
                float2 z = p.xy * _TextureTiling;

                float3 nx = UnpackNormal(
                    SAMPLE_TEXTURE2D(tex, samp, x)
                );

                float3 ny = UnpackNormal(
                    SAMPLE_TEXTURE2D(tex, samp, y)
                );

                float3 nz = UnpackNormal(
                    SAMPLE_TEXTURE2D(tex, samp, z)
                );

                return normalize(
                    nx * w.x +
                    ny * w.y +
                    nz * w.z
                );
            }

            // =====================================
            // RNM NORMAL BLENDING
            // =====================================

            float3 BlendRNM(float3 n1, float3 n2)
            {
                n1 += float3(0,0,1);
                n2 *= float3(-1,-1,1);

                return normalize(n1 * dot(n1, n2) / n1.z - n2);
            }

            // =====================================
            // DITHER
            // =====================================

            float Dither(float2 screenPos)
            {
                return frac(
                    sin(dot(screenPos, float2(12.9898,78.233)))
                    * 43758.5453
                );
            }

            // =====================================
            // COLOR GRADE
            // =====================================

            float3 ApplyColorGrade(float3 col)
            {
                col += _Brightness;

                col = (col - 0.5) * _Contrast + 0.5;

                float l = dot(col, float3(0.299,0.587,0.114));

                col = lerp(float3(l,l,l), col, _Saturation);

                return col;
            }

            // =====================================
            // VERTEX
            // =====================================

            Varyings vert(Attributes v)
            {
                Varyings o;

                float3 worldPos =
                    TransformObjectToWorld(v.positionOS.xyz);

                o.worldPos = worldPos;

                o.worldNormal =
                    normalize(
                        TransformObjectToWorldNormal(v.normalOS)
                    );

                o.positionHCS =
                    TransformWorldToHClip(worldPos);

                o.shadowCoord =
                    TransformWorldToShadowCoord(worldPos);

                o.screenPos =
                    o.positionHCS;

                return o;
            }

            // =====================================
            // FRAGMENT
            // =====================================

            half4 frag(Varyings i) : SV_Target
            {
                float3 normalWS =
                    normalize(i.worldNormal);

                float3 w =
                    GetTriWeights(normalWS);

                // =========================
                // ALBEDO
                // =========================

                half4 albedo =
                    SampleTri(
                        TEXTURE2D_ARGS(_BaseColor, sampler_BaseColor),
                        i.worldPos,
                        w
                    );

                // =========================
                // NORMAL
                // =========================

                float3 triNormal =
                    SampleTriNormal(
                        TEXTURE2D_ARGS(_NormalMap, sampler_NormalMap),
                        i.worldPos,
                        w
                    );

                triNormal =
                    normalize(
                        lerp(
                            float3(0,0,1),
                            triNormal,
                            _NormalStrength
                        )
                    );

                float3 finalNormal =
                    BlendRNM(normalWS, triNormal);

                // =========================
                // HEIGHT
                // =========================

                float height =
                    SampleTri(
                        TEXTURE2D_ARGS(_HeightMap, sampler_HeightMap),
                        i.worldPos,
                        w
                    ).r;

                albedo.rgb *=
                    (1 + (height - 0.5) * _HeightStrength);

                // =========================
                // AO
                // =========================

                float ao =
                    SampleTri(
                        TEXTURE2D_ARGS(_AOMap, sampler_AOMap),
                        i.worldPos,
                        w
                    ).r;

                ao = lerp(1, ao, _AOStrength);

                albedo.rgb *= ao;

                // =========================
                // LIGHT
                // =========================

                Light mainLight =
                    GetMainLight(i.shadowCoord);

                float NdotL =
                    saturate(dot(finalNormal, mainLight.direction));

                float shadow =
                    mainLight.shadowAttenuation;

                // shadow stabilization
                shadow = lerp(0.15, shadow, 0.85);

                float diffuse =
                    NdotL * shadow;

                // =========================
                // ROUGHNESS
                // =========================

                float roughness =
                    SampleTri(
                        TEXTURE2D_ARGS(_RoughnessMap, sampler_RoughnessMap),
                        i.worldPos,
                        w
                    ).r;

                float rough =
                    lerp(1, roughness, _RoughnessStrength);

                diffuse *= lerp(1.15, 0.85, rough);

                // =========================
                // APPLY LIGHT
                // =========================

                float3 lighting =
                    mainLight.color * diffuse;

                lighting += 0.2;

                albedo.rgb *= lighting;

                // =========================
                // DITHER
                // =========================

                float2 screenUV =
                    i.screenPos.xy / i.screenPos.w;

                float noise =
                    Dither(screenUV * 400);

                albedo.rgb +=
                    (noise - 0.5) * _DitherStrength;

                // =========================
                // COLOR GRADE
                // =========================

                albedo.rgb =
                    ApplyColorGrade(albedo.rgb);

                return albedo;
            }

            ENDHLSL
        }

        // =====================================
        // SHADOW CASTER
        // =====================================

        Pass
        {
            Name "ShadowCaster"

            Tags
            {
                "LightMode"="ShadowCaster"
            }

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

            ENDHLSL
        }
    }
}