precision mediump float;

varying vec4 DestinationColor;

varying vec2 TexCoordOut;

uniform sampler2D texture[1];

void main(void) {
    vec4 texel0 = texture2D(texture[0], TexCoordOut);
    gl_FragColor = texel0;
}