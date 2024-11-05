//
//  shaders.metal
//  LearnMetal
//
//  Created by loyinglin on 2018/6/21.
//  Copyright © 2018年 loyinglin. All rights reserved.
//
//
//  shaders.metal
//  LearnMetal
//
//  Created by loyinglin on 2018/6/21.
//  Copyright © 2018年 loyinglin. All rights reserved.
//

#include <metal_stdlib>
#import "LYShaderTypes.h"
#define CLAMPCOLOR(x) (uchar)((x)<(0)?(0):((x)>(255)?(255):(x)))
using namespace metal;

typedef struct
{
    float4 clipSpacePosition [[position]]; // position的修饰符表示这个是顶点
    
    float2 textureCoordinate; // 纹理坐标，会做插值处理
    
} RasterizerData;

vertex RasterizerData // 返回给片元着色器的结构体
vertexShader(uint vertexID [[ vertex_id ]], // vertex_id是顶点shader每次处理的index，用于定位当前的顶点
             constant LYVertex *vertexArray [[ buffer(0) ]]) { // buffer表明是缓存数据，0是索引
    RasterizerData out;
    out.clipSpacePosition = vertexArray[vertexID].position;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    return out;
}

//constant float3 greenMaskColor = float3(0.0, 1.0, 0.0); // 过滤掉绿色的

fragment float4
samplingShader(RasterizerData input [[stage_in]], // stage_in表示这个数据来自光栅化。（光栅化是顶点处理之后的步骤，业务层无法修改）
               texture2d<float> greenTextureY [[ texture(LYFragmentTextureIndexGreenTextureY) ]], // texture表明是纹理数据，LYFragmentTextureIndexGreenTextureY是索引
               texture2d<float> greenTextureUV [[ texture(LYFragmentTextureIndexGreenTextureUV) ]], // texture表明是纹理数据，LYFragmentTextureIndexGreenTextureUV是索引
               texture2d<float> normalTextureY [[ texture(LYFragmentTextureIndexNormalTextureY) ]], // texture表明是纹理数据，LYFragmentTextureIndexNormalTextureY是索引
               texture2d<float> normalTextureUV [[ texture(LYFragmentTextureIndexNormalTextureUV) ]], // texture表明是纹理数据，LYFragmentTextureIndexNormalTextureUV是索引
               constant LYConvertMatrix *convertMatrix [[ buffer(LYFragmentInputIndexMatrix) ]]) //buffer表明是缓存数据，LYFragmentInputIndexMatrix是索引
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器
    

   // float3 maskRGB = float3(greenMaskColor.r,  greenMaskColor.g, greenMaskColor.b) ;
    

//    float4 backVideoRGBA = float4(greenTextureY.sample(textureSampler, input.textureCoordinate).r,greenTextureY.sample(textureSampler, input.textureCoordinate).g,greenTextureY.sample(textureSampler, input.textureCoordinate).b,greenTextureY.sample(textureSampler, input.textureCoordinate).a);
    
//    float3 greenVideoRGB = float3(greenTextureUV.sample(textureSampler, input.textureCoordinate).r,greenTextureUV.sample(textureSampler, input.textureCoordinate).g,greenTextureUV.sample(textureSampler, input.textureCoordinate).b);



    // yuv转成rgb版
    float4 normalVideoRGBA = float4(normalTextureY.sample(textureSampler, input.textureCoordinate).rgba);
    
    float4 fgVideoRGBA = float4(normalTextureUV.sample(textureSampler, input.textureCoordinate).rgba);
    
    // 计算需要替换的值
//    float blendValue = smoothstep(0.1, 1, distance(maskRGB.yz, greenVideoRGB.yz));
    float alpha=normalVideoRGBA.b;
    float beta=1.0-alpha;
//
    float3 resultRGB=fgVideoRGBA.rgb*alpha;

    return float4(resultRGB.rgb, alpha);

 
