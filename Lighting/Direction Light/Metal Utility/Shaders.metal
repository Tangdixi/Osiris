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
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]]) {
    VertexOut vertexOut;
    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertexIn.position;
    vertexOut.worldPosition = (uniforms.modelMatrix * vertexIn.position).xyz;
    vertexOut.worldNormal = uniforms.normalMatrix * vertexIn.normal;
    return vertexOut;
}

fragment float4 fragment_main(const VertexOut in [[stage_in]],
                              constant Light *lights [[buffer(2)]],
                              constant FragmentUniforms &fragmentUniforms [[buffer(3)]]) {
    float3 basicColor = float3(0, 0, 0.5);
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    float materialShininess = 16;
    float3 materialSpecularColor = float3(1, 1, 1);
    
    float3 normalDirection = normalize(in.worldNormal);
    for(uint i=0;i<fragmentUniforms.lightCount;i++){
        Light light = lights[i];
        if(light.lightType == SunLight) {
            float3 lightDirection = normalize(light.position);
            float diffuseIntensity = saturate(dot(lightDirection, normalDirection));
            diffuseColor += light.color * basicColor * diffuseIntensity;
            
            if(diffuseIntensity > 0) {
                
                // R
                float3 reflection = reflect(lightDirection, normalDirection);
                
                // V
                float3 cameraPosition = normalize(in.worldPosition - fragmentUniforms.cameraPosition);
                float specularIntensity = pow(saturate(dot(reflection, cameraPosition)), materialShininess);
                specularColor += light.specularColor * materialSpecularColor * specularIntensity;
            }
            
        } else if (light.lightType == AmbientLight) {
            ambientColor += light.color * light.intensity;
        }
    }
    
    float3 color = ambientColor + diffuseColor + specularColor;
    
    return float4(color, 1);
}
