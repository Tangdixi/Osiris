//
//  Shaders.metal
//  Chapter 3
//
//  Created by DC on 2018/8/21.
//  Copyright © 2018 DC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#import "Common.h"

struct VertexIn {
    float4 position [[attribute(Position)]];
    float3 normal [[attribute(Normal)]];
    float2 uv [[attribute(UV)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
    float2 uv;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]]) {
    VertexOut vertexOut;
    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertexIn.position;
    vertexOut.worldPosition = (uniforms.modelMatrix * vertexIn.position).xyz;
    vertexOut.worldNormal = uniforms.normalMatrix * vertexIn.normal;
    vertexOut.uv = vertexIn.uv;
    return vertexOut;
}

fragment float4 fragment_main(const VertexOut in [[stage_in]],
                              constant Light *lights [[buffer(2)]],
                              constant FragmentUniforms &fragmentUniforms [[buffer(3)]],
                              texture2d<float> baseColorTexture [[texture(BaseColorTexture)]],
                              sampler textureSampler [[sampler(0)]]) {
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv * fragmentUniforms.tiling).rgb;
    
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    float materialShininess = 128;
    float3 materialSpecularColor = float3(1, 1, 1);
    
    float3 normalDirection = normalize(in.worldNormal);
    for(uint i=0;i<fragmentUniforms.lightCount;i++){
        Light light = lights[i];
        
        if(light.lightType == SunLight) {
            // All the lights is parallel
            float3 lightDirection = normalize(light.position);
            // The cos between the light direction and vertex normal, negtive when the angle is bigger than 90'
            float diffuseIntensity = saturate(dot(lightDirection, normalDirection));
            diffuseColor += light.color * baseColor * diffuseIntensity;
            
            // We only handle that primitive that face to the user
            if(diffuseIntensity > 0) {
                
                // R (point to the +z)
                float3 reflection = reflect(lightDirection, normalDirection);
                
                // V
                float3 cameraPosition = normalize(in.worldPosition - fragmentUniforms.cameraPosition);
                float specularIntensity = pow(saturate(dot(reflection, cameraPosition)), materialShininess);
                specularColor += light.specularColor * materialSpecularColor * specularIntensity;
            }
            
        } else if (light.lightType == AmbientLight) {
            ambientColor += light.color * light.intensity;
        } else if (light.lightType == PointLight) {
            float d = distance(light.position, in.worldPosition);
            float3 lightDirection = normalize(light.position - in.worldPosition);
            
            // Point light attenuation formular:
            float attenuation = 1.0/(light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
            float diffuseIntensity = saturate(dot(lightDirection, normalDirection));
            float3 color = light.color * baseColor * diffuseIntensity;
            
            color *= attenuation;
            diffuseColor += color;
        } else if (light.lightType == SpotLight) {
            float d = distance(light.position, in.worldPosition);
            
            // Light point to the vertex
            float3 lightDirection = normalize(light.position-in.worldPosition);
            
            // Inverse it for a correct direction
            float3 coneDirection = normalize(-light.coneDirection);
            float spotResult = dot(lightDirection, coneDirection);
            
            // Make sure the spot light inside the circle
            if (spotResult > cos(light.coneAngle)) {
                float attenuation = 1.0/(light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
                attenuation *= pow(spotResult, light.coneAttenuation);
                float diffuseIntensity = saturate(dot(lightDirection, normalDirection));
                
                float3 color = light.color * baseColor * diffuseIntensity;
                color *= attenuation;
                diffuseColor += color;
            }
        }
    }
    
    float3 color = ambientColor + diffuseColor + specularColor;
    
    return float4(color, 1);
}

