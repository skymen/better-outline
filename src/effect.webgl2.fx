#version 300 es

// Sample WebGL 2 shader. This just outputs a green color
// to indicate WebGL 2 is in use. Notice that WebGL 2 shaders
// must be written with '#version 300 es' as the very first line
// (no linebreaks or comments before it!) and have updated syntax.

in mediump vec2 vTex;
out lowp vec4 outColor;

#ifdef GL_FRAGMENT_PRECISION_HIGH
#define highmedp highp
#else
#define highmedp mediump
#endif

precision lowp float;

uniform lowp sampler2D samplerFront;
uniform mediump vec2 srcStart;
uniform mediump vec2 srcEnd;
uniform mediump vec2 srcOriginStart;
uniform mediump vec2 srcOriginEnd;
uniform mediump vec2 layoutStart;
uniform mediump vec2 layoutEnd;
uniform lowp sampler2D samplerBack;
uniform lowp sampler2D samplerDepth;
uniform mediump vec2 destStart;
uniform mediump vec2 destEnd;
uniform highmedp float seconds;
uniform mediump vec2 pixelSize;
uniform mediump float layerScale;
uniform mediump float layerAngle;
uniform mediump float devicePixelRatio;
uniform mediump float zNear;
uniform mediump float zFar;

//<-- UNIFORMS -->

#define PI 3.14159265359
#define SAMPLES 96
#define PASSES 64

void main(void)
{
	mediump float outlineAlpha = 0.0;
	mediump vec2 actualWidth;
	mediump float widthCopy = width;
	mediump vec4 color = vec4(outlinecolor.x, outlinecolor.y, outlinecolor.z, 1.0);
	mediump float angle;
	mediump vec2 layoutSize = abs(vec2(layoutEnd.x-layoutStart.x,(layoutEnd.y-layoutStart.y))); 
	mediump vec2 texelSize = abs(srcOriginEnd-srcOriginStart)/layoutSize;
	mediump vec4 fragColor;
	mediump vec2 testPoint;
	mediump float sampledAlpha;
	int passes = int(clamp(width / precisionStep, 1.0, float(PASSES)));
	int sampleCount = int(clamp(samples, 0.0, float(SAMPLES)));
	for (int j = 0; j < passes; j++) {
		widthCopy = mix(0.0, width, float(j)/float(passes));
		actualWidth = widthCopy * texelSize;
		angle = 0.0;
		for( int i = 0; i < sampleCount; i++ ) {
			angle += 1.0/(float(sampleCount)/2.0) * PI;
			testPoint = vTex + actualWidth * vec2(cos(angle), sin(angle));
			sampledAlpha = texture( samplerFront,  testPoint ).a;
			outlineAlpha = max( outlineAlpha, sampledAlpha );
		}
	}
	fragColor = mix( vec4(0.0), color, outlineAlpha );
	//TEXTURE
	mediump vec4 tex0 = texture( samplerFront, vTex );
	outColor = mix(fragColor, tex0, tex0.a);
}
