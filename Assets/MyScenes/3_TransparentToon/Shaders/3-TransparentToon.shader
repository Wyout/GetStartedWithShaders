Shader "GetStartedWithShader/TransparentToon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _GradientMap ("Gradient Map", 2D) = "white" {}

        _ShadowColor1stTex("1st Shadow Color Tex", 2D) = "white" {}
        _ShadowColor2ndTex("2nd Shadow Color Tex", 2D) = "white" {}
        _ShadowColor1st("1st Shadow Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _ShadowColor2nd("2nd Shadow Color", Color) = (1.0, 1.0, 1.0, 1.0)

        [HDR] _SpecularColor("Specular Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _SpecularPower("Specular Power", float) = 20

        [HDR] _RimColor("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _RimPower("Rim Power", float) = 20
        
        _OutlineWidth("Outline Width", Range(0.0, 3.0)) = 1.0
        _OutlineColor("Outline Color", Color) = (0.5, 0.5, 0.5)
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" } // "Transparent = 3000"

        Pass
        {
            ZWrite On
            ColorMask 0
        }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #define IS_TRANSPARENT
            #include "Assets/MyScenes/0_Common/ShadingCommon.cginc"

            ENDCG
        }
        
        // Outline
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            Cull Front
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define IS_TRANSPARENT
            #include "Assets/MyScenes/0_Common/OutlineCommon.cginc"
            
            ENDCG
        }
       
    }
}