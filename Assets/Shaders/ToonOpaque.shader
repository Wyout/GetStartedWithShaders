Shader "GetStartedWithShader/ToonOpaque"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowThreshold("Shadow Threshold", Range(-1.0, 1.0)) = 0.0
        _ShadowColor ("Shadow Color", Color) = (0.5, 0.5, 0.5, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half _ShadowThreshold;
            half4 _ShadowColor;

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

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normalDir = normalize(i.normalDir);
                half3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                half nl = dot(lightDir, normalDir);
                half diff = nl > _ShadowThreshold ? 1.0 : _ShadowColor.rgb;

                fixed4 col = tex2D(_MainTex, i.uv);
                return half4(diff.rrr, 1.0);
            }
            ENDCG
        }
    }
}
