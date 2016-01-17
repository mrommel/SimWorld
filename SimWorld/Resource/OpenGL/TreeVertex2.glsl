// Matrices
uniform mat4 Projection;
uniform mat4 View;
uniform mat4 World;

// Attributes
attribute vec3 Position; // 1
attribute vec3 Normal; // 2
attribute vec2 TexCoordIn;
attribute vec2 BoneIndex; // special

#define MAXBONES 20 // Should be:  InverseReferenceFrame * AbsoluteBoneTransform
uniform mat4 Bones00;
uniform mat4 Bones01;
uniform mat4 Bones02;
uniform mat4 Bones03;
uniform mat4 Bones04;
uniform mat4 Bones05;
uniform mat4 Bones06;
uniform mat4 Bones07;
uniform mat4 Bones08;
uniform mat4 Bones09;
uniform mat4 Bones10;

// Varyings
varying vec2 TexCoordOut;
varying lowp vec4 DestinationColor; // 3

void main(void) { // 4
    //gl_Position = Projection * View * World * vec4(Position, 1.0);
    
    //gl_Position = Projection * View * World * Bones[int(BoneIndex.x)] * vec4(Position, 1.0);
    //Projection * View * World * Position;
    if (int(BoneIndex.x) == 0) {
        gl_Position = Projection * View * World * Bones00 * vec4(Position, 1.0);
    } else if (int(BoneIndex.x) == 1) {
        gl_Position = Projection * View * World * Bones01 * vec4(Position, 1.0);
    } else {
        gl_Position = Projection * View * World * vec4(Position, 1.0);
    }
    
    
    TexCoordOut = TexCoordIn;
    
    // Always set alpha to 1
    DestinationColor = vec4(0, 0.5, 0.5, 1);
}