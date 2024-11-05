//
//  LYShaderTypes.h
//  LearnMetal
//
//  Created by loyinglin on 2018/6/21.
//  Copyright © 2018年 loyinglin. All rights reserved.
//

#ifndef LYShaderTypes_h
#define LYShaderTypes_h

#include <simd/simd.h>

typedef struct
{
    vector_float4 position;
    vector_float2 textureCoordinate;
} LYVertex;

typedef enum LYVertexInputIndex
{
    LYVertexInputIndexVertices     = 0,
} LYVertexInputIndex;


//typedef enum LYFragmentTextureIndex2
//{
//    LYFragmentTextureIndexTextureSource     = 0,
//    LYFragmentTextureIndexTextureDest       = 1,
//} LYFragmentTextureIndex2;

typedef enum LYFragmentBufferIndex
{
    LYFragmentInputIndexMatrix     = 0,
} LYFragmentBufferIndex;


typedef struct {
    matrix_float3x3 matrix;
    vector_float3 offset;
} LYConvertMatrix;

typedef enum LYFragmentTextureIndex
{
    LYFragmentTextureIndexGreenTextureY     = 0,
    LYFragmentTextureIndexGreenTextureUV     = 1,
    LYFragmentTextureIndexNormalTextureY     = 2,
    LYFragmentTextureIndexNormalTextureUV     = 3,
} LYFragmentTextureIndex;

typedef struct
{
    vector_float3 kRec709Luma; // position的修饰符表示这个是顶点
    
} TransParam;

#endif /* LYShaderTypes_h */
