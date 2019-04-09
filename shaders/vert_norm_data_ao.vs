#version 330 core

layout (location = 0) in vec3  position;
layout (location = 1) in float normal_idx;
layout (location = 2) in float color_idx;
layout (location = 3) in float ao;

out VS_OUT {
	vec3 vert_color;
	vec3 normal;
	vec4 frag_pos_lightspace;
} vs_out;


uniform mat4 M;
uniform mat4 V;
uniform mat4 P;

uniform mat4 lightPV;

vec3 default_palette[256] = vec3[](
    vec3(0.000,0.000,0.000),vec3(1.000,1.000,1.000),vec3(1.000,1.000,0.800),vec3(1.000,1.000,0.600),vec3(1.000,1.000,0.400),vec3(1.000,1.000,0.200),vec3(1.000,1.000,0.000),vec3(1.000,0.800,1.000),
    vec3(1.000,0.800,0.800),vec3(1.000,0.800,0.600),vec3(1.000,0.800,0.400),vec3(1.000,0.800,0.200),vec3(1.000,0.800,0.000),vec3(1.000,0.600,1.000),vec3(1.000,0.600,0.800),vec3(1.000,0.600,0.600),
    vec3(1.000,0.600,0.400),vec3(1.000,0.600,0.200),vec3(1.000,0.600,0.000),vec3(1.000,0.400,1.000),vec3(1.000,0.400,0.800),vec3(1.000,0.400,0.600),vec3(1.000,0.400,0.400),vec3(1.000,0.400,0.200),
    vec3(1.000,0.400,0.000),vec3(1.000,0.200,1.000),vec3(1.000,0.200,0.800),vec3(1.000,0.200,0.600),vec3(1.000,0.200,0.400),vec3(1.000,0.200,0.200),vec3(1.000,0.200,0.000),vec3(1.000,0.000,1.000),
    vec3(1.000,0.000,0.800),vec3(1.000,0.000,0.600),vec3(1.000,0.000,0.400),vec3(1.000,0.000,0.200),vec3(1.000,0.000,0.000),vec3(0.800,1.000,1.000),vec3(0.800,1.000,0.800),vec3(0.800,1.000,0.600),
    vec3(0.800,1.000,0.400),vec3(0.800,1.000,0.200),vec3(0.800,1.000,0.000),vec3(0.800,0.800,1.000),vec3(0.800,0.800,0.800),vec3(0.800,0.800,0.600),vec3(0.800,0.800,0.400),vec3(0.800,0.800,0.200),
    vec3(0.800,0.800,0.000),vec3(0.800,0.600,1.000),vec3(0.800,0.600,0.800),vec3(0.800,0.600,0.600),vec3(0.800,0.600,0.400),vec3(0.800,0.600,0.200),vec3(0.800,0.600,0.000),vec3(0.800,0.400,1.000),
    vec3(0.800,0.400,0.800),vec3(0.800,0.400,0.600),vec3(0.800,0.400,0.400),vec3(0.800,0.400,0.200),vec3(0.800,0.400,0.000),vec3(0.800,0.200,1.000),vec3(0.800,0.200,0.800),vec3(0.800,0.200,0.600),
    vec3(0.800,0.200,0.400),vec3(0.800,0.200,0.200),vec3(0.800,0.200,0.000),vec3(0.800,0.000,1.000),vec3(0.800,0.000,0.800),vec3(0.800,0.000,0.600),vec3(0.800,0.000,0.400),vec3(0.800,0.000,0.200),
    vec3(0.800,0.000,0.000),vec3(0.600,1.000,1.000),vec3(0.600,1.000,0.800),vec3(0.600,1.000,0.600),vec3(0.600,1.000,0.400),vec3(0.600,1.000,0.200),vec3(0.600,1.000,0.000),vec3(0.600,0.800,1.000),
    vec3(0.600,0.800,0.800),vec3(0.600,0.800,0.600),vec3(0.600,0.800,0.400),vec3(0.600,0.800,0.200),vec3(0.600,0.800,0.000),vec3(0.600,0.600,1.000),vec3(0.600,0.600,0.800),vec3(0.600,0.600,0.600),
    vec3(0.600,0.600,0.400),vec3(0.600,0.600,0.200),vec3(0.600,0.600,0.000),vec3(0.600,0.400,1.000),vec3(0.600,0.400,0.800),vec3(0.600,0.400,0.600),vec3(0.600,0.400,0.400),vec3(0.600,0.400,0.200),
    vec3(0.600,0.400,0.000),vec3(0.600,0.200,1.000),vec3(0.600,0.200,0.800),vec3(0.600,0.200,0.600),vec3(0.600,0.200,0.400),vec3(0.600,0.200,0.200),vec3(0.600,0.200,0.000),vec3(0.600,0.000,1.000),
    vec3(0.600,0.000,0.800),vec3(0.600,0.000,0.600),vec3(0.600,0.000,0.400),vec3(0.600,0.000,0.200),vec3(0.600,0.000,0.000),vec3(0.400,1.000,1.000),vec3(0.400,1.000,0.800),vec3(0.400,1.000,0.600),
    vec3(0.400,1.000,0.400),vec3(0.400,1.000,0.200),vec3(0.400,1.000,0.000),vec3(0.400,0.800,1.000),vec3(0.400,0.800,0.800),vec3(0.400,0.800,0.600),vec3(0.400,0.800,0.400),vec3(0.400,0.800,0.200),
    vec3(0.400,0.800,0.000),vec3(0.400,0.600,1.000),vec3(0.400,0.600,0.800),vec3(0.400,0.600,0.600),vec3(0.400,0.600,0.400),vec3(0.400,0.600,0.200),vec3(0.400,0.600,0.000),vec3(0.400,0.400,1.000),
    vec3(0.400,0.400,0.800),vec3(0.400,0.400,0.600),vec3(0.400,0.400,0.400),vec3(0.400,0.400,0.200),vec3(0.400,0.400,0.000),vec3(0.400,0.200,1.000),vec3(0.400,0.200,0.800),vec3(0.400,0.200,0.600),
    vec3(0.400,0.200,0.400),vec3(0.400,0.200,0.200),vec3(0.400,0.200,0.000),vec3(0.400,0.000,1.000),vec3(0.400,0.000,0.800),vec3(0.400,0.000,0.600),vec3(0.400,0.000,0.400),vec3(0.400,0.000,0.200),
    vec3(0.400,0.000,0.000),vec3(0.200,1.000,1.000),vec3(0.200,1.000,0.800),vec3(0.200,1.000,0.600),vec3(0.200,1.000,0.400),vec3(0.200,1.000,0.200),vec3(0.200,1.000,0.000),vec3(0.200,0.800,1.000),
    vec3(0.200,0.800,0.800),vec3(0.200,0.800,0.600),vec3(0.200,0.800,0.400),vec3(0.200,0.800,0.200),vec3(0.200,0.800,0.000),vec3(0.200,0.600,1.000),vec3(0.200,0.600,0.800),vec3(0.200,0.600,0.600),
    vec3(0.200,0.600,0.400),vec3(0.200,0.600,0.200),vec3(0.200,0.600,0.000),vec3(0.200,0.400,1.000),vec3(0.200,0.400,0.800),vec3(0.200,0.400,0.600),vec3(0.200,0.400,0.400),vec3(0.200,0.400,0.200),
    vec3(0.200,0.400,0.000),vec3(0.200,0.200,1.000),vec3(0.200,0.200,0.800),vec3(0.200,0.200,0.600),vec3(0.200,0.200,0.400),vec3(0.200,0.200,0.200),vec3(0.200,0.200,0.000),vec3(0.200,0.000,1.000),
    vec3(0.200,0.000,0.800),vec3(0.200,0.000,0.600),vec3(0.200,0.000,0.400),vec3(0.200,0.000,0.200),vec3(0.200,0.000,0.000),vec3(0.000,1.000,1.000),vec3(0.000,1.000,0.800),vec3(0.000,1.000,0.600),
    vec3(0.000,1.000,0.400),vec3(0.000,1.000,0.200),vec3(0.000,1.000,0.000),vec3(0.000,0.800,1.000),vec3(0.000,0.800,0.800),vec3(0.000,0.800,0.600),vec3(0.000,0.800,0.400),vec3(0.000,0.800,0.200),
    vec3(0.000,0.800,0.000),vec3(0.000,0.600,1.000),vec3(0.000,0.600,0.800),vec3(0.000,0.600,0.600),vec3(0.000,0.600,0.400),vec3(0.000,0.600,0.200),vec3(0.000,0.600,0.000),vec3(0.000,0.400,1.000),
    vec3(0.000,0.400,0.800),vec3(0.000,0.400,0.600),vec3(0.000,0.400,0.400),vec3(0.000,0.400,0.200),vec3(0.000,0.400,0.000),vec3(0.000,0.200,1.000),vec3(0.000,0.200,0.800),vec3(0.000,0.200,0.600),
    vec3(0.000,0.200,0.400),vec3(0.000,0.200,0.200),vec3(0.000,0.200,0.000),vec3(0.000,0.000,1.000),vec3(0.000,0.000,0.800),vec3(0.000,0.000,0.600),vec3(0.000,0.000,0.400),vec3(0.000,0.000,0.200),
    vec3(0.933,0.000,0.000),vec3(0.867,0.000,0.000),vec3(0.733,0.000,0.000),vec3(0.667,0.000,0.000),vec3(0.533,0.000,0.000),vec3(0.467,0.000,0.000),vec3(0.333,0.000,0.000),vec3(0.267,0.000,0.000),
    vec3(0.133,0.000,0.000),vec3(0.067,0.000,0.000),vec3(0.000,0.933,0.000),vec3(0.000,0.867,0.000),vec3(0.000,0.733,0.000),vec3(0.000,0.667,0.000),vec3(0.000,0.533,0.000),vec3(0.000,0.467,0.000),
    vec3(0.000,0.333,0.000),vec3(0.000,0.267,0.000),vec3(0.000,0.133,0.000),vec3(0.000,0.067,0.000),vec3(0.000,0.000,0.933),vec3(0.000,0.000,0.867),vec3(0.000,0.000,0.733),vec3(0.000,0.000,0.667),
    vec3(0.000,0.000,0.533),vec3(0.000,0.000,0.467),vec3(0.000,0.000,0.333),vec3(0.000,0.000,0.267),vec3(0.000,0.000,0.133),vec3(0.000,0.000,0.067),vec3(0.933,0.933,0.933),vec3(0.867,0.867,0.867),
    vec3(0.733,0.733,0.733),vec3(0.667,0.667,0.667),vec3(0.533,0.533,0.533),vec3(0.467,0.467,0.467),vec3(0.333,0.333,0.333),vec3(0.267,0.267,0.267),vec3(0.133,0.133,0.133),vec3(0.067,0.067,0.067)
);


// @.@
vec3 default_normals[6] = vec3[](
	vec3(0, 0, 1), vec3(0, 0, -1),
	vec3(1, 0, 0), vec3(-1, 0, 0),
	vec3(0, 1, 0), vec3(0, -1, 0)
);

void main()
{
    float occ = 1.0f - ao * 0.2f;
    gl_Position = P * V * M * vec4(position, 1.0f);
	vs_out.vert_color = default_palette[int(color_idx)] * occ;
	vs_out.normal     = default_normals[int(normal_idx)];
	
	vec3 frag = vec3(M * vec4(position, 1.0f)); 
	vs_out.frag_pos_lightspace = lightPV * vec4(frag, 1.0);
}