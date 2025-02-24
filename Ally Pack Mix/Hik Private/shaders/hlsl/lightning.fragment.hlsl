#include "ShaderConstants.fxh"

#include "function/tonemap.hlsl"

struct PS_Input
{
    float4 position : SV_Position;
    float4 color : COLOR;
};

struct PS_Output
{
    float4 color : SV_Target;
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
    float4 base = PSInput.color;
    base.rgb = GBias(base.rgb);
    base.rgb *= 1.5;
    PSOutput.color = base;
}