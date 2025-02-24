float3 lightSource(float3 C, float I) {
	return C * min(max(dot(I - 0.2, 0.5), 0.1), max(dot(I, 0.6), 0.0) * 0.4);
}