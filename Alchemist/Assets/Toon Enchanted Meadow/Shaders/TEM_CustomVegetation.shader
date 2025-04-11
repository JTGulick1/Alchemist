// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon/TEM_CustomVegetation"
{
	Properties
	{
		[Header(Textures)][Space(8)]_TextureRamp("Texture Ramp", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.475
		_MainTexture("Main Texture", 2D) = "white" {}
		_NormalMapScale("Normal Map Scale", Range( 0 , 1)) = 1
		[Normal]_NormalMap("Normal Map", 2D) = "white" {}
		[Header(Wind)][Space(8)][Toggle]_EnableWind("Enable Wind", Float) = 1
		[Space(2)]_WindDirection("WindDirection", Vector) = (1,0,0.5,0)
		_WindSwayStrength("Wind Sway Strength", Range( 0 , 1)) = 0.5
		_WindSwaySpeed("Wind Sway Speed", Range( 0 , 10)) = 0.4
		_WindJitterStrength("Wind Jitter Strength", Range( 0 , 1)) = 1
		_WindJitterSpeed("Wind Jitter Speed", Range( 0 , 10)) = 0.4
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
		#include "UnityStandardUtils.cginc"
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

		uniform float _EnableWind;
		uniform float3 _WindDirection;
		uniform sampler2D _NoiseTexture;
		uniform float _WindJitterSpeed;
		uniform float _WindJitterStrength;
		uniform float _WindSwaySpeed;
		uniform float _WindSwayStrength;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform sampler2D _TextureRamp;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _NormalMapScale;
		uniform float _Cutoff = 0.475;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 temp_cast_0 = (0.0).xxxx;
			float3 WindDirection411 = _WindDirection;
			float3 temp_output_593_0 = float3( (WindDirection411).xz ,  0.0 );
			float3 ase_positionWS = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult597 = (float2(ase_positionWS.x , ase_positionWS.z));
			float2 panner598 = ( 1.0 * _Time.y * ( temp_output_593_0 * (0.0 + (_WindJitterSpeed - 0.0) * (100.0 - 0.0) / (10.0 - 0.0)) ).xy + appendResult597);
			float4 WindJitter453 = tex2Dlod( _NoiseTexture, float4( ( panner598 / float2( 2,2 ) ), 0, 0.0) );
			float3 temp_output_520_0 = float3( (WindDirection411).xz ,  0.0 );
			float2 appendResult585 = (float2(ase_positionWS.x , ase_positionWS.z));
			float2 panner525 = ( 1.0 * _Time.y * ( temp_output_520_0 * (0.0 + (_WindSwaySpeed - 0.0) * (100.0 - 0.0) / (10.0 - 0.0)) ).xy + appendResult585);
			float4 WindSway515 = tex2Dlod( _NoiseTexture, float4( ( panner525 / float2( 150,150 ) ), 0, 0.0) );
			float4 transform437 = mul(unity_WorldToObject,( float4( WindDirection411 , 0.0 ) * ( ( WindJitter453 * (0.1 + (_WindJitterStrength - 0.0) * (1.0 - 0.1) / (1.0 - 0.0)) * v.color.r ) + ( v.color.g * WindSway515 * (0.5 + (_WindSwayStrength - 0.0) * (7.5 - 0.5) / (1.0 - 0.0)) ) ) ));
			float4 VertexOffset438 = transform437;
			v.vertex.xyz += (( _EnableWind )?( VertexOffset438 ):( temp_cast_0 )).xyz;
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
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float2 MainTextureTiling318 = ( i.uv_texcoord * 1.0 );
			float4 BlendedTextures406 = tex2D( _MainTexture, MainTextureTiling318 );
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
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float MainNormalMapScale582 = _NormalMapScale;
			float3 ase_positionWS = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_lightDirWS = 0;
			#else //aseld
			float3 ase_lightDirWS = normalize( UnityWorldSpaceLightDir( ase_positionWS ) );
			#endif //aseld
			float dotResult356 = dot( normalize( (WorldNormalVector( i , UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), MainNormalMapScale582 ) )) ) , ase_lightDirWS );
			float temp_output_359_0 = (dotResult356*0.49 + 0.5);
			float2 temp_cast_2 = (temp_output_359_0).xx;
			float3 ase_normalWS = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normalWSNorm = normalize( ase_normalWS );
			UnityGI gi361 = gi;
			float3 diffNorm361 = ase_normalWSNorm;
			gi361 = UnityGI_Base( data, 1, diffNorm361 );
			float3 indirectDiffuse361 = gi361.indirect.diffuse + diffNorm361 * 0.0001;
			float3 break357 = temp_output_354_0;
			float4 CustomLighting379 = ( ( ( BlendedTextures406 * float4( staticSwitch371 , 0.0 ) ) * ( ( tex2D( _TextureRamp, temp_cast_2 ) * float4( ( ase_lightColor.rgb + indirectDiffuse361 ) , 0.0 ) ) * ( temp_output_359_0 * max( max( break357.x , break357.y ) , break357.z ) ) ) ) + ( BlendedTextures406 * float4( ( indirectDiffuse361 * ase_lightColor.rgb * ase_lightColor.a ) , 0.0 ) ) );
			c.rgb = CustomLighting379.rgb;
			c.a = 1;
			clip( tex2D( _MainTexture, uv_MainTexture ).a - _Cutoff );
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
Node;AmplifyShaderEditor.Vector3Node;409;2016,912;Float;False;Property;_WindDirection;WindDirection;7;0;Create;True;0;0;0;False;1;Space(2);False;1,0,0.5;0.5,0,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;410;-1376,2176;Inherit;False;2115.348;746.7375;Comment;13;516;517;518;520;523;525;529;531;533;535;536;537;585;Sway;1,0,0.7064714,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;589;-1376,1392;Inherit;False;2115.348;746.7375;Comment;13;602;601;600;599;598;597;596;595;594;593;592;591;590;Jitter;1,0,0.7064714,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;411;2256,912;Inherit;False;WindDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;516;-1200,2576;Inherit;False;411;WindDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;590;-1200,1792;Inherit;False;411;WindDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;536;-1184,2704;Float;False;Property;_WindSwaySpeed;Wind Sway Speed;9;0;Create;True;0;0;0;False;0;False;0.4;1.75;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;517;-976,2576;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;592;-976,1792;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;591;-1184,1920;Float;False;Property;_WindJitterSpeed;Wind Jitter Speed;11;0;Create;True;0;0;0;False;0;False;0.4;0.16;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;520;-816,2576;Inherit;False;World;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;518;-816,2400;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;537;-880,2720;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;4;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;593;-816,1792;Inherit;False;World;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;594;-816,1616;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;595;-880,1936;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;4;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;405;2784,1520;Inherit;True;Property;_NormalMap;Normal Map;4;1;[Normal];Create;True;0;0;0;False;0;False;None;None;True;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;580;1920,1440;Inherit;False;Property;_NormalMapScale;Normal Map Scale;3;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;582;2432,1440;Inherit;False;MainNormalMapScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;535;-544,2624;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;585;-560,2496;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;596;-544,1840;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;597;-560,1712;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;317;3104,1520;Inherit;False;MainNormalMap;-1;True;1;0;SAMPLER2D;_Sampler0317;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;447;2784,1728;Inherit;True;Property;_NoiseTexture;Noise Texture;12;0;Create;True;0;0;0;False;0;False;None;0743b4c0c9f87f04db6d97cf3a093d82;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;309;1920,1088;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;308;1920,1216;Inherit;False;Constant;_MainTextureTiling;Main Texture Tiling;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;346;-1376,2992;Inherit;False;2436;1091;Comment;29;379;378;377;376;375;374;373;372;371;370;369;368;366;365;364;363;362;361;360;359;357;356;355;354;353;351;349;604;607;Custom Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;350;-1680,3200;Inherit;False;317;MainNormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;605;-1712,3456;Inherit;False;582;MainNormalMapScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;525;-320,2544;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;598;-320,1760;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;448;3024,1728;Inherit;False;NoiseTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;312;2240,1120;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LightColorNode;349;-1280,3712;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;351;-1328,3616;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;604;-1296,3280;Inherit;True;Property;_TextureSample2;Texture Sample 2;21;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleDivideOpNode;531;-16,2544;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;150,150;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;533;-112,2464;Inherit;False;448;NoiseTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;600;-112,1680;Inherit;False;448;NoiseTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;599;-16,1760;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;332;2784,1312;Inherit;True;Property;_MainTexture;Main Texture;2;0;Create;True;0;0;0;False;0;False;None;fec074f32e2e64f45aa5591a0e1befee;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;307;1184,2912;Inherit;False;1924;1003;Comment;3;404;382;381;Blended Textures;0,0.745283,0.293966,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;318;2464,1120;Inherit;False;MainTextureTiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;-1040,3616;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;353;-1088,3472;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;355;-976,3280;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;466;-864,624;Inherit;False;1604;723;Comment;13;433;432;434;437;463;444;464;431;430;465;425;435;436;Wind;0.05281782,0,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;529;128,2512;Inherit;True;Property;_NoiseTexture1;NoiseTexture;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;601;128,1728;Inherit;True;Property;_NoiseTexture2;NoiseTexture;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TexturePropertyNode;403;2784,1104;Inherit;True;Property;_TextureRamp;Texture Ramp;0;1;[Header];Create;True;1;Textures;0;0;False;1;Space(8);False;None;069955a34770d354e819c2e2180fb61f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;340;3024,1312;Inherit;False;MainTexture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.BreakToComponentsNode;357;-800,3616;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;358;3024,1104;Inherit;False;TextureRamp;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DotProductOpNode;356;-704,3440;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;463;-800,1136;Inherit;False;Property;_WindSwayStrength;Wind Sway Strength;8;0;Create;True;0;0;0;False;0;False;0.5;0.55;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;425;-816,752;Inherit;False;Property;_WindJitterStrength;Wind Jitter Strength;10;0;Create;True;0;0;0;False;0;False;1;0.13;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;515;768,2512;Inherit;False;WindSway;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;453;768,1728;Inherit;False;WindJitter;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;381;2112,3216;Inherit;False;318;MainTextureTiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;382;2112,3136;Inherit;False;340;MainTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;360;-672,3616;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;361;-736,3824;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;362;-592,3344;Inherit;False;358;TextureRamp;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;444;-432,672;Inherit;False;453;WindJitter;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;431;-720,848;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;430;-464,1088;Inherit;False;515;WindSway;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;464;-432,752;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;465;-464,1168;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.5;False;4;FLOAT;7.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;404;2576,3168;Inherit;True;Property;_MainTextureRef;Main Texture Ref;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ScaleAndOffsetNode;359;-544,3456;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0.49;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;363;-1088,3168;Inherit;False;Constant;_Value;Value;1;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;364;-528,3632;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;365;-432,3728;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;366;-304,3280;Inherit;True;Property;_TextureRampRef;Texture Ramp Ref;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;433;-112,896;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;432;-112,1104;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;406;3152,3168;Inherit;False;BlendedTextures;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;368;-288,3488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;369;-704,3920;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;32,3376;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;371;-656,3088;Inherit;True;Property;_UNITY_PASS_FORWARDBASE4;UNITY_PASS_FORWARDBASE;1;0;Create;False;0;0;0;True;0;False;0;0;0;False;UNITY_PASS_FORWARDBASE;Toggle;2;UNITY_PASS_FORWARDBASE;Key1;Fetch;False;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;607;-80,3088;Inherit;False;406;BlendedTextures;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;434;128,944;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;435;80,768;Inherit;False;411;WindDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;372;176,3136;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;373;-304,3856;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;375;208,3392;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;32,3600;Inherit;False;406;BlendedTextures;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;436;320,864;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;376;384,3264;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;377;384,3616;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;437;528,960;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;378;640,3424;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;438;768,960;Inherit;False;VertexOffset;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;539;-1296,4144;Inherit;False;1748;635;Comment;13;551;550;549;548;547;546;545;544;543;542;541;540;441;Overlay Coverage;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;554;1184,4000;Inherit;False;1684;1307;Comment;23;577;576;575;574;573;572;571;570;569;568;567;566;565;564;563;562;561;560;559;558;557;556;555;Blended Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;407;1888,1888;Inherit;False;340;MainTexture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;470;1856,2144;Inherit;False;Constant;_DeactivateWind;DeactivateWind;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;439;1856,2224;Inherit;False;438;VertexOffset;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;379;816,3424;Inherit;False;CustomLighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;540;-1248,4192;Inherit;False;317;MainNormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;551;-1248,4544;Inherit;False;-1;;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;541;-1008,4192;Inherit;True;Property;_TextureSample1;Texture Sample 0;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;542;-1008,4384;Inherit;False;Property;_CovOffset;Overlay Coverage;5;0;Create;False;0;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;543;-1008,4544;Inherit;True;Property;_CovMask;Coverage Mask;14;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.WorldNormalVector;545;-688,4192;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;544;-688,4352;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;547;-416,4288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;546;-432,4416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;441;-448,4528;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;548;-176,4400;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;549;16,4400;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;550;208,4400;Inherit;False;OverlayCoverage;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;555;1472,4976;Inherit;False;Constant;_Vector5;Vector 5;17;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;556;1472,5152;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;557;1440,4656;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;558;1440,4496;Inherit;False;-1;;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DotProductOpNode;563;1728,4976;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;564;1216,4448;Inherit;False;Constant;_Vector2;Vector 2;15;0;Create;True;0;0;0;False;0;False;1,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;565;1216,4288;Inherit;False;Constant;_Vector1;Vector 1;15;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;566;1216,4816;Inherit;False;Constant;_Vector4;Vector 4;15;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;567;1232,4672;Inherit;False;Constant;_Vector3;Vector 3;15;0;Create;True;0;0;0;False;0;False;1,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;561;1216,4048;Inherit;False;317;MainNormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;560;1216,4128;Inherit;False;318;MainTextureTiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;562;1200,4208;Inherit;False;582;MainNormalMapScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;559;1440,4576;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;568;1728,5184;Inherit;False;550;OverlayCoverage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;569;1712,4512;Inherit;True;Spherical;World;True;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;8;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;570;1488,4048;Inherit;True;Property;_MainNormalMapRef;Main Normal Map Ref;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;571;2048,4976;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;572;1632,4304;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;573;1552,4784;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;574;1824,4256;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;575;2144,4672;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;576;2272,4976;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;577;2592,4640;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;408;2096,1888;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SwizzleNode;523;-592,2416;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;602;-592,1632;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;380;2096,2080;Inherit;False;379;CustomLighting;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;578;2928,4656;Inherit;False;BlendedNormals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;468;2096,2176;Inherit;False;Property;_EnableWind;Enable Wind;6;0;Create;True;0;0;0;False;2;Header(Wind);Space(8);False;1;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2416,1792;Float;False;True;-1;2;;0;0;CustomLighting;Toon/TEM_CustomVegetation;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.475;True;True;0;True;TransparentCutout;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;15.82;0,0,0,0;VertexOffset;False;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;411;0;409;0
WireConnection;517;0;516;0
WireConnection;592;0;590;0
WireConnection;520;0;517;0
WireConnection;537;0;536;0
WireConnection;593;0;592;0
WireConnection;595;0;591;0
WireConnection;582;0;580;0
WireConnection;535;0;520;0
WireConnection;535;1;537;0
WireConnection;585;0;518;1
WireConnection;585;1;518;3
WireConnection;596;0;593;0
WireConnection;596;1;595;0
WireConnection;597;0;594;1
WireConnection;597;1;594;3
WireConnection;317;0;405;0
WireConnection;525;0;585;0
WireConnection;525;2;535;0
WireConnection;598;0;597;0
WireConnection;598;2;596;0
WireConnection;448;0;447;0
WireConnection;312;0;309;0
WireConnection;312;1;308;0
WireConnection;604;0;350;0
WireConnection;604;5;605;0
WireConnection;531;0;525;0
WireConnection;599;0;598;0
WireConnection;318;0;312;0
WireConnection;354;0;351;0
WireConnection;354;1;349;1
WireConnection;354;2;349;2
WireConnection;355;0;604;0
WireConnection;529;0;533;0
WireConnection;529;1;531;0
WireConnection;601;0;600;0
WireConnection;601;1;599;0
WireConnection;340;0;332;0
WireConnection;357;0;354;0
WireConnection;358;0;403;0
WireConnection;356;0;355;0
WireConnection;356;1;353;0
WireConnection;515;0;529;0
WireConnection;453;0;601;0
WireConnection;360;0;357;0
WireConnection;360;1;357;1
WireConnection;464;0;425;0
WireConnection;465;0;463;0
WireConnection;404;0;382;0
WireConnection;404;1;381;0
WireConnection;359;0;356;0
WireConnection;364;0;360;0
WireConnection;364;1;357;2
WireConnection;365;0;349;1
WireConnection;365;1;361;0
WireConnection;366;0;362;0
WireConnection;366;1;359;0
WireConnection;433;0;444;0
WireConnection;433;1;464;0
WireConnection;433;2;431;1
WireConnection;432;0;431;2
WireConnection;432;1;430;0
WireConnection;432;2;465;0
WireConnection;406;0;404;0
WireConnection;368;0;359;0
WireConnection;368;1;364;0
WireConnection;370;0;366;0
WireConnection;370;1;365;0
WireConnection;371;1;354;0
WireConnection;371;0;363;0
WireConnection;434;0;433;0
WireConnection;434;1;432;0
WireConnection;372;0;607;0
WireConnection;372;1;371;0
WireConnection;373;0;361;0
WireConnection;373;1;369;1
WireConnection;373;2;369;2
WireConnection;375;0;370;0
WireConnection;375;1;368;0
WireConnection;436;0;435;0
WireConnection;436;1;434;0
WireConnection;376;0;372;0
WireConnection;376;1;375;0
WireConnection;377;0;374;0
WireConnection;377;1;373;0
WireConnection;437;0;436;0
WireConnection;378;0;376;0
WireConnection;378;1;377;0
WireConnection;438;0;437;0
WireConnection;379;0;378;0
WireConnection;541;0;540;0
WireConnection;543;0;551;0
WireConnection;545;0;541;0
WireConnection;544;0;542;0
WireConnection;547;0;545;2
WireConnection;547;1;544;0
WireConnection;546;0;543;4
WireConnection;548;0;547;0
WireConnection;548;1;546;0
WireConnection;548;2;441;4
WireConnection;549;0;548;0
WireConnection;550;0;549;0
WireConnection;563;0;555;0
WireConnection;563;1;556;0
WireConnection;569;0;558;0
WireConnection;569;8;559;0
WireConnection;569;3;557;0
WireConnection;570;0;561;0
WireConnection;570;1;560;0
WireConnection;570;5;562;0
WireConnection;571;0;563;0
WireConnection;571;1;568;0
WireConnection;572;0;565;0
WireConnection;572;1;564;0
WireConnection;573;0;567;0
WireConnection;573;1;566;0
WireConnection;574;0;570;0
WireConnection;574;1;572;0
WireConnection;575;0;569;0
WireConnection;575;1;573;0
WireConnection;576;0;571;0
WireConnection;577;0;574;0
WireConnection;577;1;575;0
WireConnection;577;2;576;0
WireConnection;408;0;407;0
WireConnection;523;0;518;0
WireConnection;602;0;594;0
WireConnection;578;0;574;0
WireConnection;468;0;470;0
WireConnection;468;1;439;0
WireConnection;0;10;408;4
WireConnection;0;13;380;0
WireConnection;0;11;468;0
ASEEND*/
//CHKSM=CAE341344418FAE4CEC7C335FC0BED9AC43C9DA0