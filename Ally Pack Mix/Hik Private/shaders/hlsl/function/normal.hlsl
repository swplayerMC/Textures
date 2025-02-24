float3 normalMap(in sampler tex, in float2 uv, float depthness, float strength)
{
    float4 avgRGB0 = float4(1.0/3.0, 1.0/3.0, 1.0/3.0, 0.0);
    float2 du = float2(1.0/depthness, 0.0);
    float2 dv = float2(0.0, 1.0/depthness);

    float h0  = dot(avgRGB0, TEXTURE_0.Sample(tex, uv)) * strength;
    float hpx = dot(avgRGB0, TEXTURE_0.Sample(tex, uv + du)) * strength;
    float hmx = dot(avgRGB0, TEXTURE_0.Sample(tex, uv - du)) * strength;
    float hpy = dot(avgRGB0, TEXTURE_0.Sample(tex, uv + dv)) * strength;
    float hmy = dot(avgRGB0, TEXTURE_0.Sample(tex, uv - dv)) * strength;
    
    float dHdU = (hmx - hpx) / (2.0 * du.x);
    float dHdV = (hmy - hpy) / (2.0 * dv.y);
    
    return normalize(float3(dHdU, dHdV, 1.0)) * 0.5 + 0.5;
}