// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon/TEM_Water"
{
	Properties
	{
		[Header(Textures)][Space(8)]_TilingSize("Tiling Size", Float) = 6
		_DistortionAmount("Distortion Amount", Range( -1 , 1)) = 0.35
		_LerpStrength("Lerp Strength", Range( 0 , 1)) = 1
		[Normal]_NormalMap("Normal Map", 2D) = "bump" {}
		_NoiseTexture("Noise Texture", 2D) = "white" {}
		_FlowDirection("Flow Direction", Vector) = (1,0,0.5,0)
		[Header(Water Colors)][Space(8)]_ShallowColor("Shallow Color", Color) = (0,0,0,0)
		_DeepColor("Deep Color", Color) = (0,0,0,0)
		_ShallowColorDepth("Shallow Color Depth", Range( 0 , 30)) = 2.75
		_FresnelColor("Fresnel Color", Color) = (0.8313726,0.8313726,0.8313726,1)
		_FresnelIntensity("Fresnel Intensity", Range( 0 , 1)) = 0.4
		_DepthFadeDistance("Depth Fade Distance", Range( 1 , 20)) = 1.5
		_CameraDepthFadeLength("Camera Depth Fade Length", Range( 0 , 16)) = 1
		_CameraDepthFadeOffset("Camera Depth Fade Offset", Range( 0 , 6)) = 0.5
		[Header(Edge Foam)][Space(8)]_EdgeFoamColor("Edge Foam Color", Color) = (1,1,1,1)
		_EdgeFoamOpacity("Edge Foam Opacity", Range( 0 , 1)) = 0.65
		_EdgeFoamDistance("Edge Foam Distance", Range( 0 , 1)) = 1
		_EdgeFoamHardness("Edge Foam Hardness", Range( 0 , 1)) = 0.33
		_EdgeFade1("Edge Fade", Range( 0 , 1)) = 1
		[Header(Reflections)][Space(8)]_ReflectionsColor("Reflections Color", Color) = (1,1,1,1)
		_ReflectionsCutoff("Reflections Cutoff", Range( 0 , 1)) = 0.35
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.65
		_Occlusion("Occlusion", Range( 0 , 1)) = 0.65
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
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha addshadow fullforwardshadows exclude_path:deferred nodirlightmap vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
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

		uniform float4 _EdgeFoamColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform sampler2D _NoiseTexture;
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
			float2 appendResult689 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
			float3 temp_output_801_0 = float3( (_FlowDirection).xz ,  0.0 );
			float3 ase_positionWS = i.worldPos;
			float2 appendResult803 = (float2(ase_positionWS.x , ase_positionWS.z));
			float2 panner804 = ( 7.916384 * _Time.y * temp_output_801_0.xy + appendResult803);
			float TexturesScale838 = _TilingSize;
			float2 Panner1806 = ( panner804 / TexturesScale838 );
			float4 ase_positionSSNorm = ase_positionSS / ase_positionSS.w;
			ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
			float screenDepth678 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth678 = saturate( abs( ( screenDepth678 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _DepthFadeDistance ) ) );
			float depthFade679 = distanceDepth678;
			float3 FlowDirection728 = _FlowDirection;
			float3 temp_output_811_0 = float3( (FlowDirection728).xz ,  0.0 );
			float2 appendResult812 = (float2(( ase_positionWS.x * 1.27943 ) , ( ase_positionWS.z * 1.27943 )));
			float2 panner813 = ( 3.4984 * _Time.y * temp_output_811_0.xy + appendResult812);
			float2 Panner2814 = ( panner813 / TexturesScale838 );
			float3 lerpResult675 = lerp( UnpackScaleNormal( tex2D( _NormalMap, Panner1806 ), ( _DistortionAmount * depthFade679 ) ) , UnpackScaleNormal( tex2D( _NormalMap, Panner2814 ), ( depthFade679 * _DistortionAmount ) ) , _LerpStrength);
			float3 normalMapping682 = lerpResult675;
			float2 screenUV691 = ( appendResult689 - ( (normalMapping682).xy * 0.1 ) );
			float4 screenColor885 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BeforeWater,screenUV691);
			float3 indirectNormal695 = normalize( WorldNormalVector( i , normalMapping682 ) );
			Unity_GlossyEnvironmentData g695 = UnityGlossyEnvironmentSetup( _Smoothness, data.worldViewDir, indirectNormal695, float3(0,0,0));
			float3 indirectSpecular695 = UnityGI_IndirectSpecular( data, _Occlusion, indirectNormal695, g695 );
			float screenDepth146 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth146 = abs( ( screenDepth146 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _ShallowColorDepth ) );
			float clampResult211 = clamp( distanceDepth146 , 0.0 , 1.0 );
			float4 lerpResult831 = lerp( _ShallowColor , _DeepColor , clampResult211);
			float3 ase_normalWS = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normalWSNorm = normalize( ase_normalWS );
			UnityGI gi886 = gi;
			float3 diffNorm886 = ase_normalWSNorm;
			gi886 = UnityGI_Base( data, 1, diffNorm886 );
			float3 indirectDiffuse886 = gi886.indirect.diffuse + diffNorm886 * 0.0001;
			float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - ase_positionWS );
			float3 ase_viewDirWS = normalize( ase_viewVectorWS );
			float fresnelNdotV861 = dot( ase_normalWS, ase_viewDirWS );
			float fresnelNode861 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV861, (10.0 + (_FresnelIntensity - 0.0) * (0.0 - 10.0) / (1.0 - 0.0)) ) );
			float clampResult862 = clamp( fresnelNode861 , 0.0 , 1.0 );
			float4 lerpResult863 = lerp( ( float4( indirectSpecular695 , 0.0 ) + ( lerpResult831 * float4( indirectDiffuse886 , 0.0 ) ) ) , _FresnelColor , clampResult862);
			float cameraDepthFade721 = (( i.eyeDepth -_ProjectionParams.y - _CameraDepthFadeOffset ) / _CameraDepthFadeLength);
			float cameraDepthFade723 = saturate( cameraDepthFade721 );
			float4 lerpResult700 = lerp( screenColor885 , lerpResult863 , ( cameraDepthFade723 * depthFade679 ));
			c.rgb = lerpResult700.rgb;
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
			float4 ase_positionSS = float4( i.screenPos.xyz , i.screenPos.w + 1e-7 );
			float4 ase_positionSSNorm = ase_positionSS / ase_positionSS.w;
			ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
			float3 temp_output_801_0 = float3( (_FlowDirection).xz ,  0.0 );
			float3 ase_positionWS = i.worldPos;
			float2 appendResult803 = (float2(ase_positionWS.x , ase_positionWS.z));
			float2 panner804 = ( 7.916384 * _Time.y * temp_output_801_0.xy + appendResult803);
			float TexturesScale838 = _TilingSize;
			float2 Panner1806 = ( panner804 / TexturesScale838 );
			float screenDepth163 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth163 = abs( ( screenDepth163 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( ( tex2D( _NoiseTexture, Panner1806 ).r * (0.0 + (_EdgeFoamDistance - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) );
			float clampResult208 = clamp( distanceDepth163 , 0.0 , 1.0 );
			float clampResult160 = clamp( pow( clampResult208 , (1.0 + (_EdgeFoamHardness - 0.0) * (10.0 - 1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
			float screenDepth191 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth191 = abs( ( screenDepth191 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( (0.0 + (_EdgeFoamDistance - 0.0) * (15.0 - 0.0) / (1.0 - 0.0)) ) );
			float clampResult207 = clamp( distanceDepth191 , 0.0 , 1.0 );
			float screenDepth867 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth867 = abs( ( screenDepth867 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _EdgeFade1 ) );
			float EdgeFoam626 = ( ( ( ( 1.0 - clampResult160 ) * _EdgeFoamOpacity ) + ( ( 1.0 - clampResult207 ) * ( (0.0 + (_EdgeFoamOpacity - 0.0) * (0.85 - 0.0) / (1.0 - 0.0)) * tex2D( _NoiseTexture, Panner1806 ).r ) ) ) * saturate( distanceDepth867 ) );
			float3 temp_cast_2 = (1.0).xxx;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 lerpResult7 = lerp( temp_cast_2 , ase_lightColor.rgb , 1.0);
			float3 normalizeResult754 = ASESafeNormalize( ( _WorldSpaceCameraPos - ase_positionWS ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_lightDirWS = 0;
			#else //aseld
			float3 ase_lightDirWS = normalize( UnityWorldSpaceLightDir( ase_positionWS ) );
			#endif //aseld
			float dotResult762 = dot( reflect( -normalizeResult754 , (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, Panner1806 ) ) )) ) , ase_lightDirWS );
			float saferPower765 = abs( dotResult762 );
			float3 FlowDirection728 = _FlowDirection;
			float3 temp_output_811_0 = float3( (FlowDirection728).xz ,  0.0 );
			float2 appendResult812 = (float2(( ase_positionWS.x * 1.27943 ) , ( ase_positionWS.z * 1.27943 )));
			float2 panner813 = ( 3.4984 * _Time.y * temp_output_811_0.xy + appendResult812);
			float2 Panner2814 = ( panner813 / TexturesScale838 );
			float4 clampResult769 = clamp( ( ( pow( saferPower765 , exp( (0.0 + (_ReflectionsCutoff - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) * ase_lightColor * float4( ase_lightColor.rgb , 0.0 ) * ase_lightColor.a ) * UnpackNormal( tex2D( _NormalMap, Panner2814 ) ).g ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 ReflexionsCutoff770 = ( clampResult769 * _ReflectionsColor );
			o.Emission = ( ( ( _EdgeFoamColor * EdgeFoam626 ) * float4( lerpResult7 , 0.0 ) ) + ReflexionsCutoff770 ).rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.CommentaryNode;857;-4864,-2752;Inherit;False;1396;395;Comment;9;727;728;802;800;801;803;804;855;854;Panner1;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;858;-4864,-3328;Inherit;False;260;163;Comment;1;837;Texture Scale;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;727;-4816,-2656;Float;False;Property;_FlowDirection;Flow Direction;5;0;Create;True;0;0;0;False;0;False;1,0,0.5;0.25,0.05,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;802;-4336,-2704;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;800;-4512,-2544;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;837;-4816,-3280;Inherit;False;Property;_TilingSize;Tiling Size;0;1;[Header];Create;True;1;Textures;0;0;False;1;Space(8);False;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;838;-4544,-3280;Inherit;False;TexturesScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;801;-4336,-2544;Inherit;False;World;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;803;-4080,-2688;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;855;-3888,-2512;Inherit;False;838;TexturesScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;804;-3872,-2656;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;7.916384;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;856;-4864,-2288;Inherit;False;1392.502;427;Comment;10;817;809;810;818;819;811;852;812;813;853;Panner2;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;728;-4544,-2656;Inherit;False;FlowDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;854;-3616,-2592;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;173;-4384,-3632;Float;True;Property;_NoiseTexture;Noise Texture;4;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;817;-4816,-2144;Inherit;False;728;FlowDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;809;-4544,-2208;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;631;-5728,320;Inherit;False;3315.78;661.7512;EdgeFoam;30;172;433;325;170;167;163;162;324;208;335;158;191;161;434;334;207;193;160;189;157;188;156;185;186;869;870;871;868;866;867;EdgeFoam;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;431;-4144,-3632;Inherit;False;NoiseMap1;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;806;-3440,-2592;Inherit;False;Panner1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;810;-4544,-2048;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleNode;818;-4320,-2240;Inherit;False;1.27943;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;819;-4320,-2128;Inherit;False;1.27943;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;666;-4864,-1456;Inherit;False;902.656;187.6821;Depth Fade;2;678;677;Depth Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-5232,656;Float;False;Property;_EdgeFoamDistance;Edge Foam Distance;16;0;Create;True;0;0;0;False;0;False;1;0.04;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;433;-5440,400;Inherit;False;431;NoiseMap1;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;871;-5648,672;Inherit;False;806;Panner1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformDirectionNode;811;-4368,-2048;Inherit;False;World;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;812;-4112,-2240;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;677;-4816,-1408;Inherit;False;Property;_DepthFadeDistance;Depth Fade Distance;11;0;Create;True;0;0;0;False;0;False;1.5;12;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;743;-5344,-432;Inherit;False;2912.429;589.1261;Reflections;25;769;766;765;764;763;762;761;760;759;758;757;756;755;754;752;751;750;749;786;807;780;777;832;872;873;Reflections;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;325;-4896,512;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;170;-5248,400;Inherit;True;Property;_TextureSample3;Texture Sample 3;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TexturePropertyNode;45;-4864,-3632;Float;True;Property;_NormalMap;Normal Map;3;1;[Normal];Create;True;1;Textures;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;853;-4032,-2016;Inherit;False;838;TexturesScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;813;-3904,-2192;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;3.4984;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DepthFade;678;-4448,-1392;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;750;-5072,-384;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;749;-5296,-272;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-4608,416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;426;-4608,-3632;Inherit;False;NormalMap;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;852;-3616,-2144;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;667;-3840,-1104;Inherit;False;1556.876;561.5722;Normal Mapping;12;676;675;674;673;672;671;670;668;724;815;816;822;Normal Mapping;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;679;-3872,-1392;Inherit;False;depthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;751;-4736,-288;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;752;-5056,-176;Inherit;False;426;NormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;807;-5056,-80;Inherit;False;806;Panner1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-4672,528;Float;False;Property;_EdgeFoamHardness;Edge Foam Hardness;17;0;Create;True;0;0;0;False;0;False;0.33;0.33;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;163;-4432,400;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;814;-3440,-2144;Inherit;False;Panner2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;676;-3808,-800;Inherit;False;679;depthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;668;-3808,-976;Inherit;False;Property;_DistortionAmount;Distortion Amount;1;0;Create;True;0;0;0;False;0;False;0.35;0.5;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;754;-4480,-368;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;755;-4800,-176;Inherit;True;Property;_TextureSample5;Texture Sample 5;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TFHCRemapNode;335;-4544,624;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;324;-4336,496;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;208;-4160,400;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;724;-3008,-1056;Inherit;False;426;NormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;822;-3008,-880;Inherit;False;426;NormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;815;-3200,-976;Inherit;False;806;Panner1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;816;-3200,-816;Inherit;False;814;Panner2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;670;-3360,-896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;671;-3360,-720;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;756;-4400,32;Float;False;Property;_ReflectionsCutoff;Reflections Cutoff;23;0;Create;True;0;0;0;False;0;False;0.35;0.45;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;757;-4496,-176;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;758;-4304,-368;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;870;-4432,848;Inherit;False;806;Panner1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-3984,512;Float;False;Property;_EdgeFoamOpacity;Edge Foam Opacity;15;0;Create;True;0;0;0;False;0;False;0.65;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;191;-4144,592;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;161;-3856,400;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;434;-4224,736;Inherit;False;431;NoiseMap1;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;674;-2784,-848;Inherit;True;Property;_TextureSample2;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;673;-2784,-1056;Inherit;True;Property;_NormalMap1;Normal Map;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;672;-2784,-640;Inherit;False;Property;_LerpStrength;Lerp Strength;2;0;Create;True;0;0;0;False;0;False;1;2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;759;-4064,-48;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;760;-4304,-128;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ReflectOpNode;761;-4096,-304;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;207;-3856,592;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;193;-3984,736;Inherit;True;Property;_TextureSample4;Texture Sample 4;38;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TFHCRemapNode;334;-3648,672;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;160;-3648,416;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;675;-2432,-864;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ExpOpNode;763;-3872,-112;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;762;-3872,-304;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;189;-3440,592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;157;-3440,480;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-3456,672;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;866;-3648,864;Inherit;False;Property;_EdgeFade1;Edge Fade;18;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;683;-3440,-1712;Inherit;False;1157.783;432.0106;Screen UVs;8;691;690;689;688;687;686;685;684;Screen UV's;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;682;-2176,-864;Inherit;False;normalMapping;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;764;-3728,-192;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;777;-3728,-64;Inherit;False;426;NormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;832;-3728,48;Inherit;False;814;Panner2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;765;-3712,-304;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;-3264,480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-3264,592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;867;-3296,832;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;718;-4864,-1808;Inherit;False;1027.7;253.9;Camera Depth Fade;4;722;721;720;719;Camera Depth Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;684;-3408,-1488;Inherit;False;682;normalMapping;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-1248,-480;Float;False;Property;_ShallowColorDepth;Shallow Color Depth;8;0;Create;True;0;0;0;False;0;False;2.75;4;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;766;-3472,-240;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;780;-3424,-64;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleAddOpNode;186;-2928,544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;868;-2944,672;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;686;-3120,-1408;Inherit;False;Constant;_constant01;constant 0.1;1;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;687;-3152,-1488;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;685;-3168,-1664;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;719;-4848,-1680;Inherit;False;Property;_CameraDepthFadeOffset;Camera Depth Fade Offset;13;0;Create;True;0;0;0;False;0;False;0.5;1;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;720;-4848,-1760;Inherit;False;Property;_CameraDepthFadeLength;Camera Depth Fade Length;12;0;Create;True;0;0;0;False;0;False;1;1;0;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;146;-928,-512;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;786;-3072,-240;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;869;-2608,544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;688;-2880,-1488;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;689;-2880,-1632;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CameraDepthFade;721;-4528,-1728;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;859;-208,-320;Float;False;Property;_FresnelIntensity;Fresnel Intensity;10;0;Create;True;0;0;0;False;0;False;0.4;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;830;-896,-752;Inherit;False;Property;_DeepColor;Deep Color;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.3444286,0.5023155,0.5660378,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ClampOpNode;211;-592,-608;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;692;-896,-960;Inherit;False;Property;_ShallowColor;Shallow Color;6;1;[Header];Create;True;1;Water Colors;0;0;False;1;Space(8);False;0,0,0,0;0.3444286,0.5023155,0.5660378,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ClampOpNode;769;-2864,-240;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;626;-2368,544;Inherit;False;EdgeFoam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;872;-2928,-80;Float;False;Property;_ReflectionsColor;Reflections Color;22;1;[Header];Create;True;1;Reflections;0;0;False;1;Space(8);False;1,1,1,1;0,1,0.1185064,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;874;-272,-1072;Inherit;False;Property;_Smoothness;Smoothness;24;0;Create;True;0;0;0;False;0;False;0.65;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;875;-272,-976;Inherit;False;Property;_Occlusion;Occlusion;25;0;Create;True;0;0;0;False;0;False;0.65;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;690;-2704,-1632;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;722;-4240,-1696;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;860;96,-320;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;10;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;831;-208,-640;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;886;-314.5339,-430.0901;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;701;-224,-1152;Inherit;False;682;normalMapping;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;873;-2640,-176;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;10;432,-1744;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;8;736,-1760;Float;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;624,-1648;Float;False;Constant;_LightColorInfluence;Light Color Influence;17;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;628;624,-1888;Inherit;False;626;EdgeFoam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;155;400,-1984;Float;False;Property;_EdgeFoamColor;Edge Foam Color;14;1;[Header];Create;True;1;Edge Foam;0;0;False;1;Space(8);False;1,1,1,1;0,1,0.1185064,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RegisterLocalVarNode;691;-2512,-1632;Inherit;False;screenUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;723;-3760,-1696;Inherit;False;cameraDepthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;861;320,-320;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;887;-3.833984,-540.5901;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectSpecularLight;695;256,-976;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;770;-2368,-176;Inherit;False;ReflexionsCutoff;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;7;928,-1744;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;864,-1952;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;702;416,-1184;Inherit;False;691;screenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;864;560,-688;Float;False;Property;_FresnelColor;Fresnel Color;9;0;Create;True;0;0;0;False;0;False;0.8313726,0.8313726,0.8313726,1;0.8313726,0.8313726,0.8313726,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ClampOpNode;862;592,-432;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;694;880,-528;Inherit;False;679;depthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;696;864,-608;Inherit;False;723;cameraDepthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;699;640,-912;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;372;-4864,-3072;Inherit;False;844.5542;236.5325;Global UV's;4;363;364;365;366;Global UV's;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;605;-4832,1152;Inherit;False;2405.97;488.6509;Surface Foam;22;494;497;482;483;478;551;552;550;554;476;555;475;498;496;557;556;493;492;491;495;606;608;Surface Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;1472,-1760;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;771;1440,-1616;Inherit;False;770;ReflexionsCutoff;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;885;624,-1184;Float;False;Global;_BeforeWater;BeforeWater;34;0;Create;True;0;0;0;True;0;False;Object;-1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;863;896,-864;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;698;1136,-576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;363;-4816,-3024;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;364;-4608,-3024;Inherit;False;FLOAT2;0;2;1;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;365;-4432,-3024;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.025,0.025;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexToFragmentNode;366;-4240,-3024;Inherit;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;794;-3984,-3024;Inherit;False;GlobalUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;3;1728,-1680;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;700;1312,-960;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;491;-4784,1312;Float;False;Property;_SurfaceFoamScale;Surface Foam Scale;21;0;Create;True;0;0;0;False;0;False;1;5;0;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;492;-4464,1312;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;40;False;3;FLOAT;1;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;494;-4512,1520;Float;False;Property;_SurfaceFoamScrollSpeed;Surface Foam Scroll Speed;20;0;Create;True;0;0;0;False;0;False;0.7065745;-0.025;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;493;-4464,1232;Inherit;False;794;GlobalUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;495;-4256,1264;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;608;-4080,1456;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;-0.2;False;4;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;557;-4256,1392;Inherit;False;Constant;_Scale;Scale;33;0;Create;True;0;0;0;False;0;False;0.777;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;497;-3856,1376;Inherit;False;431;NoiseMap1;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;556;-4064,1328;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;498;-3856,1232;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;483;-3616,1216;Inherit;True;Property;_TextureSample6;Texture Sample 4;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;482;-3296,1312;Float;False;Constant;_Step;Step;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;496;-3856,1456;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;552;-3616,1424;Inherit;True;Property;_TextureSample9;Texture Sample 4;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.StepOpNode;478;-3072,1232;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;551;-3296,1392;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;476;-3296,1552;Float;False;Property;_SurfaceFoamIntensity;Surface Foam Intensity;19;0;Create;True;0;0;0;False;0;False;0.05;0;-0.4;0.4;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;554;-3296,1472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;550;-2944,1296;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;555;-2768,1344;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;606;-2768,1488;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;475;-2608,1392;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;487;-2368,1392;Inherit;False;Foam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;203;1936,-1728;Float;False;True;-1;3;;0;0;CustomLighting;Toon/TEM_Water;False;False;False;False;False;False;False;False;True;False;False;False;False;False;True;True;False;False;False;False;True;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;800;0;727;0
WireConnection;838;0;837;0
WireConnection;801;0;800;0
WireConnection;803;0;802;1
WireConnection;803;1;802;3
WireConnection;804;0;803;0
WireConnection;804;2;801;0
WireConnection;728;0;727;0
WireConnection;854;0;804;0
WireConnection;854;1;855;0
WireConnection;431;0;173;0
WireConnection;806;0;854;0
WireConnection;810;0;817;0
WireConnection;818;0;809;1
WireConnection;819;0;809;3
WireConnection;811;0;810;0
WireConnection;812;0;818;0
WireConnection;812;1;819;0
WireConnection;325;0;172;0
WireConnection;170;0;433;0
WireConnection;170;1;871;0
WireConnection;813;0;812;0
WireConnection;813;2;811;0
WireConnection;678;0;677;0
WireConnection;167;0;170;1
WireConnection;167;1;325;0
WireConnection;426;0;45;0
WireConnection;852;0;813;0
WireConnection;852;1;853;0
WireConnection;679;0;678;0
WireConnection;751;0;750;0
WireConnection;751;1;749;0
WireConnection;163;0;167;0
WireConnection;814;0;852;0
WireConnection;754;0;751;0
WireConnection;755;0;752;0
WireConnection;755;1;807;0
WireConnection;335;0;172;0
WireConnection;324;0;162;0
WireConnection;208;0;163;0
WireConnection;670;0;668;0
WireConnection;670;1;676;0
WireConnection;671;0;676;0
WireConnection;671;1;668;0
WireConnection;757;0;755;0
WireConnection;758;0;754;0
WireConnection;191;0;335;0
WireConnection;161;0;208;0
WireConnection;161;1;324;0
WireConnection;674;0;822;0
WireConnection;674;1;816;0
WireConnection;674;5;671;0
WireConnection;673;0;724;0
WireConnection;673;1;815;0
WireConnection;673;5;670;0
WireConnection;759;0;756;0
WireConnection;761;0;758;0
WireConnection;761;1;757;0
WireConnection;207;0;191;0
WireConnection;193;0;434;0
WireConnection;193;1;870;0
WireConnection;334;0;158;0
WireConnection;160;0;161;0
WireConnection;675;0;673;0
WireConnection;675;1;674;0
WireConnection;675;2;672;0
WireConnection;763;0;759;0
WireConnection;762;0;761;0
WireConnection;762;1;760;0
WireConnection;189;0;207;0
WireConnection;157;0;160;0
WireConnection;188;0;334;0
WireConnection;188;1;193;1
WireConnection;682;0;675;0
WireConnection;765;0;762;0
WireConnection;765;1;763;0
WireConnection;156;0;157;0
WireConnection;156;1;158;0
WireConnection;185;0;189;0
WireConnection;185;1;188;0
WireConnection;867;0;866;0
WireConnection;766;0;765;0
WireConnection;766;1;764;0
WireConnection;766;2;764;1
WireConnection;766;3;764;2
WireConnection;780;0;777;0
WireConnection;780;1;832;0
WireConnection;186;0;156;0
WireConnection;186;1;185;0
WireConnection;868;0;867;0
WireConnection;687;0;684;0
WireConnection;146;0;150;0
WireConnection;786;0;766;0
WireConnection;786;1;780;2
WireConnection;869;0;186;0
WireConnection;869;1;868;0
WireConnection;688;0;687;0
WireConnection;688;1;686;0
WireConnection;689;0;685;1
WireConnection;689;1;685;2
WireConnection;721;0;720;0
WireConnection;721;1;719;0
WireConnection;211;0;146;0
WireConnection;769;0;786;0
WireConnection;626;0;869;0
WireConnection;690;0;689;0
WireConnection;690;1;688;0
WireConnection;722;0;721;0
WireConnection;860;0;859;0
WireConnection;831;0;692;0
WireConnection;831;1;830;0
WireConnection;831;2;211;0
WireConnection;873;0;769;0
WireConnection;873;1;872;0
WireConnection;691;0;690;0
WireConnection;723;0;722;0
WireConnection;861;3;860;0
WireConnection;887;0;831;0
WireConnection;887;1;886;0
WireConnection;695;0;701;0
WireConnection;695;1;874;0
WireConnection;695;2;875;0
WireConnection;770;0;873;0
WireConnection;7;0;8;0
WireConnection;7;1;10;1
WireConnection;7;2;11;0
WireConnection;184;0;155;0
WireConnection;184;1;628;0
WireConnection;862;0;861;0
WireConnection;699;0;695;0
WireConnection;699;1;887;0
WireConnection;5;0;184;0
WireConnection;5;1;7;0
WireConnection;885;0;702;0
WireConnection;863;0;699;0
WireConnection;863;1;864;0
WireConnection;863;2;862;0
WireConnection;698;0;696;0
WireConnection;698;1;694;0
WireConnection;364;0;363;0
WireConnection;365;0;364;0
WireConnection;366;0;365;0
WireConnection;794;0;366;0
WireConnection;3;0;5;0
WireConnection;3;1;771;0
WireConnection;700;0;885;0
WireConnection;700;1;863;0
WireConnection;700;2;698;0
WireConnection;492;0;491;0
WireConnection;495;0;493;0
WireConnection;495;1;492;0
WireConnection;608;0;494;0
WireConnection;556;0;495;0
WireConnection;556;1;557;0
WireConnection;498;0;495;0
WireConnection;498;2;608;0
WireConnection;483;0;497;0
WireConnection;483;1;498;0
WireConnection;496;0;556;0
WireConnection;496;2;608;0
WireConnection;552;0;497;0
WireConnection;552;1;496;0
WireConnection;478;0;483;1
WireConnection;478;1;482;0
WireConnection;551;0;483;1
WireConnection;554;0;552;1
WireConnection;550;0;478;0
WireConnection;550;1;551;0
WireConnection;550;2;482;0
WireConnection;555;0;550;0
WireConnection;555;1;554;0
WireConnection;606;0;476;0
WireConnection;475;0;555;0
WireConnection;475;1;606;0
WireConnection;487;0;475;0
WireConnection;203;2;3;0
WireConnection;203;13;700;0
ASEEND*/
//CHKSM=7C3F1F8001ADDA780405ECBF13713617C25B3384