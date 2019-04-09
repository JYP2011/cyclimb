#version 330 core

layout (location = 0) in vec3  position;
layout (location = 1) in float attr1;

out vec3 vert_color;

uniform mat4 M;
uniform mat4 V;
uniform mat4 P;

vec3 default_palette[256] = vec3[](
	vec3(0.0,0.0,0.0),vec3(1.0,1.0,1.0),vec3(0.8,1.0,1.0),vec3(0.6,1.0,1.0),vec3(0.4,1.0,1.0),vec3(0.2,1.0,1.0),vec3(0.0,1.0,1.0),vec3(1.0,0.8,1.0),
    vec3(0.8,0.8,1.0),vec3(0.6,0.8,1.0),vec3(0.4,0.8,1.0),vec3(0.2,0.8,1.0),vec3(0.0,0.8,1.0),vec3(1.0,0.6,1.0),vec3(0.8,0.6,1.0),vec3(0.6,0.6,1.0),
    vec3(0.4,0.6,1.0),vec3(0.2,0.6,1.0),vec3(0.0,0.6,1.0),vec3(1.0,0.4,1.0),vec3(0.8,0.4,1.0),vec3(0.6,0.4,1.0),vec3(0.4,0.4,1.0),vec3(0.2,0.4,1.0),
    vec3(0.0,0.4,1.0),vec3(1.0,0.2,1.0),vec3(0.8,0.2,1.0),vec3(0.6,0.2,1.0),vec3(0.4,0.2,1.0),vec3(0.2,0.2,1.0),vec3(0.0,0.2,1.0),vec3(1.0,0.0,1.0),
    vec3(0.8,0.0,1.0),vec3(0.6,0.0,1.0),vec3(0.4,0.0,1.0),vec3(0.2,0.0,1.0),vec3(0.0,0.0,1.0),vec3(1.0,1.0,0.8),vec3(0.8,1.0,0.8),vec3(0.6,1.0,0.8),
    vec3(0.4,1.0,0.8),vec3(0.2,1.0,0.8),vec3(0.0,1.0,0.8),vec3(1.0,0.8,0.8),vec3(0.8,0.8,0.8),vec3(0.6,0.8,0.8),vec3(0.4,0.8,0.8),vec3(0.2,0.8,0.8),
    vec3(0.0,0.8,0.8),vec3(1.0,0.6,0.8),vec3(0.8,0.6,0.8),vec3(0.6,0.6,0.8),vec3(0.4,0.6,0.8),vec3(0.2,0.6,0.8),vec3(0.0,0.6,0.8),vec3(1.0,0.4,0.8),
    vec3(0.8,0.4,0.8),vec3(0.6,0.4,0.8),vec3(0.4,0.4,0.8),vec3(0.2,0.4,0.8),vec3(0.0,0.4,0.8),vec3(1.0,0.2,0.8),vec3(0.8,0.2,0.8),vec3(0.6,0.2,0.8),
    vec3(0.4,0.2,0.8),vec3(0.2,0.2,0.8),vec3(0.0,0.2,0.8),vec3(1.0,0.0,0.8),vec3(0.8,0.0,0.8),vec3(0.6,0.0,0.8),vec3(0.4,0.0,0.8),vec3(0.2,0.0,0.8),
    vec3(0.0,0.0,0.8),vec3(1.0,1.0,0.6),vec3(0.8,1.0,0.6),vec3(0.6,1.0,0.6),vec3(0.4,1.0,0.6),vec3(0.2,1.0,0.6),vec3(0.0,1.0,0.6),vec3(1.0,0.8,0.6),
    vec3(0.8,0.8,0.6),vec3(0.6,0.8,0.6),vec3(0.4,0.8,0.6),vec3(0.2,0.8,0.6),vec3(0.0,0.8,0.6),vec3(1.0,0.6,0.6),vec3(0.8,0.6,0.6),vec3(0.6,0.6,0.6),
    vec3(0.4,0.6,0.6),vec3(0.2,0.6,0.6),vec3(0.0,0.6,0.6),vec3(1.0,0.4,0.6),vec3(0.8,0.4,0.6),vec3(0.6,0.4,0.6),vec3(0.4,0.4,0.6),vec3(0.2,0.4,0.6),
    vec3(0.0,0.4,0.6),vec3(1.0,0.2,0.6),vec3(0.8,0.2,0.6),vec3(0.6,0.2,0.6),vec3(0.4,0.2,0.6),vec3(0.2,0.2,0.6),vec3(0.0,0.2,0.6),vec3(1.0,0.0,0.6),
    vec3(0.8,0.0,0.6),vec3(0.6,0.0,0.6),vec3(0.4,0.0,0.6),vec3(0.2,0.0,0.6),vec3(0.0,0.0,0.6),vec3(1.0,1.0,0.4),vec3(0.8,1.0,0.4),vec3(0.6,1.0,0.4),
    vec3(0.4,1.0,0.4),vec3(0.2,1.0,0.4),vec3(0.0,1.0,0.4),vec3(1.0,0.8,0.4),vec3(0.8,0.8,0.4),vec3(0.6,0.8,0.4),vec3(0.4,0.8,0.4),vec3(0.2,0.8,0.4),
    vec3(0.0,0.8,0.4),vec3(1.0,0.6,0.4),vec3(0.8,0.6,0.4),vec3(0.6,0.6,0.4),vec3(0.4,0.6,0.4),vec3(0.2,0.6,0.4),vec3(0.0,0.6,0.4),vec3(1.0,0.4,0.4),
    vec3(0.8,0.4,0.4),vec3(0.6,0.4,0.4),vec3(0.4,0.4,0.4),vec3(0.2,0.4,0.4),vec3(0.0,0.4,0.4),vec3(1.0,0.2,0.4),vec3(0.8,0.2,0.4),vec3(0.6,0.2,0.4),
    vec3(0.4,0.2,0.4),vec3(0.2,0.2,0.4),vec3(0.0,0.2,0.4),vec3(1.0,0.0,0.4),vec3(0.8,0.0,0.4),vec3(0.6,0.0,0.4),vec3(0.4,0.0,0.4),vec3(0.2,0.0,0.4),
    vec3(0.0,0.0,0.4),vec3(1.0,1.0,0.2),vec3(0.8,1.0,0.2),vec3(0.6,1.0,0.2),vec3(0.4,1.0,0.2),vec3(0.2,1.0,0.2),vec3(0.0,1.0,0.2),vec3(1.0,0.8,0.2),
    vec3(0.8,0.8,0.2),vec3(0.6,0.8,0.2),vec3(0.4,0.8,0.2),vec3(0.2,0.8,0.2),vec3(0.0,0.8,0.2),vec3(1.0,0.6,0.2),vec3(0.8,0.6,0.2),vec3(0.6,0.6,0.2),
    vec3(0.4,0.6,0.2),vec3(0.2,0.6,0.2),vec3(0.0,0.6,0.2),vec3(1.0,0.4,0.2),vec3(0.8,0.4,0.2),vec3(0.6,0.4,0.2),vec3(0.4,0.4,0.2),vec3(0.2,0.4,0.2),
    vec3(0.0,0.4,0.2),vec3(1.0,0.2,0.2),vec3(0.8,0.2,0.2),vec3(0.6,0.2,0.2),vec3(0.4,0.2,0.2),vec3(0.2,0.2,0.2),vec3(0.0,0.2,0.2),vec3(1.0,0.0,0.2),
    vec3(0.8,0.0,0.2),vec3(0.6,0.0,0.2),vec3(0.4,0.0,0.2),vec3(0.2,0.0,0.2),vec3(0.0,0.0,0.2),vec3(1.0,1.0,0.0),vec3(0.8,1.0,0.0),vec3(0.6,1.0,0.0),
    vec3(0.4,1.0,0.0),vec3(0.2,1.0,0.0),vec3(0.0,1.0,0.0),vec3(1.0,0.8,0.0),vec3(0.8,0.8,0.0),vec3(0.6,0.8,0.0),vec3(0.4,0.8,0.0),vec3(0.2,0.8,0.0),
    vec3(0.0,0.8,0.0),vec3(1.0,0.6,0.0),vec3(0.8,0.6,0.0),vec3(0.6,0.6,0.0),vec3(0.4,0.6,0.0),vec3(0.2,0.6,0.0),vec3(0.0,0.6,0.0),vec3(1.0,0.4,0.0),
    vec3(0.8,0.4,0.0),vec3(0.6,0.4,0.0),vec3(0.4,0.4,0.0),vec3(0.2,0.4,0.0),vec3(0.0,0.4,0.0),vec3(1.0,0.2,0.0),vec3(0.8,0.2,0.0),vec3(0.6,0.2,0.0),
    vec3(0.4,0.2,0.0),vec3(0.2,0.2,0.0),vec3(0.0,0.2,0.0),vec3(1.0,0.0,0.0),vec3(0.8,0.0,0.0),vec3(0.6,0.0,0.0),vec3(0.4,0.0,0.0),vec3(0.2,0.0,0.0),
    vec3(0.0,0.0,0.9),vec3(0.0,0.0,0.9),vec3(0.0,0.0,0.7),vec3(0.0,0.0,0.7),vec3(0.0,0.0,0.5),vec3(0.0,0.0,0.5),vec3(0.0,0.0,0.3),vec3(0.0,0.0,0.3),
    vec3(0.0,0.0,0.1),vec3(0.0,0.0,0.1),vec3(0.0,0.9,0.0),vec3(0.0,0.9,0.0),vec3(0.0,0.7,0.0),vec3(0.0,0.7,0.0),vec3(0.0,0.5,0.0),vec3(0.0,0.5,0.0),
    vec3(0.0,0.3,0.0),vec3(0.0,0.3,0.0),vec3(0.0,0.1,0.0),vec3(0.0,0.1,0.0),vec3(0.9,0.0,0.0),vec3(0.9,0.0,0.0),vec3(0.7,0.0,0.0),vec3(0.7,0.0,0.0),
    vec3(0.5,0.0,0.0),vec3(0.5,0.0,0.0),vec3(0.3,0.0,0.0),vec3(0.3,0.0,0.0),vec3(0.1,0.0,0.0),vec3(0.1,0.0,0.0),vec3(0.9,0.9,0.9),vec3(0.9,0.9,0.9),
    vec3(0.7,0.7,0.7),vec3(0.7,0.7,0.7),vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(0.3,0.3,0.3),vec3(0.3,0.3,0.3),vec3(0.1,0.1,0.1),vec3(0.1,0.1,0.1)
);
    
void main()
{
    //gl_Position = P * V * M * vec4(position, 1.0f);
    gl_Position = P * V * M * vec4(position, 1.0f);
	vert_color = default_palette[int(attr1)]; 
}