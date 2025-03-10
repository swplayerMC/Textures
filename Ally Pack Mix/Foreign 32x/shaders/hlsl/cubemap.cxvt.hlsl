//File modified by @CrisXolt.
#include "ShaderConstants.fxh"

struct VS_Input
{
    float3 position : POSITION;
    float2 uv : TEXCOORD_0;
#ifdef INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
};

struct PS_Input
{
    float4 position : SV_Position;
    float2 uv : TEXCOORD_0;
#ifdef CUBEMAP
		float2 uv1 : TEXCOORD_1;
#endif
#ifdef GEOMETRY_INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	uint renTarget_id : SV_RenderTargetArrayIndex;
#endif
};

ROOT_SIGNATURE
void main(in VS_Input VSInput, out PS_Input PSInput)
{
    PSInput.uv = VSInput.uv;
#ifdef INSTANCEDSTEREO
	int i = VSInput.instanceID;
	PSInput.position = mul( WORLDVIEWPROJ_STEREO[i], float4( VSInput.position, 1 ) );
#else
	PSInput.position = mul(WORLDVIEWPROJ, float4(VSInput.position, 1));
#endif
#ifdef GEOMETRY_INSTANCEDSTEREO
	PSInput.instanceID = VSInput.instanceID;
#endif 
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	PSInput.renTarget_id = VSInput.instanceID;
#endif

#ifdef YPOSFIX
	float3 YPos = float3(0.0,0.125,0.0);
#ifdef SKY_ROTATION
	PSInput.position = mul(mul(WORLDVIEWPROJ,CUBE_MAP_ROTATION),float4(VSInput.position.xyz+YPos,1));
#else
	PSInput.position = mul(WORLDVIEWPROJ,float4(VSInput.position.xyz+YPos,1));
#endif
#endif
}