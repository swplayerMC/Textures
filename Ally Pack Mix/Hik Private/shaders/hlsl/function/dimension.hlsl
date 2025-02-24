bool nether(float3 N) {
	if(N.r > N.g && N.b > N.g && N.r < 0.4 && N.g < 0.2 && N.b < 0.1) {
		return true;
	} else {
		return false;
	}
}

bool underwater(float N) {
	if(N > 0.0 && N < 0.3) {
		return true;
	} else {
		return false;
	}
}