//    if(normalVideoRGBA.a<0.3)
//    {
////////
////////        return float4(mix(backVideoRGBA.rgb, normalVideoRGBA.rgb, blendValue), 1.0);
//////        // 混合两个图像
////////        float blendValue = smoothstep(0.1, 0.15, distance(backVideoRGBA.yz, normalVideoRGBA.yz));
//////        return float4(backVideoRGBA.bgr, normalVideoRGBA.a);
//      return float4(0,0,0,0); // blendValue=0，表示接近绿色，取normalColor；
//    }else
//    {
// 
////         混合两个图像
////        float blendValue = smoothstep(0.1, 0.3, distance(fgVideoRGBA.yz, greenVideoRGB.yz));
////        return float4(mix(fgVideoRGBA.rgb, greenVideoRGB, blendValue), 1.0);
////        return float4(fgVideoRGBA.rgb,0); // blendValue=0，表示接近绿色，取normalColor；
////        float blendValue = smoothstep(0.1, 0.27, distance(backVideoRGBA.yz, fgVideoRGBA.yz));
//    return float4(resultRGB.rgb, 1.0);
////        return float4(resultRGB.rgb, beta);
//    }

}

fragment float4
samplingShader2(RasterizerData input [[stage_in]], // stage_in表示这个数据来自光栅化。（光栅化是顶点处理之后的步骤，业务层无法修改）
               texture2d<float> greenTextureY [[ texture(LYFragmentTextureIndexGreenTextureY) ]], // texture表明是纹理数据，LYFragmentTextureIndexGreenTextureY是索引
               texture2d<float> greenTextureUV [[ texture(LYFragmentTextureIndexGreenTextureUV) ]], // texture表明是纹理数据，LYFragmentTextureIndexGreenTextureUV是索引
               texture2d<float> normalTextureY [[ texture(LYFragmentTextureIndexNormalTextureY) ]], // texture表明是纹理数据，LYFragmentTextureIndexNormalTextureY是索引
               texture2d<float> normalTextureUV [[ texture(LYFragmentTextureIndexNormalTextureUV) ]], // texture表明是纹理数据，LYFragmentTextureIndexNormalTextureUV是索引
               constant LYConvertMatrix *convertMatrix [[ buffer(LYFragmentInputIndexMatrix) ]]) //buffer表明是缓存数据，LYFragmentInputIndexMatrix是索引
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器
    

   // float3 maskRGB = float3(greenMaskColor.r,  greenMaskColor.g, greenMaskColor.b) ;
    

    float4 backVideoRGBA = float4(greenTextureY.sample(textureSampler, input.textureCoordinate).r,greenTextureY.sample(textureSampler, input.textureCoordinate).g,greenTextureY.sample(textureSampler, input.textureCoordinate).b,greenTextureY.sample(textureSampler, input.textureCoordinate).a);
    
//    float3 greenVideoRGB = float3(greenTextureUV.sample(textureSampler, input.textureCoordinate).r,greenTextureUV.sample(textureSampler, input.textureCoordinate).g,greenTextureUV.sample(textureSampler, input.textureCoordinate).b);



    // yuv转成rgb版
    float4 normalVideoRGBA = float4(normalTextureY.sample(textureSampler, input.textureCoordinate).rgba);
    
    float4 fgVideoRGBA = float4(normalTextureUV.sample(textureSampler, input.textureCoordinate).rgba);
    
    // 计算需要替换的值
//    float blendValue = smoothstep(0.1, 1, distance(maskRGB.yz, greenVideoRGB.yz));
    float alpha=normalVideoRGBA.b;
    float beta=1.0-alpha;
//
    float3 resultRGB=fgVideoRGBA.rgb*alpha+backVideoRGBA.rgb*(beta);

    return float4(resultRGB.rgb, beta);

 
