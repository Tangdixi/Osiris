//
//  OsirisShaderBridge.h
//  Osiris
//
//  Created by DC on 2018/9/3.
//  Copyright © 2018 DC. All rights reserved.
//

#ifndef OsirisShaderBridge_h
#define OsirisShaderBridge_h

#import <simd/simd.h>

typedef matrix_float4x4 float4x4;
typedef matrix_float3x3 float3x3;
typedef vector_float2 float2;
typedef vector_float3 float3;
typedef vector_float4 float4;

typedef struct {
    float3 position;
    float2 uv;
} Vertexs;

typedef struct {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float3x3 normalMatrix;
} Uniforms;

typedef enum {
    BufferIndexVertex = 0,
    BufferIndexUniforms = 1,
} BufferIndices;

typedef enum {
    Position = 0,
    UV = 1
} Attributes;

typedef enum {
    BaseColorTexture = 0,
} Textures;

#endif /* OsirisShaderBridge_h */
