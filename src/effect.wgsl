/////////////////////////////////////////////////////////
// Minimal sample WebGPU shader. This just outputs a blue
// color to indicate WebGPU is in use (rather than one of
// the WebGL shader variants).

%%FRAGMENTINPUT_STRUCT%%
/* input struct contains the following fields:
fragUV : vec2<f32>
fragPos : vec4<f32>
fn c3_getBackUV(fragPos : vec2<f32>, texBack : texture_2d<f32>) -> vec2<f32>
fn c3_getDepthUV(fragPos : vec2<f32>, texDepth : texture_depth_2d) -> vec2<f32>
*/
%%FRAGMENTOUTPUT_STRUCT%%

%%SAMPLERFRONT_BINDING%% var samplerFront : sampler;
%%TEXTUREFRONT_BINDING%% var textureFront : texture_2d<f32>;

//%//%SAMPLERBACK_BINDING%//% var samplerBack : sampler;
//%//%TEXTUREBACK_BINDING%//% var textureBack : texture_2d<f32>;

//%//%SAMPLERDEPTH_BINDING%//% var samplerDepth : sampler;
//%//%TEXTUREDEPTH_BINDING%//% var textureDepth : texture_depth_2d;


//<-- shaderParams -->

%%C3PARAMS_STRUCT%%
/* c3Params struct contains the following fields:
srcStart : vec2<f32>,
srcEnd : vec2<f32>,
srcOriginStart : vec2<f32>,
srcOriginEnd : vec2<f32>,
layoutStart : vec2<f32>,
layoutEnd : vec2<f32>,
destStart : vec2<f32>,
destEnd : vec2<f32>,
devicePixelRatio : f32,
layerScale : f32,
layerAngle : f32,
seconds : f32,
zNear : f32,
zFar : f32,
isSrcTexRotated : u32
fn c3_srcToNorm(p : vec2<f32>) -> vec2<f32>
fn c3_normToSrc(p : vec2<f32>) -> vec2<f32>
fn c3_srcOriginToNorm(p : vec2<f32>) -> vec2<f32>
fn c3_normToSrcOrigin(p : vec2<f32>) -> vec2<f32>
fn c3_clampToSrc(p : vec2<f32>) -> vec2<f32>
fn c3_clampToSrcOrigin(p : vec2<f32>) -> vec2<f32>
fn c3_getLayoutPos(p : vec2<f32>) -> vec2<f32>
fn c3_srcToDest(p : vec2<f32>) -> vec2<f32>
fn c3_clampToDest(p : vec2<f32>) -> vec2<f32>
fn c3_linearizeDepth(depthSample : f32) -> f32
*/

//%//%C3_UTILITY_FUNCTIONS%//%
/*
fn c3_premultiply(c : vec4<f32>) -> vec4<f32>
fn c3_unpremultiply(c : vec4<f32>) -> vec4<f32>
fn c3_grayscale(rgb : vec3<f32>) -> f32
fn c3_getPixelSize(t : texture_2d<f32>) -> vec2<f32>
fn c3_RGBtoHSL(color : vec3<f32>) -> vec3<f32>
fn c3_HSLtoRGB(hsl : vec3<f32>) -> vec3<f32>
*/

// define SAMPLES, PASSES and PI

const PI:f32 = 3.14159265359;
const SAMPLES:i32 = 96;
const PASSES:i32 = 64;

@fragment
fn main(input : FragmentInput) -> FragmentOutput
{
	var output : FragmentOutput;
	if (shaderParams.width <= 0.0 || shaderParams.outlineOpacity <= 0.0) {
		output.color = textureSample(textureFront, samplerFront, input.fragUV );
		return output;
	}
	var outlineAlpha: f32 = 0.0;
	var actualWidth: vec2<f32>;
	var widthCopy: f32 = shaderParams.width;
	var color: vec4<f32> = vec4<f32>(shaderParams.outlinecolor.x, shaderParams.outlinecolor.y, shaderParams.outlinecolor.z, 1.0);
	var angle: f32;
	let layoutSize: vec2<f32> = abs(vec2<f32>(c3Params.layoutEnd.x - c3Params.layoutStart.x, c3Params.layoutEnd.y - c3Params.layoutStart.y));
	let texelSize: vec2<f32> = abs(c3Params.srcOriginEnd - c3Params.srcOriginStart) / layoutSize;
	var fragColor: vec4<f32>;
	var testPoint: vec2<f32>;
	var sampledAlpha: f32;
	let passes: u32 = u32(clamp(shaderParams.width / shaderParams.precisionStep, 1.0, f32(SAMPLES)));
	let sampleCount: u32 = u32(clamp(shaderParams.samples, 0.0, f32(SAMPLES)));

	for (var j: u32 = 0u; j <= passes; j = j + 1u) {
			widthCopy = mix(0.0, shaderParams.width, f32(j) / f32(passes));
			actualWidth = widthCopy * texelSize;
			angle = 0.0;
			for (var i: u32 = 0u; i < sampleCount; i = i + 1u) {
					angle = angle + 1.0 / (f32(sampleCount) / 2.0) * PI;
					testPoint = input.fragUV + actualWidth * vec2<f32>(cos(angle), sin(angle));
					sampledAlpha = textureSample(textureFront, samplerFront, testPoint).a; // Assuming 'samplerFrontSampler' is the sampler associated with 'samplerFront'
					outlineAlpha = max(outlineAlpha, sampledAlpha);
			}
	}
	fragColor = mix( vec4(0.0), color, outlineAlpha * shaderParams.outlineOpacity );
	//TEXTURE
	var tex0 : vec4<f32> = textureSample(textureFront, samplerFront, input.fragUV );
	output.color = mix(fragColor, tex0, tex0.a);
	return output;
}