//    if(normalVideoRGBA.a<0.3)
//    {
////////
////////        return float4(mix(backVideoRGBA.rgb, normalVideoRGBA.rgb, blendValue), 1.0);
//////        // 混合两个图像
////////        float blendValue = smoothstep(0.1, 0.15, distance(backVideoRGBA.yz, normalVideoRGBA.yz));
//////        return float4(backVideoRGBA.bgr, normalVideoRGBA.a);
//      return float4(0,0,0,0); // blendValue=0，表示接近绿色，取normalColor；
//    }else
//    {
//
////         混合两个图像
////        float blendValue = smoothstep(0.1, 0.3, distance(fgVideoRGBA.yz, greenVideoRGB.yz));
////        return float4(mix(fgVideoRGBA.rgb, greenVideoRGB, blendValue), 1.0);
////        return float4(fgVideoRGBA.rgb,0); // blendValue=0，表示接近绿色，取normalColor；
////        float blendValue = smoothstep(0.1, 0.27, distance(backVideoRGBA.yz, fgVideoRGBA.yz));
//    return float4(resultRGB.rgb, 1.0);
////        return float4(resultRGB.rgb, beta);
//    }

}
fragment float4
samplingShader3(RasterizerData input [[stage_in]], // stage_in表示这个数据来自光栅化。（光栅化是顶点处理之后的步骤，业务层无法修改）
               texture2d<float> greenTextureY [[ texture(LYFragmentTextureIndexGreenTextureY) ]], // texture表明是纹理数据，LYFragmentTextureIndexGreenTextureY是索引
               texture2d<float> greenTextureUV [[ texture(LYFragmentTextureIndexGreenTextureUV) ]], // texture表明是纹理数据，LYFragmentTextureIndexGreenTextureUV是索引
               texture2d<float> normalTextureY [[ texture(LYFragmentTextureIndexNormalTextureY) ]], // texture表明是纹理数据，LYFragmentTextureIndexNormalTextureY是索引
               texture2d<float> normalTextureUV [[ texture(LYFragmentTextureIndexNormalTextureUV) ]], // texture表明是纹理数据，LYFragmentTextureIndexNormalTextureUV是索引
               constant LYConvertMatrix *convertMatrix [[ buffer(LYFragmentInputIndexMatrix) ]]) //buffer表明是缓存数据，LYFragmentInputIndexMatrix是索引
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器
    

   // float3 maskRGB = float3(greenMaskColor.r,  greenMaskColor.g, greenMaskColor.b) ;
    

//    float4 backVideoRGBA = float4(greenTextureY.sample(textureSampler, input.textureCoordinate).r,greenTextureY.sample(textureSampler, input.textureCoordinate).g,greenTextureY.sample(textureSampler, input.textureCoordinate).b,greenTextureY.sample(textureSampler, input.textureCoordinate).a);
    
//    float3 greenVideoRGB = float3(greenTextureUV.sample(textureSampler, input.textureCoordinate).r,greenTextureUV.sample(textureSampler, input.textureCoordinate).g,greenTextureUV.sample(textureSampler, input.textureCoordinate).b);



    // yuv转成rgb版
//    float4 normalVideoRGBA = float4(normalTextureY.sample(textureSampler, input.textureCoordinate).rgba);
    
    float4 fgVideoRGBA = float4(normalTextureUV.sample(textureSampler, input.textureCoordinate).rgba);
    
    // 计算需要替换的值
//    float blendValue = smoothstep(0.1, 1, distance(maskRGB.yz, greenVideoRGB.yz));
//    float alpha=1-fgVideoRGBA.b;
//    float beta=1.0-alpha;
//
    float3 resultRGB=fgVideoRGBA.rgb;

    return float4(resultRGB.rgb, 1.0);

 
//    if(normalVideoRGBA.a<0.3)
//    {
////////
////////        return float4(mix(backVideoRGBA.rgb, normalVideoRGBA.rgb, blendValue), 1.0);
//////        // 混合两个图像
////////        float blendValue = smoothstep(0.1, 0.15, distance(backVideoRGBA.yz, normalVideoRGBA.yz));
//////        return float4(backVideoRGBA.bgr, normalVideoRGBA.a);
//      return float4(0,0,0,0); // blendValue=0，表示接近绿色，取normalColor；
//    }else
//    {
//
////         混合两个图像
////        float blendValue = smoothstep(0.1, 0.3, distance(fgVideoRGBA.yz, greenVideoRGB.yz));
////        return float4(mix(fgVideoRGBA.rgb, greenVideoRGB, blendValue), 1.0);
////        return float4(fgVideoRGBA.rgb,0); // blendValue=0，表示接近绿色，取normalColor；
////        float blendValue = smoothstep(0.1, 0.27, distance(backVideoRGBA.yz, fgVideoRGBA.yz));
//    return float4(resultRGB.rgb, 1.0);
////        return float4(resultRGB.rgb, beta);
//    }

}
