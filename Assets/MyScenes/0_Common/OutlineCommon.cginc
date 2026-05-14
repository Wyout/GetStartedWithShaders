#ifndef OUTLINE_COMMON
#define OUTLINE_COMMON

// Texture
sampler2D _MainTex;
float4 _MainTex_ST;
half4 _Color;

// Outline
float _OutlineWidth;
half4 _OutlineColor;

// Clip
float _ClipThreshold;


struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
};

v2f vert (appdata v)
{
    v2f o;

    // Texture
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    
    // Outline
    float3 viewPos = UnityObjectToViewPos(v.vertex);
    float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
    viewNormal.z = -0.5;
    viewPos = viewPos + normalize(viewNormal) * _OutlineWidth * 0.002;
    
    o.vertex = mul(UNITY_MATRIX_P, float4(viewPos, 1.0));

    return o;
}

half4 frag (v2f i) : SV_Target
{
    //texture color affects outline color
    half4 albedo = tex2D(_MainTex, i.uv) * _Color;
    half3 color = albedo * _OutlineColor.rgb;

    // Clip
#if defined (IS_CLIP)
    clip(albedo - _ClipThreshold);
#endif

#if defined(IS_TRANSPARENT)
    return half4(color, albedo.a);
#else 
    return half4(color, 1.0);
#endif
}
#endif