#include "ShaderConstants.fxh"
#include "util.fxh"

#include "function/tonemap.hlsl"
#include "function/light.hlsl"
#include "function/compute.hlsl"
#include "function/dimension.hlsl"

struct PS_Input
{
	float4 position : SV_Position;

	#ifdef FOG
		float4 fogColor : FOG_COLOR;
	#endif
	#ifndef BYPASS_PIXEL_SHADER
		lpfloat4 color : COLOR;
		snorm float2 uv0 : TEXCOORD_0_FB_MSAA;
		snorm float2 uv1 : TEXCOORD_1_FB_MSAA;
	#endif

	float4 haze : HAZE;
};

struct PS_Output
{
	float4 color : SV_Target;
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
	#ifdef BYPASS_PIXEL_SHADER
		PSOutput.color = float4(0.0f, 0.0f, 0.0f, 0.0f);
		return;
	#else
		#if USE_TEXEL_AA
			float4 diffuse = texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv0 );
		#else
			float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv0);
		#endif

		float2 newUV1 = float2(PSInput.uv1.x, max(0.8*PSInput.uv1.y, pow(PSInput.uv1.y, 3.0)));
		float4 ambient = TEXTURE_1.Sample(TextureSampler1, newUV1);
		float skyexp = TEXTURE_1.Sample(TextureSampler1, float2(0.0, PSInput.uv1.y)).g;

		diffuse.rgb = lerp(diffuse.rgb + lightSource(float3(1.0, 0.6, 0.2), PSInput.uv1.x), diffuse.rgb, skyexp);

		#ifdef SEASONS_FAR
			diffuse.a = 1.0f;
		#endif

		#if USE_ALPHA_TEST
			#ifdef ALPHA_TO_COVERAGE
				#define ALPHA_THRESHOLD 0.05
			#else
				#define ALPHA_THRESHOLD 0.5
			#endif
			if(diffuse.a < ALPHA_THRESHOLD) discard;
		#endif

		#if defined(BLEND)
			diffuse.a *= PSInput.color.a;
		#endif

		#if !defined(ALWAYS_LIT)
			float checkSky = max(PSInput.uv1.y * 0.3, 0.2);
			diffuse *= max(ambient, checkSky);
		#endif

		#ifndef SEASONS
			#if !USE_ALPHA_TEST && !defined(BLEND)
				diffuse.a = PSInput.color.a;
			#endif

			diffuse.rgb *= PSInput.color.rgb;
		#else
			float2 uv = PSInput.color.xy;
			diffuse.rgb *= lerp(1.0f, TEXTURE_2.Sample(TextureSampler2, uv).rgb*2.0f, PSInput.color.b);
			diffuse.rgb *= PSInput.color.aaa;
			diffuse.a = 1.0f;
		#endif

		diffuse.rgb = GBias(diffuse.rgb);

		#ifdef FANCY
			float3 mono = polarize3(diffuse.rgb);
			float uncolor = 1.0;
			if(!(nether(FOG_COLOR.rgb) && underwater(FOG_CONTROL.x))) {
				uncolor = lerp(1.0, clamp(range1(FOG_CONTROL.y, 1.0, 0.9, 1.0, 0.8), 0.0, 1.0), PSInput.uv1.y);
			}
			diffuse.rgb = lerp(mono, diffuse.rgb, uncolor);
		#endif

		#ifdef FOG
			diffuse.rgb = lerp(diffuse.rgb, PSInput.fogColor.rgb, PSInput.fogColor.a);
		#endif
		diffuse.rgb = lerp(diffuse.rgb, PSInput.haze.rgb, PSInput.haze.a);

		PSOutput.color = diffuse;

		#ifdef VR_MODE
			// On Rift, the transition from 0 brightness to the lowest 8 bit value is abrupt, so clamp to 
			// the lowest 8 bit value.
			PSOutput.color = max(PSOutput.color, 1 / 255.0f);
		#endif
	#endif // BYPASS_PIXEL_SHADER
}