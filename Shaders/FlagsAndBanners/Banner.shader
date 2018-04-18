/*
** Copyright 2018, Unity Opensource Shaders
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
**
*  A simple shader designed to cover the needs of banners. This shader
*  provides a unique texture for each side of the banner to allow for
*  a more multi-fabric sewn banner look.
* 
*  Originally written for use with Aquarius Max's Fantasy Castle pack.
*/

Shader "Aquarius Max/Banner"
{
    Properties
    {
        _BaseBannerColor("Base Banner Color", Color) = (0.3432094,0.3579256,0.5073529,0)
        [Toggle(_USEFRONTIMAGE_ON)] _UseFrontImage("Use Front Image", Float) = 0
        _BannerFrontImage("Banner Front Image", 2D) = "white" {}
        [Toggle(_USEBACKIMAGE_ON)] _UseBackImage("Use Back Image", Float) = 0
        _BannerBackImage("Banner Back Image", 2D) = "white" {}
        [HideInInspector] _texcoord( "", 2D ) = "white" {}
        [HideInInspector] __dirty( "", Int ) = 1
        _BannerHoleMask("Banner Hole Mask", 2D) = "white" {}
    }

    SubShader
    {
        Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
        Cull Off
        CGINCLUDE
        #include "UnityPBSLighting.cginc"
        #include "Lighting.cginc"
        #pragma target 3.0
        #pragma shader_feature _USEFRONTIMAGE_ON
        #pragma shader_feature _USEBACKIMAGE_ON
        struct Input
        {
            float2 uv_texcoord;
            fixed ASEVFace : VFACE;
        };

        uniform float4 _BaseBannerColor;
        uniform sampler2D _BannerFrontImage;
        uniform float4 _BannerFrontImage_ST;
        uniform sampler2D _BannerBackImage;
        uniform float4 _BannerBackImage_ST;
        uniform sampler2D _BannerHoleMask;
        uniform float4 _BannerHoleMask_ST;

        void surf( Input i , inout SurfaceOutputStandard o )
        {
            float2 uv_BannerFrontImage = i.uv_texcoord * _BannerFrontImage_ST.xy + _BannerFrontImage_ST.zw;
            float4 tex2DNode2 = tex2D( _BannerFrontImage, uv_BannerFrontImage );
            float4 lerpResult8 = lerp( _BaseBannerColor , tex2DNode2 , tex2DNode2.a);
            #ifdef _USEFRONTIMAGE_ON
                float4 staticSwitch22 = lerpResult8;
            #else
                float4 staticSwitch22 = _BaseBannerColor;
            #endif
            float2 uv_BannerBackImage = i.uv_texcoord * _BannerBackImage_ST.xy + _BannerBackImage_ST.zw;
            float4 tex2DNode16 = tex2D( _BannerBackImage, uv_BannerBackImage );
            float4 lerpResult17 = lerp( tex2DNode16 , _BaseBannerColor , tex2DNode16.a);
            #ifdef _USEBACKIMAGE_ON
                float4 staticSwitch23 = lerpResult17;
            #else
                float4 staticSwitch23 = _BaseBannerColor;
            #endif
            float4 switchResult15 = (((i.ASEVFace>0)?(staticSwitch22):(staticSwitch23)));
            o.Albedo = switchResult15.rgb;
            float2 uv_BannerHoleMask = i.uv_texcoord * _BannerHoleMask_ST.xy + _BannerHoleMask_ST.zw;
            o.Alpha = tex2D( _BannerHoleMask, uv_BannerHoleMask ).r;
        }

        ENDCG
        CGPROGRAM
        #pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

        ENDCG
        Pass
        {
            Name "ShadowCaster"
            Tags{ "LightMode" = "ShadowCaster" }
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_shadowcaster
            #pragma multi_compile UNITY_PASS_SHADOWCASTER
            #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
            #include "HLSLSupport.cginc"
            #if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
                #define CAN_SKIP_VPOS
            #endif
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            sampler3D _DitherMaskLOD;
            struct v2f
            {
                V2F_SHADOW_CASTER;
                float2 customPack1 : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            v2f vert( appdata_full v )
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_INITIALIZE_OUTPUT( v2f, o );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                Input customInputData;
                float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
                o.customPack1.xy = customInputData.uv_texcoord;
                o.customPack1.xy = v.texcoord;
                o.worldPos = worldPos;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
                return o;
            }
            fixed4 frag( v2f IN
            #if !defined( CAN_SKIP_VPOS )
            , UNITY_VPOS_TYPE vpos : VPOS
            #endif
            ) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID( IN );
                Input surfIN;
                UNITY_INITIALIZE_OUTPUT( Input, surfIN );
                surfIN.uv_texcoord = IN.customPack1.xy;
                float3 worldPos = IN.worldPos;
                fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
                SurfaceOutputStandard o;
                UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
                surf( surfIN, o );
                #if defined( CAN_SKIP_VPOS )
                float2 vpos = IN.pos;
                #endif
                half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
                clip( alphaRef - 0.01 );
                SHADOW_CASTER_FRAGMENT( IN )
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
