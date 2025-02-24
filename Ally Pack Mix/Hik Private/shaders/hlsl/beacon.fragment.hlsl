#include "ShaderConstants.fxh"
#include "util.fxh"

#include "function/tonemap.hlsl"

struct PS_Input {
	float4 position : SV_Position;
	float4 light : LIGHT;
	float4 color : COLOR;
};

struct PS_Output
{
	float4 color : SV_Target;
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
	float4 color = PSInput.color;

	color.rgb = GBias(color.rgb);
	color.rgb *= 1.5;

	PSOutput.color = color;

	#ifdef VR_MODE
		// On Rift, the transition from 0 brightness to the lowest 8 bit value is abrupt, so clamp to 
		// the lowest 8 bit value.
		PSOutput.color = max(PSOutput.color, 1 / 255.0f);
	#endif
}