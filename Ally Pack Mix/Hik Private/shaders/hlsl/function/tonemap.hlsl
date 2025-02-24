float3 GBias(float3 x) {
	float A = 0.6;
	float B = 0.4;
	float C = 0.8;
	float D = 0.65;
	float E = 0.9;
	float F = 1.2;

	float3 film = float3(0.4, 0.3, 0.0);
	float3 colorize = float3(0.4, 0.3, 0.0);

	float newFilm = dot(film, film * x);
	float3 newColor = colorize * newFilm;

	x = x * (x + newColor);
	x = clamp(x, 0.0, 1.0);
	x *= 3.0;

	return -((x * ((A + B) / (x + C)) + D) / (x * (A / B) + (A * E))) + F;
}