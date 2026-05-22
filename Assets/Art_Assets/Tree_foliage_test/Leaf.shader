Shader "Custom/LeafWind_URP"
{
    Properties
    {
        [MainTexture] _BaseMap ("Leaf Texture", 2D) = "white" {}
        [MainColor] _BaseColor ("Leaf Color", Color) = (1,1,1,1)

        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5

        // wind
        _WindStrength ("Wind Strength", Range(0,1)) = 0.1
        _WindSpeed ("Wind Speed", Range(0,10)) = 2.0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest"
        }

        Cull Off

        Pass
        {
            Name "ForwardLit"

            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            // shadows
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;

                float3 normalWS : TEXCOORD1;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)

                half4 _BaseColor;
                float4 _BaseMap_ST;

                half _Cutoff;

                half _WindStrength;
                half _WindSpeed;

            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float3 position = IN.positionOS.xyz;

                // anim wind


                float time = _Time.y * _WindSpeed;


                float wind =
                    sin(position.x * 2.0 + time) *
                    _WindStrength;


                wind *= position.y;


                position.x += wind;


                VertexPositionInputs posInputs =
                    GetVertexPositionInputs(position);

                OUT.positionHCS = posInputs.positionCS;

                OUT.normalWS =
                    TransformObjectToWorldNormal(IN.normalOS);

                OUT.uv =
                    TRANSFORM_TEX(IN.uv, _BaseMap);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 tex =
                    SAMPLE_TEXTURE2D(
                        _BaseMap,
                        sampler_BaseMap,
                        IN.uv);

                half4 color = tex * _BaseColor;

 
                clip(color.a - _Cutoff);

                Light mainLight = GetMainLight();

                half3 normalWS =
                    normalize(IN.normalWS);

                half NdotL =
                    saturate(dot(normalWS, mainLight.direction));

                half3 diffuse =
                    color.rgb *
                    mainLight.color *
                    NdotL;

                return half4(diffuse, 1);
            }

            ENDHLSL
        }


        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}