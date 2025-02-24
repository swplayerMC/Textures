#include "ShaderConstants.fxh"

#include "function/fog.hlsl"
#include "function/grain.hlsl"

struct VS_Input {
	float3 position : POSITION;
	float4 color : COLOR;
	float2 uv0 : TEXCOORD_0;
	float2 uv1 : TEXCOORD_1;

	#ifdef INSTANCEDSTEREO
		uint instanceID : SV_InstanceID;
	#endif
};

struct PS_Input {
	float4 position : SV_Position;

	#ifdef FOG
		float4 fogColor : FOG_COLOR;
	#endif
	#ifndef BYPASS_PIXEL_SHADER
		lpfloat4 color : COLOR;
		snorm float2 uv0 : TEXCOORD_0_FB_MSAA;
		snorm float2 uv1 : TEXCOORD_1_FB_MSAA;
	#endif
	#ifdef GEOMETRY_INSTANCEDSTEREO
		uint instanceID : SV_InstanceID;
	#endif
	#ifdef VERTEXSHADER_INSTANCEDSTEREO
		uint renTarget_id : SV_RenderTargetArrayIndex;
	#endif

	float4 haze : HAZE;
};

static const float rA = 1.0;
static const float rB = 1.0;
static const float3 UNIT_Y = float3(0, 1, 0);
static const float DIST_DESATURATION = 56.0 / 255.0; //WARNING this value is also hardcoded in the water color, don'tchange

ROOT_SIGNATURE
void main(in VS_Input VSInput, out PS_Input PSInput)
{
	#ifndef BYPASS_PIXEL_SHADER
		PSInput.uv0 = VSInput.uv0;
		PSInput.uv1 = VSInput.uv1;
		PSInput.color = VSInput.color;
	#endif

	#ifdef AS_ENTITY_RENDERER
		#ifdef INSTANCEDSTEREO
			int i = VSInput.instanceID;
			PSInput.position = mul(WORLDVIEWPROJ_STEREO[i], float4(VSInput.position, 1));
		#else
			PSInput.position = mul(WORLDVIEWPROJ, float4(VSInput.position, 1));
		#endif
		float3 worldPos = PSInput.position;
	#else
		float3 worldPos = (VSInput.position.xyz * CHUNK_ORIGIN_AND_SCALE.w) + CHUNK_ORIGIN_AND_SCALE.xyz;

		// Transform to view space before projection instead of all at once to avoid floating point errors
		// Not required for entities because they are already offset by camera translation before rendering
		// World position here is calculated above and can get huge
		#ifdef INSTANCEDSTEREO
			int i = VSInput.instanceID;

			PSInput.position = mul(WORLDVIEW_STEREO[i], float4(worldPos, 1 ));
			PSInput.position = mul(PROJ_STEREO[i], PSInput.position);
		#else
			PSInput.position = mul(WORLDVIEW, float4( worldPos, 1 ));
			PSInput.position = mul(PROJ, PSInput.position);
		#endif
	#endif

	float3 blockPos = fmod(mul(WORLD, float4(VSInput.position.xyz, 1.0)).xyz * CHUNK_ORIGIN_AND_SCALE.w, 16.0);

	#ifdef GEOMETRY_INSTANCEDSTEREO
			PSInput.instanceID = VSInput.instanceID;
	#endif 
	#ifdef VERTEXSHADER_INSTANCEDSTEREO
			PSInput.renTarget_id = VSInput.instanceID;
	#endif

	///// find distance from the camera
	#if defined(FOG) || defined(BLEND)
		#ifdef FANCY
			float3 relPos = -worldPos;
			float cameraDepth = length(relPos);
		#else
			float cameraDepth = PSInput.position.z;
		#endif
	#endif

	///// wavy leaves
	#ifdef FANCY
		#ifdef ALPHA_TEST
			if (PSInput.color.g >= PSInput.color.b && PSInput.color.g > PSInput.color.r || PSInput.color.b > PSInput.color.r) {
				PSInput.position.x += sineWave(blockPos.x*1.2 + blockPos.z*0.7, 0.05, TOTAL_REAL_WORLD_TIME * 0.07, 0.0) * sineWave(blockPos.x*0.5 + blockPos.z*0.9, 0.08, TOTAL_REAL_WORLD_TIME * 0.3, 2.4);
			}
		#endif
	#endif

	///// apply fog
	#ifdef FOG
		float len = cameraDepth / RENDER_DISTANCE;
		#ifdef ALLOW_FADE
			len += RENDER_CHUNK_FOG_ALPHA.r;
		#endif
		PSInput.fogColor.rgb = FOG_COLOR.rgb;
		PSInput.fogColor.a = clamp((len - FOG_CONTROL.x) / (FOG_CONTROL.y - FOG_CONTROL.x), 0.0, 3.0);
	#endif
	float dist = clamp(length(worldPos) / RENDER_DISTANCE, 0.0, 4.0);
	PSInput.haze.rgb = FOG_COLOR.rgb;
	PSInput.haze.a = CurveMap(dist);
}
