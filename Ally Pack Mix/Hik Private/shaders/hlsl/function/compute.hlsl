/*
Compute.hlsl, by Nick Genghar.
Free, Open-Source, Modifiable, Redistributable, Creditable as well as Non-Creditable.

Feel free to credit me if you appreciate my hard work on these fancy functions...
*/

//Fractionals
	//Starts at 0
	float bpfractO1(float F) {
		return 2.0 * (F - round(F));
	}
	float bpfractO2(float2 F) {
		return 2.0 * ((F.x * F.y) - round(F.x * F.y));
	}
	float bpfractO3(float3 F) {
		return 2.0 * ((F.x * F.y * F.z) - round(F.x * F.y * F.z));
	}
	float bpfractO4(float4 F) {
		return 2.0 * ((F.x * F.y * F.z * F.w) - round(F.x * F.y * F.z * F.w));
	}

	//Starts at -1
	float bpfractN1(float F) {
		return 2.0 * (F - floor(F)) - 1.0;
	}
	float bpfractN2(float2 F) {
		return 2.0 * ((F.x * F.y) - floor(F.x * F.y)) - 1.0;
	}
	float bpfractN3(float3 F) {
		return 2.0 * ((F.x * F.y * F.z) - floor(F.x * F.y * F.z)) - 1.0;
	}
	float bpfractN4(float4 F) {
		return 2.0 * ((F.x * F.y * F.z * F.w) - floor(F.x * F.y * F.z * F.w)) - 1.0;
	}

	//Starts at +1
	float bpfractP1(float F) {
		return 2.0 * (F - ceil(F)) + 1.0;
	}
	float bpfractP2(float2 F) {
		return 2.0 * ((F.x * F.y) - ceil(F.x * F.y)) + 1.0;
	}
	float bpfractP3(float3 F) {
		return 2.0 * ((F.x * F.y * F.z) - ceil(F.x * F.y * F.z)) + 1.0;
	}
	float bpfractP4(float4 F) {
		return 2.0 * ((F.x * F.y * F.z * F.w) - ceil(F.x * F.y * F.z * F.w)) + 1.0;
	}
//Fractionals

//Linearizers
	//Linearize N component to 1 component
	float2 linearize2(float2 x) {
		float l = (x.x * x.y);
		return float2(l, l);
	}
	float3 linearize3(float3 x) {
		float l = (x.x * x.y * x.z);
		return float3(l, l, l);
	}
	float4 linearize4(float4 x) {
		float l = (x.x * x.y * x.z * x.w);
		return float4(l, l, l, l);
	}

	//Linearize 2 component to 1 component with N
	float linearize211(float2 x, float f) {
		return x.x * f + x.y * f;
	}
	float linearize221(float2 x, float2 f) {
		return x.x * f.x + x.y * f.y;
	}
	float linearize231(float2 x, float3 f) {
		float2 newF = float2(f.x * f.z, f.y * f.z);
		return x.x * newF.x + x.y * newF.y;
	}
	float linearize241(float2 x, float4 f) {
		float2 newF = float2(f.x * f.z, f.y * f.w) * float2(f.x * f.y, f.z * f.w);
		return x.x * newF.x + x.y * newF.y;
	}

	//Linearize 3 component to 1 component with N
	float linearize311(float3 x, float f) {
		return x.x * f + x.y * f + x.z * f;
	}
	float linearize321(float3 x, float2 f) {
		float3 newF = float3(f.x, f.y, f.x * f.y);
		return x.x * newF.x + x.y * newF.y + x.z * newF.z;
	}
	float linearize331(float3 x, float3 f) {
		return x.x * f.x + x.y * f.y + x.z * f.z;
	}
	float linearize341(float3 x, float4 f) {
		float4 newF = float4(f.x * f.z, f.y * f.w, f.z * f.w, f.w * f.x);
		return x.x * newF.x * newF.w + x.y * newF.y * newF.w + x.z * newF.z * newF.w;
	}

	//Linearize 4 component to 1 component with N
	float linearize411(float4 x, float f) {
		return x.x * f + x.y * f + x.z * f + x.w * f;
	}
	float linearize421(float4 x, float2 f) {
		float4 newF = float4(f.x, f.y, f.x, f.y) * float4(f.x * f.y, f.x, f.y, f.x * f.y);
		return x.x * newF.x + x.y * newF.y + x.z * newF.z + x.w * newF.w;
	}
	float linearize431(float4 x, float3 f) {
		float4 newF = float4(f.x, f.y, f.z, f.x) * float4(f.z, f.x, f.y, f.z);
		return x.x * newF.x + x.y * newF.y + x.z * newF.z + x.w * newF.w;
	}
	float linearize441(float4 x, float4 f) {
		return x.x * f.x + x.y * f.y + x.z * f.z + x.w * f.w;
	}
