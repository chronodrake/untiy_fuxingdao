// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Surface Shader/Vegetation Pro Shader"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainColor("Main Color", Color) = (1,1,1,1)
		_Albedo("Albedo", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_GlossR("Gloss (R)", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_LightMapUV1("LightMap (UV1)", 2D) = "white" {}
		_LightMap("LightMap", Range( 0 , 1)) = 0.5
		[Toggle]_LightMapVertexAlpha("LightMap Vertex Alpha", Float) = 0
		_LeafMaskRGB("Leaf Mask (RGB)", 2D) = "white" {}
		_Leaf("Leaf", Color) = (1,1,1,1)
		_Bark("Bark", Color) = (1,1,1,1)
		_ColorMap("Color Map", 2D) = "white" {}
		_ColorMapIntensity("Color Map Intensity", Range( 0 , 1)) = 0.5
		_SizeLandscape("Size Landscape", Float) = 100
		[Toggle]_OnlyLeaf("Only Leaf", Float) = 1
		_GlobalWind("Global Wind", Range( 0 , 1)) = 0.5
		_Turbulence("Turbulence", Float) = 1
		_SpeedTurbulence("Speed Turbulence", Float) = 1
		_WindMain("Wind Main", Float) = 2
		_PulseFrequency("Pulse Frequency", Float) = 3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TreeTransparentCutout"  "Queue" = "Geometry+0" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma surface surf StandardSpecularCustom keepalpha addshadow fullforwardshadows exclude_path:deferred dithercrossfade vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			fixed ASEVFace : VFACE;
			float3 worldPos;
			float2 uv2_texcoord2;
			float4 vertexColor : COLOR;
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

		uniform float _SpeedTurbulence;
		uniform float _Turbulence;
		uniform float _GlobalWind;
		uniform float _WindMain;
		uniform float _PulseFrequency;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _ColorMap;
		uniform float _SizeLandscape;
		uniform float _OnlyLeaf;
		uniform float _ColorMapIntensity;
		uniform sampler2D _LeafMaskRGB;
		uniform float4 _LeafMaskRGB_ST;
		uniform float4 _Bark;
		uniform float4 _Leaf;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _MainColor;
		uniform sampler2D _GlossR;
		uniform float4 _GlossR_ST;
		uniform float _Smoothness;
		uniform float _LightMapVertexAlpha;
		uniform sampler2D _LightMapUV1;
		uniform float4 _LightMapUV1_ST;
		uniform float _LightMap;
		uniform float _Cutoff = 0.5;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float simplePerlin3D16 = snoise( ase_vertexNormal );
			float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float temp_output_323_0 = ( ase_worldPos.x * 0.2 );
			float4 transform57 = mul(unity_WorldToObject,float4( ( _GlobalWind * v.color.b * ase_objectScale * float3(0.1,0,0.1) * _WindMain * (0.1 + (( cos( ( ( _PulseFrequency * _Time.y ) + temp_output_323_0 ) ) - sin( ( _Time.z + temp_output_323_0 ) ) ) - -1.0) * (1.0 - 0.1) / (1.0 - -1.0)) ) , 0.0 ));
			float4 Wind390 = ( float4( ( 0.01 * sin( ( _Time.y * ( 20.0 * simplePerlin3D16 ) * _SpeedTurbulence * v.color.r ) ) * ( _Turbulence * ase_vertexNormal * v.color.g ) * _GlobalWind ) , 0.0 ) + transform57 );
			v.vertex.xyz += Wind390.xyz;
		}

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
			float3 NormalMap386 = switchResult68;
			o.Normal = NormalMap386;
			float3 ase_worldPos = i.worldPos;
			float2 uv_LeafMaskRGB = i.uv_texcoord * _LeafMaskRGB_ST.xy + _LeafMaskRGB_ST.zw;
			float4 tex2DNode81 = tex2D( _LeafMaskRGB, uv_LeafMaskRGB );
			float4 lerpResult368 = lerp( float4( 1,1,1,1 ) , tex2D( _ColorMap, ( ( (ase_worldPos).xz * ( 1.0 / _SizeLandscape ) ) + 0.5 ) ) , lerp(_ColorMapIntensity,( _ColorMapIntensity * tex2DNode81.r ),_OnlyLeaf));
			float4 lerpResult359 = lerp( _Bark , _Leaf , tex2DNode81.r);
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode1 = tex2D( _Albedo, uv_Albedo );
			float4 Albedo384 = ( lerpResult368 * lerpResult359 * tex2DNode1 * _MainColor );
			o.Albedo = Albedo384.rgb;
			float3 temp_cast_2 = (0.0).xxx;
			o.Specular = temp_cast_2;
			float2 uv_GlossR = i.uv_texcoord * _GlossR_ST.xy + _GlossR_ST.zw;
			float Gloss394 = ( tex2D( _GlossR, uv_GlossR ).r * _Smoothness );
			o.Smoothness = Gloss394;
			float2 uv2_LightMapUV1 = i.uv2_texcoord2 * _LightMapUV1_ST.xy + _LightMapUV1_ST.zw;
			float4 temp_cast_3 = (i.vertexColor.a).xxxx;
			float4 lerpResult33 = lerp( float4( 1,1,1,1 ) , lerp(tex2D( _LightMapUV1, uv2_LightMapUV1 ),temp_cast_3,_LightMapVertexAlpha) , _LightMap);
			float4 AmbientOcclusion388 = lerpResult33;
			o.Occlusion = AmbientOcclusion388.r;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 Transmission395 = ( tex2DNode81.r * ase_lightColor );
			o.Transmission = Transmission395.rgb;
			o.Alpha = 1;
			float Opacity397 = tex2DNode1.a;
			clip( Opacity397 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15301
7;29;1906;1004;5608.147;2164.031;3.85926;True;True
Node;AmplifyShaderEditor.CommentaryNode;389;-2630.183,33.03481;Float;False;2454.985;1367.42;Wind;34;390;54;57;324;162;319;307;301;304;267;321;320;323;147;291;10;39;17;334;155;80;157;9;11;14;12;31;15;18;8;16;156;19;13;Wind;0.5588235,0.8174441,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-2622.005,977.2928;Float;False;Property;_PulseFrequency;Pulse Frequency;20;0;Create;True;0;0;False;0;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;291;-2623.892,1048.293;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;319;-2624.531,1181.294;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;324;-2623.734,1317.294;Float;False;Constant;_Float4;Float 4;13;0;Create;True;0;0;False;0;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;381;-2614.641,-2081.239;Float;False;1762.672;1008.12;Albedo;29;384;1;359;84;71;2;81;358;355;370;371;369;368;363;375;374;366;364;373;365;367;372;82;83;394;395;397;400;401;Albedo;0.6137931,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-2299.892,1012.293;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;323;-2373.892,1212.294;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;367;-2579.537,-1850.499;Float;False;Constant;_Float2;Float 2;18;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;364;-2581.07,-2026.777;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;320;-2158.892,1026.293;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;372;-2584.717,-1782.112;Float;False;Property;_SizeLandscape;Size Landscape;14;0;Create;True;0;0;False;0;100;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;321;-2189.892,1150.294;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;156;-2623.869,281.9691;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;373;-2300.549,-1838.119;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;267;-2033.891,1036.293;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;16;-2424.203,275.9686;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2621.757,209.5375;Float;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;False;0;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;304;-2031.891,1122.294;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;365;-2396.854,-2031.706;Float;True;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;81;-2584.653,-1393.845;Float;True;Property;_LeafMaskRGB;Leaf Mask (RGB);9;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;375;-2132.404,-1931.599;Float;False;Constant;_Float3;Float 3;18;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;369;-2141.67,-1851.739;Float;False;Property;_ColorMapIntensity;Color Map Intensity;13;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;366;-2121.053,-2026.908;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;31;-2428.163,427.8361;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-2425.969,350.8424;Float;False;Property;_SpeedTurbulence;Speed Turbulence;18;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;13;-2622.812,72.14419;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-2188.978,216.1441;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;301;-1892.889,1062.293;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;374;-1962.605,-2028.099;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;155;-2622.444,904.9507;Float;False;Property;_WindMain;Wind Main;19;0;Create;True;0;0;False;0;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1826.999,102.877;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;307;-1746.889,1063.293;Float;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0.1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1823.993,238.4913;Float;False;Property;_Turbulence;Turbulence;17;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;371;-1872.075,-1784.437;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;11;-1828.273,312.3828;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;157;-2621.404,764.5164;Float;False;Constant;_Vector2;Vector 2;11;0;Create;True;0;0;False;0;0.1,0,0.1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;387;-2628.194,-479.7775;Float;False;1024.8;393.4998;AmbientOcclusion;6;35;33;354;326;353;388;AmbientOcclusion;0.5367647,0.5367647,0.5367647,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;334;-1630.192,513.9894;Float;False;Property;_GlobalWind;Global Wind;16;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;80;-2619.666,629.9508;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;385;-2624.874,-974.3581;Float;False;871.4;373.9999;Normal Map;5;72;68;70;3;386;Normal Map;0.5019608,0.5019608,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;363;-1824.17,-2026.45;Float;True;Property;_ColorMap;Color Map;12;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-984.1248,577.1776;Float;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;326;-2619.84,-253.0064;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;370;-1738.464,-1846.775;Float;False;Property;_OnlyLeaf;Only Leaf;15;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;355;-2585.418,-1711.726;Float;False;Property;_Bark;Bark;11;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;358;-2583.87,-1551.561;Float;False;Property;_Leaf;Leaf;10;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;70;-2616.66,-744.1288;Float;False;Constant;_Vector1;Vector 1;12;0;Create;True;0;0;False;0;-1,-1,-1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;3;-2619.447,-931.9617;Float;True;Property;_NormalMap;Normal Map;3;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;12;-1664.748,100.7426;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;353;-2618.84,-436.006;Float;True;Property;_LightMapUV1;LightMap (UV1);6;0;Create;True;0;0;False;0;None;None;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1502.71,372.4586;Float;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1293.311,71.7582;Float;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;359;-1878.672,-1694.854;Float;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-1864.559,-1178.411;Float;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;368;-1499.719,-2011.453;Float;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;400;-1884.034,-1363.713;Float;True;Property;_GlossR;Gloss (R);4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;401;-1572.456,-1412.448;Float;False;Property;_MainColor;Main Color;1;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-1883.908,-1577.739;Float;True;Property;_Albedo;Albedo;2;0;Create;True;0;0;False;0;None;84508b93f15f2b64386ec07486afc7a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-2282.772,-269.1635;Float;False;Property;_LightMap;LightMap;7;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;354;-2279.839,-365.0061;Float;False;Property;_LightMapVertexAlpha;LightMap Vertex Alpha;8;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;2;-2587.535,-1206.734;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-979.772,382.0438;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;57;-821.0729,575.3683;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-2301.154,-760.3412;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;33;-1987.796,-382.8653;Float;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-1193.675,-1865.464;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-1569.148,-1195.729;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-2266.168,-1228.703;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchByFaceNode;68;-2146.874,-921.3581;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-535.6853,388.5706;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;394;-1437.536,-1200.544;Float;False;Gloss;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;384;-1057.774,-1870.121;Float;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;396;-1275.167,-379.2552;Float;False;395;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;388;-1834.063,-382.3395;Float;False;AmbientOcclusion;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;399;-1246.403,-522.3536;Float;False;394;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;377;-1215.198,-593.9827;Float;False;Constant;_Float5;Float 5;21;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;398;-1243.403,-308.3539;Float;False;397;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;393;-1244.516,-239.5297;Float;False;390;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;397;-1582.973,-1486.214;Float;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;395;-2123.004,-1232.398;Float;False;Transmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;390;-396.0283,382.6937;Float;False;Wind;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;386;-1963.448,-927.4362;Float;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;392;-1305.516,-451.5297;Float;False;388;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;391;-1267.766,-661.3875;Float;False;386;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;383;-1252.908,-731.5882;Float;False;384;0;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-777.6139,-636.2104;Float;False;True;2;Float;ASEMaterialInspector;0;0;StandardSpecular;Surface Shader/Vegetation Pro Shader;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;True;False;False;False;Off;0;False;-1;0;False;-1;False;0;0;False;0;Custom;0.5;True;True;0;True;TreeTransparentCutout;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;147;0;162;0
WireConnection;147;1;291;2
WireConnection;323;0;319;1
WireConnection;323;1;324;0
WireConnection;320;0;147;0
WireConnection;320;1;323;0
WireConnection;321;0;291;3
WireConnection;321;1;323;0
WireConnection;373;0;367;0
WireConnection;373;1;372;0
WireConnection;267;0;320;0
WireConnection;16;0;156;0
WireConnection;304;0;321;0
WireConnection;365;0;364;0
WireConnection;366;0;365;0
WireConnection;366;1;373;0
WireConnection;8;0;19;0
WireConnection;8;1;16;0
WireConnection;301;0;267;0
WireConnection;301;1;304;0
WireConnection;374;0;366;0
WireConnection;374;1;375;0
WireConnection;18;0;13;2
WireConnection;18;1;8;0
WireConnection;18;2;15;0
WireConnection;18;3;31;1
WireConnection;307;0;301;0
WireConnection;371;0;369;0
WireConnection;371;1;81;1
WireConnection;363;1;374;0
WireConnection;39;0;334;0
WireConnection;39;1;31;3
WireConnection;39;2;80;0
WireConnection;39;3;157;0
WireConnection;39;4;155;0
WireConnection;39;5;307;0
WireConnection;370;0;369;0
WireConnection;370;1;371;0
WireConnection;12;0;18;0
WireConnection;9;0;14;0
WireConnection;9;1;11;0
WireConnection;9;2;31;2
WireConnection;359;0;355;0
WireConnection;359;1;358;0
WireConnection;359;2;81;0
WireConnection;368;1;363;0
WireConnection;368;2;370;0
WireConnection;354;0;353;0
WireConnection;354;1;326;4
WireConnection;10;0;17;0
WireConnection;10;1;12;0
WireConnection;10;2;9;0
WireConnection;10;3;334;0
WireConnection;57;0;39;0
WireConnection;72;0;3;0
WireConnection;72;1;70;0
WireConnection;33;1;354;0
WireConnection;33;2;35;0
WireConnection;84;0;368;0
WireConnection;84;1;359;0
WireConnection;84;2;1;0
WireConnection;84;3;401;0
WireConnection;83;0;400;1
WireConnection;83;1;82;0
WireConnection;71;0;81;1
WireConnection;71;1;2;0
WireConnection;68;0;3;0
WireConnection;68;1;72;0
WireConnection;54;0;10;0
WireConnection;54;1;57;0
WireConnection;394;0;83;0
WireConnection;384;0;84;0
WireConnection;388;0;33;0
WireConnection;397;0;1;4
WireConnection;395;0;71;0
WireConnection;390;0;54;0
WireConnection;386;0;68;0
WireConnection;0;0;383;0
WireConnection;0;1;391;0
WireConnection;0;3;377;0
WireConnection;0;4;399;0
WireConnection;0;5;392;0
WireConnection;0;6;396;0
WireConnection;0;10;398;0
WireConnection;0;11;393;0
ASEEND*/
//CHKSM=89A84F11C9298A0A30B5F1785065CCD679F26A8D