#include "ShaderConstants.fxh"

struct PS_Input
{
	float4 position : SV_Position;
};

struct PS_Output
{
	float4 color : SV_Target;

	#ifdef FORCE_DEPTH_ZERO
		float depth : SV_Depth;
	#endif
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
	float3 chroma = 0.5 + 0.5 * cos(TOTAL_REAL_WORLD_TIME + float3(0.0, 2.0, 4.0));
	PSOutput.color = float4(chroma, 1.0);

	#ifdef FORCE_DEPTH_ZERO
		PSOutput.depth = 0.0;
	#endif
}