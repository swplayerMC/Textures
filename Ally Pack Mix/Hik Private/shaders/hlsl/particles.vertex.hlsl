#include "ShaderConstants.fxh"

#include "function/fog.hlsl"

struct VS_Input
{
    float3 position : POSITION;
    float4 color : COLOR;
    float2 texCoords : TEXCOORD_0;

	#ifdef INSTANCEDSTEREO
		uint instanceID : SV_InstanceID;
	#endif
};

struct PS_Input
{
    float4 position : SV_Position;
    float4 color : COLOR;
    float2 texCoords : TEXCOORD_0;

	#ifdef GLINT
		float2 layer1UV : UV_1;
		float2 layer2UV : UV_2;
	#endif
	#ifdef GEOMETRY_INSTANCEDSTEREO
		uint instanceID : SV_InstanceID;
	#endif
	#ifdef VERTEXSHADER_INSTANCEDSTEREO
		uint renTarget_id : SV_RenderTargetArrayIndex;
	#endif

	float4 haze : HAZE;
};

#ifdef GLINT
	float2 calculateLayerUV(float2 origUV, float offset, float rotation) {
		float2 uv = origUV;
		uv -= 0.5;
		float rsin = sin(rotation);
		float rcos = cos(rotation);
		uv = mul(uv, float2x2(rcos, -rsin, rsin, rcos));
		uv.x += offset;
		uv += 0.5;

		return uv * GLINT_UV_SCALE;
	}
#endif

ROOT_SIGNATURE
void main(in VS_Input VSInput, out PS_Input PSInput) {
    PSInput.color = VSInput.color;
	PSInput.texCoords = VSInput.texCoords;

	#ifdef INSTANCEDSTEREO
		int i = VSInput.instanceID;
		PSInput.position = mul( WORLDVIEWPROJ_STEREO[i], float4( VSInput.position, 1 ) );
	#else
		PSInput.position = mul(WORLDVIEWPROJ, float4(VSInput.position, 1));
	#endif

	#ifdef USE_LIGHTING
		PSInput.color *= float4(TILE_LIGHT_COLOR.rgb, 1.0);
	#endif

	#ifdef GLINT
		PSInput.layer1UV = calculateLayerUV(VSInput.texCoords, UV_OFFSET.x, UV_ROTATION.x);
		PSInput.layer2UV = calculateLayerUV(VSInput.texCoords, UV_OFFSET.y, UV_ROTATION.y);
	#endif
	#ifdef GEOMETRY_INSTANCEDSTEREO
		PSInput.instanceID = VSInput.instanceID;
	#endif 
	#ifdef VERTEXSHADER_INSTANCEDSTEREO
		PSInput.renTarget_id = VSInput.instanceID;
	#endif

	PSInput.haze.rgb = FOG_COLOR.rgb;
	float len = clamp(PSInput.position.xyz / RENDER_DISTANCE, 0.0, 1.0);
	PSInput.haze.a = CurveMap(len);
}