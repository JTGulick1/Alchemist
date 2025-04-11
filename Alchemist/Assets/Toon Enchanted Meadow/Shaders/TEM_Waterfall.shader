// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon/TEM_Waterfall"
{
	Properties
	{
		[Header(Textures)][Space(8)]_TilingSize("Tiling Size", Float) = 6
		_DistortionAmount("Distortion Amount", Range( -1 , 1)) = 0.35
		_LerpStrength("Lerp Strength", Range( 0 , 1)) = 1
		[Normal]_NormalMap("Normal Map", 2D) = "bump" {}
		_NoiseTexture1("Noise Texture 1", 2D) = "white" {}
		_NoiseTexture2("Noise Texture 2", 2D) = "white" {}
		_NoiseTexture3("Noise Texture 3", 2D) = "white" {}
		_FlowDirection("Flow Direction", Vector) = (1,0,0.5,0)
		_VerticalFlowSpeed("Vertical Flow Speed", Vector) = (0,0.65,0,0)
		[Header(Water Colors)][Space(8)]_ShallowColor("Shallow Color", Color) = (0,0,0,0)
		_DeepColor("Deep Color", Color) = (0,0,0,0)
		_ShallowColorDepth("Shallow Color Depth", Range( 0 , 30)) = 2.75
		_FresnelColor("Fresnel Color", Color) = (0.8313726,0.8313726,0.8313726,1)
		_FresnelIntensity("Fresnel Intensity", Range( 0 , 1)) = 0.4
		_DepthFadeDistance("Depth Fade Distance", Range( 1 , 20)) = 1.5
		_CameraDepthFadeLength("Camera Depth Fade Length", Range( 0 , 16)) = 1
		_CameraDepthFadeOffset("Camera Depth Fade Offset", Range( 0 , 6)) = 0.5
		_Highlights1Color("Highlights 1 Color", Color) = (0.5896226,0.9331943,1,1)
		_Highlights2Color("Highlights 2 Color", Color) = (0,0.5954423,0.6792453,1)
		[Header(Edge Foam)][Space(8)]_EdgeFoamColor("Edge Foam Color", Color) = (1,1,1,1)
		_EdgeFoamOpacity("Edge Foam Opacity", Range( 0 , 1)) = 0.65
		_EdgeFoamDistance("Edge Foam Distance", Range( 0 , 1)) = 1
		_EdgeFoamHardness("Edge Foam Hardness", Range( 0 , 1)) = 0.33
		_EdgeFade1("Edge Fade", Range( 0 , 1)) = 1
		[Header(Reflections)][Space(8)]_ReflectionsColor("Reflections Color", Color) = (1,1,1,1)
		_ReflectionsCutoff("Reflections Cutoff", Range( 0 , 1)) = 0.35
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.65
		_Occlusion("Occlusion", Range( 0 , 1)) = 0.65
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ "_BeforeWater" }
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.5
		#define ASE_VERSION 19801
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha addshadow fullforwardshadows nodirlightmap vertex:vertexDataFunc 
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float4 screenPos;
			float eyeDepth;
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

		uniform float4 _Highlights1Color;
		uniform sampler2D _NoiseTexture2;
		uniform float2 _VerticalFlowSpeed;
		uniform float4 _Highlights2Color;
		uniform sampler2D _NoiseTexture3;
		uniform float4 _EdgeFoamColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform sampler2D _NoiseTexture1;
		uniform float3 _FlowDirection;
		uniform float _TilingSize;
		uniform float _EdgeFoamDistance;
		uniform float _EdgeFoamHardness;
		uniform float _EdgeFoamOpacity;
		uniform float _EdgeFade1;
		uniform sampler2D _NormalMap;
		uniform float _ReflectionsCutoff;
		uniform float4 _ReflectionsColor;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _BeforeWater )
		uniform float _DistortionAmount;
		uniform float _DepthFadeDistance;
		uniform float _LerpStrength;
		uniform float _Smoothness;
		uniform float _Occlusion;
		uniform float4 _ShallowColor;
		uniform float4 _DeepColor;
		uniform float _ShallowColorDepth;
		uniform float4 _FresnelColor;
		uniform float _FresnelIntensity;
		uniform float _CameraDepthFadeLength;
		uniform float _CameraDepthFadeOffset;


		float3 ASESafeNormalize(float3 inVec)
		{
			float dp3 = max(1.175494351e-38, dot(inVec, inVec));
			return inVec* rsqrt(dp3);
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float4 ase_positionSS = float4( i.screenPos.xyz , i.screenPos.w + 1e-7 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_positionSS );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 appendResult1329 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
			float3 temp_output_1232_0 = float3( (_FlowDirection).xz ,  0.0 );
			float3 ase_positionWS = i.worldPos;
			float2 appendResult1233 = (float2(ase_positionWS.x , ase_positionWS.z));
			float2 panner1236 = ( 7.916384 * _Time.y * temp_output_1232_0.xy + appendResult1233);
			float TexturesScale1231 = _TilingSize;
			float2 Panner11245 = ( panner1236 / TexturesScale1231 );
			float4 ase_positionSSNorm = ase_positionSS / ase_positionSS.w;
			ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
			float screenDepth1256 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth1256 = saturate( abs( ( screenDepth1256 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _DepthFadeDistance ) ) );
			float depthFade1262 = distanceDepth1256;
			float3 FlowDirection1234 = _FlowDirection;
			float3 temp_output_1249_0 = float3( (FlowDirection1234).xz ,  0.0 );
			float2 appendResult1250 = (float2(( ase_positionWS.x * 1.27943 ) , ( ase_positionWS.z * 1.27943 )));
			float2 panner1255 = ( 3.4984 * _Time.y * temp_output_1249_0.xy + appendResult1250);
			float2 Panner21271 = ( panner1255 / TexturesScale1231 );
			float3 lerpResult1294 = lerp( UnpackScaleNormal( tex2D( _NormalMap, Panner11245 ), ( _DistortionAmount * depthFade1262 ) ) , UnpackScaleNormal( tex2D( _NormalMap, Panner21271 ), ( depthFade1262 * _DistortionAmount ) ) , _LerpStrength);
			float3 normalMapping1302 = lerpResult1294;
			float2 screenUV1337 = ( appendResult1329 - ( (normalMapping1302).xy * 0.1 ) );
			float4 screenColor1218 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BeforeWater,screenUV1337);
			float3 indirectNormal1205 = normalize( WorldNormalVector( i , normalMapping1302 ) );
			Unity_GlossyEnvironmentData g1205 = UnityGlossyEnvironmentSetup( _Smoothness, data.worldViewDir, indirectNormal1205, float3(0,0,0));
			float3 indirectSpecular1205 = UnityGI_IndirectSpecular( data, _Occlusion, indirectNormal1205, g1205 );
			float screenDepth1191 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth1191 = abs( ( screenDepth1191 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _ShallowColorDepth ) );
			float clampResult1194 = clamp( distanceDepth1191 , 0.0 , 1.0 );
			float4 lerpResult1200 = lerp( _ShallowColor , _DeepColor , clampResult1194);
			float3 ase_normalWS = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normalWSNorm = normalize( ase_normalWS );
			UnityGI gi1371 = gi;
			float3 diffNorm1371 = ase_normalWSNorm;
			gi1371 = UnityGI_Base( data, 1, diffNorm1371 );
			float3 indirectDiffuse1371 = gi1371.indirect.diffuse + diffNorm1371 * 0.0001;
			float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - ase_positionWS );
			float3 ase_viewDirWS = normalize( ase_viewVectorWS );
			float fresnelNdotV1204 = dot( ase_normalWS, ase_viewDirWS );
			float fresnelNode1204 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV1204, (10.0 + (_FresnelIntensity - 0.0) * (0.0 - 10.0) / (1.0 - 0.0)) ) );
			float clampResult1211 = clamp( fresnelNode1204 , 0.0 , 1.0 );
			float4 lerpResult1221 = lerp( ( float4( indirectSpecular1205 , 0.0 ) + ( lerpResult1200 * float4( indirectDiffuse1371 , 0.0 ) ) ) , _FresnelColor , clampResult1211);
			float cameraDepthFade1330 = (( i.eyeDepth -_ProjectionParams.y - _CameraDepthFadeOffset ) / _CameraDepthFadeLength);
			float cameraDepthFade1338 = saturate( cameraDepthFade1330 );
			float4 lerpResult1226 = lerp( screenColor1218 , lerpResult1221 , ( cameraDepthFade1338 * depthFade1262 ));
			c.rgb = lerpResult1226.rgb;
			c.a = 1;
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
			float3 ase_normalWS = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normalWSNorm = normalize( ase_normalWS );
			float3 ase_positionWS = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_lightDirWS = 0;
			#else //aseld
			float3 ase_lightDirWS = normalize( UnityWorldSpaceLightDir( ase_positionWS ) );
			#endif //aseld
			float dotResult860 = dot( ase_normalWSNorm , ase_lightDirWS );
			float NormalCalc863 = dotResult860;
			float2 FlowSpeed794 = _VerticalFlowSpeed;
			float2 uv_TexCoord648 = i.uv_texcoord * float2( 6,1 );
			float2 panner644 = ( 1.1 * _Time.y * ( FlowSpeed794 * float2( 0,1.31 ) ) + uv_TexCoord648);
			float2 uv_TexCoord700 = i.uv_texcoord * float2( 5,1 );
			float2 panner701 = ( 1.1 * _Time.y * ( FlowSpeed794 * float2( 0,-0.32 ) ) + uv_TexCoord700);
			float2 uv_TexCoord677 = i.uv_texcoord * float2( 2,1 );
			float2 panner678 = ( 1.1 * _Time.y * ( FlowSpeed794 * float2( 0,2 ) ) + uv_TexCoord677);
			float2 uv_TexCoord820 = i.uv_texcoord * float2( 6,1 );
			float2 panner819 = ( 1.1 * _Time.y * ( FlowSpeed794 * float2( 0,2.6 ) ) + uv_TexCoord820);
			float4 blendOpSrc825 = tex2D( _NoiseTexture3, panner678 );
			float4 blendOpDest825 = ( NormalCalc863 * tex2D( _NoiseTexture3, panner819 ) );
			float4 lerpBlendMode825 = lerp(blendOpDest825,( blendOpSrc825 + blendOpDest825 ),NormalCalc863);
			float4 blendOpSrc686 = ( _Highlights1Color * 5.0 * ( NormalCalc863 * ( tex2D( _NoiseTexture2, panner644 ) * tex2D( _NoiseTexture2, panner701 ) ) ) );
			float4 blendOpDest686 = ( _Highlights2Color * 2.0 * ( saturate( lerpBlendMode825 )) );
			float4 lerpResult657 = lerp( float4( 0,0,0,0 ) , ( saturate( ( blendOpSrc686 + blendOpDest686 ) )) , i.vertexColor.a);
			float4 VerticalReflections660 = lerpResult657;
			float4 ase_positionSS = float4( i.screenPos.xyz , i.screenPos.w + 1e-7 );
			float4 ase_positionSSNorm = ase_positionSS / ase_positionSS.w;
			ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
			float3 temp_output_1232_0 = float3( (_FlowDirection).xz ,  0.0 );
			float2 appendResult1233 = (float2(ase_positionWS.x , ase_positionWS.z));
			float2 panner1236 = ( 7.916384 * _Time.y * temp_output_1232_0.xy + appendResult1233);
			float TexturesScale1231 = _TilingSize;
			float2 Panner11245 = ( panner1236 / TexturesScale1231 );
			float screenDepth1270 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth1270 = abs( ( screenDepth1270 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( ( tex2D( _NoiseTexture1, Panner11245 ).r * (0.0 + (_EdgeFoamDistance - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) );
			float clampResult1282 = clamp( distanceDepth1270 , 0.0 , 1.0 );
			float clampResult1301 = clamp( pow( clampResult1282 , (1.0 + (_EdgeFoamHardness - 0.0) * (10.0 - 1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
			float screenDepth1291 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth1291 = abs( ( screenDepth1291 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( (0.0 + (_EdgeFoamDistance - 0.0) * (15.0 - 0.0) / (1.0 - 0.0)) ) );
			float clampResult1298 = clamp( distanceDepth1291 , 0.0 , 1.0 );
			float screenDepth1315 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth1315 = abs( ( screenDepth1315 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _EdgeFade1 ) );
			float EdgeFoam1332 = ( ( ( ( 1.0 - clampResult1301 ) * _EdgeFoamOpacity ) + ( ( 1.0 - clampResult1298 ) * ( (0.0 + (_EdgeFoamOpacity - 0.0) * (0.85 - 0.0) / (1.0 - 0.0)) * tex2D( _NoiseTexture1, Panner11245 ).r ) ) ) * saturate( distanceDepth1315 ) );
			float3 temp_cast_2 = (1.0).xxx;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 lerpResult1209 = lerp( temp_cast_2 , ase_lightColor.rgb , 1.0);
			float3 normalizeResult1278 = ASESafeNormalize( ( _WorldSpaceCameraPos - ase_positionWS ) );
			float dotResult1304 = dot( reflect( -normalizeResult1278 , (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, Panner11245 ) ) )) ) , ase_lightDirWS );
			float saferPower1312 = abs( dotResult1304 );
			float3 FlowDirection1234 = _FlowDirection;
			float3 temp_output_1249_0 = float3( (FlowDirection1234).xz ,  0.0 );
			float2 appendResult1250 = (float2(( ase_positionWS.x * 1.27943 ) , ( ase_positionWS.z * 1.27943 )));
			float2 panner1255 = ( 3.4984 * _Time.y * temp_output_1249_0.xy + appendResult1250);
			float2 Panner21271 = ( panner1255 / TexturesScale1231 );
			float4 clampResult1331 = clamp( ( ( pow( saferPower1312 , exp( (0.0 + (_ReflectionsCutoff - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) * ase_lightColor * float4( ase_lightColor.rgb , 0.0 ) * ase_lightColor.a ) * UnpackNormal( tex2D( _NormalMap, Panner21271 ) ).g ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 ReflexionsCutoff1339 = ( clampResult1331 * _ReflectionsColor );
			o.Emission = ( ( ( VerticalReflections660 + ( _EdgeFoamColor * EdgeFoam1332 ) ) * float4( lerpResult1209 , 0.0 ) ) + ReflexionsCutoff1339 ).rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.CommentaryNode;1181;-2768,-2576;Inherit;False;1396;395;Comment;9;1239;1236;1235;1234;1233;1232;1229;1228;1227;Panner1;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1182;-2768,-3152;Inherit;False;260;163;Comment;1;1230;Texture Scale;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;1227;-2720,-2480;Float;False;Property;_FlowDirection;Flow Direction;7;0;Create;True;0;0;0;False;0;False;1,0,0.5;0.25,0.05,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;1228;-2240,-2528;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;1229;-2416,-2368;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1230;-2720,-3104;Inherit;False;Property;_TilingSize;Tiling Size;0;1;[Header];Create;True;1;Textures;0;0;False;1;Space(8);False;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1231;-2448,-3104;Inherit;False;TexturesScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;1232;-2240,-2368;Inherit;False;World;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;1233;-1984,-2512;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1235;-1792,-2336;Inherit;False;1231;TexturesScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;1236;-1776,-2480;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;7.916384;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;1183;-2768,-2112;Inherit;False;1392.502;427;Comment;10;1261;1255;1254;1250;1249;1243;1242;1241;1238;1237;Panner2;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1234;-2448,-2480;Inherit;False;FlowDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1239;-1520,-2416;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;173;624,-4016;Float;True;Property;_NoiseTexture1;Noise Texture 1;4;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;1237;-2720,-1968;Inherit;False;1234;FlowDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1238;-2448,-2032;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;1185;-3632,496;Inherit;False;3315.78;661.7512;EdgeFoam;30;1327;1320;1319;1315;1314;1313;1308;1307;1306;1305;1301;1300;1299;1298;1293;1292;1291;1290;1289;1282;1281;1280;1270;1269;1260;1253;1252;1248;1247;1246;EdgeFoam;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1245;-1344,-2416;Inherit;False;Panner1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;431;864,-4016;Inherit;False;NoiseMap1;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;1184;-2768,-1280;Inherit;False;902.656;187.6821;Depth Fade;2;1256;1251;Depth Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;1241;-2448,-1872;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleNode;1242;-2224,-2064;Inherit;False;1.27943;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;1243;-2224,-1952;Inherit;False;1.27943;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1246;-3136,832;Float;False;Property;_EdgeFoamDistance;Edge Foam Distance;21;0;Create;True;0;0;0;False;0;False;1;0.04;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1247;-3344,576;Inherit;False;431;NoiseMap1;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;1248;-3552,848;Inherit;False;1245;Panner1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;812;2208,-4016;Inherit;False;Property;_VerticalFlowSpeed;Vertical Flow Speed;8;0;Create;True;0;0;0;False;0;False;0,0.65;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TransformDirectionNode;1249;-2272,-1872;Inherit;False;World;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;1250;-2016,-2064;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1251;-2720,-1232;Inherit;False;Property;_DepthFadeDistance;Depth Fade Distance;14;0;Create;True;0;0;0;False;0;False;1.5;12;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1252;-2800,688;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1253;-3152,576;Inherit;True;Property;_TextureSample3;Texture Sample 3;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.CommentaryNode;885;144,-3552;Inherit;False;2692;1236;Comment;38;799;823;815;804;800;648;700;824;820;821;701;644;809;808;818;819;677;810;807;817;678;790;865;811;859;864;789;673;853;672;687;682;825;674;671;656;686;657;Vertical Reflections;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;794;2448,-4016;Inherit;False;FlowSpeed;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;1186;-3248,-256;Inherit;False;2912.429;589.1261;Reflections;25;1336;1333;1331;1326;1318;1317;1312;1311;1310;1309;1304;1303;1297;1296;1295;1288;1287;1286;1279;1278;1268;1267;1266;1259;1258;Reflections;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;1254;-1936,-1840;Inherit;False;1231;TexturesScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;1255;-1808,-2016;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;3.4984;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DepthFade;1256;-2352,-1216;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1260;-2512,592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;799;208,-3216;Inherit;False;794;FlowSpeed;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;45;144,-4016;Float;True;Property;_NormalMap;Normal Map;3;1;[Normal];Create;True;0;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;1187;-1744,-928;Inherit;False;1556.876;561.5722;Normal Mapping;12;1294;1285;1284;1283;1277;1276;1275;1274;1273;1272;1265;1264;Normal Mapping;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;1258;-2976,-208;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;1259;-3200,-96;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;1261;-1520,-1968;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1262;-1776,-1216;Inherit;False;depthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;426;384,-4016;Inherit;False;NormalMap;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;1269;-2576,704;Float;False;Property;_EdgeFoamHardness;Edge Foam Hardness;22;0;Create;True;0;0;0;False;0;False;0.33;0.33;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;1270;-2336,576;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;791;1104,-4016;Float;True;Property;_NoiseTexture2;Noise Texture 2;5;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;861;1616,-3856;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;862;1632,-4016;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;892;672,-4240;Inherit;True;Property;_NoiseTexture3;Noise Texture 3;6;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;823;544,-2576;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,2.6;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1264;-1712,-624;Inherit;False;1262;depthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1265;-1712,-800;Inherit;False;Property;_DistortionAmount;Distortion Amount;1;0;Create;True;0;0;0;False;0;False;0.35;0.5;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1266;-2640,-112;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1267;-2960,0;Inherit;False;426;NormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;1268;-2960,96;Inherit;False;1245;Panner1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1271;-1344,-1968;Inherit;False;Panner2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;1280;-2448,800;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1281;-2240,672;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1282;-2064,576;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;792;1360,-4016;Inherit;False;NoiseMap2;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DotProductOpNode;860;1856,-4016;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;893;960,-4240;Inherit;False;NoiseMap3;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;800;688,-3280;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,1.31;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;824;912,-2400;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;804;688,-3152;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,-0.32;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;815;544,-2768;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;700;656,-3040;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;5,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;648;656,-3424;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;6,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;820;832,-2576;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;6,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1272;-912,-880;Inherit;False;426;NormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;1273;-912,-704;Inherit;False;426;NormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;1274;-1104,-800;Inherit;False;1245;Panner1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1275;-1104,-640;Inherit;False;1271;Panner2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1276;-1264,-720;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1277;-1264,-544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;1278;-2384,-192;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1279;-2704,0;Inherit;True;Property;_TextureSample5;Texture Sample 5;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;1289;-2336,1024;Inherit;False;1245;Panner1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1290;-1888,688;Float;False;Property;_EdgeFoamOpacity;Edge Foam Opacity;20;0;Create;True;0;0;0;False;0;False;0.65;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;1291;-2048,768;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;1292;-1760,576;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1293;-2128,912;Inherit;False;431;NoiseMap1;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;863;1984,-4016;Inherit;False;NormalCalc;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;821;912,-2656;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;644;944,-3280;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,1;False;1;FLOAT;1.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;701;944,-3056;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,1;False;1;FLOAT;1.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;819;1184,-2576;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,1.17;False;1;FLOAT;1.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;809;944,-3360;Inherit;False;792;NoiseMap2;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;818;1184,-2656;Inherit;False;893;NoiseMap3;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;808;944,-3136;Inherit;False;792;NoiseMap2;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;677;832,-2832;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1283;-688,-672;Inherit;True;Property;_TextureSample2;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;1284;-688,-880;Inherit;True;Property;_NormalMap2;Normal Map;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;1285;-688,-464;Inherit;False;Property;_LerpStrength;Lerp Strength;2;0;Create;True;0;0;0;False;0;False;1;2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1286;-2304,208;Float;False;Property;_ReflectionsCutoff;Reflections Cutoff;28;0;Create;True;0;0;0;False;0;False;0.35;0.45;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;1287;-2400,0;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;1288;-2208,-192;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;1298;-1760,768;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1299;-1888,912;Inherit;True;Property;_TextureSample4;Texture Sample 4;38;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TFHCRemapNode;1300;-1552,848;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1301;-1552,592;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;810;1168,-3360;Inherit;True;Property;_TextureSample15;Texture Sample 10;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;807;1168,-3136;Inherit;True;Property;_TextureSample14;Texture Sample 10;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;817;1408,-2640;Inherit;True;Property;_TextureSample11;Texture Sample 10;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode;865;1408,-2720;Inherit;False;863;NormalCalc;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;678;1184,-2832;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,1.17;False;1;FLOAT;1.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;790;1184,-2912;Inherit;False;893;NoiseMap3;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;1294;-336,-688;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;1295;-1968,128;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1296;-2208,48;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ReflectOpNode;1297;-2000,-128;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;1305;-1344,768;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1306;-1344,656;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1307;-1360,848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1308;-1552,1040;Inherit;False;Property;_EdgeFade1;Edge Fade;23;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;811;1520,-3248;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;864;1504,-3328;Inherit;False;863;NormalCalc;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;789;1408,-2912;Inherit;True;Property;_TextureSample10;Texture Sample 10;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;859;1712,-2768;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1188;-1344,-1536;Inherit;False;1157.783;432.0106;Screen UVs;8;1337;1334;1329;1328;1323;1322;1321;1316;Screen UV's;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1302;-80,-688;Inherit;False;normalMapping;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ExpOpNode;1303;-1776,64;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1304;-1776,-128;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1313;-1168,656;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1314;-1168,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;1315;-1200,1008;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;673;1728,-3504;Inherit;False;Property;_Highlights1Color;Highlights 1 Color;17;0;Create;True;0;0;0;False;0;False;0.5896226,0.9331943,1,1;0.5896226,0.9331943,1,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;853;1712,-3248;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;672;1744,-3328;Inherit;False;Constant;_VertReflectionsOpacity_1;VertReflections Opacity_1;33;0;Create;True;0;0;0;False;0;False;5;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;687;1728,-3152;Inherit;False;Property;_Highlights2Color;Highlights 2 Color;18;0;Create;True;0;0;0;False;0;False;0,0.5954423,0.6792453,1;0,0.5954423,0.6792453,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.BlendOpsNode;825;1904,-2832;Inherit;True;LinearDodge;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;682;1744,-2976;Inherit;False;Constant;_VertReflectionsOpacity_2;VertReflections Opacity_2;33;0;Create;True;0;0;0;False;0;False;2;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1189;-2768,-1632;Inherit;False;1027.7;253.9;Camera Depth Fade;4;1335;1330;1325;1324;Camera Depth Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;1309;-1632,-16;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;1310;-1632,112;Inherit;False;426;NormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;1311;-1632,224;Inherit;False;1271;Panner2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;1312;-1616,-128;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1316;-1312,-1312;Inherit;False;1302;normalMapping;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1319;-832,720;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1320;-848,848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;674;2128,-3152;Inherit;False;3;3;0;COLOR;1,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;671;2128,-3296;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1190;256,0;Float;False;Property;_ShallowColorDepth;Shallow Color Depth;11;0;Create;True;0;0;0;False;0;False;2.75;4;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1317;-1376,-64;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1318;-1328,112;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;1321;-1024,-1232;Inherit;False;Constant;_constant01;constant 0.1;1;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;1322;-1056,-1312;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;1323;-1072,-1488;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1324;-2752,-1504;Inherit;False;Property;_CameraDepthFadeOffset;Camera Depth Fade Offset;16;0;Create;True;0;0;0;False;0;False;0.5;1;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1325;-2752,-1584;Inherit;False;Property;_CameraDepthFadeLength;Camera Depth Fade Length;15;0;Create;True;0;0;0;False;0;False;1;1;0;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1327;-512,720;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;686;2368,-3232;Inherit;True;LinearDodge;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;656;2400,-3008;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;1191;576,-32;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1192;1296,160;Float;False;Property;_FresnelIntensity;Fresnel Intensity;13;0;Create;True;0;0;0;False;0;False;0.4;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1326;-976,-64;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1328;-784,-1312;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;1329;-784,-1456;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CameraDepthFade;1330;-2432,-1552;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1332;-272,720;Inherit;False;EdgeFoam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;657;2672,-3152;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1193;608,-272;Inherit;False;Property;_DeepColor;Deep Color;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.3444286,0.5023155,0.5660378,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ClampOpNode;1194;912,-128;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1195;608,-480;Inherit;False;Property;_ShallowColor;Shallow Color;9;1;[Header];Create;True;1;Water Colors;0;0;False;1;Space(8);False;0,0,0,0;0.3444286,0.5023155,0.5660378,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TFHCRemapNode;1196;1600,160;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;10;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1197;1280,-672;Inherit;False;1302;normalMapping;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1198;1232,-592;Inherit;False;Property;_Smoothness;Smoothness;29;0;Create;True;0;0;0;False;0;False;0.65;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1199;1232,-496;Inherit;False;Property;_Occlusion;Occlusion;30;0;Create;True;0;0;0;False;0;False;0.65;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1331;-768,-64;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1333;-832,96;Float;False;Property;_ReflectionsColor;Reflections Color;27;1;[Header];Create;True;1;Reflections;0;0;False;1;Space(8);False;1,1,1,1;0,1,0.1185064,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1334;-608,-1456;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;1335;-2144,-1520;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1206;2128,-1408;Inherit;False;1332;EdgeFoam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1207;1904,-1504;Float;False;Property;_EdgeFoamColor;Edge Foam Color;19;1;[Header];Create;True;1;Edge Foam;0;0;False;1;Space(8);False;1,1,1,1;0,1,0.1185064,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;660;2896,-3152;Inherit;False;VerticalReflections;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1200;1296,-160;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;1371;1264,0;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;1201;1936,-1264;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;1202;2240,-1280;Float;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1203;2128,-1168;Float;False;Constant;_LightColorInfluence;Light Color Influence;17;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;1204;1824,160;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;1205;1760,-496;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1336;-544,0;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1337;-416,-1456;Inherit;False;screenUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1338;-1664,-1520;Inherit;False;cameraDepthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1215;2368,-1472;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1369;2346.014,-1668.591;Inherit;False;660;VerticalReflections;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1370;1601.626,-122.6413;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1208;1920,-704;Inherit;False;1337;screenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;1209;2432,-1264;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;1210;2064,-208;Float;False;Property;_FresnelColor;Fresnel Color;12;0;Create;True;0;0;0;False;0;False;0.8313726,0.8313726,0.8313726,1;0.8313726,0.8313726,0.8313726,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ClampOpNode;1211;2096,48;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1212;2384,-48;Inherit;False;1262;depthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1213;2368,-128;Inherit;False;1338;cameraDepthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1214;2144,-432;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1339;-272,0;Inherit;False;ReflexionsCutoff;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1368;2752,-1616;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1216;-2768,-2896;Inherit;False;844.5542;236.5325;Global UV's;4;1343;1342;1341;1340;Global UV's;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1217;-2736,1328;Inherit;False;2405.97;488.6509;Surface Foam;22;1366;1365;1364;1363;1362;1361;1360;1359;1358;1357;1356;1355;1354;1353;1352;1351;1350;1349;1348;1347;1346;1345;Surface Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenColorNode;1218;2128,-704;Float;False;Global;_BeforeWater;BeforeWater;34;0;Create;True;0;0;0;True;0;False;Object;-1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1219;2976,-1280;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1221;2400,-384;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1222;2640,-96;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1220;2944,-1136;Inherit;False;1339;ReflexionsCutoff;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1225;3232,-1200;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1226;2816,-480;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1340;-2720,-2848;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;1341;-2512,-2848;Inherit;False;FLOAT2;0;2;1;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1342;-2336,-2848;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.025,0.025;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexToFragmentNode;1343;-2144,-2848;Inherit;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1344;-1888,-2848;Inherit;False;GlobalUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1345;-2688,1488;Float;False;Property;_SurfaceFoamScale;Surface Foam Scale;26;0;Create;True;0;0;0;False;0;False;1;5;0;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1346;-2368,1488;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;40;False;3;FLOAT;1;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1347;-2416,1696;Float;False;Property;_SurfaceFoamScrollSpeed;Surface Foam Scroll Speed;25;0;Create;True;0;0;0;False;0;False;0.7065745;-0.025;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1348;-2368,1408;Inherit;False;794;FlowSpeed;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1349;-2160,1440;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;1350;-1984,1632;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;-0.2;False;4;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1351;-2160,1568;Inherit;False;Constant;_Scale;Scale;33;0;Create;True;0;0;0;False;0;False;0.777;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1352;-1760,1552;Inherit;False;431;NoiseMap1;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1353;-1968,1504;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;1354;-1760,1408;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1355;-1520,1392;Inherit;True;Property;_TextureSample6;Texture Sample 4;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;1356;-1200,1488;Float;False;Constant;_Step;Step;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;1357;-1760,1632;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1358;-1520,1600;Inherit;True;Property;_TextureSample9;Texture Sample 4;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.StepOpNode;1359;-976,1408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1360;-1200,1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1361;-1200,1728;Float;False;Property;_SurfaceFoamIntensity;Surface Foam Intensity;24;0;Create;True;0;0;0;False;0;False;0.05;0;-0.4;0.4;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;1362;-1200,1648;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1363;-848,1472;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1364;-672,1520;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;1365;-672,1664;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1366;-512,1568;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1367;-272,1568;Inherit;False;Foam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;203;3568,-960;Float;False;True;-1;3;;0;0;CustomLighting;Toon/TEM_Waterfall;False;False;False;False;False;False;False;False;True;False;False;False;False;False;True;True;False;False;False;False;True;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1229;0;1227;0
WireConnection;1231;0;1230;0
WireConnection;1232;0;1229;0
WireConnection;1233;0;1228;1
WireConnection;1233;1;1228;3
WireConnection;1236;0;1233;0
WireConnection;1236;2;1232;0
WireConnection;1234;0;1227;0
WireConnection;1239;0;1236;0
WireConnection;1239;1;1235;0
WireConnection;1245;0;1239;0
WireConnection;431;0;173;0
WireConnection;1241;0;1237;0
WireConnection;1242;0;1238;1
WireConnection;1243;0;1238;3
WireConnection;1249;0;1241;0
WireConnection;1250;0;1242;0
WireConnection;1250;1;1243;0
WireConnection;1252;0;1246;0
WireConnection;1253;0;1247;0
WireConnection;1253;1;1248;0
WireConnection;794;0;812;0
WireConnection;1255;0;1250;0
WireConnection;1255;2;1249;0
WireConnection;1256;0;1251;0
WireConnection;1260;0;1253;1
WireConnection;1260;1;1252;0
WireConnection;1261;0;1255;0
WireConnection;1261;1;1254;0
WireConnection;1262;0;1256;0
WireConnection;426;0;45;0
WireConnection;1270;0;1260;0
WireConnection;823;0;799;0
WireConnection;1266;0;1258;0
WireConnection;1266;1;1259;0
WireConnection;1271;0;1261;0
WireConnection;1280;0;1246;0
WireConnection;1281;0;1269;0
WireConnection;1282;0;1270;0
WireConnection;792;0;791;0
WireConnection;860;0;862;0
WireConnection;860;1;861;0
WireConnection;893;0;892;0
WireConnection;800;0;799;0
WireConnection;824;0;823;0
WireConnection;804;0;799;0
WireConnection;815;0;799;0
WireConnection;1276;0;1265;0
WireConnection;1276;1;1264;0
WireConnection;1277;0;1264;0
WireConnection;1277;1;1265;0
WireConnection;1278;0;1266;0
WireConnection;1279;0;1267;0
WireConnection;1279;1;1268;0
WireConnection;1291;0;1280;0
WireConnection;1292;0;1282;0
WireConnection;1292;1;1281;0
WireConnection;863;0;860;0
WireConnection;821;0;815;0
WireConnection;644;0;648;0
WireConnection;644;2;800;0
WireConnection;701;0;700;0
WireConnection;701;2;804;0
WireConnection;819;0;820;0
WireConnection;819;2;824;0
WireConnection;1283;0;1273;0
WireConnection;1283;1;1275;0
WireConnection;1283;5;1277;0
WireConnection;1284;0;1272;0
WireConnection;1284;1;1274;0
WireConnection;1284;5;1276;0
WireConnection;1287;0;1279;0
WireConnection;1288;0;1278;0
WireConnection;1298;0;1291;0
WireConnection;1299;0;1293;0
WireConnection;1299;1;1289;0
WireConnection;1300;0;1290;0
WireConnection;1301;0;1292;0
WireConnection;810;0;809;0
WireConnection;810;1;644;0
WireConnection;807;0;808;0
WireConnection;807;1;701;0
WireConnection;817;0;818;0
WireConnection;817;1;819;0
WireConnection;678;0;677;0
WireConnection;678;2;821;0
WireConnection;1294;0;1284;0
WireConnection;1294;1;1283;0
WireConnection;1294;2;1285;0
WireConnection;1295;0;1286;0
WireConnection;1297;0;1288;0
WireConnection;1297;1;1287;0
WireConnection;1305;0;1298;0
WireConnection;1306;0;1301;0
WireConnection;1307;0;1300;0
WireConnection;1307;1;1299;1
WireConnection;811;0;810;0
WireConnection;811;1;807;0
WireConnection;789;0;790;0
WireConnection;789;1;678;0
WireConnection;859;0;865;0
WireConnection;859;1;817;0
WireConnection;1302;0;1294;0
WireConnection;1303;0;1295;0
WireConnection;1304;0;1297;0
WireConnection;1304;1;1296;0
WireConnection;1313;0;1306;0
WireConnection;1313;1;1290;0
WireConnection;1314;0;1305;0
WireConnection;1314;1;1307;0
WireConnection;1315;0;1308;0
WireConnection;853;0;864;0
WireConnection;853;1;811;0
WireConnection;825;0;789;0
WireConnection;825;1;859;0
WireConnection;825;2;865;0
WireConnection;1312;0;1304;0
WireConnection;1312;1;1303;0
WireConnection;1319;0;1313;0
WireConnection;1319;1;1314;0
WireConnection;1320;0;1315;0
WireConnection;674;0;687;0
WireConnection;674;1;682;0
WireConnection;674;2;825;0
WireConnection;671;0;673;0
WireConnection;671;1;672;0
WireConnection;671;2;853;0
WireConnection;1317;0;1312;0
WireConnection;1317;1;1309;0
WireConnection;1317;2;1309;1
WireConnection;1317;3;1309;2
WireConnection;1318;0;1310;0
WireConnection;1318;1;1311;0
WireConnection;1322;0;1316;0
WireConnection;1327;0;1319;0
WireConnection;1327;1;1320;0
WireConnection;686;0;671;0
WireConnection;686;1;674;0
WireConnection;1191;0;1190;0
WireConnection;1326;0;1317;0
WireConnection;1326;1;1318;2
WireConnection;1328;0;1322;0
WireConnection;1328;1;1321;0
WireConnection;1329;0;1323;1
WireConnection;1329;1;1323;2
WireConnection;1330;0;1325;0
WireConnection;1330;1;1324;0
WireConnection;1332;0;1327;0
WireConnection;657;1;686;0
WireConnection;657;2;656;4
WireConnection;1194;0;1191;0
WireConnection;1196;0;1192;0
WireConnection;1331;0;1326;0
WireConnection;1334;0;1329;0
WireConnection;1334;1;1328;0
WireConnection;1335;0;1330;0
WireConnection;660;0;657;0
WireConnection;1200;0;1195;0
WireConnection;1200;1;1193;0
WireConnection;1200;2;1194;0
WireConnection;1204;3;1196;0
WireConnection;1205;0;1197;0
WireConnection;1205;1;1198;0
WireConnection;1205;2;1199;0
WireConnection;1336;0;1331;0
WireConnection;1336;1;1333;0
WireConnection;1337;0;1334;0
WireConnection;1338;0;1335;0
WireConnection;1215;0;1207;0
WireConnection;1215;1;1206;0
WireConnection;1370;0;1200;0
WireConnection;1370;1;1371;0
WireConnection;1209;0;1202;0
WireConnection;1209;1;1201;1
WireConnection;1209;2;1203;0
WireConnection;1211;0;1204;0
WireConnection;1214;0;1205;0
WireConnection;1214;1;1370;0
WireConnection;1339;0;1336;0
WireConnection;1368;0;1369;0
WireConnection;1368;1;1215;0
WireConnection;1218;0;1208;0
WireConnection;1219;0;1368;0
WireConnection;1219;1;1209;0
WireConnection;1221;0;1214;0
WireConnection;1221;1;1210;0
WireConnection;1221;2;1211;0
WireConnection;1222;0;1213;0
WireConnection;1222;1;1212;0
WireConnection;1225;0;1219;0
WireConnection;1225;1;1220;0
WireConnection;1226;0;1218;0
WireConnection;1226;1;1221;0
WireConnection;1226;2;1222;0
WireConnection;1341;0;1340;0
WireConnection;1342;0;1341;0
WireConnection;1343;0;1342;0
WireConnection;1344;0;1343;0
WireConnection;1346;0;1345;0
WireConnection;1349;0;1348;0
WireConnection;1349;1;1346;0
WireConnection;1350;0;1347;0
WireConnection;1353;0;1349;0
WireConnection;1353;1;1351;0
WireConnection;1354;0;1349;0
WireConnection;1354;2;1350;0
WireConnection;1355;0;1352;0
WireConnection;1355;1;1354;0
WireConnection;1357;0;1353;0
WireConnection;1357;2;1350;0
WireConnection;1358;0;1352;0
WireConnection;1358;1;1357;0
WireConnection;1359;0;1355;1
WireConnection;1359;1;1356;0
WireConnection;1360;0;1355;1
WireConnection;1362;0;1358;1
WireConnection;1363;0;1359;0
WireConnection;1363;1;1360;0
WireConnection;1363;2;1356;0
WireConnection;1364;0;1363;0
WireConnection;1364;1;1362;0
WireConnection;1365;0;1361;0
WireConnection;1366;0;1364;0
WireConnection;1366;1;1365;0
WireConnection;1367;0;1366;0
WireConnection;203;2;1225;0
WireConnection;203;13;1226;0
ASEEND*/
//CHKSM=CDE2D36D5682DA69A19589A3825E204AFD9B3D39