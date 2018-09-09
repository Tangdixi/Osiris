//
//  Osiris_Bridging.h
//  Osiris
//
//  Created by 汤迪希 on 2018/9/10.
//  Copyright © 2018 DC. All rights reserved.
//

#ifndef Osiris_Bridging_h
#define Osiris_Bridging_h

#import <simd/simd.h>

typedef matrix_float4x4 float4x4;
typedef matrix_float3x3 float3x3;
typedef vector_float2 float2;
typedef vector_float3 float3;
typedef vector_float4 float4;

typedef struct {
    float4 position;
    float2 uv;
} Vertex;

typedef struct {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float3x3 normalMatrix;
} Uniform;

typedef enum {
    BufferIndexVertex = 0,
    BufferIndexUniforms = 1,
} BufferIndices;

typedef enum {
    Position = 0,
    UV = 1
} AttributeIndices;

typedef enum {
    TextureIndexSource = 0,
    TextureIndexDestination = 1
} TextureIndice;

typedef enum {
    SamplerIndexTexture = 0
} SamplerIndices;

#endif /* Osiris_Bridging_h */
