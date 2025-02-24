//Playing Grains
//Officially called the "Genghar's Cuatom Pseudo Random Noise".
//Yes, CUATOM. Called so from my misspelled "custom". Sounds deliberate eh?

float grain(float2 UV, float seed) {
    UV = fmod(UV, 147.0);
    float uv1 = frac(dot(UV, float2(5412.051,241.053)));
    float uv2 = frac(dot(UV, float2(182.051,2186.15)));

    float2 hax = float2(uv1, uv2) * frac(dot(UV,UV)) * 42610.0 * abs(seed);

    float4 dis = float4(hax.y, frac(seed) * 1.0-hax.x, frac(seed) * 1.0-hax.y, hax.x);
    float4 haxr = float4(hax, hax * frac(seed));
    float final = (distance(dis, haxr)+length(dis)+length(haxr))/3.0;

    return fmod(final, 1.0);
}

float sineWave(float dimension, float amplitude, float frequency, float phase) {
	return amplitude * sin(frequency + (dimension + phase));
}