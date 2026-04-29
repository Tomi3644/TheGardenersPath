Shader "Custom/TerrainShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)

        _MaskTex ("Mask (RGBA)", 2D) = "black" {}

        _Layer0Tex ("Layer 0 (RGB)", 2D) = "white" {}
        _Layer1Tex ("Layer 1 (RGB)", 2D) = "white" {}
        _Layer2Tex ("Layer 2 (RGB)", 2D) = "white" {}
        _Layer3Tex ("Layer 3 (RGB)", 2D) = "white" {}
        _Layer4Tex ("Layer 4 (RGB)", 2D) = "white" {}

        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MaskTex;

        sampler2D _Layer0Tex;
        sampler2D _Layer1Tex;
        sampler2D _Layer2Tex;
        sampler2D _Layer3Tex;
        sampler2D _Layer4Tex;

        struct Input
        {
            float2 uv_MaskTex;
            float2 uv_Layer0Tex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Masque RGBA (contrôle des textures)
            fixed4 blend = tex2D(_MaskTex, IN.uv_MaskTex);

            // Textures
            fixed4 c0 = tex2D(_Layer0Tex, IN.uv_Layer0Tex);
            fixed4 c1 = tex2D(_Layer1Tex, IN.uv_Layer0Tex);
            fixed4 c2 = tex2D(_Layer2Tex, IN.uv_Layer0Tex);
            fixed4 c3 = tex2D(_Layer3Tex, IN.uv_Layer0Tex);
            fixed4 c4 = tex2D(_Layer4Tex, IN.uv_Layer0Tex);

            // Blend progressif
            fixed4 c = lerp(c0, c1, blend.r);
            c = lerp(c, c2, blend.g);
            c = lerp(c, c3, blend.b);
            c = lerp(c, c4, blend.a);

            // Résultat final
            o.Albedo = c.rgb * _Color;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }

    FallBack "Diffuse"
}