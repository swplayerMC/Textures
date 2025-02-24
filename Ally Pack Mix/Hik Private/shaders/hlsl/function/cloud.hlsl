static const float cloudscale = 1.1;
static const float speed = 0.03;
static const float clouddark = 0.5;
static const float cloudlight = 0.3;
static const float cloudcover = 0.2;
static const float cloudalpha = 8.0;
static const float skytint = 0.5;
static const float3 skycolour1 = float3(0.2, 0.4, 0.6);
static const float3 skycolour2 = float3(0.4, 0.7, 1.0);

static const float2x2 m = float2x2(1.6, 1.2, -1.2, 1.6);

float3 vec3(float x) {return float3(x,x,x);}

float2 hash(float2 p) {
    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
    return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

float Hnoise(in float2 p) {
    static const float K1 = 0.366025404;
    static const float K2 = 0.211324865;

    float2 i = floor(p + (p.x + p.y) * K1);
    float2 a = p - i + (i.x + i.y) * K2;
    float2 o = (a.x>a.y) ? float2(1.0,0.0) : float2(0.0,1.0);
    float2 b = a - o + K2;
    float2 c = a - 1.0 + 2.0 * K2;
    float3 h = max(0.5 - float3(dot(a,a), dot(b,b), dot(c,c)), 0.0);
    float3 n = pow(h, vec3(5.0)) * float3(dot(a, hash(i+0.0)), dot(b, hash(i+o)), dot(c, hash(i+1.0)));
    return dot(n, vec3(70.0));
}

float fbm(float2 n) {
    float total = 0.0;
    float amplitude = 0.1;
    for(int i = 0; i < 7; i++) {
        total += Hnoise(n) * amplitude;
        n = mul(m,n);
        amplitude *= 0.4;
    }
    return total;
}