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
		[Header(Sigil)]
        _Sigil("Sigil Albedo", 2D) = "white" {}
        _SigilNormal("Sigil Normal", 2D) = "white" {}
		[Toggle]_Tile("Tile Sigil", Float) = 0
		_SigilScale("Sigil Scale", Float) = 1
		_SigilOffset("Sigil Offset", Vector) = (0,0,0,0)

        [Header(BaseTexture)]
        _BannerColor("Banner Color", Color) = (1,1,1,1)
        _BaseBanner("Base Banner Albedo", 2D) = "white" {}
		_BaseBannerNormal("Base Banner Normal", 2D) = "white" {}
		[Toggle]_TwoSidedSigil("Two Sided Sigil", Float) = 0
		_Tear("Tear", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			fixed ASEVFace : VFACE;
		};

		uniform sampler2D _BaseBannerNormal;
		uniform float4 _BaseBannerNormal_ST;
		uniform sampler2D _SigilNormal;
		uniform float _Tile;
		uniform float _SigilScale;
		uniform float2 _SigilOffset;
		uniform float4 _BannerColor;
		uniform sampler2D _BaseBanner;
		uniform float4 _BaseBanner_ST;
		uniform sampler2D _Sigil;
		uniform float _TwoSidedSigil;
		uniform sampler2D _Tear;
		uniform float4 _Tear_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BaseBannerNormal = i.uv_texcoord * _BaseBannerNormal_ST.xy + _BaseBannerNormal_ST.zw;
			float4 tex2DNode46 = tex2D( _BaseBannerNormal, uv_BaseBannerNormal );
			float2 uv_TexCoord5_g21 = i.uv_texcoord * float2( 1,1 ) + float2( -0.5,-0.5 );
			float2 temp_output_9_0_g21 = ( ( uv_TexCoord5_g21 * ( 1.0 / _SigilScale ) ) + float2( 0.5,0.5 ) + _SigilOffset );
			float2 clampResult12_g21 = clamp( temp_output_9_0_g21 , float2( -0.0001,-0.0001 ) , float2( 1.0001,1.0001 ) );
			float4 tex2DNode14_g21 = tex2D( _SigilNormal, lerp(clampResult12_g21,temp_output_9_0_g21,_Tile) );
			float4 lerpResult47 = lerp( tex2DNode46 , tex2DNode14_g21 , tex2DNode14_g21.a);
			float4 switchResult19 = (((i.ASEVFace>0)?(lerpResult47):(tex2DNode46)));
			o.Normal = switchResult19.rgb;
			float2 uv_BaseBanner = i.uv_texcoord * _BaseBanner_ST.xy + _BaseBanner_ST.zw;
			float4 tex2DNode20 = tex2D( _BaseBanner, uv_BaseBanner );
			float4 temp_output_49_0 = ( _BannerColor * tex2DNode20 );
			float2 uv_TexCoord5_g20 = i.uv_texcoord * float2( 1,1 ) + float2( -0.5,-0.5 );
			float2 temp_output_9_0_g20 = ( ( uv_TexCoord5_g20 * ( 1.0 / _SigilScale ) ) + float2( 0.5,0.5 ) + _SigilOffset );
			float2 clampResult12_g20 = clamp( temp_output_9_0_g20 , float2( -0.0001,-0.0001 ) , float2( 1.0001,1.0001 ) );
			float4 tex2DNode14_g20 = tex2D( _Sigil, lerp(clampResult12_g20,temp_output_9_0_g20,_Tile) );
			float4 lerpResult27 = lerp( temp_output_49_0 , tex2DNode14_g20 , tex2DNode14_g20.a);
			float4 switchResult18 = (((i.ASEVFace>0)?(lerpResult27):(lerp(temp_output_49_0,lerpResult27,_TwoSidedSigil))));
			o.Albedo = switchResult18.rgb;
			float2 uv_Tear = i.uv_texcoord * _Tear_ST.xy + _Tear_ST.zw;
			o.Alpha = ( tex2DNode20.a * tex2D( _Tear, uv_Tear ) ).r;
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
	CustomEditor "ASEMaterialInspector"
}