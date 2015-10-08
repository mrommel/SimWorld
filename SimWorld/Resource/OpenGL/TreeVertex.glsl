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
uniform mat4 Bones[MAXBONES];

// Varyings
varying vec2 TexCoordOut;
varying vec4 DestinationColor; // 3

// temp vars
//vec4 localPosition;
//vec4 worldPosition;
//vec4 viewPosition;

vec4 normalTemp;

vec4 DirLight0DiffuseColor = vec4(1,1,1,0);
vec4 DirLight0Direction = vec4(0,-1,0,0);			// Unit vector from light source towards object
bool DirLight0Enabled = true;

vec4 DirLight1DiffuseColor = vec4(1,1,0.8,0);
vec4 DirLight1Direction = vec4(1,0,0,0);
bool DirLight1Enabled = true;

vec4 AmbientLight = vec4(0.05,0.05,0.05,0);

void main(void) { // 4
    //localPosition = Position * ;
    //worldPosition = localPosition * World;
    //viewPosition = worldPosition * View;
    //gl_Position = viewPosition * Projection;
    gl_Position = Projection * View * World * Bones[int(BoneIndex.x)] * Position;
    
    TexCoordOut = TexCoordIn;
    
    normalTemp = Bones[int(BoneIndex.x)] * Normal;
    normalTemp = normalize(World * normalTemp);
    
    DestinationColor = AmbientLight;
    
    if (DirLight0Enabled)
    {
        DestinationColor = DestinationColor + DirLight0DiffuseColor * clamp(dot(normalTemp, -DirLight0Direction), 0.0, 1.0);
    }
    
    if (DirLight1Enabled)
    {
        // We assume that DirLight1 is only enabled if DirLight0 is also enabled, so use += here
        DestinationColor = DestinationColor + DirLight1DiffuseColor * clamp(dot(normalTemp, -DirLight1Direction), 0.0, 1.0);
    }
    
    // Always set alpha to 1
    DestinationColor.z = 1.0; // 5
}