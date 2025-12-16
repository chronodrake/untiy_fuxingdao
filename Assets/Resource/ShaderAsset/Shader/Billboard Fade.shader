// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Surface Shader/Billboard Fade"
{
	Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		_Billboard("Billboard", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_LightMapUV0("LightMap (UV0)", 2D) = "white" {}
		_LightMap("LightMap", Range( 0 , 1)) = 0.5
		_LeafMaskRGB("Leaf Mask (RGB)", 2D) = "white" {}
		_Leaf("Leaf", Color) = (1,1,1,1)
		_Bark("Bark", Color) = (1,1,1,1)
		_ColorMap("Color Map", 2D) = "white" {}
		_ColorMapIntensity("Color Map Intensity", Range( 0 , 1)) = 0.5
		_SizeLandscape("Size Landscape", Float) = 500
		[Toggle]_OnlyFoliage("Only Foliage", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+2" "IgnoreProjector" = "True" }
		Cull Off
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardSpecularCustom alpha:fade keepalpha noshadow exclude_path:deferred dithercrossfade 
		struct Input
		{
			float2 uv_texcoord;
			fixed ASEVFace : VFACE;
			float3 worldPos;
			float2 uv2_texcoord2;
		};

		struct SurfaceOutputStandardSpecularCustom
		{
			fixed3 Albedo;
			fixed3 Normal;
			half3 Emission;
			fixed3 Specular;
			half Smoothness;
			half Occlusion;
			fixed Alpha;
			fixed3 Transmission;
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _ColorMap;
		uniform float _SizeLandscape;
		uniform float _OnlyFoliage;
		uniform float _ColorMapIntensity;
		uniform sampler2D _LeafMaskRGB;
		uniform float4 _LeafMaskRGB_ST;
		uniform float4 _Bark;
		uniform float4 _Leaf;
		uniform sampler2D _Billboard;
		uniform float4 _Billboard_ST;
		uniform sampler2D _LightMapUV0;
		uniform float4 _LightMapUV0_ST;
		uniform float _LightMap;
		uniform float4 _MainColor;

		inline half4 LightingStandardSpecularCustom(SurfaceOutputStandardSpecularCustom s, half3 viewDir, UnityGI gi )
		{
			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandardSpecular r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Specular = s.Specular;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandardSpecular (r, viewDir, gi) + d;
		}

		inline void LightingStandardSpecularCustom_GI(SurfaceOutputStandardSpecularCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardSpecularCustom o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode3 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			float3 switchResult68 = (((i.ASEVFace>0)?(tex2DNode3):(( tex2DNode3 * float3(-1,-1,-1) ))));
			o.Normal = switchResult68;
			float3 ase_worldPos = i.worldPos;
			float2 uv_LeafMaskRGB = i.uv_texcoord * _LeafMaskRGB_ST.xy + _LeafMaskRGB_ST.zw;
			float4 tex2DNode87 = tex2D( _LeafMaskRGB, uv_LeafMaskRGB );
			float4 lerpResult99 = lerp( float4( 1,1,1,1 ) , tex2D( _ColorMap, ( ( (ase_worldPos).xz * ( 1.0 / _SizeLandscape ) ) + 0.5 ) ) , lerp(_ColorMapIntensity,( _ColorMapIntensity * tex2DNode87.r ),_OnlyFoliage));
			float4 lerpResult96 = lerp( float4( 1,1,1,1 ) , _Bark , tex2DNode87.r);
			float4 lerpResult93 = lerp( float4( 1,1,1,1 ) , _Leaf , tex2DNode87.r);
			float2 uv_Billboard = i.uv_texcoord * _Billboard_ST.xy + _Billboard_ST.zw;
			float4 tex2DNode1 = tex2D( _Billboard, uv_Billboard );
			float2 uv2_LightMapUV0 = i.uv2_texcoord2 * _LightMapUV0_ST.xy + _LightMapUV0_ST.zw;
			float4 lerpResult101 = lerp( float4( 1,1,1,1 ) , tex2D( _LightMapUV0, uv2_LightMapUV0 ) , _LightMap);
			o.Albedo = ( lerpResult99 * ( lerpResult96 * lerpResult93 ) * tex2DNode1 * lerpResult101 * _MainColor ).rgb;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			o.Transmission = ( tex2DNode87.r * ase_lightColor ).rgb;
			o.Alpha = tex2DNode1.a;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15301
7;29;1906;1004;2946.761;2236.322;1.6;True;True
Node;AmplifyShaderEditor.RangedFloatNode;80;-1982.016,-1626.816;Float;False;Constant;_Float0;Float 0;18;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;79;-2120.017,-1818.816;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;81;-1981.161,-1562.05;Float;False;Property;_SizeLandscape;Size Landscape;10;0;Create;True;0;0;False;0;500;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;82;-1788.713,-1613.229;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;83;-1885.017,-1806.816;Float;True;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1565.016,-1666.816;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-1497.068,-1541.609;Float;False;Constant;_Float2;Float 2;18;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;87;-2060.811,-1158.504;Float;True;Property;_LeafMaskRGB;Leaf Mask (RGB);5;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;85;-1576.923,-1263.77;Float;False;Property;_ColorMapIntensity;Color Map Intensity;9;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-1270.311,-1196.349;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;91;-1982.537,-1322.671;Float;False;Property;_Leaf;Leaf;6;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;89;-1979.863,-1492.618;Float;False;Property;_Bark;Bark;7;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-1322.068,-1618.609;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;100;-1833.396,-782.5172;Float;True;Property;_LightMapUV0;LightMap (UV0);3;0;Create;True;0;0;False;0;None;None;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;96;-1532.047,-1185.888;Float;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;94;-1161.733,-1660.86;Float;True;Property;_ColorMap;Color Map;8;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;70;-207.748,-222.7725;Float;False;Constant;_Vector1;Vector 1;12;0;Create;True;0;0;False;0;-1,-1,-1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;3;-250,-447;Float;True;Property;_NormalMap;Normal Map;2;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;102;-1543.73,-426.8743;Float;False;Property;_LightMap;LightMap;4;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;97;-1062.677,-1264.278;Float;False;Property;_OnlyFoliage;Only Foliage;11;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;93;-1531.698,-1074.069;Float;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;189.252,-293.7725;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;101;-854.7782,-495.4711;Float;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;75;-51.5827,116.0764;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;1;-752,-682;Float;True;Property;_Billboard;Billboard;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;103;-92.3056,-546.2423;Float;False;Property;_MainColor;Main Color;0;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-1313.62,-1101.173;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;99;-825.6545,-1345.127;Float;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;353.6693,-110.6962;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;105.252,-686.772;Float;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchByFaceNode;68;408.252,-450.7725;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;649,-495;Float;False;True;2;Float;ASEMaterialInspector;0;0;StandardSpecular;Surface Shader/Billboard Fade;False;False;False;False;False;False;False;False;False;False;False;False;True;False;True;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;0;False;0;Transparent;0.5;True;False;2;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;2;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;82;0;80;0
WireConnection;82;1;81;0
WireConnection;83;0;79;0
WireConnection;86;0;83;0
WireConnection;86;1;82;0
WireConnection;88;0;85;0
WireConnection;88;1;87;1
WireConnection;90;0;86;0
WireConnection;90;1;84;0
WireConnection;96;1;89;0
WireConnection;96;2;87;1
WireConnection;94;1;90;0
WireConnection;97;0;85;0
WireConnection;97;1;88;0
WireConnection;93;1;91;0
WireConnection;93;2;87;1
WireConnection;72;0;3;0
WireConnection;72;1;70;0
WireConnection;101;1;100;0
WireConnection;101;2;102;0
WireConnection;98;0;96;0
WireConnection;98;1;93;0
WireConnection;99;1;94;0
WireConnection;99;2;97;0
WireConnection;73;0;87;1
WireConnection;73;1;75;0
WireConnection;77;0;99;0
WireConnection;77;1;98;0
WireConnection;77;2;1;0
WireConnection;77;3;101;0
WireConnection;77;4;103;0
WireConnection;68;0;3;0
WireConnection;68;1;72;0
WireConnection;0;0;77;0
WireConnection;0;1;68;0
WireConnection;0;6;73;0
WireConnection;0;9;1;4
ASEEND*/
//CHKSM=4BDC23352C233342FF73C19575F6EF7DA8911DD9