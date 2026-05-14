#ifndef SHADING_COMMON
#define SHADING_COMMON

sampler2D _MainTex;
float4 _MainTex_ST;
half4 _Color;

sampler2D _GradientMap;
sampler2D _ShadowColor1stTex;
sampler2D _ShadowColor2ndTex;
half4 _ShadowColor1st;
half4 _ShadowColor2nd;

half _SpecularPower;
half4 _SpecularColor;

half _RimPower;
half4 _RimColor;

float4 _LightColor0;

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
    float3 normalDir : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
};

v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normalDir = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    return o;
}

half4 frag (v2f i) : SV_Target
{
    half3 normalDir = normalize(i.normalDir);
    half3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
    half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
    half3 halfDir = normalize(viewDir + lightDir);

    // Defaut color
    half4 albedo = tex2D(_MainTex, i.uv) * _Color;

    // Diffuse lighting
    half nl = dot(lightDir, normalDir);
    half2 diffGradient = tex2D(_GradientMap, float2(nl * 0.5 +0.5, 0.5)).rg;
    half3 diffColor = lerp(albedo.rgb, tex2D(_ShadowColor1stTex, i.uv) * _ShadowColor1st.rgb, diffGradient.x);
    diffColor = lerp(diffColor, tex2D(_ShadowColor2ndTex, i.uv) * _ShadowColor2nd.rgb, diffGradient.y);

    // Specular lighting
    half nh = dot(normalDir, halfDir);
    half specGradient = tex2D(_GradientMap, float2(pow(max(nh, 1e-5), _SpecularPower), 0.5)).b;
    half3 specColor = specGradient * _SpecularColor.rgb * albedo;

    // Ambient lighting
    half3 ambient = ShadeSH9(half4(0.0, 1.0, 0.0, 1.0));

    // Rim lighting
    half nv = dot(normalDir, viewDir);
    nv = 1 - nv;
    half rimGradient = tex2D(_GradientMap, float2(pow(max(nv, 1e-5), _RimPower), 0.5)).a;
    half3 rimColor = rimGradient * _RimColor.rgb * albedo;

    // Clip
#if defined (IS_CLIP)
    clip(albedo - _ClipThreshold);
#endif
    // Combine all
    half3 color = ambient * albedo.rgb + (diffColor + specColor) * _LightColor0.rgb + rimColor;  

#if defined (IS_TRANSPARENT)          
    return half4(color, albedo.a);
#else
    return half4(color, 1.0);
#endif
}
#endif