#include "ShaderConstants.fxh"
#include "util.fxh"

struct PS_Input
{
	float4 position : SV_Position;
	snorm float2 uv : TEXCOORD_0_FB_MSAA;
};

struct PS_Output
{
	float4 color : SV_Target;
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
	#if USE_TEXEL_AA
		float4 diffuse = texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv);
	#else
		float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv);
	#endif

	#if USE_ALPHA_TEST
		if(diffuse.a < 0.05) discard;
	#endif

	PSOutput.color = diffuse;

	#ifdef VR_MODE
		// On Rift, the transition from 0 brightness to the lowest 8 bit value is abrupt, so clamp to 
		// the lowest 8 bit value.
		PSOutput.color = max(PSOutput.color, 1 / 255.0f);
	#endif
}