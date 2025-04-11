// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon/TEM_CustomGrass"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_TextureRamp("Texture Ramp", 2D) = "white" {}
		_MainTextureTiling("Main Texture Tiling", Range( 1 , 20)) = 1
		_MainTexture("Main Texture", 2D) = "white" {}
		[Toggle]_Highlights("Highlights", Float) = 1
		_HighlightsColor("Highlights Color", Color) = (0,0,0,0)
		[Toggle]_Wind("Wind", Float) = 1
		_WindDirection("WindDirection", Vector) = (1,0,0.5,0)
		_WindSwayStrength("Wind Sway Strength", Range( 0 , 10)) = 1
		_WindWavesScale("Wind Noise Scale", Range( 0.1 , 10)) = 1
		_WindWavesScale1("Wind Noise Speed", Range( 0.1 , 10)) = 1
		_NoiseTexture("Noise Texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#define ASE_VERSION 19801
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _Wind;
		uniform float3 _WindDirection;
		uniform sampler2D _NoiseTexture;
		uniform float _WindWavesScale1;
		uniform float _WindWavesScale;
		uniform float _WindSwayStrength;
		uniform sampler2D _MainTexture;
		uniform float _MainTextureTiling;
		uniform float _Highlights;
		uniform sampler2D _TextureRamp;
		uniform float4 _HighlightsColor;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 temp_cast_0 = (0.0).xxxx;
			float3 WindDirection411 = _WindDirection;
			float2 appendResult681 = (float2(_WindDirection.x , _WindDirection.z));
			float2 WindDirection2D682 = appendResult681;
			float3 ase_positionWS = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult678 = (float2(ase_positionWS.x , ase_positionWS.z));
			float2 panner675 = ( -1.0 * _Time.y * ( WindDirection2D682 * (0.1 + (_WindWavesScale1 - 0.1) * (5.0 - 0.1) / (10.0 - 0.1)) ) + ( appendResult678 * ( 1.0 / (0.1 + (_WindWavesScale - 0.1) * (150.0 - 0.1) / (10.0 - 0.1)) ) ));
			float4 WindSway453 = tex2Dlod( _NoiseTexture, float4( panner675, 0, 0.0) );
			float4 transform437 = mul(unity_WorldToObject,( float4( WindDirection411 , 0.0 ) * ( WindSway453 * (0.0 + (_WindSwayStrength - 0.0) * (30.0 - 0.0) / (10.0 - 0.0)) * v.color.g ) ));
			float4 VertexOffset438 = transform437;
			v.vertex.xyz += (( _Wind )?( VertexOffset438 ):( temp_cast_0 )).xyz;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float4 tex2DNode404 = tex2D( _MainTexture, ( i.uv_texcoord * _MainTextureTiling ) );
			float4 MainTexture587 = tex2DNode404;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 temp_output_354_0 = ( ase_lightAtten * ase_lightColor.rgb * ase_lightColor.a );
			float3 temp_cast_0 = (1.0).xxx;
			#ifdef UNITY_PASS_FORWARDBASE
				float3 staticSwitch371 = temp_cast_0;
			#else
				float3 staticSwitch371 = temp_output_354_0;
			#endif
			float3 ase_normalWS = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normalWSNorm = normalize( ase_normalWS );
			float3 ase_positionWS = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_lightDirWS = 0;
			#else //aseld
			float3 ase_lightDirWS = normalize( UnityWorldSpaceLightDir( ase_positionWS ) );
			#endif //aseld
			float dotResult356 = dot( ase_normalWSNorm , ase_lightDirWS );
			float temp_output_359_0 = (dotResult356*0.49 + 0.5);
			float2 temp_cast_2 = (temp_output_359_0).xx;
			UnityGI gi361 = gi;
			float3 diffNorm361 = ase_normalWSNorm;
			gi361 = UnityGI_Base( data, 1, diffNorm361 );
			float3 indirectDiffuse361 = gi361.indirect.diffuse + diffNorm361 * 0.0001;
			float3 break357 = temp_output_354_0;
			float4 temp_output_378_0 = ( ( ( MainTexture587 * float4( staticSwitch371 , 0.0 ) ) * ( ( tex2D( _TextureRamp, temp_cast_2 ) * float4( ( ase_lightColor.rgb + indirectDiffuse361 ) , 0.0 ) ) * ( temp_output_359_0 * max( max( break357.x , break357.y ) , break357.z ) ) ) ) + ( float4( ( indirectDiffuse361 * ase_lightColor.rgb * ase_lightColor.a ) , 0.0 ) * MainTexture587 ) );
			float2 temp_cast_6 = (temp_output_359_0).xx;
			float4 blendOpSrc619 = _HighlightsColor;
			float4 blendOpDest619 = temp_output_378_0;
			float2 appendResult681 = (float2(_WindDirection.x , _WindDirection.z));
			float2 WindDirection2D682 = appendResult681;
			float2 appendResult678 = (float2(ase_positionWS.x , ase_positionWS.z));
			float2 panner675 = ( -1.0 * _Time.y * ( WindDirection2D682 * (0.1 + (_WindWavesScale1 - 0.1) * (5.0 - 0.1) / (10.0 - 0.1)) ) + ( appendResult678 * ( 1.0 / (0.1 + (_WindWavesScale - 0.1) * (150.0 - 0.1) / (10.0 - 0.1)) ) ));
			float4 WindSway453 = tex2D( _NoiseTexture, panner675 );
			float4 lerpBlendMode619 = lerp(blendOpDest619, (( blendOpSrc619 > 0.5 ) ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpSrc619 - 0.5 ) ) * ( 1.0 - blendOpDest619 ) ) : ( 2.0 * blendOpSrc619 * blendOpDest619 ) ),( WindSway453 * i.vertexColor.g * ase_lightAtten * ase_lightColor ).r);
			float4 CustomLighting379 = (( _Highlights )?( ( saturate( lerpBlendMode619 )) ):( temp_output_378_0 ));
			c.rgb = CustomLighting379.rgb;
			c.a = 1;
			clip( tex2DNode404.a - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows dithercrossfade vertex:vertexDataFunc 

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
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.CommentaryNode;538;-896,1520;Inherit;False;1643;435;Comment;13;472;490;613;668;683;680;678;675;689;677;692;693;694;Sway;0,0.7165971,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;409;1024,2112;Float;False;Property;_WindDirection;WindDirection;7;0;Create;True;0;0;0;False;0;False;1,0,0.5;0.1,0,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;681;1360,2192;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;490;-864,1728;Inherit;False;Property;_WindWavesScale;Wind Noise Scale;9;0;Create;False;0;0;0;False;0;False;1;5;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;346;-1936,2000;Inherit;False;2436;1091;Comment;34;378;377;376;375;374;373;372;371;370;369;368;367;366;365;364;363;362;361;360;359;357;356;355;354;353;351;349;616;619;620;686;685;698;699;Custom Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;682;1536,2192;Inherit;False;WindDirection2D;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;472;-880,1568;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;693;-864,1856;Inherit;False;Property;_WindWavesScale1;Wind Noise Speed;10;0;Create;False;0;0;0;False;0;False;1;1.5;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;668;-512,1648;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;10;False;3;FLOAT;0.1;False;4;FLOAT;150;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;349;-1840,2720;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;351;-1888,2624;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;687;1904,2080;Inherit;True;Property;_NoiseTexture;Noise Texture;11;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DynamicAppendNode;678;-656,1568;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;683;-192,1680;Inherit;False;682;WindDirection2D;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;613;-320,1632;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;694;-304,1776;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;10;False;3;FLOAT;0.1;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;308;1248,2672;Inherit;False;Property;_MainTextureTiling;Main Texture Tiling;2;0;Create;True;0;0;0;False;0;False;1;1;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;309;1248,2544;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;353;-1664,2464;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;-1600,2624;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;355;-1616,2320;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;403;1904,2288;Inherit;True;Property;_TextureRamp;Texture Ramp;1;0;Create;True;0;0;0;False;0;False;None;069955a34770d354e819c2e2180fb61f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;688;2144,2080;Inherit;False;NoiseTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;680;-128,1568;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;692;32,1712;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;312;1568,2576;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;356;-1376,2400;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;357;-1360,2624;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;358;2144,2288;Inherit;False;TextureRamp;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;332;1472,2368;Inherit;True;Property;_MainTexture;Main Texture;3;0;Create;True;0;0;0;False;0;False;None;fec074f32e2e64f45aa5591a0e1befee;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;689;192,1568;Inherit;False;688;NoiseTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;675;208,1648;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-1,-1;False;1;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;404;1888,2512;Inherit;True;Property;_MainTextureRef;Main Texture Ref;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMaxOpNode;360;-1232,2624;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;361;-1296,2832;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;362;-1152,2352;Inherit;False;358;TextureRamp;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;359;-1104,2464;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0.49;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;677;448,1664;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.CommentaryNode;466;-864,720;Inherit;False;1604;723;Comment;8;433;437;431;435;436;425;444;669;Wind;0.05281782,0,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;587;2224,2512;Inherit;False;MainTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;363;-1648,2176;Inherit;False;Constant;_Value;Value;1;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;364;-1088,2640;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;365;-992,2736;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;366;-864,2288;Inherit;True;Property;_TextureRampRef;Texture Ramp Ref;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;453;816,1664;Inherit;False;WindSway;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;425;-784,864;Inherit;False;Property;_WindSwayStrength;Wind Sway Strength;8;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;-528,2384;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;371;-1216,2096;Inherit;True;Property;_UNITY_PASS_FORWARDBASE4;UNITY_PASS_FORWARDBASE;1;0;Create;False;0;0;0;True;0;False;0;0;0;False;UNITY_PASS_FORWARDBASE;Toggle;2;UNITY_PASS_FORWARDBASE;Key1;Fetch;False;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;367;-672,2128;Inherit;False;587;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;368;-848,2512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;369;-1264,2928;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.VertexColorNode;431;-432,1040;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;444;-400,784;Inherit;False;453;WindSway;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;411;1312,2112;Inherit;False;WindDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;669;-432,864;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;4;FLOAT;30;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;373;-864,2864;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;372;-400,2256;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;-592,2928;Inherit;False;587;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;375;-352,2448;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;435;80,864;Inherit;False;411;WindDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;433;-112,992;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;376;-160,2320;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;377;-160,2496;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;620;-176,2608;Inherit;False;453;WindSway;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;698;-288,2864;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;685;-224,2688;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;699;-176,2944;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;616;-192,2112;Inherit;False;Property;_HighlightsColor;Highlights Color;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.7787376,0.8313726,0.380392,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;436;352,1008;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;378;80,2432;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;686;96,2640;Inherit;False;4;4;0;COLOR;1,1,1,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;437;528,1056;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;619;256,2336;Inherit;False;HardLight;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;438;768,1056;Inherit;False;VertexOffset;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ToggleSwitchNode;695;560,2432;Inherit;False;Property;_Highlights;Highlights;4;0;Create;True;0;0;0;False;0;False;1;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;439;1952,2848;Inherit;False;438;VertexOffset;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;470;1952,2768;Inherit;False;Constant;_DeactivateWind;DeactivateWind;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;379;816,2432;Inherit;False;CustomLighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;380;2192,2704;Inherit;False;379;CustomLighting;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;468;2192,2800;Inherit;False;Property;_Wind;Wind;6;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2512,2416;Float;False;True;-1;2;;0;0;CustomLighting;Toon/TEM_CustomGrass;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;15.82;0,0,0,0;VertexOffset;False;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;681;0;409;1
WireConnection;681;1;409;3
WireConnection;682;0;681;0
WireConnection;668;0;490;0
WireConnection;678;0;472;1
WireConnection;678;1;472;3
WireConnection;613;1;668;0
WireConnection;694;0;693;0
WireConnection;354;0;351;0
WireConnection;354;1;349;1
WireConnection;354;2;349;2
WireConnection;688;0;687;0
WireConnection;680;0;678;0
WireConnection;680;1;613;0
WireConnection;692;0;683;0
WireConnection;692;1;694;0
WireConnection;312;0;309;0
WireConnection;312;1;308;0
WireConnection;356;0;355;0
WireConnection;356;1;353;0
WireConnection;357;0;354;0
WireConnection;358;0;403;0
WireConnection;675;0;680;0
WireConnection;675;2;692;0
WireConnection;404;0;332;0
WireConnection;404;1;312;0
WireConnection;360;0;357;0
WireConnection;360;1;357;1
WireConnection;359;0;356;0
WireConnection;677;0;689;0
WireConnection;677;1;675;0
WireConnection;587;0;404;0
WireConnection;364;0;360;0
WireConnection;364;1;357;2
WireConnection;365;0;349;1
WireConnection;365;1;361;0
WireConnection;366;0;362;0
WireConnection;366;1;359;0
WireConnection;453;0;677;0
WireConnection;370;0;366;0
WireConnection;370;1;365;0
WireConnection;371;1;354;0
WireConnection;371;0;363;0
WireConnection;368;0;359;0
WireConnection;368;1;364;0
WireConnection;411;0;409;0
WireConnection;669;0;425;0
WireConnection;373;0;361;0
WireConnection;373;1;369;1
WireConnection;373;2;369;2
WireConnection;372;0;367;0
WireConnection;372;1;371;0
WireConnection;375;0;370;0
WireConnection;375;1;368;0
WireConnection;433;0;444;0
WireConnection;433;1;669;0
WireConnection;433;2;431;2
WireConnection;376;0;372;0
WireConnection;376;1;375;0
WireConnection;377;0;373;0
WireConnection;377;1;374;0
WireConnection;436;0;435;0
WireConnection;436;1;433;0
WireConnection;378;0;376;0
WireConnection;378;1;377;0
WireConnection;686;0;620;0
WireConnection;686;1;685;2
WireConnection;686;2;698;0
WireConnection;686;3;699;0
WireConnection;437;0;436;0
WireConnection;619;0;616;0
WireConnection;619;1;378;0
WireConnection;619;2;686;0
WireConnection;438;0;437;0
WireConnection;695;0;378;0
WireConnection;695;1;619;0
WireConnection;379;0;695;0
WireConnection;468;0;470;0
WireConnection;468;1;439;0
WireConnection;0;10;404;4
WireConnection;0;13;380;0
WireConnection;0;11;468;0
ASEEND*/
//CHKSM=B7FC6B882056282350073C955B6BF9ACD2261B9E