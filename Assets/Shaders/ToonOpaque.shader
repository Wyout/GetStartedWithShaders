Shader "GetStartedWithShader/ToonOpaque"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _ShadowThreshold("Shadow Threshold", Range(-1.0, 1.0)) = 0.0
        _ShadowColor ("Shadow Color", Color) = (0.5, 0.5, 0.5, 1.0)

        [HDR] _SpecularColor("Specular Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _SpecularPower("Specular Power", float) = 20
        _SpecularThreshold("Specular Threshold", Range(0.0, 1.0)) = 0.5
        _OutlineWidth("Outline Width", Range(0.0, 3.0)) = 1.0
        _OutlineColor("Outline Color", Color) = (0.5, 0.5, 0.5)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half _ShadowThreshold;
            half4 _ShadowColor;
            half4 _Color;

            half _SpecularPower;
            half _SpecularThreshold;
            half4 _SpecularColor;

            float4 _LightColor0;

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
                half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 halfDir = normalize(viewDir + lightDir);

                // Defaut color
                half3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                // Diffuse lighting
                half nl = dot(lightDir, normalDir);
                half3 diff = nl > _ShadowThreshold ? 1.0 : _ShadowColor.rgb;

                // Specular lighting
                half nh = dot(normalDir, halfDir);
                half3 spec = pow(max(nh, 1e-5), _SpecularPower) > _SpecularThreshold ? _SpecularColor.rgb : 0.0;

                // Ambient lighting
                half3 ambient = ShadeSH9(half4(0.0, 1.0, 0.0, 1.0));
                
                // Combine all
                half3 color = ambient * albedo.rgb + (diff + spec) * albedo.rgb  * _LightColor0.rgb;              
                return half4(color, 1.0);
            }
            ENDCG
        }
        
        // Outline
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            // Texture
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Color;

            // Outline
            float _OutlineWidth;
            half4 _OutlineColor;


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
                half3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                half3 color = albedo * _OutlineColor.rgb;

                return half4(color, 1.0);
            }
            ENDCG
        }
       
    }
}