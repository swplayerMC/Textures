//File modified by @CrisXolt.
#include "ShaderConstants.fxh"
#include "util.fxh"

struct PS_Input
{
    float4 position : SV_Position;
#ifndef BYPASS_PIXEL_SHADER
    float2 uv : TEXCOORD_0_FB_MSAA;
#endif
};

struct PS_Output
{
    float4 color : SV_Target;
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE) || (VERSION < 0xa000 /*D3D_FEATURE_LEVEL_10_0*/) 
	float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv);
#else
	float4 diffuse = texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv);
#endif

#ifdef ALPHA_TEST
    if( diffuse.a < 0.5 )
    {
        discard;
    }
#endif

#ifdef IGNORE_CURRENTCOLOR
    PSOutput.color = diffuse;
#else
    PSOutput.color = CURRENT_COLOR * diffuse;
#endif

#ifdef WINDOWSMR_MAGICALPHA
    // Set the magic MR value alpha value so that this content pops over layers
    PSOutput.color.a = 133.0f / 255.0f;
#endif

#ifdef CUBEMAP

float CCMST = lerp(1.0,0.0,pow(max(min(1.0-FOG_COLOR.r*1.5,1.0),0.0),1.2));

float4 CT = TEXTURE_1.Sample(TextureSampler1, float2(0.0,1.0));
float ST = (CT.r - 0.5) / 0.5;
ST = max(0.0, min(1.0, ST));

float TD = (CCMST);
float TS = (0.5-abs(0.5-ST));
float TN = (1.0-CCMST);

float WRain = (1.0-pow(FOG_CONTROL.y,5.0));

float2 CMST = float2 (0.0,0.501);

float2 CMNT = float2 (0.501,0.0);

float2 CMDT = float2(0.499,0.499);

float4 N = TEXTURE_0.Sample(TextureSampler0,PSInput.uv.xy*CMDT+CMNT);

float4 D = TEXTURE_0.Sample(TextureSampler0,PSInput.uv.xy*CMDT);

float4 S = TEXTURE_0.Sample(TextureSampler0,PSInput.uv.xy*CMDT+CMST);


D = D * 1.0;

S = S * 2.25;

N = N * 1.0;

D = D * TD;

S = S * TS;

N = N * TN;

float4 D_and_S = (1.0-S.a)*D+S.a*S;

float4 CMC = (1.0-N.a)*D_and_S+N.a*N;

CMC -= CMC*WRain;

PSOutput.color = CMC;

#endif
}
