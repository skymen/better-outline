//<-- UNIFORMS -->

/////////////////////////////////////////////////////////
// BetterOutline

//The current foreground texture co-ordinate
varying mediump vec2 vTex;
//The foreground texture sampler, to be sampled at vTex
uniform lowp sampler2D samplerFront;
//The current foreground rectangle being rendered
uniform mediump vec2 srcStart;
uniform mediump vec2 srcEnd;
//The current foreground source rectangle being rendered
uniform mediump vec2 srcOriginStart;
uniform mediump vec2 srcOriginEnd;
//The current foreground source rectangle being rendered, in layout 
uniform mediump vec2 layoutStart;
uniform mediump vec2 layoutEnd;
//The background texture sampler used for background - blending effects
uniform lowp sampler2D samplerBack;
//The current background rectangle being rendered to, in texture co-ordinates, for background-blending effects
uniform mediump vec2 destStart;
uniform mediump vec2 destEnd;
//The time in seconds since the runtime started. This can be used for animated effects
uniform mediump float seconds;
//The size of a texel in the foreground texture in texture co-ordinates
uniform mediump vec2 pixelSize;
//The current layer scale as a factor (i.e. 1 is unscaled)
uniform mediump float layerScale;
//The current layer angle in radians.
uniform mediump float layerAngle;

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
	for (int j=0; j<PASSES; j++) {
		if (j >= passes ) break;
		widthCopy = mix(0.0, width, float(j)/float(passes));
		actualWidth = widthCopy * texelSize;
		angle = 0.0;
		for( int i=0; i<SAMPLES; i++ ){
			if (i >= int(samples)) break;
			angle += 1.0/(clamp(samples, 0.0, float(SAMPLES))/2.0) * PI;
			testPoint = vTex + actualWidth * vec2(cos(angle), sin(angle));
			sampledAlpha = texture2D( samplerFront,  testPoint ).a;
			outlineAlpha = max( outlineAlpha, sampledAlpha );
		}
	}
	fragColor = mix( vec4(0.0), color, outlineAlpha );
	//TEXTURE
	mediump vec4 tex0 = texture2D( samplerFront, vTex );
	gl_FragColor = mix(fragColor, tex0, tex0.a);
}