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

Shader "Aquarius Max/Advanced Banner Shader"
{
	Properties
	{
		[HideInInspector] _VTInfoBlock( "VT( auto )", Vector ) = ( 0, 0, 0, 0 )
		[Header(BannerImage)]
        _BannerBaseColor("Banner Base Color", Color) = (0,0,0,0)
		_BackgroundAlbedo("Background Albedo", 2D) = "white" {}
		_BackgroundNormal("Background Normal", 2D) = "white" {}
        [Toggle(_SIGILONBACK_ON)] _SigilonBack("Sigil on Back", Float) = 0
        [Toggle(_SIGILONFRONT_ON)] _SigilonFront("Sigil on Front", Float) = 0

        _SigilAlbedo("Sigil Albedo", 2D) = "white" {}
		_SigilNormal("Sigil Normal", 2D) = "white" {}
        
        _BackSigilAlbedo("Back Sigil Albedo", 2D) = "white" {}
		_BackSigilNormal("Back Sigil Normal", 2D) = "white" {}
        
		_BannerHoleMask("Banner Hole Mask", 2D) = "white" {}
        
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
        
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "Amplify" = "True"  }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _SIGILONFRONT_ON
		#pragma shader_feature _SIGILONBACK_ON
		struct Input
		{
			float2 uv_texcoord;
			fixed ASEVFace : VFACE;
		};

		uniform sampler2D _BackgroundNormal;
		uniform sampler2D _SigilNormal;
		uniform float4 _SigilNormal_ST;
		uniform sampler2D _BackSigilNormal;
		uniform float4 _BackSigilNormal_ST;
		uniform sampler2D _BackgroundAlbedo;
		uniform float4 _BannerBaseColor;
		uniform sampler2D _SigilAlbedo;
		uniform float4 _SigilAlbedo_ST;
		uniform sampler2D _BackSigilAlbedo;
		uniform float4 _BackSigilAlbedo_ST;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform sampler2D _BannerHoleMask;
		uniform float4 _BannerHoleMask_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 _Color3 = float4(1,1,1,1);
			float4 temp_output_9_0_g6 = ( tex2D( _BackgroundNormal, float2( 0,0 ) ) * _Color3 );
			float2 uv_SigilNormal = i.uv_texcoord * _SigilNormal_ST.xy + _SigilNormal_ST.zw;
			float4 tex2DNode10_g6 = tex2D( _SigilNormal, uv_SigilNormal );
			float4 lerpResult12_g6 = lerp( temp_output_9_0_g6 , ( tex2DNode10_g6 * _Color3 ) , tex2DNode10_g6.a);
			#ifdef _SIGILONFRONT_ON
				float4 staticSwitch31_g6 = lerpResult12_g6;
			#else
				float4 staticSwitch31_g6 = temp_output_9_0_g6;
			#endif
			float2 uv_TexCoord4_g6 = i.uv_texcoord * _BackSigilNormal_ST.xy + _BackSigilNormal_ST.zw;
			float4 tex2DNode8_g6 = tex2D( _BackSigilNormal, ( float2( -1,1 ) * uv_TexCoord4_g6 ) );
			float4 lerpResult11_g6 = lerp( temp_output_9_0_g6 , ( tex2DNode8_g6 * _Color3 ) , tex2DNode8_g6.a);
			#ifdef _SIGILONBACK_ON
				float4 staticSwitch30_g6 = lerpResult11_g6;
			#else
				float4 staticSwitch30_g6 = temp_output_9_0_g6;
			#endif
			float4 switchResult15_g6 = (((i.ASEVFace>0)?(staticSwitch31_g6):(staticSwitch30_g6)));
			o.Normal = switchResult15_g6.rgb;
			float4 temp_output_9_0_g5 = ( tex2D( _BackgroundAlbedo, float2( 0,0 ) ) * _BannerBaseColor );
			float2 uv_SigilAlbedo = i.uv_texcoord * _SigilAlbedo_ST.xy + _SigilAlbedo_ST.zw;
			float4 tex2DNode10_g5 = tex2D( _SigilAlbedo, uv_SigilAlbedo );
			float4 lerpResult12_g5 = lerp( temp_output_9_0_g5 , ( tex2DNode10_g5 * float4(0,0,0,0) ) , tex2DNode10_g5.a);
			#ifdef _SIGILONFRONT_ON
				float4 staticSwitch31_g5 = lerpResult12_g5;
			#else
				float4 staticSwitch31_g5 = temp_output_9_0_g5;
			#endif
			float2 uv_TexCoord4_g5 = i.uv_texcoord * _BackSigilAlbedo_ST.xy + _BackSigilAlbedo_ST.zw;
			float4 tex2DNode8_g5 = tex2D( _BackSigilAlbedo, ( float2( -1,1 ) * uv_TexCoord4_g5 ) );
			float4 lerpResult11_g5 = lerp( temp_output_9_0_g5 , ( tex2DNode8_g5 * float4(1,1,1,0) ) , tex2DNode8_g5.a);
			#ifdef _SIGILONBACK_ON
				float4 staticSwitch30_g5 = lerpResult11_g5;
			#else
				float4 staticSwitch30_g5 = temp_output_9_0_g5;
			#endif
			float4 switchResult15_g5 = (((i.ASEVFace>0)?(staticSwitch31_g5):(staticSwitch30_g5)));
			o.Albedo = switchResult15_g5.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
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
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
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