#include "ShaderConstants.fxh"

struct VS_Input {
	float3 position : POSITION;
	float4 normal : NORMAL;
	float4 color : COLOR;

	#ifdef USE_SKINNING
		uint boneId : BONEID_0;
	#endif
	#ifdef INSTANCEDSTEREO
		uint instanceID : SV_InstanceID;
	#endif
};

struct PS_Input {
	float4 position : SV_Position;
	float4 light : LIGHT;
	float4 color : COLOR;
};

ROOT_SIGNATURE
void main(in VS_Input VSInput, out PS_Input PSInput) {
	PSInput.color = VSInput.color;
	#ifdef INSTANCEDSTEREO
		int i = VSInput.instanceID;
		#ifdef USE_SKINNING
			PSInput.position = mul(WORLDVIEWPROJ_STEREO[i], mul(BONES[VSInput.boneId], float4(VSInput.position, 1)));
		#else
			PSInput.position = mul(WORLDVIEWPROJ_STEREO[i], float4(VSInput.position, 1));
		#endif
	#else
		#ifdef USE_SKINNING
			PSInput.position = mul(WORLDVIEWPROJ, mul(BONES[VSInput.boneId], float4(VSInput.position, 1)));
		#else
			PSInput.position = mul(WORLDVIEWPROJ, float4(VSInput.position, 1));
		#endif
	#endif
}