//Linearizers

//Polarizers
	//Polarize N component to N
	float2 polarize2(float2 P) {
		float newP = (P.x + P.y) / 2.0;
		return float2(newP, newP);
	}
	float3 polarize3(float3 P) {
		float newP = (P.x + P.y + P.z) / 3.0;
		return float3(newP, newP, newP);
	}
	float4 polarize4(float4 P) {
		float newP = (P.x + P.y + P.z + P.w) / 4.0;
		return float4(newP, newP, newP, newP);
	}

	//Unipolarize N component to N
	float unipolar1(float U) {
		return 0.5 * U + 0.5;
	}
	float2 unipolar2(float2 U) {
		return float2(0.5, 0.5) * U + float2(0.5, 0.5);
	}
	float3 unipolar3(float3 U) {
		return float3(0.5, 0.5, 0.5) * U + float3(0.5, 0.5, 0.5);
	}
	float4 unipolar4(float4 U) {
		return float4(0.5, 0.5, 0.5, 0.5) * U + float4(0.5, 0.5, 0.5, 0.5);
	}

	//Bipolarize N component to N
	float bipolar1(float B) {
		return 2.0 * B - 1.0;
	}
	float2 bipolar2(float2 B) {
		return float2(2.0, 2.0) * B - float2(1.0, 1.0);
	}
	float3 bipolar3(float3 B) {
		return float3(2.0, 2.0, 2.0) * B - float3(1.0, 1.0, 1.0);
	}
	float4 bipolar4(float4 B) {
		return float4(2.0, 2.0, 2.0, 2.0) * B - float4(1.0, 1.0, 1.0, 1.0);
	}
//Polarizers

//Smoother Step
	float smootherstep1(float N) {
		return clamp(N * N * N * (N * (N * 6.0 - 15.0) + 10.0), 0.0, 1.0);
	}
	float2 smootherstep2(float2 N) {
		return clamp(N * N * N * (N * (N * float2(6.0, 6.0) - float2(15.0, 15.0)) + float2(10.0, 10.0)), 0.0, 1.0);
	}
	float3 smootherstep3(float3 N) {
		return clamp(N * N * N * (N * (N * float3(6.0, 6.0, 6.0) - float3(15.0, 15.0, 15.0)) + float3(10.0, 10.0, 10.0)), 0.0, 1.0);
	}
	float4 smootherstep4(float4 N) {
		return clamp(N * N * N * (N * (N * float4(6.0, 6.0, 6.0, 6.0) - float4(15.0, 15.0, 15.0, 15.0)) + float4(10.0, 10.0, 10.0, 10.0)), 0.0, 1.0);
	}
//Smoother Step

//Rangers
	float range1(float oldValue, float oldMax, float oldMin, float newMax, float newMin) {
		float oldRange = oldMax - oldMin;
		float newRange = newMax - newMin;
		float newValue;

		if (oldRange == 0.0) {
			newValue = newMin;
		} else {
			newValue = (((oldValue - oldMin) * newRange) / oldRange) + newMin;
		}

		return newValue;
	}
	float2 range2(float2 oldValue, float2 oldMax, float2 oldMin, float2 newMax, float2 newMin) {
		float2 oldRange = oldMax - oldMin;
		float2 newRange = newMax - newMin;
		float2 newValue;

		if (oldRange.x == 0.0 || oldRange.y == 0.0) {
			newValue = newMin;
		} else {
			newValue = (((oldValue - oldMin) * newRange) / oldRange) + newMin;
		}

		return newValue;
	}
	float3 range3(float3 oldValue, float3 oldMax, float3 oldMin, float3 newMax, float3 newMin) {
		float3 oldRange = oldMax - oldMin;
		float3 newRange = newMax - newMin;
		float3 newValue;

		if (oldRange.x == 0.0 || oldRange.y == 0.0 || oldRange.z == 0.0) {
			newValue = newMin;
		} else {
			newValue = (((oldValue - oldMin) * newRange) / oldRange) + newMin;
		}

		return newValue;
	}
	float4 range4(float4 oldValue, float4 oldMax, float4 oldMin, float4 newMax, float4 newMin) {
		float4 oldRange = oldMax - oldMin;
		float4 newRange = newMax - newMin;
		float4 newValue;

		if (oldRange.x == 0.0 || oldRange.y == 0.0 || oldRange.z == 0.0 || oldRange.w == 0.0) {
			newValue = newMin;
		} else {
			newValue = (((oldValue - oldMin) * newRange) / oldRange) + newMin;
		}

		return newValue;
	}
//Rangers