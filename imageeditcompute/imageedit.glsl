#[compute]
#version 450

//float computemax = GL_MAX_COMPUTE_WORK_GROUP_SIZE;

layout(local_size_x = 10, local_size_y = 10, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba32f) uniform image2D OUTPUT_TEXTURE;

void main() {
    ivec2 texel = ivec2(gl_GlobalInvocationID.xy);
    ivec2 dimensions = imageSize(OUTPUT_TEXTURE);
    vec2 fromCenter = vec2 (float(texel.x)-4.5, float(texel.y)-4.5);

    //vec4 color = vec4(float(texel.x)/dimensions.x,float(texel.y)/dimensions.y,0,1);
    vec4 color = vec4(fromCenter.y, fromCenter.x,0,1);
    imageStore(OUTPUT_TEXTURE, texel, color);
}