#include "ShaderConstants.fxh"

#include "function/tonemap.hlsl"

struct PS_Input
{
	float4 position : SV_Position;
	float4 color : COLOR;
	float2 uv : TEXCOORD_0;

	#ifdef GLINT
		float2 layer1UV : UV_1;
		float2 layer2UV : UV_2;
	#endif

	float4 haze : HAZE;
};

struct PS_Output
{
	float4 color : SV_Target;
};

float4 glintBlend(float4 dest, float4 source) {
	return float4(source.rgb * source.rgb, 0.0) + dest;
}

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput) {
	#ifdef EFFECTS_OFFSET
		float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv + EFFECT_UV_OFFSET);
	#else
		float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv);
	#endif

	#ifdef MULTI_COLOR_TINT
		// Texture is a mask for tinting with two colors
		float2 colorMask = diffuse.rg;

		// Apply the base color tint
		diffuse.rgb = colorMask.rrr * PSInput.color.rgb;

		// Apply the secondary color mask and tint so long as its grayscale value is not 0
		diffuse.rgb = lerp(diffuse.rgb, colorMask.ggg * CHANGE_COLOR, ceil(colorMask.g));
	#endif

	#ifdef ALPHA_TEST
		#ifdef ENABLE_VERTEX_TINT_MASK
			if( diffuse.a <= 0.0f )
		#else
			if (diffuse.a <= 0.5f)
		#endif
		
		discard;
	#endif

	#if defined(ENABLE_VERTEX_TINT_MASK) && !defined(MULTI_COLOR_TINT)
		diffuse.rgb = lerp(diffuse.rgb, diffuse.rgb*PSInput.color.rgb, diffuse.a);
		if (PSInput.color.a > 0.0f) diffuse.a = diffuse.a > 0.0f ? 1.0f : 0.0f; // This line is needed for horse armour icon and dyed leather to work properly
	#endif

	#ifdef GLINT
		float4 layer1 = TEXTURE_1.Sample(TextureSampler1, frac(PSInput.layer1UV)).rgbr * GLINT_COLOR;
		float4 layer2 = TEXTURE_1.Sample(TextureSampler1, frac(PSInput.layer2UV)).rgbr * GLINT_COLOR;
		float4 glint = (layer1 + layer2);
		glint.rgb *= PSInput.color.a;

		#ifdef INVENTORY
			diffuse.rgb = glint.rgb;
		#else
			diffuse.rgb = glintBlend(diffuse, glint).rgb;
		#endif
	#endif

	#ifdef USE_OVERLAY
		//use either the diffuse or the OVERLAY_COLOR
		diffuse.rgb = lerp( diffuse, OVERLAY_COLOR, OVERLAY_COLOR.a ).rgb;
	#endif

	#ifdef ENABLE_VERTEX_TINT_MASK
		#ifdef ENABLE_CURRENT_ALPHA_MULTIPLY
			diffuse = diffuse * float4(1.0f, 1.0f, 1.0f, HUD_OPACITY);
		#endif
	#elif !defined(MULTI_COLOR_TINT)
		diffuse = diffuse * PSInput.color;
	#endif

	diffuse.rgb = GBias(diffuse.rgb);
	diffuse.rgb = lerp(diffuse.rgb, PSInput.haze.rgb, PSInput.haze.a);

	PSOutput.color = diffuse;

	#ifdef VR_MODE
		// On Rift, the transition from 0 brightness to the lowest 8 bit value is abrupt, so clamp to 
		// the lowest 8 bit value.
		PSOutput.color = max(PSOutput.color, 1 / 255.0f);
	#endif
}