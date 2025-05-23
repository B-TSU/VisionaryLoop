#version 430
//#include <required.glsl> // [HACK 4/6/2023] See SCC shader_merger.cpp
//SG_REFLECTION_BEGIN(200)
//attribute vec4 boneData 5
//attribute vec3 blendShape0Pos 6
//attribute vec3 blendShape0Normal 12
//attribute vec3 blendShape1Pos 7
//attribute vec3 blendShape1Normal 13
//attribute vec3 blendShape2Pos 8
//attribute vec3 blendShape2Normal 14
//attribute vec3 blendShape3Pos 9
//attribute vec3 blendShape4Pos 10
//attribute vec3 blendShape5Pos 11
//attribute vec4 position 0
//attribute vec3 normal 1
//attribute vec4 tangent 2
//attribute vec2 texture0 3
//attribute vec2 texture1 4
//attribute vec4 color 18
//attribute vec3 positionNext 15
//attribute vec3 positionPrevious 16
//attribute vec4 strandProperties 17
//sampler sampler additional_settings_btn_refl_texSmpSC 0:22
//sampler sampler iconSmpSC 0:23
//sampler sampler intensityTextureSmpSC 0:24
//sampler sampler sc_OITCommonSampler 0:27
//sampler sampler sc_ScreenTextureSmpSC 0:29
//sampler sampler z_hitIdAndBarycentricSmp 0:32
//sampler sampler z_rayDirectionsSmpSC 0:33
//texture texture2D additional_settings_btn_refl_tex 0:3:0:22
//texture texture2D icon 0:4:0:23
//texture texture2D intensityTexture 0:5:0:24
//texture texture2D sc_OITAlpha0 0:8:0:27
//texture texture2D sc_OITAlpha1 0:9:0:27
//texture texture2D sc_OITDepthHigh0 0:10:0:27
//texture texture2D sc_OITDepthHigh1 0:11:0:27
//texture texture2D sc_OITDepthLow0 0:12:0:27
//texture texture2D sc_OITDepthLow1 0:13:0:27
//texture texture2D sc_OITFilteredDepthBoundsTexture 0:14:0:27
//texture texture2D sc_OITFrontDepthTexture 0:15:0:27
//texture texture2D sc_ScreenTexture 0:17:0:29
//texture utexture2D z_hitIdAndBarycentric 0:20:0:32
//texture texture2D z_rayDirections 0:21:0:33
//texture texture2DArray additional_settings_btn_refl_texArrSC 0:34:0:22
//texture texture2DArray iconArrSC 0:35:0:23
//texture texture2DArray intensityTextureArrSC 0:36:0:24
//texture texture2DArray sc_ScreenTextureArrSC 0:39:0:29
//ssbo int layoutIndices 0:0:4 {
//uint _Triangles 0:[]:4
//}
//ssbo float layoutVertices 0:1:4 {
//float _Vertices 0:[]:4
//}
//ssbo float layoutVerticesPN 0:2:4 {
//float _VerticesPN 0:[]:4
//}
//SG_REFLECTION_END
#if defined VERTEX_SHADER
#if 0
NGS_BACKEND_SHADER_FLAGS_BEGIN__
NGS_BACKEND_SHADER_FLAGS_END__
#endif
#ifdef iconEnabled
#undef iconEnabled
#endif
#define sc_StereoRendering_Disabled 0
#define sc_StereoRendering_InstancedClipped 1
#define sc_StereoRendering_Multiview 2
#ifdef GL_ES
    #define SC_GLES_VERSION_20 2000
    #define SC_GLES_VERSION_30 3000
    #define SC_GLES_VERSION_31 3100
    #define SC_GLES_VERSION_32 3200
#endif
#ifdef VERTEX_SHADER
    #define scOutPos(clipPosition) gl_Position=clipPosition
    #define MAIN main
#endif
#ifdef SC_ENABLE_INSTANCED_RENDERING
    #ifndef sc_EnableInstancing
        #define sc_EnableInstancing 1
    #endif
#endif
#define mod(x,y) (x-y*floor((x+1e-6)/y))
#if defined(GL_ES)&&(__VERSION__<300)&&!defined(GL_OES_standard_derivatives)
#define dFdx(A) (A)
#define dFdy(A) (A)
#define fwidth(A) (A)
#endif
#if __VERSION__<300
#define isinf(x) (x!=0.0&&x*2.0==x ? true : false)
#define isnan(x) (x>0.0||x<0.0||x==0.0 ? false : true)
#define inverse(M) M
#endif
#ifdef sc_EnableFeatureLevelES3
    #ifdef sc_EnableStereoClipDistance
        #if defined(GL_APPLE_clip_distance)
            #extension GL_APPLE_clip_distance : require
        #elif defined(GL_EXT_clip_cull_distance)
            #extension GL_EXT_clip_cull_distance : require
        #else
            #error Clip distance is requested but not supported by this device.
        #endif
    #endif
#else
    #ifdef sc_EnableStereoClipDistance
        #error Clip distance is requested but not supported by this device.
    #endif
#endif
#ifdef sc_EnableFeatureLevelES3
    #ifdef VERTEX_SHADER
        #define attribute in
        #define varying out
    #endif
    #ifdef FRAGMENT_SHADER
        #define varying in
    #endif
    #define gl_FragColor sc_FragData0
    #define texture2D texture
    #define texture2DLod textureLod
    #define texture2DLodEXT textureLod
    #define textureCubeLodEXT textureLod
    #define sc_CanUseTextureLod 1
#else
    #ifdef FRAGMENT_SHADER
        #if defined(GL_EXT_shader_texture_lod)
            #extension GL_EXT_shader_texture_lod : require
            #define sc_CanUseTextureLod 1
            #define texture2DLod texture2DLodEXT
        #endif
    #endif
#endif
#if defined(sc_EnableMultiviewStereoRendering)
    #define sc_StereoRenderingMode sc_StereoRendering_Multiview
    #define sc_NumStereoViews 2
    #extension GL_OVR_multiview2 : require
    #ifdef VERTEX_SHADER
        #ifdef sc_EnableInstancingFallback
            #define sc_GlobalInstanceID (sc_FallbackInstanceID*2+gl_InstanceID)
        #else
            #define sc_GlobalInstanceID gl_InstanceID
        #endif
        #define sc_LocalInstanceID sc_GlobalInstanceID
        #define sc_StereoViewID int(gl_ViewID_OVR)
    #endif
#elif defined(sc_EnableInstancedClippedStereoRendering)
    #ifndef sc_EnableInstancing
        #error Instanced-clipped stereo rendering requires enabled instancing.
    #endif
    #ifndef sc_EnableStereoClipDistance
        #define sc_StereoRendering_IsClipDistanceEnabled 0
    #else
        #define sc_StereoRendering_IsClipDistanceEnabled 1
    #endif
    #define sc_StereoRenderingMode sc_StereoRendering_InstancedClipped
    #define sc_NumStereoClipPlanes 1
    #define sc_NumStereoViews 2
    #ifdef VERTEX_SHADER
        #ifdef sc_EnableInstancingFallback
            #define sc_GlobalInstanceID (sc_FallbackInstanceID*2+gl_InstanceID)
        #else
            #define sc_GlobalInstanceID gl_InstanceID
        #endif
        #ifdef sc_EnableFeatureLevelES3
            #define sc_LocalInstanceID (sc_GlobalInstanceID/2)
            #define sc_StereoViewID (sc_GlobalInstanceID%2)
        #else
            #define sc_LocalInstanceID int(sc_GlobalInstanceID/2.0)
            #define sc_StereoViewID int(mod(sc_GlobalInstanceID,2.0))
        #endif
    #endif
#else
    #define sc_StereoRenderingMode sc_StereoRendering_Disabled
#endif
#ifdef VERTEX_SHADER
    #ifdef sc_EnableInstancing
        #ifdef GL_ES
            #if defined(sc_EnableFeatureLevelES2)&&!defined(GL_EXT_draw_instanced)
                #define gl_InstanceID (0)
            #endif
        #else
            #if defined(sc_EnableFeatureLevelES2)&&!defined(GL_EXT_draw_instanced)&&!defined(GL_ARB_draw_instanced)&&!defined(GL_EXT_gpu_shader4)
                #define gl_InstanceID (0)
            #endif
        #endif
        #ifdef GL_ARB_draw_instanced
            #extension GL_ARB_draw_instanced : require
            #define gl_InstanceID gl_InstanceIDARB
        #endif
        #ifdef GL_EXT_draw_instanced
            #extension GL_EXT_draw_instanced : require
            #define gl_InstanceID gl_InstanceIDEXT
        #endif
        #ifndef sc_InstanceID
            #define sc_InstanceID gl_InstanceID
        #endif
        #ifndef sc_GlobalInstanceID
            #ifdef sc_EnableInstancingFallback
                #define sc_GlobalInstanceID (sc_FallbackInstanceID)
                #define sc_LocalInstanceID (sc_FallbackInstanceID)
            #else
                #define sc_GlobalInstanceID gl_InstanceID
                #define sc_LocalInstanceID gl_InstanceID
            #endif
        #endif
    #endif
#endif
#ifdef VERTEX_SHADER
    #if (__VERSION__<300)&&!defined(GL_EXT_gpu_shader4)
        #define gl_VertexID (0)
    #endif
#endif
#ifndef GL_ES
        #extension GL_EXT_gpu_shader4 : enable
    #extension GL_ARB_shader_texture_lod : enable
    #ifndef texture2DLodEXT
        #define texture2DLodEXT texture2DLod
    #endif
    #ifndef sc_CanUseTextureLod
    #define sc_CanUseTextureLod 1
    #endif
    #define precision
    #define lowp
    #define mediump
    #define highp
    #define sc_FragmentPrecision
#endif
#ifdef sc_EnableFeatureLevelES3
    #define sc_CanUseSampler2DArray 1
#endif
#if defined(sc_EnableFeatureLevelES2)&&defined(GL_ES)
    #ifdef FRAGMENT_SHADER
        #ifdef GL_OES_standard_derivatives
            #extension GL_OES_standard_derivatives : require
            #define sc_CanUseStandardDerivatives 1
        #endif
    #endif
    #ifdef GL_EXT_texture_array
        #extension GL_EXT_texture_array : require
        #define sc_CanUseSampler2DArray 1
    #else
        #define sc_CanUseSampler2DArray 0
    #endif
#endif
#ifdef GL_ES
    #ifdef sc_FramebufferFetch
        #if defined(GL_EXT_shader_framebuffer_fetch)
            #extension GL_EXT_shader_framebuffer_fetch : require
        #elif defined(GL_ARM_shader_framebuffer_fetch)
            #extension GL_ARM_shader_framebuffer_fetch : require
        #else
            #error Framebuffer fetch is requested but not supported by this device.
        #endif
    #endif
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        #define sc_FragmentPrecision highp
    #else
        #define sc_FragmentPrecision mediump
    #endif
    #ifdef FRAGMENT_SHADER
        precision highp int;
        precision highp float;
    #endif
#endif
#ifdef VERTEX_SHADER
    #ifdef sc_EnableMultiviewStereoRendering
        layout(num_views=sc_NumStereoViews) in;
    #endif
#endif
#if __VERSION__>100
    #define SC_INT_FALLBACK_FLOAT int
    #define SC_INTERPOLATION_FLAT flat
    #define SC_INTERPOLATION_CENTROID centroid
#else
    #define SC_INT_FALLBACK_FLOAT float
    #define SC_INTERPOLATION_FLAT
    #define SC_INTERPOLATION_CENTROID
#endif
#ifndef sc_NumStereoViews
    #define sc_NumStereoViews 1
#endif
#ifndef sc_CanUseSampler2DArray
    #define sc_CanUseSampler2DArray 0
#endif
    #if __VERSION__==100||defined(SCC_VALIDATION)
        #define sampler2DArray vec2
        #define sampler3D vec3
        #define samplerCube vec4
        vec4 texture3D(vec3 s,vec3 uv)                       { return vec4(0.0); }
        vec4 texture3D(vec3 s,vec3 uv,float bias)           { return vec4(0.0); }
        vec4 texture3DLod(vec3 s,vec3 uv,float bias)        { return vec4(0.0); }
        vec4 texture3DLodEXT(vec3 s,vec3 uv,float lod)      { return vec4(0.0); }
        vec4 texture2DArray(vec2 s,vec3 uv)                  { return vec4(0.0); }
        vec4 texture2DArray(vec2 s,vec3 uv,float bias)      { return vec4(0.0); }
        vec4 texture2DArrayLod(vec2 s,vec3 uv,float lod)    { return vec4(0.0); }
        vec4 texture2DArrayLodEXT(vec2 s,vec3 uv,float lod) { return vec4(0.0); }
        vec4 textureCube(vec4 s,vec3 uv)                     { return vec4(0.0); }
        vec4 textureCube(vec4 s,vec3 uv,float lod)          { return vec4(0.0); }
        vec4 textureCubeLod(vec4 s,vec3 uv,float lod)       { return vec4(0.0); }
        vec4 textureCubeLodEXT(vec4 s,vec3 uv,float lod)    { return vec4(0.0); }
        #if defined(VERTEX_SHADER)||!sc_CanUseTextureLod
            #define texture2DLod(s,uv,lod)      vec4(0.0)
            #define texture2DLodEXT(s,uv,lod)   vec4(0.0)
        #endif
    #elif __VERSION__>=300
        #define texture3D texture
        #define textureCube texture
        #define texture2DArray texture
        #define texture2DLod textureLod
        #define texture3DLod textureLod
        #define texture2DLodEXT textureLod
        #define texture3DLodEXT textureLod
        #define textureCubeLod textureLod
        #define textureCubeLodEXT textureLod
        #define texture2DArrayLod textureLod
        #define texture2DArrayLodEXT textureLod
    #endif
    #ifndef sc_TextureRenderingLayout_Regular
        #define sc_TextureRenderingLayout_Regular 0
        #define sc_TextureRenderingLayout_StereoInstancedClipped 1
        #define sc_TextureRenderingLayout_StereoMultiview 2
    #endif
    #define depthToGlobal   depthScreenToViewSpace
    #define depthToLocal    depthViewToScreenSpace
    #ifndef quantizeUV
        #define quantizeUV sc_QuantizeUV
        #define sc_platformUVFlip sc_PlatformFlipV
        #define sc_PlatformFlipUV sc_PlatformFlipV
    #endif
    #ifndef sc_texture2DLod
        #define sc_texture2DLod sc_InternalTextureLevel
        #define sc_textureLod sc_InternalTextureLevel
        #define sc_textureBias sc_InternalTextureBiasOrLevel
        #define sc_texture sc_InternalTexture
    #endif
#ifdef uv2
#undef uv2
#endif
#ifdef uv3
#undef uv3
#endif
struct sc_Vertex_t
{
vec4 position;
vec3 normal;
vec3 tangent;
vec2 texture0;
vec2 texture1;
};
#ifndef sc_StereoRenderingMode
#define sc_StereoRenderingMode 0
#endif
#ifndef sc_StereoViewID
#define sc_StereoViewID 0
#endif
#ifndef sc_RenderingSpace
#define sc_RenderingSpace -1
#endif
#ifndef sc_StereoRendering_IsClipDistanceEnabled
#define sc_StereoRendering_IsClipDistanceEnabled 0
#endif
#ifndef sc_NumStereoViews
#define sc_NumStereoViews 1
#endif
#ifndef sc_ShaderCacheConstant
#define sc_ShaderCacheConstant 0
#endif
#ifndef sc_SkinBonesCount
#define sc_SkinBonesCount 0
#endif
#ifndef sc_VertexBlending
#define sc_VertexBlending 0
#elif sc_VertexBlending==1
#undef sc_VertexBlending
#define sc_VertexBlending 1
#endif
#ifndef sc_VertexBlendingUseNormals
#define sc_VertexBlendingUseNormals 0
#elif sc_VertexBlendingUseNormals==1
#undef sc_VertexBlendingUseNormals
#define sc_VertexBlendingUseNormals 1
#endif
struct sc_Camera_t
{
vec3 position;
float aspect;
vec2 clipPlanes;
};
#ifndef sc_IsEditor
#define sc_IsEditor 0
#elif sc_IsEditor==1
#undef sc_IsEditor
#define sc_IsEditor 1
#endif
#ifndef SC_DISABLE_FRUSTUM_CULLING
#define SC_DISABLE_FRUSTUM_CULLING 0
#elif SC_DISABLE_FRUSTUM_CULLING==1
#undef SC_DISABLE_FRUSTUM_CULLING
#define SC_DISABLE_FRUSTUM_CULLING 1
#endif
#ifndef sc_DepthBufferMode
#define sc_DepthBufferMode 0
#endif
#ifndef sc_ProjectiveShadowsReceiver
#define sc_ProjectiveShadowsReceiver 0
#elif sc_ProjectiveShadowsReceiver==1
#undef sc_ProjectiveShadowsReceiver
#define sc_ProjectiveShadowsReceiver 1
#endif
#ifndef sc_OITDepthGatherPass
#define sc_OITDepthGatherPass 0
#elif sc_OITDepthGatherPass==1
#undef sc_OITDepthGatherPass
#define sc_OITDepthGatherPass 1
#endif
#ifndef sc_OITCompositingPass
#define sc_OITCompositingPass 0
#elif sc_OITCompositingPass==1
#undef sc_OITCompositingPass
#define sc_OITCompositingPass 1
#endif
#ifndef sc_OITDepthBoundsPass
#define sc_OITDepthBoundsPass 0
#elif sc_OITDepthBoundsPass==1
#undef sc_OITDepthBoundsPass
#define sc_OITDepthBoundsPass 1
#endif
#ifndef UseViewSpaceDepthVariant
#define UseViewSpaceDepthVariant 1
#elif UseViewSpaceDepthVariant==1
#undef UseViewSpaceDepthVariant
#define UseViewSpaceDepthVariant 1
#endif
#ifndef sc_PointLightsCount
#define sc_PointLightsCount 0
#endif
#ifndef sc_DirectionalLightsCount
#define sc_DirectionalLightsCount 0
#endif
#ifndef sc_AmbientLightsCount
#define sc_AmbientLightsCount 0
#endif
struct sc_PointLight_t
{
bool falloffEnabled;
float falloffEndDistance;
float negRcpFalloffEndDistance4;
float angleScale;
float angleOffset;
vec3 direction;
vec3 position;
vec4 color;
};
struct sc_DirectionalLight_t
{
vec3 direction;
vec4 color;
};
struct sc_AmbientLight_t
{
vec3 color;
float intensity;
};
struct sc_SphericalGaussianLight_t
{
vec3 color;
float sharpness;
vec3 axis;
};
struct sc_LightEstimationData_t
{
sc_SphericalGaussianLight_t sg[12];
vec3 ambientLight;
};
layout(binding=0,std430) readonly buffer layoutIndices
{
uint _Triangles[];
} layoutIndices_obj;
layout(binding=1,std430) readonly buffer layoutVertices
{
float _Vertices[];
} layoutVertices_obj;
layout(binding=2,std430) readonly buffer layoutVerticesPN
{
float _VerticesPN[];
} layoutVerticesPN_obj;
uniform vec4 sc_EnvmapDiffuseDims;
uniform vec4 sc_EnvmapSpecularDims;
uniform vec4 sc_ScreenTextureDims;
uniform bool isProxyMode;
uniform bool noEarlyZ;
uniform vec4 z_rayDirectionsDims;
uniform mat4 sc_ModelMatrix;
uniform mat4 sc_ProjectorMatrix;
uniform vec4 sc_StereoClipPlanes[sc_NumStereoViews];
uniform vec4 sc_UniformConstants;
uniform vec4 sc_BoneMatrices[(sc_SkinBonesCount*3)+1];
uniform mat3 sc_SkinBonesNormalMatrices[sc_SkinBonesCount+1];
uniform vec4 weights0;
uniform vec4 weights1;
uniform mat4 sc_ViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewMatrixArray[sc_NumStereoViews];
uniform sc_Camera_t sc_Camera;
uniform mat4 sc_ProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ViewMatrixArray[sc_NumStereoViews];
uniform float sc_DisableFrustumCullingMarker;
uniform mat4 sc_ProjectionMatrixArray[sc_NumStereoViews];
uniform mat3 sc_NormalMatrix;
uniform vec2 sc_TAAJitterOffset;
uniform vec4 intensityTextureDims;
uniform int PreviewEnabled;
uniform vec4 additional_settings_btn_refl_texDims;
uniform vec4 iconDims;
uniform float depthRef;
uniform int overrideTimeEnabled;
uniform float overrideTimeElapsed;
uniform vec4 sc_Time;
uniform float overrideTimeDelta;
uniform sc_PointLight_t sc_PointLights[sc_PointLightsCount+1];
uniform sc_DirectionalLight_t sc_DirectionalLights[sc_DirectionalLightsCount+1];
uniform sc_AmbientLight_t sc_AmbientLights[sc_AmbientLightsCount+1];
uniform sc_LightEstimationData_t sc_LightEstimationData;
uniform vec4 sc_EnvmapDiffuseSize;
uniform vec4 sc_EnvmapDiffuseView;
uniform vec4 sc_EnvmapSpecularSize;
uniform vec4 sc_EnvmapSpecularView;
uniform vec3 sc_EnvmapRotation;
uniform float sc_EnvmapExposure;
uniform vec3 sc_Sh[9];
uniform float sc_ShIntensity;
uniform vec4 sc_GeometryInfo;
uniform mat4 sc_ModelViewProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ViewProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewMatrixInverseArray[sc_NumStereoViews];
uniform mat3 sc_ViewNormalMatrixArray[sc_NumStereoViews];
uniform mat3 sc_ViewNormalMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ViewMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_PrevFrameViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_ModelMatrixInverse;
uniform mat3 sc_NormalMatrixInverse;
uniform mat4 sc_PrevFrameModelMatrix;
uniform mat4 sc_PrevFrameModelMatrixInverse;
uniform vec3 sc_LocalAabbMin;
uniform vec3 sc_LocalAabbMax;
uniform vec3 sc_WorldAabbMin;
uniform vec3 sc_WorldAabbMax;
uniform vec4 sc_WindowToViewportTransform;
uniform vec4 sc_CurrentRenderTargetDims;
uniform float sc_ShadowDensity;
uniform vec4 sc_ShadowColor;
uniform float _sc_GetFramebufferColorInvalidUsageMarker;
uniform float shaderComplexityValue;
uniform vec4 weights2;
uniform int sc_FallbackInstanceID;
uniform float _sc_framebufferFetchMarker;
uniform float strandWidth;
uniform float strandTaper;
uniform vec4 sc_StrandDataMapTextureSize;
uniform float clumpInstanceCount;
uniform float clumpRadius;
uniform float clumpTipScale;
uniform float hairstyleInstanceCount;
uniform float hairstyleNoise;
uniform vec4 sc_ScreenTextureSize;
uniform vec4 sc_ScreenTextureView;
uniform int instance_id;
uniform int lray_triangles_last;
uniform bool has_animated_pn;
uniform int emitter_stride;
uniform int proxy_offset_position;
uniform int proxy_offset_normal;
uniform int proxy_offset_tangent;
uniform int proxy_offset_color;
uniform int proxy_offset_texture0;
uniform int proxy_offset_texture1;
uniform int proxy_offset_texture2;
uniform int proxy_offset_texture3;
uniform int proxy_format_position;
uniform int proxy_format_normal;
uniform int proxy_format_tangent;
uniform int proxy_format_color;
uniform int proxy_format_texture0;
uniform int proxy_format_texture1;
uniform int proxy_format_texture2;
uniform int proxy_format_texture3;
uniform vec4 z_rayDirectionsSize;
uniform vec4 z_rayDirectionsView;
uniform float correctedIntensity;
uniform vec4 intensityTextureSize;
uniform vec4 intensityTextureView;
uniform mat3 intensityTextureTransform;
uniform vec4 intensityTextureUvMinMax;
uniform vec4 intensityTextureBorderColor;
uniform float reflBlurWidth;
uniform float reflBlurMinRough;
uniform float reflBlurMaxRough;
uniform int PreviewNodeID;
uniform float alphaTestThreshold;
uniform vec4 additional_settings_btn_refl_texSize;
uniform vec4 additional_settings_btn_refl_texView;
uniform mat3 additional_settings_btn_refl_texTransform;
uniform vec4 additional_settings_btn_refl_texUvMinMax;
uniform vec4 additional_settings_btn_refl_texBorderColor;
uniform vec4 iconSize;
uniform vec4 iconView;
uniform mat3 iconTransform;
uniform vec4 iconUvMinMax;
uniform vec4 iconBorderColor;
uniform bool iconEnabled;
uniform float Port_Import_N006;
uniform vec3 Port_Import_N049;
uniform float Port_Input1_N053;
uniform float Port_Input2_N053;
uniform float Port_Import_N062;
uniform vec3 Port_Import_N068;
uniform float Port_Input1_N073;
uniform float Port_Input2_N073;
uniform float Port_Input2_N005;
uniform vec2 Port_Input1_N009;
uniform vec2 Port_Input2_N009;
uniform vec4 Port_Value0_N003;
uniform float Port_Position1_N003;
uniform vec4 Port_Value1_N003;
uniform float Port_Position2_N003;
uniform vec4 Port_Value2_N003;
uniform float Port_Position3_N003;
uniform vec4 Port_Value3_N003;
uniform vec4 Port_Value4_N003;
uniform vec2 Port_Scale_N002;
uniform vec2 Port_Center_N002;
uniform float Port_Input2_N007;
out float varClipDistance;
flat out int varStereoViewID;
in vec4 boneData;
in vec3 blendShape0Pos;
in vec3 blendShape0Normal;
in vec3 blendShape1Pos;
in vec3 blendShape1Normal;
in vec3 blendShape2Pos;
in vec3 blendShape2Normal;
in vec3 blendShape3Pos;
in vec3 blendShape4Pos;
in vec3 blendShape5Pos;
in vec4 position;
in vec3 normal;
in vec4 tangent;
in vec2 texture0;
in vec2 texture1;
out vec3 varPos;
out vec3 varNormal;
out vec4 varTangent;
out vec4 varPackedTex;
out vec4 varScreenPos;
out vec2 varScreenTexturePos;
out vec2 varShadowTex;
out float varViewSpaceDepth;
out vec4 varColor;
in vec4 color;
out vec4 PreviewVertexColor;
out float PreviewVertexSaved;
in vec3 positionNext;
in vec3 positionPrevious;
in vec4 strandProperties;
void sc_SetClipDistancePlatform(float dstClipDistance)
{
    #if sc_StereoRenderingMode==sc_StereoRendering_InstancedClipped&&sc_StereoRendering_IsClipDistanceEnabled
        gl_ClipDistance[0]=dstClipDistance;
    #endif
}
void sc_SetClipDistance(float dstClipDistance)
{
#if (sc_StereoRendering_IsClipDistanceEnabled==1)
{
sc_SetClipDistancePlatform(dstClipDistance);
}
#else
{
varClipDistance=dstClipDistance;
}
#endif
}
void sc_SetClipDistance(vec4 clipPosition)
{
#if (sc_StereoRenderingMode==1)
{
sc_SetClipDistance(dot(clipPosition,sc_StereoClipPlanes[sc_StereoViewID]));
}
#endif
}
void sc_SetClipPosition(vec4 clipPosition)
{
#if (sc_ShaderCacheConstant!=0)
{
clipPosition.x+=(sc_UniformConstants.x*float(sc_ShaderCacheConstant));
}
#endif
#if (sc_StereoRenderingMode>0)
{
varStereoViewID=sc_StereoViewID;
}
#endif
sc_SetClipDistance(clipPosition);
gl_Position=clipPosition;
}
void blendTargetShapeWithNormal(inout sc_Vertex_t v,vec3 position_1,vec3 normal_1,float weight)
{
vec3 l9_0=v.position.xyz+(position_1*weight);
v=sc_Vertex_t(vec4(l9_0.x,l9_0.y,l9_0.z,v.position.w),v.normal,v.tangent,v.texture0,v.texture1);
v.normal+=(normal_1*weight);
}
void sc_GetBoneMatrix(int index,out vec4 m0,out vec4 m1,out vec4 m2)
{
int l9_0=3*index;
m0=sc_BoneMatrices[l9_0];
m1=sc_BoneMatrices[l9_0+1];
m2=sc_BoneMatrices[l9_0+2];
}
vec3 skinVertexPosition(int i,vec4 v)
{
vec3 l9_0;
#if (sc_SkinBonesCount>0)
{
vec4 param_1;
vec4 param_2;
vec4 param_3;
sc_GetBoneMatrix(i,param_1,param_2,param_3);
l9_0=vec3(dot(v,param_1),dot(v,param_2),dot(v,param_3));
}
#else
{
l9_0=v.xyz;
}
#endif
return l9_0;
}
int sc_GetStereoViewIndex()
{
int l9_0;
#if (sc_StereoRenderingMode==0)
{
l9_0=0;
}
#else
{
l9_0=sc_StereoViewID;
}
#endif
return l9_0;
}
void main()
{
if (isProxyMode)
{
sc_SetClipPosition(vec4(position.xy,depthRef+(1e-10*position.z),1.0+(1e-10*position.w)));
return;
}
PreviewVertexColor=vec4(0.5);
PreviewVertexSaved=0.0;
vec4 l9_0;
#if (sc_IsEditor&&SC_DISABLE_FRUSTUM_CULLING)
{
vec4 l9_1=position;
l9_1.x=position.x+sc_DisableFrustumCullingMarker;
l9_0=l9_1;
}
#else
{
l9_0=position;
}
#endif
vec2 l9_2;
vec2 l9_3;
vec3 l9_4;
vec3 l9_5;
vec4 l9_6;
#if (sc_VertexBlending)
{
vec2 l9_7;
vec2 l9_8;
vec3 l9_9;
vec3 l9_10;
vec4 l9_11;
#if (sc_VertexBlendingUseNormals)
{
sc_Vertex_t l9_12=sc_Vertex_t(l9_0,normal,tangent.xyz,texture0,texture1);
blendTargetShapeWithNormal(l9_12,blendShape0Pos,blendShape0Normal,weights0.x);
blendTargetShapeWithNormal(l9_12,blendShape1Pos,blendShape1Normal,weights0.y);
blendTargetShapeWithNormal(l9_12,blendShape2Pos,blendShape2Normal,weights0.z);
l9_11=l9_12.position;
l9_10=l9_12.normal;
l9_9=l9_12.tangent;
l9_8=l9_12.texture0;
l9_7=l9_12.texture1;
}
#else
{
vec3 l9_14=(((((l9_0.xyz+(blendShape0Pos*weights0.x)).xyz+(blendShape1Pos*weights0.y)).xyz+(blendShape2Pos*weights0.z)).xyz+(blendShape3Pos*weights0.w)).xyz+(blendShape4Pos*weights1.x)).xyz+(blendShape5Pos*weights1.y);
l9_11=vec4(l9_14.x,l9_14.y,l9_14.z,l9_0.w);
l9_10=normal;
l9_9=tangent.xyz;
l9_8=texture0;
l9_7=texture1;
}
#endif
l9_6=l9_11;
l9_5=l9_10;
l9_4=l9_9;
l9_3=l9_8;
l9_2=l9_7;
}
#else
{
l9_6=l9_0;
l9_5=normal;
l9_4=tangent.xyz;
l9_3=texture0;
l9_2=texture1;
}
#endif
vec3 l9_15;
vec3 l9_16;
vec4 l9_17;
#if (sc_SkinBonesCount>0)
{
vec4 l9_18;
#if (sc_SkinBonesCount>0)
{
vec4 l9_19=vec4(1.0,fract(boneData.yzw));
vec4 l9_20=l9_19;
l9_20.x=1.0-dot(l9_19.yzw,vec3(1.0));
l9_18=l9_20;
}
#else
{
l9_18=vec4(0.0);
}
#endif
int l9_21=int(boneData.x);
int l9_22=int(boneData.y);
int l9_23=int(boneData.z);
int l9_24=int(boneData.w);
vec3 l9_25=(((skinVertexPosition(l9_21,l9_6)*l9_18.x)+(skinVertexPosition(l9_22,l9_6)*l9_18.y))+(skinVertexPosition(l9_23,l9_6)*l9_18.z))+(skinVertexPosition(l9_24,l9_6)*l9_18.w);
l9_17=vec4(l9_25.x,l9_25.y,l9_25.z,l9_6.w);
l9_16=((((sc_SkinBonesNormalMatrices[l9_21]*l9_5)*l9_18.x)+((sc_SkinBonesNormalMatrices[l9_22]*l9_5)*l9_18.y))+((sc_SkinBonesNormalMatrices[l9_23]*l9_5)*l9_18.z))+((sc_SkinBonesNormalMatrices[l9_24]*l9_5)*l9_18.w);
l9_15=((((sc_SkinBonesNormalMatrices[l9_21]*l9_4)*l9_18.x)+((sc_SkinBonesNormalMatrices[l9_22]*l9_4)*l9_18.y))+((sc_SkinBonesNormalMatrices[l9_23]*l9_4)*l9_18.z))+((sc_SkinBonesNormalMatrices[l9_24]*l9_4)*l9_18.w);
}
#else
{
l9_17=l9_6;
l9_16=l9_5;
l9_15=l9_4;
}
#endif
#if (sc_RenderingSpace==3)
{
varPos=vec3(0.0);
varNormal=l9_16;
varTangent=vec4(l9_15.x,l9_15.y,l9_15.z,varTangent.w);
}
#else
{
#if (sc_RenderingSpace==4)
{
varPos=vec3(0.0);
varNormal=l9_16;
varTangent=vec4(l9_15.x,l9_15.y,l9_15.z,varTangent.w);
}
#else
{
#if (sc_RenderingSpace==2)
{
varPos=l9_17.xyz;
varNormal=l9_16;
varTangent=vec4(l9_15.x,l9_15.y,l9_15.z,varTangent.w);
}
#else
{
#if (sc_RenderingSpace==1)
{
varPos=(sc_ModelMatrix*l9_17).xyz;
varNormal=sc_NormalMatrix*l9_16;
vec3 l9_26=sc_NormalMatrix*l9_15;
varTangent=vec4(l9_26.x,l9_26.y,l9_26.z,varTangent.w);
}
#endif
}
#endif
}
#endif
}
#endif
bool l9_27=PreviewEnabled==1;
vec2 l9_28;
if (l9_27)
{
vec2 l9_29=l9_3;
l9_29.x=1.0-l9_3.x;
l9_28=l9_29;
}
else
{
l9_28=l9_3;
}
varColor=color;
vec3 l9_30=varPos;
vec3 l9_31=varNormal;
vec3 l9_32;
vec3 l9_33;
vec3 l9_34;
if (l9_27)
{
l9_34=varTangent.xyz;
l9_33=varNormal;
l9_32=varPos;
}
else
{
l9_34=varTangent.xyz;
l9_33=l9_31;
l9_32=l9_30;
}
varPos=l9_32;
varNormal=normalize(l9_33);
vec3 l9_35=normalize(l9_34);
varTangent=vec4(l9_35.x,l9_35.y,l9_35.z,varTangent.w);
varTangent.w=tangent.w;
#if (UseViewSpaceDepthVariant&&((sc_OITDepthGatherPass||sc_OITCompositingPass)||sc_OITDepthBoundsPass))
{
vec4 l9_36;
#if (sc_RenderingSpace==3)
{
l9_36=sc_ProjectionMatrixInverseArray[sc_GetStereoViewIndex()]*l9_17;
}
#else
{
vec4 l9_37;
#if (sc_RenderingSpace==2)
{
l9_37=sc_ViewMatrixArray[sc_GetStereoViewIndex()]*l9_17;
}
#else
{
vec4 l9_38;
#if (sc_RenderingSpace==1)
{
l9_38=sc_ModelViewMatrixArray[sc_GetStereoViewIndex()]*l9_17;
}
#else
{
l9_38=l9_17;
}
#endif
l9_37=l9_38;
}
#endif
l9_36=l9_37;
}
#endif
varViewSpaceDepth=-l9_36.z;
}
#endif
vec4 l9_39;
#if (sc_RenderingSpace==3)
{
l9_39=l9_17;
}
#else
{
vec4 l9_40;
#if (sc_RenderingSpace==4)
{
l9_40=(sc_ModelViewMatrixArray[sc_GetStereoViewIndex()]*l9_17)*vec4(1.0/sc_Camera.aspect,1.0,1.0,1.0);
}
#else
{
vec4 l9_41;
#if (sc_RenderingSpace==2)
{
l9_41=sc_ViewProjectionMatrixArray[sc_GetStereoViewIndex()]*vec4(varPos,1.0);
}
#else
{
vec4 l9_42;
#if (sc_RenderingSpace==1)
{
l9_42=sc_ViewProjectionMatrixArray[sc_GetStereoViewIndex()]*vec4(varPos,1.0);
}
#else
{
l9_42=vec4(0.0);
}
#endif
l9_41=l9_42;
}
#endif
l9_40=l9_41;
}
#endif
l9_39=l9_40;
}
#endif
varPackedTex=vec4(l9_28,l9_2);
#if (sc_ProjectiveShadowsReceiver)
{
vec4 l9_43;
#if (sc_RenderingSpace==1)
{
l9_43=sc_ModelMatrix*l9_17;
}
#else
{
l9_43=l9_17;
}
#endif
vec4 l9_44=sc_ProjectorMatrix*l9_43;
varShadowTex=((l9_44.xy/vec2(l9_44.w))*0.5)+vec2(0.5);
}
#endif
vec4 l9_45;
#if (sc_DepthBufferMode==1)
{
vec4 l9_46;
if (sc_ProjectionMatrixArray[sc_GetStereoViewIndex()][2].w!=0.0)
{
vec4 l9_47=l9_39;
l9_47.z=((log2(max(sc_Camera.clipPlanes.x,1.0+l9_39.w))*(2.0/log2(sc_Camera.clipPlanes.y+1.0)))-1.0)*l9_39.w;
l9_46=l9_47;
}
else
{
l9_46=l9_39;
}
l9_45=l9_46;
}
#else
{
l9_45=l9_39;
}
#endif
sc_SetClipPosition(l9_45);
}
#elif defined FRAGMENT_SHADER // #if defined VERTEX_SHADER
#if 0
NGS_BACKEND_SHADER_FLAGS_BEGIN__
NGS_BACKEND_SHADER_FLAGS_END__
#endif
#ifdef iconEnabled
#undef iconEnabled
#endif
#define sc_StereoRendering_Disabled 0
#define sc_StereoRendering_InstancedClipped 1
#define sc_StereoRendering_Multiview 2
#ifdef GL_ES
    #define SC_GLES_VERSION_20 2000
    #define SC_GLES_VERSION_30 3000
    #define SC_GLES_VERSION_31 3100
    #define SC_GLES_VERSION_32 3200
#endif
#ifdef VERTEX_SHADER
    #define scOutPos(clipPosition) gl_Position=clipPosition
    #define MAIN main
#endif
#ifdef SC_ENABLE_INSTANCED_RENDERING
    #ifndef sc_EnableInstancing
        #define sc_EnableInstancing 1
    #endif
#endif
#define mod(x,y) (x-y*floor((x+1e-6)/y))
#if defined(GL_ES)&&(__VERSION__<300)&&!defined(GL_OES_standard_derivatives)
#define dFdx(A) (A)
#define dFdy(A) (A)
#define fwidth(A) (A)
#endif
#if __VERSION__<300
#define isinf(x) (x!=0.0&&x*2.0==x ? true : false)
#define isnan(x) (x>0.0||x<0.0||x==0.0 ? false : true)
#define inverse(M) M
#endif
#ifdef sc_EnableFeatureLevelES3
    #ifdef sc_EnableStereoClipDistance
        #if defined(GL_APPLE_clip_distance)
            #extension GL_APPLE_clip_distance : require
        #elif defined(GL_EXT_clip_cull_distance)
            #extension GL_EXT_clip_cull_distance : require
        #else
            #error Clip distance is requested but not supported by this device.
        #endif
    #endif
#else
    #ifdef sc_EnableStereoClipDistance
        #error Clip distance is requested but not supported by this device.
    #endif
#endif
#ifdef sc_EnableFeatureLevelES3
    #ifdef VERTEX_SHADER
        #define attribute in
        #define varying out
    #endif
    #ifdef FRAGMENT_SHADER
        #define varying in
    #endif
    #define gl_FragColor sc_FragData0
    #define texture2D texture
    #define texture2DLod textureLod
    #define texture2DLodEXT textureLod
    #define textureCubeLodEXT textureLod
    #define sc_CanUseTextureLod 1
#else
    #ifdef FRAGMENT_SHADER
        #if defined(GL_EXT_shader_texture_lod)
            #extension GL_EXT_shader_texture_lod : require
            #define sc_CanUseTextureLod 1
            #define texture2DLod texture2DLodEXT
        #endif
    #endif
#endif
#if defined(sc_EnableMultiviewStereoRendering)
    #define sc_StereoRenderingMode sc_StereoRendering_Multiview
    #define sc_NumStereoViews 2
    #extension GL_OVR_multiview2 : require
    #ifdef VERTEX_SHADER
        #ifdef sc_EnableInstancingFallback
            #define sc_GlobalInstanceID (sc_FallbackInstanceID*2+gl_InstanceID)
        #else
            #define sc_GlobalInstanceID gl_InstanceID
        #endif
        #define sc_LocalInstanceID sc_GlobalInstanceID
        #define sc_StereoViewID int(gl_ViewID_OVR)
    #endif
#elif defined(sc_EnableInstancedClippedStereoRendering)
    #ifndef sc_EnableInstancing
        #error Instanced-clipped stereo rendering requires enabled instancing.
    #endif
    #ifndef sc_EnableStereoClipDistance
        #define sc_StereoRendering_IsClipDistanceEnabled 0
    #else
        #define sc_StereoRendering_IsClipDistanceEnabled 1
    #endif
    #define sc_StereoRenderingMode sc_StereoRendering_InstancedClipped
    #define sc_NumStereoClipPlanes 1
    #define sc_NumStereoViews 2
    #ifdef VERTEX_SHADER
        #ifdef sc_EnableInstancingFallback
            #define sc_GlobalInstanceID (sc_FallbackInstanceID*2+gl_InstanceID)
        #else
            #define sc_GlobalInstanceID gl_InstanceID
        #endif
        #ifdef sc_EnableFeatureLevelES3
            #define sc_LocalInstanceID (sc_GlobalInstanceID/2)
            #define sc_StereoViewID (sc_GlobalInstanceID%2)
        #else
            #define sc_LocalInstanceID int(sc_GlobalInstanceID/2.0)
            #define sc_StereoViewID int(mod(sc_GlobalInstanceID,2.0))
        #endif
    #endif
#else
    #define sc_StereoRenderingMode sc_StereoRendering_Disabled
#endif
#ifdef VERTEX_SHADER
    #ifdef sc_EnableInstancing
        #ifdef GL_ES
            #if defined(sc_EnableFeatureLevelES2)&&!defined(GL_EXT_draw_instanced)
                #define gl_InstanceID (0)
            #endif
        #else
            #if defined(sc_EnableFeatureLevelES2)&&!defined(GL_EXT_draw_instanced)&&!defined(GL_ARB_draw_instanced)&&!defined(GL_EXT_gpu_shader4)
                #define gl_InstanceID (0)
            #endif
        #endif
        #ifdef GL_ARB_draw_instanced
            #extension GL_ARB_draw_instanced : require
            #define gl_InstanceID gl_InstanceIDARB
        #endif
        #ifdef GL_EXT_draw_instanced
            #extension GL_EXT_draw_instanced : require
            #define gl_InstanceID gl_InstanceIDEXT
        #endif
        #ifndef sc_InstanceID
            #define sc_InstanceID gl_InstanceID
        #endif
        #ifndef sc_GlobalInstanceID
            #ifdef sc_EnableInstancingFallback
                #define sc_GlobalInstanceID (sc_FallbackInstanceID)
                #define sc_LocalInstanceID (sc_FallbackInstanceID)
            #else
                #define sc_GlobalInstanceID gl_InstanceID
                #define sc_LocalInstanceID gl_InstanceID
            #endif
        #endif
    #endif
#endif
#ifdef VERTEX_SHADER
    #if (__VERSION__<300)&&!defined(GL_EXT_gpu_shader4)
        #define gl_VertexID (0)
    #endif
#endif
#ifndef GL_ES
        #extension GL_EXT_gpu_shader4 : enable
    #extension GL_ARB_shader_texture_lod : enable
    #ifndef texture2DLodEXT
        #define texture2DLodEXT texture2DLod
    #endif
    #ifndef sc_CanUseTextureLod
    #define sc_CanUseTextureLod 1
    #endif
    #define precision
    #define lowp
    #define mediump
    #define highp
    #define sc_FragmentPrecision
#endif
#ifdef sc_EnableFeatureLevelES3
    #define sc_CanUseSampler2DArray 1
#endif
#if defined(sc_EnableFeatureLevelES2)&&defined(GL_ES)
    #ifdef FRAGMENT_SHADER
        #ifdef GL_OES_standard_derivatives
            #extension GL_OES_standard_derivatives : require
            #define sc_CanUseStandardDerivatives 1
        #endif
    #endif
    #ifdef GL_EXT_texture_array
        #extension GL_EXT_texture_array : require
        #define sc_CanUseSampler2DArray 1
    #else
        #define sc_CanUseSampler2DArray 0
    #endif
#endif
#ifdef GL_ES
    #ifdef sc_FramebufferFetch
        #if defined(GL_EXT_shader_framebuffer_fetch)
            #extension GL_EXT_shader_framebuffer_fetch : require
        #elif defined(GL_ARM_shader_framebuffer_fetch)
            #extension GL_ARM_shader_framebuffer_fetch : require
        #else
            #error Framebuffer fetch is requested but not supported by this device.
        #endif
    #endif
    #ifdef GL_FRAGMENT_PRECISION_HIGH
        #define sc_FragmentPrecision highp
    #else
        #define sc_FragmentPrecision mediump
    #endif
    #ifdef FRAGMENT_SHADER
        precision highp int;
        precision highp float;
    #endif
#endif
#ifdef VERTEX_SHADER
    #ifdef sc_EnableMultiviewStereoRendering
        layout(num_views=sc_NumStereoViews) in;
    #endif
#endif
#if __VERSION__>100
    #define SC_INT_FALLBACK_FLOAT int
    #define SC_INTERPOLATION_FLAT flat
    #define SC_INTERPOLATION_CENTROID centroid
#else
    #define SC_INT_FALLBACK_FLOAT float
    #define SC_INTERPOLATION_FLAT
    #define SC_INTERPOLATION_CENTROID
#endif
#ifndef sc_NumStereoViews
    #define sc_NumStereoViews 1
#endif
#ifndef sc_CanUseSampler2DArray
    #define sc_CanUseSampler2DArray 0
#endif
    #if __VERSION__==100||defined(SCC_VALIDATION)
        #define sampler2DArray vec2
        #define sampler3D vec3
        #define samplerCube vec4
        vec4 texture3D(vec3 s,vec3 uv)                       { return vec4(0.0); }
        vec4 texture3D(vec3 s,vec3 uv,float bias)           { return vec4(0.0); }
        vec4 texture3DLod(vec3 s,vec3 uv,float bias)        { return vec4(0.0); }
        vec4 texture3DLodEXT(vec3 s,vec3 uv,float lod)      { return vec4(0.0); }
        vec4 texture2DArray(vec2 s,vec3 uv)                  { return vec4(0.0); }
        vec4 texture2DArray(vec2 s,vec3 uv,float bias)      { return vec4(0.0); }
        vec4 texture2DArrayLod(vec2 s,vec3 uv,float lod)    { return vec4(0.0); }
        vec4 texture2DArrayLodEXT(vec2 s,vec3 uv,float lod) { return vec4(0.0); }
        vec4 textureCube(vec4 s,vec3 uv)                     { return vec4(0.0); }
        vec4 textureCube(vec4 s,vec3 uv,float lod)          { return vec4(0.0); }
        vec4 textureCubeLod(vec4 s,vec3 uv,float lod)       { return vec4(0.0); }
        vec4 textureCubeLodEXT(vec4 s,vec3 uv,float lod)    { return vec4(0.0); }
        #if defined(VERTEX_SHADER)||!sc_CanUseTextureLod
            #define texture2DLod(s,uv,lod)      vec4(0.0)
            #define texture2DLodEXT(s,uv,lod)   vec4(0.0)
        #endif
    #elif __VERSION__>=300
        #define texture3D texture
        #define textureCube texture
        #define texture2DArray texture
        #define texture2DLod textureLod
        #define texture3DLod textureLod
        #define texture2DLodEXT textureLod
        #define texture3DLodEXT textureLod
        #define textureCubeLod textureLod
        #define textureCubeLodEXT textureLod
        #define texture2DArrayLod textureLod
        #define texture2DArrayLodEXT textureLod
    #endif
    #ifndef sc_TextureRenderingLayout_Regular
        #define sc_TextureRenderingLayout_Regular 0
        #define sc_TextureRenderingLayout_StereoInstancedClipped 1
        #define sc_TextureRenderingLayout_StereoMultiview 2
    #endif
    #define depthToGlobal   depthScreenToViewSpace
    #define depthToLocal    depthViewToScreenSpace
    #ifndef quantizeUV
        #define quantizeUV sc_QuantizeUV
        #define sc_platformUVFlip sc_PlatformFlipV
        #define sc_PlatformFlipUV sc_PlatformFlipV
    #endif
    #ifndef sc_texture2DLod
        #define sc_texture2DLod sc_InternalTextureLevel
        #define sc_textureLod sc_InternalTextureLevel
        #define sc_textureBias sc_InternalTextureBiasOrLevel
        #define sc_texture sc_InternalTexture
    #endif
#if sc_ExporterVersion<224
#define MAIN main
#endif
    #ifndef sc_FramebufferFetch
    #define sc_FramebufferFetch 0
    #elif sc_FramebufferFetch==1
    #undef sc_FramebufferFetch
    #define sc_FramebufferFetch 1
    #endif
    #if !defined(GL_ES)&&__VERSION__<420
        #ifdef FRAGMENT_SHADER
            #define sc_FragData0 gl_FragData[0]
            #define sc_FragData1 gl_FragData[1]
            #define sc_FragData2 gl_FragData[2]
            #define sc_FragData3 gl_FragData[3]
        #endif
        mat4 getFragData() { return mat4(vec4(0.0),vec4(0.0),vec4(0.0),vec4(0.0)); }
        #define gl_LastFragData (getFragData())
        #if sc_FramebufferFetch
            #error Framebuffer fetch is requested but not supported by this device.
        #endif
    #elif defined(sc_EnableFeatureLevelES3)
        #if sc_FragDataCount>=1
            #define sc_DeclareFragData0(StorageQualifier) layout(location=0) StorageQualifier sc_FragmentPrecision vec4 sc_FragData0
        #endif
        #if sc_FragDataCount>=2
            #define sc_DeclareFragData1(StorageQualifier) layout(location=1) StorageQualifier sc_FragmentPrecision vec4 sc_FragData1
        #endif
        #if sc_FragDataCount>=3
            #define sc_DeclareFragData2(StorageQualifier) layout(location=2) StorageQualifier sc_FragmentPrecision vec4 sc_FragData2
        #endif
        #if sc_FragDataCount>=4
            #define sc_DeclareFragData3(StorageQualifier) layout(location=3) StorageQualifier sc_FragmentPrecision vec4 sc_FragData3
        #endif
        #ifndef sc_DeclareFragData0
            #define sc_DeclareFragData0(_) const vec4 sc_FragData0=vec4(0.0)
        #endif
        #ifndef sc_DeclareFragData1
            #define sc_DeclareFragData1(_) const vec4 sc_FragData1=vec4(0.0)
        #endif
        #ifndef sc_DeclareFragData2
            #define sc_DeclareFragData2(_) const vec4 sc_FragData2=vec4(0.0)
        #endif
        #ifndef sc_DeclareFragData3
            #define sc_DeclareFragData3(_) const vec4 sc_FragData3=vec4(0.0)
        #endif
        #if sc_FramebufferFetch
            #ifdef GL_EXT_shader_framebuffer_fetch
                sc_DeclareFragData0(inout);
                sc_DeclareFragData1(inout);
                sc_DeclareFragData2(inout);
                sc_DeclareFragData3(inout);
                mediump mat4 getFragData() { return mat4(sc_FragData0,sc_FragData1,sc_FragData2,sc_FragData3); }
                #define gl_LastFragData (getFragData())
            #elif defined(GL_ARM_shader_framebuffer_fetch)
                sc_DeclareFragData0(out);
                sc_DeclareFragData1(out);
                sc_DeclareFragData2(out);
                sc_DeclareFragData3(out);
                mediump mat4 getFragData() { return mat4(gl_LastFragColorARM,vec4(0.0),vec4(0.0),vec4(0.0)); }
                #define gl_LastFragData (getFragData())
            #endif
        #else
            #ifdef sc_EnableFeatureLevelES3
                sc_DeclareFragData0(out);
                sc_DeclareFragData1(out);
                sc_DeclareFragData2(out);
                sc_DeclareFragData3(out);
                mediump mat4 getFragData() { return mat4(vec4(0.0),vec4(0.0),vec4(0.0),vec4(0.0)); }
                #define gl_LastFragData (getFragData())
            #endif
        #endif
    #elif defined(sc_EnableFeatureLevelES2)
        #define sc_FragData0 gl_FragColor
        mediump mat4 getFragData() { return mat4(vec4(0.0),vec4(0.0),vec4(0.0),vec4(0.0)); }
    #else
        #define sc_FragData0 gl_FragColor
        mediump mat4 getFragData() { return mat4(vec4(0.0),vec4(0.0),vec4(0.0),vec4(0.0)); }
    #endif
#ifdef uv2
#undef uv2
#endif
#ifdef uv3
#undef uv3
#endif
struct RayHitPayload
{
vec3 viewDirWS;
vec3 positionWS;
vec3 normalWS;
vec4 tangentWS;
vec4 color;
vec2 uv0;
vec2 uv1;
vec2 uv2;
vec2 uv3;
uvec2 id;
};
#ifndef sc_StereoRenderingMode
#define sc_StereoRenderingMode 0
#endif
#ifndef sc_ScreenTextureHasSwappedViews
#define sc_ScreenTextureHasSwappedViews 0
#elif sc_ScreenTextureHasSwappedViews==1
#undef sc_ScreenTextureHasSwappedViews
#define sc_ScreenTextureHasSwappedViews 1
#endif
#ifndef sc_ScreenTextureLayout
#define sc_ScreenTextureLayout 0
#endif
#ifndef sc_NumStereoViews
#define sc_NumStereoViews 1
#endif
#ifndef sc_BlendMode_Normal
#define sc_BlendMode_Normal 0
#elif sc_BlendMode_Normal==1
#undef sc_BlendMode_Normal
#define sc_BlendMode_Normal 1
#endif
#ifndef sc_BlendMode_AlphaToCoverage
#define sc_BlendMode_AlphaToCoverage 0
#elif sc_BlendMode_AlphaToCoverage==1
#undef sc_BlendMode_AlphaToCoverage
#define sc_BlendMode_AlphaToCoverage 1
#endif
#ifndef sc_BlendMode_PremultipliedAlphaHardware
#define sc_BlendMode_PremultipliedAlphaHardware 0
#elif sc_BlendMode_PremultipliedAlphaHardware==1
#undef sc_BlendMode_PremultipliedAlphaHardware
#define sc_BlendMode_PremultipliedAlphaHardware 1
#endif
#ifndef sc_BlendMode_PremultipliedAlphaAuto
#define sc_BlendMode_PremultipliedAlphaAuto 0
#elif sc_BlendMode_PremultipliedAlphaAuto==1
#undef sc_BlendMode_PremultipliedAlphaAuto
#define sc_BlendMode_PremultipliedAlphaAuto 1
#endif
#ifndef sc_BlendMode_PremultipliedAlpha
#define sc_BlendMode_PremultipliedAlpha 0
#elif sc_BlendMode_PremultipliedAlpha==1
#undef sc_BlendMode_PremultipliedAlpha
#define sc_BlendMode_PremultipliedAlpha 1
#endif
#ifndef sc_BlendMode_AddWithAlphaFactor
#define sc_BlendMode_AddWithAlphaFactor 0
#elif sc_BlendMode_AddWithAlphaFactor==1
#undef sc_BlendMode_AddWithAlphaFactor
#define sc_BlendMode_AddWithAlphaFactor 1
#endif
#ifndef sc_BlendMode_AlphaTest
#define sc_BlendMode_AlphaTest 0
#elif sc_BlendMode_AlphaTest==1
#undef sc_BlendMode_AlphaTest
#define sc_BlendMode_AlphaTest 1
#endif
#ifndef sc_BlendMode_Multiply
#define sc_BlendMode_Multiply 0
#elif sc_BlendMode_Multiply==1
#undef sc_BlendMode_Multiply
#define sc_BlendMode_Multiply 1
#endif
#ifndef sc_BlendMode_MultiplyOriginal
#define sc_BlendMode_MultiplyOriginal 0
#elif sc_BlendMode_MultiplyOriginal==1
#undef sc_BlendMode_MultiplyOriginal
#define sc_BlendMode_MultiplyOriginal 1
#endif
#ifndef sc_BlendMode_ColoredGlass
#define sc_BlendMode_ColoredGlass 0
#elif sc_BlendMode_ColoredGlass==1
#undef sc_BlendMode_ColoredGlass
#define sc_BlendMode_ColoredGlass 1
#endif
#ifndef sc_BlendMode_Add
#define sc_BlendMode_Add 0
#elif sc_BlendMode_Add==1
#undef sc_BlendMode_Add
#define sc_BlendMode_Add 1
#endif
#ifndef sc_BlendMode_Screen
#define sc_BlendMode_Screen 0
#elif sc_BlendMode_Screen==1
#undef sc_BlendMode_Screen
#define sc_BlendMode_Screen 1
#endif
#ifndef sc_BlendMode_Min
#define sc_BlendMode_Min 0
#elif sc_BlendMode_Min==1
#undef sc_BlendMode_Min
#define sc_BlendMode_Min 1
#endif
#ifndef sc_BlendMode_Max
#define sc_BlendMode_Max 0
#elif sc_BlendMode_Max==1
#undef sc_BlendMode_Max
#define sc_BlendMode_Max 1
#endif
#ifndef sc_StereoRendering_IsClipDistanceEnabled
#define sc_StereoRendering_IsClipDistanceEnabled 0
#endif
#ifndef sc_ShaderComplexityAnalyzer
#define sc_ShaderComplexityAnalyzer 0
#elif sc_ShaderComplexityAnalyzer==1
#undef sc_ShaderComplexityAnalyzer
#define sc_ShaderComplexityAnalyzer 1
#endif
#ifndef sc_UseFramebufferFetchMarker
#define sc_UseFramebufferFetchMarker 0
#elif sc_UseFramebufferFetchMarker==1
#undef sc_UseFramebufferFetchMarker
#define sc_UseFramebufferFetchMarker 1
#endif
#ifndef sc_FramebufferFetch
#define sc_FramebufferFetch 0
#elif sc_FramebufferFetch==1
#undef sc_FramebufferFetch
#define sc_FramebufferFetch 1
#endif
#ifndef sc_IsEditor
#define sc_IsEditor 0
#elif sc_IsEditor==1
#undef sc_IsEditor
#define sc_IsEditor 1
#endif
#ifndef sc_GetFramebufferColorInvalidUsageMarker
#define sc_GetFramebufferColorInvalidUsageMarker 0
#elif sc_GetFramebufferColorInvalidUsageMarker==1
#undef sc_GetFramebufferColorInvalidUsageMarker
#define sc_GetFramebufferColorInvalidUsageMarker 1
#endif
#ifndef sc_BlendMode_Software
#define sc_BlendMode_Software 0
#elif sc_BlendMode_Software==1
#undef sc_BlendMode_Software
#define sc_BlendMode_Software 1
#endif
#ifndef sc_MotionVectorsPass
#define sc_MotionVectorsPass 0
#elif sc_MotionVectorsPass==1
#undef sc_MotionVectorsPass
#define sc_MotionVectorsPass 1
#endif
#ifndef sc_ProxyAlphaOne
#define sc_ProxyAlphaOne 0
#elif sc_ProxyAlphaOne==1
#undef sc_ProxyAlphaOne
#define sc_ProxyAlphaOne 1
#endif
#ifndef intensityTextureHasSwappedViews
#define intensityTextureHasSwappedViews 0
#elif intensityTextureHasSwappedViews==1
#undef intensityTextureHasSwappedViews
#define intensityTextureHasSwappedViews 1
#endif
#ifndef intensityTextureLayout
#define intensityTextureLayout 0
#endif
#ifndef BLEND_MODE_REALISTIC
#define BLEND_MODE_REALISTIC 0
#elif BLEND_MODE_REALISTIC==1
#undef BLEND_MODE_REALISTIC
#define BLEND_MODE_REALISTIC 1
#endif
#ifndef BLEND_MODE_FORGRAY
#define BLEND_MODE_FORGRAY 0
#elif BLEND_MODE_FORGRAY==1
#undef BLEND_MODE_FORGRAY
#define BLEND_MODE_FORGRAY 1
#endif
#ifndef BLEND_MODE_NOTBRIGHT
#define BLEND_MODE_NOTBRIGHT 0
#elif BLEND_MODE_NOTBRIGHT==1
#undef BLEND_MODE_NOTBRIGHT
#define BLEND_MODE_NOTBRIGHT 1
#endif
#ifndef BLEND_MODE_DIVISION
#define BLEND_MODE_DIVISION 0
#elif BLEND_MODE_DIVISION==1
#undef BLEND_MODE_DIVISION
#define BLEND_MODE_DIVISION 1
#endif
#ifndef BLEND_MODE_BRIGHT
#define BLEND_MODE_BRIGHT 0
#elif BLEND_MODE_BRIGHT==1
#undef BLEND_MODE_BRIGHT
#define BLEND_MODE_BRIGHT 1
#endif
#ifndef BLEND_MODE_INTENSE
#define BLEND_MODE_INTENSE 0
#elif BLEND_MODE_INTENSE==1
#undef BLEND_MODE_INTENSE
#define BLEND_MODE_INTENSE 1
#endif
#ifndef SC_USE_UV_TRANSFORM_intensityTexture
#define SC_USE_UV_TRANSFORM_intensityTexture 0
#elif SC_USE_UV_TRANSFORM_intensityTexture==1
#undef SC_USE_UV_TRANSFORM_intensityTexture
#define SC_USE_UV_TRANSFORM_intensityTexture 1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_U_intensityTexture
#define SC_SOFTWARE_WRAP_MODE_U_intensityTexture -1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_V_intensityTexture
#define SC_SOFTWARE_WRAP_MODE_V_intensityTexture -1
#endif
#ifndef SC_USE_UV_MIN_MAX_intensityTexture
#define SC_USE_UV_MIN_MAX_intensityTexture 0
#elif SC_USE_UV_MIN_MAX_intensityTexture==1
#undef SC_USE_UV_MIN_MAX_intensityTexture
#define SC_USE_UV_MIN_MAX_intensityTexture 1
#endif
#ifndef SC_USE_CLAMP_TO_BORDER_intensityTexture
#define SC_USE_CLAMP_TO_BORDER_intensityTexture 0
#elif SC_USE_CLAMP_TO_BORDER_intensityTexture==1
#undef SC_USE_CLAMP_TO_BORDER_intensityTexture
#define SC_USE_CLAMP_TO_BORDER_intensityTexture 1
#endif
#ifndef BLEND_MODE_LIGHTEN
#define BLEND_MODE_LIGHTEN 0
#elif BLEND_MODE_LIGHTEN==1
#undef BLEND_MODE_LIGHTEN
#define BLEND_MODE_LIGHTEN 1
#endif
#ifndef BLEND_MODE_DARKEN
#define BLEND_MODE_DARKEN 0
#elif BLEND_MODE_DARKEN==1
#undef BLEND_MODE_DARKEN
#define BLEND_MODE_DARKEN 1
#endif
#ifndef BLEND_MODE_DIVIDE
#define BLEND_MODE_DIVIDE 0
#elif BLEND_MODE_DIVIDE==1
#undef BLEND_MODE_DIVIDE
#define BLEND_MODE_DIVIDE 1
#endif
#ifndef BLEND_MODE_AVERAGE
#define BLEND_MODE_AVERAGE 0
#elif BLEND_MODE_AVERAGE==1
#undef BLEND_MODE_AVERAGE
#define BLEND_MODE_AVERAGE 1
#endif
#ifndef BLEND_MODE_SUBTRACT
#define BLEND_MODE_SUBTRACT 0
#elif BLEND_MODE_SUBTRACT==1
#undef BLEND_MODE_SUBTRACT
#define BLEND_MODE_SUBTRACT 1
#endif
#ifndef BLEND_MODE_DIFFERENCE
#define BLEND_MODE_DIFFERENCE 0
#elif BLEND_MODE_DIFFERENCE==1
#undef BLEND_MODE_DIFFERENCE
#define BLEND_MODE_DIFFERENCE 1
#endif
#ifndef BLEND_MODE_NEGATION
#define BLEND_MODE_NEGATION 0
#elif BLEND_MODE_NEGATION==1
#undef BLEND_MODE_NEGATION
#define BLEND_MODE_NEGATION 1
#endif
#ifndef BLEND_MODE_EXCLUSION
#define BLEND_MODE_EXCLUSION 0
#elif BLEND_MODE_EXCLUSION==1
#undef BLEND_MODE_EXCLUSION
#define BLEND_MODE_EXCLUSION 1
#endif
#ifndef BLEND_MODE_OVERLAY
#define BLEND_MODE_OVERLAY 0
#elif BLEND_MODE_OVERLAY==1
#undef BLEND_MODE_OVERLAY
#define BLEND_MODE_OVERLAY 1
#endif
#ifndef BLEND_MODE_SOFT_LIGHT
#define BLEND_MODE_SOFT_LIGHT 0
#elif BLEND_MODE_SOFT_LIGHT==1
#undef BLEND_MODE_SOFT_LIGHT
#define BLEND_MODE_SOFT_LIGHT 1
#endif
#ifndef BLEND_MODE_HARD_LIGHT
#define BLEND_MODE_HARD_LIGHT 0
#elif BLEND_MODE_HARD_LIGHT==1
#undef BLEND_MODE_HARD_LIGHT
#define BLEND_MODE_HARD_LIGHT 1
#endif
#ifndef BLEND_MODE_COLOR_DODGE
#define BLEND_MODE_COLOR_DODGE 0
#elif BLEND_MODE_COLOR_DODGE==1
#undef BLEND_MODE_COLOR_DODGE
#define BLEND_MODE_COLOR_DODGE 1
#endif
#ifndef BLEND_MODE_COLOR_BURN
#define BLEND_MODE_COLOR_BURN 0
#elif BLEND_MODE_COLOR_BURN==1
#undef BLEND_MODE_COLOR_BURN
#define BLEND_MODE_COLOR_BURN 1
#endif
#ifndef BLEND_MODE_LINEAR_LIGHT
#define BLEND_MODE_LINEAR_LIGHT 0
#elif BLEND_MODE_LINEAR_LIGHT==1
#undef BLEND_MODE_LINEAR_LIGHT
#define BLEND_MODE_LINEAR_LIGHT 1
#endif
#ifndef BLEND_MODE_VIVID_LIGHT
#define BLEND_MODE_VIVID_LIGHT 0
#elif BLEND_MODE_VIVID_LIGHT==1
#undef BLEND_MODE_VIVID_LIGHT
#define BLEND_MODE_VIVID_LIGHT 1
#endif
#ifndef BLEND_MODE_PIN_LIGHT
#define BLEND_MODE_PIN_LIGHT 0
#elif BLEND_MODE_PIN_LIGHT==1
#undef BLEND_MODE_PIN_LIGHT
#define BLEND_MODE_PIN_LIGHT 1
#endif
#ifndef BLEND_MODE_HARD_MIX
#define BLEND_MODE_HARD_MIX 0
#elif BLEND_MODE_HARD_MIX==1
#undef BLEND_MODE_HARD_MIX
#define BLEND_MODE_HARD_MIX 1
#endif
#ifndef BLEND_MODE_HARD_REFLECT
#define BLEND_MODE_HARD_REFLECT 0
#elif BLEND_MODE_HARD_REFLECT==1
#undef BLEND_MODE_HARD_REFLECT
#define BLEND_MODE_HARD_REFLECT 1
#endif
#ifndef BLEND_MODE_HARD_GLOW
#define BLEND_MODE_HARD_GLOW 0
#elif BLEND_MODE_HARD_GLOW==1
#undef BLEND_MODE_HARD_GLOW
#define BLEND_MODE_HARD_GLOW 1
#endif
#ifndef BLEND_MODE_HARD_PHOENIX
#define BLEND_MODE_HARD_PHOENIX 0
#elif BLEND_MODE_HARD_PHOENIX==1
#undef BLEND_MODE_HARD_PHOENIX
#define BLEND_MODE_HARD_PHOENIX 1
#endif
#ifndef BLEND_MODE_HUE
#define BLEND_MODE_HUE 0
#elif BLEND_MODE_HUE==1
#undef BLEND_MODE_HUE
#define BLEND_MODE_HUE 1
#endif
#ifndef BLEND_MODE_SATURATION
#define BLEND_MODE_SATURATION 0
#elif BLEND_MODE_SATURATION==1
#undef BLEND_MODE_SATURATION
#define BLEND_MODE_SATURATION 1
#endif
#ifndef BLEND_MODE_COLOR
#define BLEND_MODE_COLOR 0
#elif BLEND_MODE_COLOR==1
#undef BLEND_MODE_COLOR
#define BLEND_MODE_COLOR 1
#endif
#ifndef BLEND_MODE_LUMINOSITY
#define BLEND_MODE_LUMINOSITY 0
#elif BLEND_MODE_LUMINOSITY==1
#undef BLEND_MODE_LUMINOSITY
#define BLEND_MODE_LUMINOSITY 1
#endif
#ifndef sc_SkinBonesCount
#define sc_SkinBonesCount 0
#endif
#ifndef UseViewSpaceDepthVariant
#define UseViewSpaceDepthVariant 1
#elif UseViewSpaceDepthVariant==1
#undef UseViewSpaceDepthVariant
#define UseViewSpaceDepthVariant 1
#endif
#ifndef sc_OITDepthGatherPass
#define sc_OITDepthGatherPass 0
#elif sc_OITDepthGatherPass==1
#undef sc_OITDepthGatherPass
#define sc_OITDepthGatherPass 1
#endif
#ifndef sc_OITCompositingPass
#define sc_OITCompositingPass 0
#elif sc_OITCompositingPass==1
#undef sc_OITCompositingPass
#define sc_OITCompositingPass 1
#endif
#ifndef sc_OITDepthBoundsPass
#define sc_OITDepthBoundsPass 0
#elif sc_OITDepthBoundsPass==1
#undef sc_OITDepthBoundsPass
#define sc_OITDepthBoundsPass 1
#endif
#ifndef sc_OITMaxLayers4Plus1
#define sc_OITMaxLayers4Plus1 0
#elif sc_OITMaxLayers4Plus1==1
#undef sc_OITMaxLayers4Plus1
#define sc_OITMaxLayers4Plus1 1
#endif
#ifndef sc_OITMaxLayersVisualizeLayerCount
#define sc_OITMaxLayersVisualizeLayerCount 0
#elif sc_OITMaxLayersVisualizeLayerCount==1
#undef sc_OITMaxLayersVisualizeLayerCount
#define sc_OITMaxLayersVisualizeLayerCount 1
#endif
#ifndef sc_OITMaxLayers8
#define sc_OITMaxLayers8 0
#elif sc_OITMaxLayers8==1
#undef sc_OITMaxLayers8
#define sc_OITMaxLayers8 1
#endif
#ifndef sc_OITFrontLayerPass
#define sc_OITFrontLayerPass 0
#elif sc_OITFrontLayerPass==1
#undef sc_OITFrontLayerPass
#define sc_OITFrontLayerPass 1
#endif
#ifndef sc_OITDepthPrepass
#define sc_OITDepthPrepass 0
#elif sc_OITDepthPrepass==1
#undef sc_OITDepthPrepass
#define sc_OITDepthPrepass 1
#endif
#ifndef ENABLE_STIPPLE_PATTERN_TEST
#define ENABLE_STIPPLE_PATTERN_TEST 0
#elif ENABLE_STIPPLE_PATTERN_TEST==1
#undef ENABLE_STIPPLE_PATTERN_TEST
#define ENABLE_STIPPLE_PATTERN_TEST 1
#endif
#ifndef sc_ProjectiveShadowsCaster
#define sc_ProjectiveShadowsCaster 0
#elif sc_ProjectiveShadowsCaster==1
#undef sc_ProjectiveShadowsCaster
#define sc_ProjectiveShadowsCaster 1
#endif
#ifndef sc_RenderAlphaToColor
#define sc_RenderAlphaToColor 0
#elif sc_RenderAlphaToColor==1
#undef sc_RenderAlphaToColor
#define sc_RenderAlphaToColor 1
#endif
#ifndef sc_BlendMode_Custom
#define sc_BlendMode_Custom 0
#elif sc_BlendMode_Custom==1
#undef sc_BlendMode_Custom
#define sc_BlendMode_Custom 1
#endif
#ifndef additional_settings_btn_refl_texHasSwappedViews
#define additional_settings_btn_refl_texHasSwappedViews 0
#elif additional_settings_btn_refl_texHasSwappedViews==1
#undef additional_settings_btn_refl_texHasSwappedViews
#define additional_settings_btn_refl_texHasSwappedViews 1
#endif
#ifndef additional_settings_btn_refl_texLayout
#define additional_settings_btn_refl_texLayout 0
#endif
#ifndef iconHasSwappedViews
#define iconHasSwappedViews 0
#elif iconHasSwappedViews==1
#undef iconHasSwappedViews
#define iconHasSwappedViews 1
#endif
#ifndef iconLayout
#define iconLayout 0
#endif
#ifndef SC_USE_UV_TRANSFORM_icon
#define SC_USE_UV_TRANSFORM_icon 0
#elif SC_USE_UV_TRANSFORM_icon==1
#undef SC_USE_UV_TRANSFORM_icon
#define SC_USE_UV_TRANSFORM_icon 1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_U_icon
#define SC_SOFTWARE_WRAP_MODE_U_icon -1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_V_icon
#define SC_SOFTWARE_WRAP_MODE_V_icon -1
#endif
#ifndef SC_USE_UV_MIN_MAX_icon
#define SC_USE_UV_MIN_MAX_icon 0
#elif SC_USE_UV_MIN_MAX_icon==1
#undef SC_USE_UV_MIN_MAX_icon
#define SC_USE_UV_MIN_MAX_icon 1
#endif
#ifndef SC_USE_CLAMP_TO_BORDER_icon
#define SC_USE_CLAMP_TO_BORDER_icon 0
#elif SC_USE_CLAMP_TO_BORDER_icon==1
#undef SC_USE_CLAMP_TO_BORDER_icon
#define SC_USE_CLAMP_TO_BORDER_icon 1
#endif
#ifndef sc_DepthOnly
#define sc_DepthOnly 0
#elif sc_DepthOnly==1
#undef sc_DepthOnly
#define sc_DepthOnly 1
#endif
#ifndef SC_USE_UV_TRANSFORM_additional_settings_btn_refl_tex
#define SC_USE_UV_TRANSFORM_additional_settings_btn_refl_tex 0
#elif SC_USE_UV_TRANSFORM_additional_settings_btn_refl_tex==1
#undef SC_USE_UV_TRANSFORM_additional_settings_btn_refl_tex
#define SC_USE_UV_TRANSFORM_additional_settings_btn_refl_tex 1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex
#define SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex -1
#endif
#ifndef SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex
#define SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex -1
#endif
#ifndef SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex
#define SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex 0
#elif SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex==1
#undef SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex
#define SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex 1
#endif
#ifndef SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex
#define SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex 0
#elif SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex==1
#undef SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex
#define SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex 1
#endif
#ifndef sc_PointLightsCount
#define sc_PointLightsCount 0
#endif
#ifndef sc_DirectionalLightsCount
#define sc_DirectionalLightsCount 0
#endif
#ifndef sc_AmbientLightsCount
#define sc_AmbientLightsCount 0
#endif
struct sc_PointLight_t
{
bool falloffEnabled;
float falloffEndDistance;
float negRcpFalloffEndDistance4;
float angleScale;
float angleOffset;
vec3 direction;
vec3 position;
vec4 color;
};
struct sc_DirectionalLight_t
{
vec3 direction;
vec4 color;
};
struct sc_AmbientLight_t
{
vec3 color;
float intensity;
};
struct sc_SphericalGaussianLight_t
{
vec3 color;
float sharpness;
vec3 axis;
};
struct sc_LightEstimationData_t
{
sc_SphericalGaussianLight_t sg[12];
vec3 ambientLight;
};
struct sc_Camera_t
{
vec3 position;
float aspect;
vec2 clipPlanes;
};
layout(binding=1,std430) readonly buffer layoutVertices
{
float _Vertices[];
} layoutVertices_obj;
layout(binding=2,std430) readonly buffer layoutVerticesPN
{
float _VerticesPN[];
} layoutVerticesPN_obj;
layout(binding=0,std430) readonly buffer layoutIndices
{
uint _Triangles[];
} layoutIndices_obj;
uniform vec4 sc_EnvmapDiffuseDims;
uniform vec4 sc_EnvmapSpecularDims;
uniform vec4 sc_ScreenTextureDims;
uniform bool isProxyMode;
uniform bool noEarlyZ;
uniform vec4 z_rayDirectionsDims;
uniform vec4 sc_CurrentRenderTargetDims;
uniform mat4 sc_ProjectionMatrixArray[sc_NumStereoViews];
uniform float sc_ShadowDensity;
uniform vec4 sc_ShadowColor;
uniform float shaderComplexityValue;
uniform float _sc_framebufferFetchMarker;
uniform float _sc_GetFramebufferColorInvalidUsageMarker;
uniform mat4 sc_ViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_PrevFrameViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_PrevFrameModelMatrix;
uniform mat4 sc_ModelMatrixInverse;
uniform int emitter_stride;
uniform int proxy_offset_position;
uniform int proxy_format_position;
uniform int proxy_offset_normal;
uniform int proxy_format_normal;
uniform int proxy_offset_tangent;
uniform int proxy_format_tangent;
uniform int proxy_offset_color;
uniform int proxy_format_color;
uniform int proxy_offset_texture0;
uniform int proxy_format_texture0;
uniform int proxy_offset_texture1;
uniform int proxy_format_texture1;
uniform int proxy_offset_texture2;
uniform int proxy_format_texture2;
uniform int proxy_offset_texture3;
uniform int proxy_format_texture3;
uniform int lray_triangles_last;
uniform int instance_id;
uniform bool has_animated_pn;
uniform mat4 sc_ModelMatrix;
uniform mat3 sc_NormalMatrix;
uniform vec4 intensityTextureDims;
uniform float correctedIntensity;
uniform mat3 intensityTextureTransform;
uniform vec4 intensityTextureUvMinMax;
uniform vec4 intensityTextureBorderColor;
uniform float alphaTestThreshold;
uniform vec4 additional_settings_btn_refl_texDims;
uniform vec4 iconDims;
uniform int PreviewEnabled;
uniform int PreviewNodeID;
uniform bool iconEnabled;
uniform vec2 Port_Center_N002;
uniform vec2 Port_Scale_N002;
uniform mat3 iconTransform;
uniform vec4 iconUvMinMax;
uniform vec4 iconBorderColor;
uniform int overrideTimeEnabled;
uniform float overrideTimeElapsed;
uniform vec4 sc_Time;
uniform float overrideTimeDelta;
uniform float Port_Import_N006;
uniform vec3 Port_Import_N049;
uniform mat4 sc_ViewMatrixArray[sc_NumStereoViews];
uniform float Port_Input1_N053;
uniform float Port_Input2_N053;
uniform mat3 additional_settings_btn_refl_texTransform;
uniform vec4 additional_settings_btn_refl_texUvMinMax;
uniform vec4 additional_settings_btn_refl_texBorderColor;
uniform float Port_Import_N062;
uniform vec3 Port_Import_N068;
uniform float Port_Input1_N073;
uniform float Port_Input2_N073;
uniform float Port_Input2_N005;
uniform vec2 Port_Input1_N009;
uniform vec2 Port_Input2_N009;
uniform vec4 Port_Value0_N003;
uniform float Port_Position1_N003;
uniform vec4 Port_Value1_N003;
uniform float Port_Position2_N003;
uniform vec4 Port_Value2_N003;
uniform float Port_Position3_N003;
uniform vec4 Port_Value3_N003;
uniform vec4 Port_Value4_N003;
uniform float Port_Input2_N007;
uniform sc_PointLight_t sc_PointLights[sc_PointLightsCount+1];
uniform sc_DirectionalLight_t sc_DirectionalLights[sc_DirectionalLightsCount+1];
uniform sc_AmbientLight_t sc_AmbientLights[sc_AmbientLightsCount+1];
uniform sc_LightEstimationData_t sc_LightEstimationData;
uniform vec4 sc_EnvmapDiffuseSize;
uniform vec4 sc_EnvmapDiffuseView;
uniform vec4 sc_EnvmapSpecularSize;
uniform vec4 sc_EnvmapSpecularView;
uniform vec3 sc_EnvmapRotation;
uniform float sc_EnvmapExposure;
uniform vec3 sc_Sh[9];
uniform float sc_ShIntensity;
uniform vec4 sc_UniformConstants;
uniform vec4 sc_GeometryInfo;
uniform mat4 sc_ModelViewProjectionMatrixArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ViewProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewMatrixArray[sc_NumStereoViews];
uniform mat4 sc_ModelViewMatrixInverseArray[sc_NumStereoViews];
uniform mat3 sc_ViewNormalMatrixArray[sc_NumStereoViews];
uniform mat3 sc_ViewNormalMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ProjectionMatrixInverseArray[sc_NumStereoViews];
uniform mat4 sc_ViewMatrixInverseArray[sc_NumStereoViews];
uniform mat3 sc_NormalMatrixInverse;
uniform mat4 sc_PrevFrameModelMatrixInverse;
uniform vec3 sc_LocalAabbMin;
uniform vec3 sc_LocalAabbMax;
uniform vec3 sc_WorldAabbMin;
uniform vec3 sc_WorldAabbMax;
uniform vec4 sc_WindowToViewportTransform;
uniform sc_Camera_t sc_Camera;
uniform mat4 sc_ProjectorMatrix;
uniform float sc_DisableFrustumCullingMarker;
uniform vec4 sc_BoneMatrices[(sc_SkinBonesCount*3)+1];
uniform mat3 sc_SkinBonesNormalMatrices[sc_SkinBonesCount+1];
uniform vec4 weights0;
uniform vec4 weights1;
uniform vec4 weights2;
uniform vec4 sc_StereoClipPlanes[sc_NumStereoViews];
uniform int sc_FallbackInstanceID;
uniform vec2 sc_TAAJitterOffset;
uniform float strandWidth;
uniform float strandTaper;
uniform vec4 sc_StrandDataMapTextureSize;
uniform float clumpInstanceCount;
uniform float clumpRadius;
uniform float clumpTipScale;
uniform float hairstyleInstanceCount;
uniform float hairstyleNoise;
uniform vec4 sc_ScreenTextureSize;
uniform vec4 sc_ScreenTextureView;
uniform vec4 z_rayDirectionsSize;
uniform vec4 z_rayDirectionsView;
uniform vec4 intensityTextureSize;
uniform vec4 intensityTextureView;
uniform float reflBlurWidth;
uniform float reflBlurMinRough;
uniform float reflBlurMaxRough;
uniform vec4 additional_settings_btn_refl_texSize;
uniform vec4 additional_settings_btn_refl_texView;
uniform vec4 iconSize;
uniform vec4 iconView;
uniform float depthRef;
uniform usampler2D z_hitIdAndBarycentric;
uniform sampler2D z_rayDirections;
uniform sampler2D additional_settings_btn_refl_tex;
uniform sampler2DArray additional_settings_btn_refl_texArrSC;
uniform sampler2D icon;
uniform sampler2DArray iconArrSC;
uniform sampler2D sc_ScreenTexture;
uniform sampler2DArray sc_ScreenTextureArrSC;
uniform sampler2D intensityTexture;
uniform sampler2DArray intensityTextureArrSC;
uniform sampler2D sc_OITFrontDepthTexture;
uniform sampler2D sc_OITDepthHigh0;
uniform sampler2D sc_OITDepthLow0;
uniform sampler2D sc_OITAlpha0;
uniform sampler2D sc_OITDepthHigh1;
uniform sampler2D sc_OITDepthLow1;
uniform sampler2D sc_OITAlpha1;
uniform sampler2D sc_OITFilteredDepthBoundsTexture;
flat in int varStereoViewID;
in vec2 varShadowTex;
in float varClipDistance;
in float varViewSpaceDepth;
in vec4 PreviewVertexColor;
in float PreviewVertexSaved;
in vec4 varTangent;
in vec3 varNormal;
in vec4 varPackedTex;
in vec3 varPos;
in vec4 varScreenPos;
in vec2 varScreenTexturePos;
in vec4 varColor;
vec3 interp_float3_animated(vec3 brc,ivec3 indices,int offset)
{
ivec3 l9_0=(indices*ivec3(6))+ivec3(offset);
int l9_1=l9_0.x;
int l9_2=l9_0.y;
int l9_3=l9_0.z;
return ((vec3(layoutVerticesPN_obj._VerticesPN[l9_1],layoutVerticesPN_obj._VerticesPN[l9_1+1],layoutVerticesPN_obj._VerticesPN[l9_1+2])*brc.x)+(vec3(layoutVerticesPN_obj._VerticesPN[l9_2],layoutVerticesPN_obj._VerticesPN[l9_2+1],layoutVerticesPN_obj._VerticesPN[l9_2+2])*brc.y))+(vec3(layoutVerticesPN_obj._VerticesPN[l9_3],layoutVerticesPN_obj._VerticesPN[l9_3+1],layoutVerticesPN_obj._VerticesPN[l9_3+2])*brc.z);
}
vec4 fetch_unorm_byte4(int offset)
{
uint l9_0=floatBitsToUint(layoutVertices_obj._Vertices[offset]);
return vec4(float(l9_0&255u),float((l9_0>>uint(8))&255u),float((l9_0>>uint(16))&255u),float((l9_0>>uint(24))&255u))/vec4(255.0);
}
RayHitPayload GetHitData(ivec2 screenPos)
{
ivec2 l9_0=screenPos;
uvec4 l9_1=texelFetch(z_hitIdAndBarycentric,l9_0,0);
uvec2 l9_2=l9_1.xy;
if (l9_1.x!=uint(instance_id))
{
return RayHitPayload(vec3(0.0),vec3(0.0),vec3(0.0),vec4(0.0),vec4(0.0),vec2(0.0),vec2(0.0),vec2(0.0),vec2(0.0),l9_2);
}
vec2 l9_3=unpackHalf2x16(l9_1.z|(l9_1.w<<uint(16)));
float l9_4=l9_3.x;
float l9_5=l9_3.y;
float l9_6=(1.0-l9_4)-l9_5;
vec3 l9_7=vec3(l9_6,l9_4,l9_5);
ivec2 l9_8=screenPos;
vec4 l9_9=texelFetch(z_rayDirections,l9_8,0);
float l9_10=l9_9.x;
float l9_11=l9_9.y;
float l9_12=(1.0-abs(l9_10))-abs(l9_11);
vec3 l9_13=vec3(l9_10,l9_11,l9_12);
float l9_14=clamp(-l9_12,0.0,1.0);
float l9_15;
if (l9_10>=0.0)
{
l9_15=-l9_14;
}
else
{
l9_15=l9_14;
}
float l9_16;
if (l9_11>=0.0)
{
l9_16=-l9_14;
}
else
{
l9_16=l9_14;
}
vec2 l9_17=vec2(l9_15,l9_16);
vec2 l9_18=l9_13.xy+l9_17;
uint l9_19=min(l9_1.y,uint(lray_triangles_last))*6u;
uint l9_20=l9_19&4294967292u;
uint l9_21=l9_20/4u;
uint l9_22=layoutIndices_obj._Triangles[l9_21];
uint l9_23=l9_21+1u;
uint l9_24=layoutIndices_obj._Triangles[l9_23];
uvec4 l9_25=(uvec4(l9_22,l9_22,l9_24,l9_24)&uvec4(65535u,4294967295u,65535u,4294967295u))>>uvec4(0u,16u,0u,16u);
ivec3 l9_26;
if (l9_19==l9_20)
{
l9_26=ivec3(l9_25.xyz);
}
else
{
l9_26=ivec3(l9_25.yzw);
}
vec3 l9_27;
if (has_animated_pn)
{
l9_27=interp_float3_animated(l9_7,l9_26,0);
}
else
{
int l9_28=(l9_26.x*emitter_stride)+proxy_offset_position;
int l9_29=(l9_26.y*emitter_stride)+proxy_offset_position;
int l9_30=(l9_26.z*emitter_stride)+proxy_offset_position;
vec3 l9_31;
if (proxy_format_position==5)
{
l9_31=((vec3(layoutVertices_obj._Vertices[l9_28],layoutVertices_obj._Vertices[l9_28+1],layoutVertices_obj._Vertices[l9_28+2])*l9_6)+(vec3(layoutVertices_obj._Vertices[l9_29],layoutVertices_obj._Vertices[l9_29+1],layoutVertices_obj._Vertices[l9_29+2])*l9_4))+(vec3(layoutVertices_obj._Vertices[l9_30],layoutVertices_obj._Vertices[l9_30+1],layoutVertices_obj._Vertices[l9_30+2])*l9_5);
}
else
{
vec3 l9_32;
if (proxy_format_position==6)
{
l9_32=((vec3(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_28])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_28+1])).x)*l9_6)+(vec3(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_29])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_29+1])).x)*l9_4))+(vec3(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_30])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_30+1])).x)*l9_5);
}
else
{
l9_32=vec3(1.0,0.0,0.0);
}
l9_31=l9_32;
}
l9_27=(sc_ModelMatrix*vec4(l9_31,1.0)).xyz;
}
vec3 l9_33;
if (proxy_offset_normal>0)
{
vec3 l9_34;
if (has_animated_pn)
{
l9_34=interp_float3_animated(l9_7,l9_26,3);
}
else
{
int l9_35=(l9_26.x*emitter_stride)+proxy_offset_normal;
int l9_36=(l9_26.y*emitter_stride)+proxy_offset_normal;
int l9_37=(l9_26.z*emitter_stride)+proxy_offset_normal;
vec3 l9_38;
if (proxy_format_normal==5)
{
l9_38=((vec3(layoutVertices_obj._Vertices[l9_35],layoutVertices_obj._Vertices[l9_35+1],layoutVertices_obj._Vertices[l9_35+2])*l9_6)+(vec3(layoutVertices_obj._Vertices[l9_36],layoutVertices_obj._Vertices[l9_36+1],layoutVertices_obj._Vertices[l9_36+2])*l9_4))+(vec3(layoutVertices_obj._Vertices[l9_37],layoutVertices_obj._Vertices[l9_37+1],layoutVertices_obj._Vertices[l9_37+2])*l9_5);
}
else
{
vec3 l9_39;
if (proxy_format_normal==6)
{
l9_39=((vec3(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_35])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_35+1])).x)*l9_6)+(vec3(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_36])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_36+1])).x)*l9_4))+(vec3(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_37])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_37+1])).x)*l9_5);
}
else
{
l9_39=vec3(1.0,0.0,0.0);
}
l9_38=l9_39;
}
l9_34=normalize(sc_NormalMatrix*l9_38);
}
l9_33=l9_34;
}
else
{
l9_33=vec3(1.0,0.0,0.0);
}
vec4 l9_40;
if ((!has_animated_pn)&&(proxy_offset_tangent>0))
{
int l9_41=(l9_26.x*emitter_stride)+proxy_offset_tangent;
int l9_42=(l9_26.y*emitter_stride)+proxy_offset_tangent;
int l9_43=(l9_26.z*emitter_stride)+proxy_offset_tangent;
vec4 l9_44;
if (proxy_format_tangent==5)
{
l9_44=((vec4(layoutVertices_obj._Vertices[l9_41],layoutVertices_obj._Vertices[l9_41+1],layoutVertices_obj._Vertices[l9_41+2],layoutVertices_obj._Vertices[l9_41+3])*l9_6)+(vec4(layoutVertices_obj._Vertices[l9_42],layoutVertices_obj._Vertices[l9_42+1],layoutVertices_obj._Vertices[l9_42+2],layoutVertices_obj._Vertices[l9_42+3])*l9_4))+(vec4(layoutVertices_obj._Vertices[l9_43],layoutVertices_obj._Vertices[l9_43+1],layoutVertices_obj._Vertices[l9_43+2],layoutVertices_obj._Vertices[l9_43+3])*l9_5);
}
else
{
vec4 l9_45;
if (proxy_format_tangent==6)
{
l9_45=((vec4(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_41])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_41+1])))*l9_6)+(vec4(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_42])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_42+1])))*l9_4))+(vec4(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_43])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_43+1])))*l9_5);
}
else
{
vec4 l9_46;
if (proxy_format_tangent==2)
{
l9_46=((fetch_unorm_byte4(l9_41)*l9_6)+(fetch_unorm_byte4(l9_42)*l9_4))+(fetch_unorm_byte4(l9_43)*l9_5);
}
else
{
l9_46=vec4(1.0,0.0,0.0,0.0);
}
l9_45=l9_46;
}
l9_44=l9_45;
}
l9_40=vec4(normalize(sc_NormalMatrix*l9_44.xyz),l9_44.w);
}
else
{
l9_40=vec4(1.0,0.0,0.0,1.0);
}
vec4 l9_47;
if (proxy_format_color>0)
{
int l9_48=(l9_26.x*emitter_stride)+proxy_offset_color;
int l9_49=(l9_26.y*emitter_stride)+proxy_offset_color;
int l9_50=(l9_26.z*emitter_stride)+proxy_offset_color;
vec4 l9_51;
if (proxy_format_color==5)
{
l9_51=((vec4(layoutVertices_obj._Vertices[l9_48],layoutVertices_obj._Vertices[l9_48+1],layoutVertices_obj._Vertices[l9_48+2],layoutVertices_obj._Vertices[l9_48+3])*l9_6)+(vec4(layoutVertices_obj._Vertices[l9_49],layoutVertices_obj._Vertices[l9_49+1],layoutVertices_obj._Vertices[l9_49+2],layoutVertices_obj._Vertices[l9_49+3])*l9_4))+(vec4(layoutVertices_obj._Vertices[l9_50],layoutVertices_obj._Vertices[l9_50+1],layoutVertices_obj._Vertices[l9_50+2],layoutVertices_obj._Vertices[l9_50+3])*l9_5);
}
else
{
vec4 l9_52;
if (proxy_format_color==6)
{
l9_52=((vec4(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_48])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_48+1])))*l9_6)+(vec4(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_49])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_49+1])))*l9_4))+(vec4(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_50])),unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_50+1])))*l9_5);
}
else
{
vec4 l9_53;
if (proxy_format_color==2)
{
l9_53=((fetch_unorm_byte4(l9_48)*l9_6)+(fetch_unorm_byte4(l9_49)*l9_4))+(fetch_unorm_byte4(l9_50)*l9_5);
}
else
{
l9_53=vec4(1.0,0.0,0.0,0.0);
}
l9_52=l9_53;
}
l9_51=l9_52;
}
l9_47=l9_51;
}
else
{
l9_47=vec4(0.0);
}
ivec3 l9_54=l9_26%ivec3(2);
vec2 l9_55=vec2(dot(l9_7,vec3(ivec3(1)-l9_54)),0.0);
vec2 l9_56;
if (proxy_format_texture0>0)
{
int l9_57=(l9_26.x*emitter_stride)+proxy_offset_texture0;
int l9_58=(l9_26.y*emitter_stride)+proxy_offset_texture0;
int l9_59=(l9_26.z*emitter_stride)+proxy_offset_texture0;
vec2 l9_60;
if (proxy_format_texture0==5)
{
l9_60=((vec2(layoutVertices_obj._Vertices[l9_57],layoutVertices_obj._Vertices[l9_57+1])*l9_6)+(vec2(layoutVertices_obj._Vertices[l9_58],layoutVertices_obj._Vertices[l9_58+1])*l9_4))+(vec2(layoutVertices_obj._Vertices[l9_59],layoutVertices_obj._Vertices[l9_59+1])*l9_5);
}
else
{
vec2 l9_61;
if (proxy_format_texture0==6)
{
l9_61=((unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_57]))*l9_6)+(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_58]))*l9_4))+(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_59]))*l9_5);
}
else
{
l9_61=vec2(1.0,0.0);
}
l9_60=l9_61;
}
l9_56=l9_60;
}
else
{
l9_56=l9_55;
}
vec2 l9_62;
if (proxy_format_texture1>0)
{
int l9_63=(l9_26.x*emitter_stride)+proxy_offset_texture1;
int l9_64=(l9_26.y*emitter_stride)+proxy_offset_texture1;
int l9_65=(l9_26.z*emitter_stride)+proxy_offset_texture1;
vec2 l9_66;
if (proxy_format_texture1==5)
{
l9_66=((vec2(layoutVertices_obj._Vertices[l9_63],layoutVertices_obj._Vertices[l9_63+1])*l9_6)+(vec2(layoutVertices_obj._Vertices[l9_64],layoutVertices_obj._Vertices[l9_64+1])*l9_4))+(vec2(layoutVertices_obj._Vertices[l9_65],layoutVertices_obj._Vertices[l9_65+1])*l9_5);
}
else
{
vec2 l9_67;
if (proxy_format_texture1==6)
{
l9_67=((unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_63]))*l9_6)+(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_64]))*l9_4))+(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_65]))*l9_5);
}
else
{
l9_67=vec2(1.0,0.0);
}
l9_66=l9_67;
}
l9_62=l9_66;
}
else
{
l9_62=l9_55;
}
vec2 l9_68;
if (proxy_format_texture2>0)
{
int l9_69=(l9_26.x*emitter_stride)+proxy_offset_texture2;
int l9_70=(l9_26.y*emitter_stride)+proxy_offset_texture2;
int l9_71=(l9_26.z*emitter_stride)+proxy_offset_texture2;
vec2 l9_72;
if (proxy_format_texture2==5)
{
l9_72=((vec2(layoutVertices_obj._Vertices[l9_69],layoutVertices_obj._Vertices[l9_69+1])*l9_6)+(vec2(layoutVertices_obj._Vertices[l9_70],layoutVertices_obj._Vertices[l9_70+1])*l9_4))+(vec2(layoutVertices_obj._Vertices[l9_71],layoutVertices_obj._Vertices[l9_71+1])*l9_5);
}
else
{
vec2 l9_73;
if (proxy_format_texture2==6)
{
l9_73=((unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_69]))*l9_6)+(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_70]))*l9_4))+(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_71]))*l9_5);
}
else
{
l9_73=vec2(1.0,0.0);
}
l9_72=l9_73;
}
l9_68=l9_72;
}
else
{
l9_68=l9_55;
}
vec2 l9_74;
if (proxy_format_texture3>0)
{
int l9_75=(l9_26.x*emitter_stride)+proxy_offset_texture3;
int l9_76=(l9_26.y*emitter_stride)+proxy_offset_texture3;
int l9_77=(l9_26.z*emitter_stride)+proxy_offset_texture3;
vec2 l9_78;
if (proxy_format_texture3==5)
{
l9_78=((vec2(layoutVertices_obj._Vertices[l9_75],layoutVertices_obj._Vertices[l9_75+1])*l9_6)+(vec2(layoutVertices_obj._Vertices[l9_76],layoutVertices_obj._Vertices[l9_76+1])*l9_4))+(vec2(layoutVertices_obj._Vertices[l9_77],layoutVertices_obj._Vertices[l9_77+1])*l9_5);
}
else
{
vec2 l9_79;
if (proxy_format_texture3==6)
{
l9_79=((unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_75]))*l9_6)+(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_76]))*l9_4))+(unpackHalf2x16(floatBitsToUint(layoutVertices_obj._Vertices[l9_77]))*l9_5);
}
else
{
l9_79=vec2(1.0,0.0);
}
l9_78=l9_79;
}
l9_74=l9_78;
}
else
{
l9_74=l9_55;
}
return RayHitPayload(-normalize(vec3(l9_18.x,l9_18.y,l9_13.z)),l9_27,l9_33,l9_40,l9_47,l9_56,l9_62,l9_68,l9_74,l9_2);
}
int sc_GetStereoViewIndex()
{
int l9_0;
#if (sc_StereoRenderingMode==0)
{
l9_0=0;
}
#else
{
l9_0=varStereoViewID;
}
#endif
return l9_0;
}
int additional_settings_btn_refl_texGetStereoViewIndex()
{
int l9_0;
#if (additional_settings_btn_refl_texHasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
void sc_SoftwareWrapEarly(inout float uv,int softwareWrapMode)
{
if (softwareWrapMode==1)
{
uv=fract(uv);
}
else
{
if (softwareWrapMode==2)
{
float l9_0=fract(uv);
uv=mix(l9_0,1.0-l9_0,clamp(step(0.25,fract((uv-l9_0)*0.5)),0.0,1.0));
}
}
}
void sc_ClampUV(inout float value,float minValue,float maxValue,bool useClampToBorder,inout float clampToBorderFactor)
{
float l9_0=clamp(value,minValue,maxValue);
float l9_1=step(abs(value-l9_0),9.9999997e-06);
clampToBorderFactor*=(l9_1+((1.0-float(useClampToBorder))*(1.0-l9_1)));
value=l9_0;
}
vec2 sc_TransformUV(vec2 uv,bool useUvTransform,mat3 uvTransform)
{
if (useUvTransform)
{
uv=vec2((uvTransform*vec3(uv,1.0)).xy);
}
return uv;
}
void sc_SoftwareWrapLate(inout float uv,int softwareWrapMode,bool useClampToBorder,inout float clampToBorderFactor)
{
if ((softwareWrapMode==0)||(softwareWrapMode==3))
{
sc_ClampUV(uv,0.0,1.0,useClampToBorder,clampToBorderFactor);
}
}
vec3 sc_SamplingCoordsViewToGlobal(vec2 uv,int renderingLayout,int viewIndex)
{
vec3 l9_0;
if (renderingLayout==0)
{
l9_0=vec3(uv,0.0);
}
else
{
vec3 l9_1;
if (renderingLayout==1)
{
l9_1=vec3(uv.x,(uv.y*0.5)+(0.5-(float(viewIndex)*0.5)),0.0);
}
else
{
l9_1=vec3(uv,float(viewIndex));
}
l9_0=l9_1;
}
return l9_0;
}
int iconGetStereoViewIndex()
{
int l9_0;
#if (iconHasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
void sc_writeFragData0(vec4 col)
{
    col.x+=sc_UniformConstants.x*float(sc_ShaderCacheConstant);
    sc_FragData0=col;
}
vec2 sc_SamplingCoordsGlobalToView(vec3 uvi,int renderingLayout,int viewIndex)
{
if (renderingLayout==1)
{
uvi.y=((2.0*uvi.y)+float(viewIndex))-1.0;
}
return uvi.xy;
}
vec2 sc_ScreenCoordsGlobalToView(vec2 uv)
{
vec2 l9_0;
#if (sc_StereoRenderingMode==1)
{
l9_0=sc_SamplingCoordsGlobalToView(vec3(uv,0.0),1,sc_GetStereoViewIndex());
}
#else
{
l9_0=uv;
}
#endif
return l9_0;
}
vec4 sc_readFragData0_Platform()
{
    return getFragData()[0];
}
int intensityTextureGetStereoViewIndex()
{
int l9_0;
#if (intensityTextureHasSwappedViews)
{
l9_0=1-sc_GetStereoViewIndex();
}
#else
{
l9_0=sc_GetStereoViewIndex();
}
#endif
return l9_0;
}
float transformSingleColor(float original,float intMap,float target)
{
#if ((BLEND_MODE_REALISTIC||BLEND_MODE_FORGRAY)||BLEND_MODE_NOTBRIGHT)
{
return original/pow(1.0-target,intMap);
}
#else
{
#if (BLEND_MODE_DIVISION)
{
return original/(1.0-target);
}
#else
{
#if (BLEND_MODE_BRIGHT)
{
return original/pow(1.0-target,2.0-(2.0*original));
}
#endif
}
#endif
}
#endif
return 0.0;
}
vec3 RGBtoHCV(vec3 rgb)
{
vec4 l9_0;
if (rgb.y<rgb.z)
{
l9_0=vec4(rgb.zy,-1.0,0.66666669);
}
else
{
l9_0=vec4(rgb.yz,0.0,-0.33333334);
}
vec4 l9_1;
if (rgb.x<l9_0.x)
{
l9_1=vec4(l9_0.xyw,rgb.x);
}
else
{
l9_1=vec4(rgb.x,l9_0.yzx);
}
float l9_2=l9_1.x-min(l9_1.w,l9_1.y);
return vec3(abs(((l9_1.w-l9_1.y)/((6.0*l9_2)+1e-07))+l9_1.z),l9_2,l9_1.x);
}
vec3 RGBToHSL(vec3 rgb)
{
vec3 l9_0=RGBtoHCV(rgb);
float l9_1=l9_0.y;
float l9_2=l9_0.z-(l9_1*0.5);
return vec3(l9_0.x,l9_1/((1.0-abs((2.0*l9_2)-1.0))+1e-07),l9_2);
}
vec3 HUEtoRGB(float hue)
{
return clamp(vec3(abs((6.0*hue)-3.0)-1.0,2.0-abs((6.0*hue)-2.0),2.0-abs((6.0*hue)-4.0)),vec3(0.0),vec3(1.0));
}
vec3 HSLToRGB(vec3 hsl)
{
return ((HUEtoRGB(hsl.x)-vec3(0.5))*((1.0-abs((2.0*hsl.z)-1.0))*hsl.y))+vec3(hsl.z);
}
vec3 transformColor(float yValue,vec3 original,vec3 target,float weight,float intMap)
{
#if (BLEND_MODE_INTENSE)
{
return mix(original,HSLToRGB(vec3(target.x,target.y,RGBToHSL(original).z)),vec3(weight));
}
#else
{
return mix(original,clamp(vec3(transformSingleColor(yValue,intMap,target.x),transformSingleColor(yValue,intMap,target.y),transformSingleColor(yValue,intMap,target.z)),vec3(0.0),vec3(1.0)),vec3(weight));
}
#endif
}
vec3 definedBlend(vec3 a,vec3 b)
{
#if (BLEND_MODE_LIGHTEN)
{
return max(a,b);
}
#else
{
#if (BLEND_MODE_DARKEN)
{
return min(a,b);
}
#else
{
#if (BLEND_MODE_DIVIDE)
{
return b/a;
}
#else
{
#if (BLEND_MODE_AVERAGE)
{
return (a+b)*0.5;
}
#else
{
#if (BLEND_MODE_SUBTRACT)
{
return max((a+b)-vec3(1.0),vec3(0.0));
}
#else
{
#if (BLEND_MODE_DIFFERENCE)
{
return abs(a-b);
}
#else
{
#if (BLEND_MODE_NEGATION)
{
return vec3(1.0)-abs((vec3(1.0)-a)-b);
}
#else
{
#if (BLEND_MODE_EXCLUSION)
{
return (a+b)-((a*2.0)*b);
}
#else
{
#if (BLEND_MODE_OVERLAY)
{
float l9_0;
if (a.x<0.5)
{
l9_0=(2.0*a.x)*b.x;
}
else
{
l9_0=1.0-((2.0*(1.0-a.x))*(1.0-b.x));
}
float l9_1;
if (a.y<0.5)
{
l9_1=(2.0*a.y)*b.y;
}
else
{
l9_1=1.0-((2.0*(1.0-a.y))*(1.0-b.y));
}
float l9_2;
if (a.z<0.5)
{
l9_2=(2.0*a.z)*b.z;
}
else
{
l9_2=1.0-((2.0*(1.0-a.z))*(1.0-b.z));
}
return vec3(l9_0,l9_1,l9_2);
}
#else
{
#if (BLEND_MODE_SOFT_LIGHT)
{
return (((vec3(1.0)-(b*2.0))*a)*a)+((a*2.0)*b);
}
#else
{
#if (BLEND_MODE_HARD_LIGHT)
{
float l9_3;
if (b.x<0.5)
{
l9_3=(2.0*b.x)*a.x;
}
else
{
l9_3=1.0-((2.0*(1.0-b.x))*(1.0-a.x));
}
float l9_4;
if (b.y<0.5)
{
l9_4=(2.0*b.y)*a.y;
}
else
{
l9_4=1.0-((2.0*(1.0-b.y))*(1.0-a.y));
}
float l9_5;
if (b.z<0.5)
{
l9_5=(2.0*b.z)*a.z;
}
else
{
l9_5=1.0-((2.0*(1.0-b.z))*(1.0-a.z));
}
return vec3(l9_3,l9_4,l9_5);
}
#else
{
#if (BLEND_MODE_COLOR_DODGE)
{
float l9_6;
if (b.x==1.0)
{
l9_6=b.x;
}
else
{
l9_6=min(a.x/(1.0-b.x),1.0);
}
float l9_7;
if (b.y==1.0)
{
l9_7=b.y;
}
else
{
l9_7=min(a.y/(1.0-b.y),1.0);
}
float l9_8;
if (b.z==1.0)
{
l9_8=b.z;
}
else
{
l9_8=min(a.z/(1.0-b.z),1.0);
}
return vec3(l9_6,l9_7,l9_8);
}
#else
{
#if (BLEND_MODE_COLOR_BURN)
{
float l9_9;
if (b.x==0.0)
{
l9_9=b.x;
}
else
{
l9_9=max(1.0-((1.0-a.x)/b.x),0.0);
}
float l9_10;
if (b.y==0.0)
{
l9_10=b.y;
}
else
{
l9_10=max(1.0-((1.0-a.y)/b.y),0.0);
}
float l9_11;
if (b.z==0.0)
{
l9_11=b.z;
}
else
{
l9_11=max(1.0-((1.0-a.z)/b.z),0.0);
}
return vec3(l9_9,l9_10,l9_11);
}
#else
{
#if (BLEND_MODE_LINEAR_LIGHT)
{
float l9_12;
if (b.x<0.5)
{
l9_12=max((a.x+(2.0*b.x))-1.0,0.0);
}
else
{
l9_12=min(a.x+(2.0*(b.x-0.5)),1.0);
}
float l9_13;
if (b.y<0.5)
{
l9_13=max((a.y+(2.0*b.y))-1.0,0.0);
}
else
{
l9_13=min(a.y+(2.0*(b.y-0.5)),1.0);
}
float l9_14;
if (b.z<0.5)
{
l9_14=max((a.z+(2.0*b.z))-1.0,0.0);
}
else
{
l9_14=min(a.z+(2.0*(b.z-0.5)),1.0);
}
return vec3(l9_12,l9_13,l9_14);
}
#else
{
#if (BLEND_MODE_VIVID_LIGHT)
{
float l9_15;
if (b.x<0.5)
{
float l9_16;
if ((2.0*b.x)==0.0)
{
l9_16=2.0*b.x;
}
else
{
l9_16=max(1.0-((1.0-a.x)/(2.0*b.x)),0.0);
}
l9_15=l9_16;
}
else
{
float l9_17;
if ((2.0*(b.x-0.5))==1.0)
{
l9_17=2.0*(b.x-0.5);
}
else
{
l9_17=min(a.x/(1.0-(2.0*(b.x-0.5))),1.0);
}
l9_15=l9_17;
}
float l9_18;
if (b.y<0.5)
{
float l9_19;
if ((2.0*b.y)==0.0)
{
l9_19=2.0*b.y;
}
else
{
l9_19=max(1.0-((1.0-a.y)/(2.0*b.y)),0.0);
}
l9_18=l9_19;
}
else
{
float l9_20;
if ((2.0*(b.y-0.5))==1.0)
{
l9_20=2.0*(b.y-0.5);
}
else
{
l9_20=min(a.y/(1.0-(2.0*(b.y-0.5))),1.0);
}
l9_18=l9_20;
}
float l9_21;
if (b.z<0.5)
{
float l9_22;
if ((2.0*b.z)==0.0)
{
l9_22=2.0*b.z;
}
else
{
l9_22=max(1.0-((1.0-a.z)/(2.0*b.z)),0.0);
}
l9_21=l9_22;
}
else
{
float l9_23;
if ((2.0*(b.z-0.5))==1.0)
{
l9_23=2.0*(b.z-0.5);
}
else
{
l9_23=min(a.z/(1.0-(2.0*(b.z-0.5))),1.0);
}
l9_21=l9_23;
}
return vec3(l9_15,l9_18,l9_21);
}
#else
{
#if (BLEND_MODE_PIN_LIGHT)
{
float l9_24;
if (b.x<0.5)
{
l9_24=min(a.x,2.0*b.x);
}
else
{
l9_24=max(a.x,2.0*(b.x-0.5));
}
float l9_25;
if (b.y<0.5)
{
l9_25=min(a.y,2.0*b.y);
}
else
{
l9_25=max(a.y,2.0*(b.y-0.5));
}
float l9_26;
if (b.z<0.5)
{
l9_26=min(a.z,2.0*b.z);
}
else
{
l9_26=max(a.z,2.0*(b.z-0.5));
}
return vec3(l9_24,l9_25,l9_26);
}
#else
{
#if (BLEND_MODE_HARD_MIX)
{
float l9_27;
if (b.x<0.5)
{
float l9_28;
if ((2.0*b.x)==0.0)
{
l9_28=2.0*b.x;
}
else
{
l9_28=max(1.0-((1.0-a.x)/(2.0*b.x)),0.0);
}
l9_27=l9_28;
}
else
{
float l9_29;
if ((2.0*(b.x-0.5))==1.0)
{
l9_29=2.0*(b.x-0.5);
}
else
{
l9_29=min(a.x/(1.0-(2.0*(b.x-0.5))),1.0);
}
l9_27=l9_29;
}
bool l9_30=l9_27<0.5;
float l9_31;
if (b.y<0.5)
{
float l9_32;
if ((2.0*b.y)==0.0)
{
l9_32=2.0*b.y;
}
else
{
l9_32=max(1.0-((1.0-a.y)/(2.0*b.y)),0.0);
}
l9_31=l9_32;
}
else
{
float l9_33;
if ((2.0*(b.y-0.5))==1.0)
{
l9_33=2.0*(b.y-0.5);
}
else
{
l9_33=min(a.y/(1.0-(2.0*(b.y-0.5))),1.0);
}
l9_31=l9_33;
}
bool l9_34=l9_31<0.5;
float l9_35;
if (b.z<0.5)
{
float l9_36;
if ((2.0*b.z)==0.0)
{
l9_36=2.0*b.z;
}
else
{
l9_36=max(1.0-((1.0-a.z)/(2.0*b.z)),0.0);
}
l9_35=l9_36;
}
else
{
float l9_37;
if ((2.0*(b.z-0.5))==1.0)
{
l9_37=2.0*(b.z-0.5);
}
else
{
l9_37=min(a.z/(1.0-(2.0*(b.z-0.5))),1.0);
}
l9_35=l9_37;
}
return vec3(l9_30 ? 0.0 : 1.0,l9_34 ? 0.0 : 1.0,(l9_35<0.5) ? 0.0 : 1.0);
}
#else
{
#if (BLEND_MODE_HARD_REFLECT)
{
float l9_38;
if (b.x==1.0)
{
l9_38=b.x;
}
else
{
l9_38=min((a.x*a.x)/(1.0-b.x),1.0);
}
float l9_39;
if (b.y==1.0)
{
l9_39=b.y;
}
else
{
l9_39=min((a.y*a.y)/(1.0-b.y),1.0);
}
float l9_40;
if (b.z==1.0)
{
l9_40=b.z;
}
else
{
l9_40=min((a.z*a.z)/(1.0-b.z),1.0);
}
return vec3(l9_38,l9_39,l9_40);
}
#else
{
#if (BLEND_MODE_HARD_GLOW)
{
float l9_41;
if (a.x==1.0)
{
l9_41=a.x;
}
else
{
l9_41=min((b.x*b.x)/(1.0-a.x),1.0);
}
float l9_42;
if (a.y==1.0)
{
l9_42=a.y;
}
else
{
l9_42=min((b.y*b.y)/(1.0-a.y),1.0);
}
float l9_43;
if (a.z==1.0)
{
l9_43=a.z;
}
else
{
l9_43=min((b.z*b.z)/(1.0-a.z),1.0);
}
return vec3(l9_41,l9_42,l9_43);
}
#else
{
#if (BLEND_MODE_HARD_PHOENIX)
{
return (min(a,b)-max(a,b))+vec3(1.0);
}
#else
{
#if (BLEND_MODE_HUE)
{
return HSLToRGB(vec3(RGBToHSL(b).x,RGBToHSL(a).yz));
}
#else
{
#if (BLEND_MODE_SATURATION)
{
vec3 l9_44=RGBToHSL(a);
return HSLToRGB(vec3(l9_44.x,RGBToHSL(b).y,l9_44.z));
}
#else
{
#if (BLEND_MODE_COLOR)
{
return HSLToRGB(vec3(RGBToHSL(b).xy,RGBToHSL(a).z));
}
#else
{
#if (BLEND_MODE_LUMINOSITY)
{
return HSLToRGB(vec3(RGBToHSL(a).xy,RGBToHSL(b).z));
}
#else
{
vec3 l9_45=a;
vec3 l9_46=b;
float l9_47=((0.29899999*l9_45.x)+(0.58700001*l9_45.y))+(0.114*l9_45.z);
float l9_48=pow(l9_47,1.0/correctedIntensity);
vec4 l9_49;
#if (intensityTextureLayout==2)
{
float l9_50=l9_48;
sc_SoftwareWrapEarly(l9_50,ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).x);
float l9_51=l9_50;
float l9_52=0.5;
sc_SoftwareWrapEarly(l9_52,ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).y);
float l9_53=l9_52;
vec2 l9_54;
float l9_55;
#if (SC_USE_UV_MIN_MAX_intensityTexture)
{
bool l9_56;
#if (SC_USE_CLAMP_TO_BORDER_intensityTexture)
{
l9_56=ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).x==3;
}
#else
{
l9_56=(int(SC_USE_CLAMP_TO_BORDER_intensityTexture)!=0);
}
#endif
float l9_57=l9_51;
float l9_58=1.0;
sc_ClampUV(l9_57,intensityTextureUvMinMax.x,intensityTextureUvMinMax.z,l9_56,l9_58);
float l9_59=l9_57;
float l9_60=l9_58;
bool l9_61;
#if (SC_USE_CLAMP_TO_BORDER_intensityTexture)
{
l9_61=ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).y==3;
}
#else
{
l9_61=(int(SC_USE_CLAMP_TO_BORDER_intensityTexture)!=0);
}
#endif
float l9_62=l9_53;
float l9_63=l9_60;
sc_ClampUV(l9_62,intensityTextureUvMinMax.y,intensityTextureUvMinMax.w,l9_61,l9_63);
l9_55=l9_63;
l9_54=vec2(l9_59,l9_62);
}
#else
{
l9_55=1.0;
l9_54=vec2(l9_51,l9_53);
}
#endif
vec2 l9_64=sc_TransformUV(l9_54,(int(SC_USE_UV_TRANSFORM_intensityTexture)!=0),intensityTextureTransform);
float l9_65=l9_64.x;
float l9_66=l9_55;
sc_SoftwareWrapLate(l9_65,ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).x,(int(SC_USE_CLAMP_TO_BORDER_intensityTexture)!=0)&&(!(int(SC_USE_UV_MIN_MAX_intensityTexture)!=0)),l9_66);
float l9_67=l9_64.y;
float l9_68=l9_66;
sc_SoftwareWrapLate(l9_67,ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).y,(int(SC_USE_CLAMP_TO_BORDER_intensityTexture)!=0)&&(!(int(SC_USE_UV_MIN_MAX_intensityTexture)!=0)),l9_68);
float l9_69=l9_68;
vec3 l9_70=sc_SamplingCoordsViewToGlobal(vec2(l9_65,l9_67),intensityTextureLayout,intensityTextureGetStereoViewIndex());
vec4 l9_71=texture(intensityTextureArrSC,l9_70,0.0);
vec4 l9_72;
#if (SC_USE_CLAMP_TO_BORDER_intensityTexture)
{
l9_72=mix(intensityTextureBorderColor,l9_71,vec4(l9_69));
}
#else
{
l9_72=l9_71;
}
#endif
l9_49=l9_72;
}
#else
{
float l9_73=l9_48;
sc_SoftwareWrapEarly(l9_73,ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).x);
float l9_74=l9_73;
float l9_75=0.5;
sc_SoftwareWrapEarly(l9_75,ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).y);
float l9_76=l9_75;
vec2 l9_77;
float l9_78;
#if (SC_USE_UV_MIN_MAX_intensityTexture)
{
bool l9_79;
#if (SC_USE_CLAMP_TO_BORDER_intensityTexture)
{
l9_79=ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).x==3;
}
#else
{
l9_79=(int(SC_USE_CLAMP_TO_BORDER_intensityTexture)!=0);
}
#endif
float l9_80=l9_74;
float l9_81=1.0;
sc_ClampUV(l9_80,intensityTextureUvMinMax.x,intensityTextureUvMinMax.z,l9_79,l9_81);
float l9_82=l9_80;
float l9_83=l9_81;
bool l9_84;
#if (SC_USE_CLAMP_TO_BORDER_intensityTexture)
{
l9_84=ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).y==3;
}
#else
{
l9_84=(int(SC_USE_CLAMP_TO_BORDER_intensityTexture)!=0);
}
#endif
float l9_85=l9_76;
float l9_86=l9_83;
sc_ClampUV(l9_85,intensityTextureUvMinMax.y,intensityTextureUvMinMax.w,l9_84,l9_86);
l9_78=l9_86;
l9_77=vec2(l9_82,l9_85);
}
#else
{
l9_78=1.0;
l9_77=vec2(l9_74,l9_76);
}
#endif
vec2 l9_87=sc_TransformUV(l9_77,(int(SC_USE_UV_TRANSFORM_intensityTexture)!=0),intensityTextureTransform);
float l9_88=l9_87.x;
float l9_89=l9_78;
sc_SoftwareWrapLate(l9_88,ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).x,(int(SC_USE_CLAMP_TO_BORDER_intensityTexture)!=0)&&(!(int(SC_USE_UV_MIN_MAX_intensityTexture)!=0)),l9_89);
float l9_90=l9_87.y;
float l9_91=l9_89;
sc_SoftwareWrapLate(l9_90,ivec2(SC_SOFTWARE_WRAP_MODE_U_intensityTexture,SC_SOFTWARE_WRAP_MODE_V_intensityTexture).y,(int(SC_USE_CLAMP_TO_BORDER_intensityTexture)!=0)&&(!(int(SC_USE_UV_MIN_MAX_intensityTexture)!=0)),l9_91);
float l9_92=l9_91;
vec3 l9_93=sc_SamplingCoordsViewToGlobal(vec2(l9_88,l9_90),intensityTextureLayout,intensityTextureGetStereoViewIndex());
vec4 l9_94=texture(intensityTexture,l9_93.xy,0.0);
vec4 l9_95;
#if (SC_USE_CLAMP_TO_BORDER_intensityTexture)
{
l9_95=mix(intensityTextureBorderColor,l9_94,vec4(l9_92));
}
#else
{
l9_95=l9_94;
}
#endif
l9_49=l9_95;
}
#endif
float l9_96=((((l9_49.x*256.0)+l9_49.y)+(l9_49.z/256.0))/257.00391)*16.0;
float l9_97;
#if (BLEND_MODE_FORGRAY)
{
l9_97=max(l9_96,1.0);
}
#else
{
l9_97=l9_96;
}
#endif
float l9_98;
#if (BLEND_MODE_NOTBRIGHT)
{
l9_98=min(l9_97,1.0);
}
#else
{
l9_98=l9_97;
}
#endif
return transformColor(l9_47,l9_45,l9_46,1.0,l9_98);
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
vec4 outputMotionVectorsIfNeeded(vec3 surfacePosWorldSpace,vec4 finalColor)
{
#if (sc_MotionVectorsPass)
{
vec4 l9_0=vec4(surfacePosWorldSpace,1.0);
vec4 l9_1=sc_ViewProjectionMatrixArray[sc_GetStereoViewIndex()]*l9_0;
vec4 l9_2=((sc_PrevFrameViewProjectionMatrixArray[sc_GetStereoViewIndex()]*sc_PrevFrameModelMatrix)*sc_ModelMatrixInverse)*l9_0;
vec2 l9_3=((l9_1.xy/vec2(l9_1.w)).xy-(l9_2.xy/vec2(l9_2.w)).xy)*0.5;
float l9_4=floor(((l9_3.x*5.0)+0.5)*65535.0);
float l9_5=floor(l9_4*0.00390625);
float l9_6=floor(((l9_3.y*5.0)+0.5)*65535.0);
float l9_7=floor(l9_6*0.00390625);
return vec4(l9_5/255.0,(l9_4-(l9_5*256.0))/255.0,l9_7/255.0,(l9_6-(l9_7*256.0))/255.0);
}
#else
{
return finalColor;
}
#endif
}
float getFrontLayerZTestEpsilon()
{
#if (sc_SkinBonesCount>0)
{
return 5e-07;
}
#else
{
return 5.0000001e-08;
}
#endif
}
void unpackValues(float channel,int passIndex,inout int values[8])
{
#if (sc_OITCompositingPass)
{
channel=floor((channel*255.0)+0.5);
int l9_0=((passIndex+1)*4)-1;
for (int snapLoopIndex=0; snapLoopIndex==0; snapLoopIndex+=0)
{
if (l9_0>=(passIndex*4))
{
values[l9_0]=(values[l9_0]*4)+int(floor(mod(channel,4.0)));
channel=floor(channel/4.0);
l9_0--;
continue;
}
else
{
break;
}
}
}
#endif
}
float getDepthOrderingEpsilon()
{
#if (sc_SkinBonesCount>0)
{
return 0.001;
}
#else
{
return 0.0;
}
#endif
}
int encodeDepth(float depth,vec2 depthBounds)
{
float l9_0=(1.0-depthBounds.x)*1000.0;
return int(clamp((depth-l9_0)/((depthBounds.y*1000.0)-l9_0),0.0,1.0)*65535.0);
}
float viewSpaceDepth()
{
#if (UseViewSpaceDepthVariant&&((sc_OITDepthGatherPass||sc_OITCompositingPass)||sc_OITDepthBoundsPass))
{
return varViewSpaceDepth;
}
#else
{
return sc_ProjectionMatrixArray[sc_GetStereoViewIndex()][3].z/(sc_ProjectionMatrixArray[sc_GetStereoViewIndex()][2].z+((gl_FragCoord.z*2.0)-1.0));
}
#endif
}
float packValue(inout int value)
{
#if (sc_OITDepthGatherPass)
{
int l9_0=value;
value/=4;
return floor(floor(mod(float(l9_0),4.0))*64.0)/255.0;
}
#else
{
return 0.0;
}
#endif
}
void sc_writeFragData1(vec4 col)
{
#if sc_FragDataCount>=2
    sc_FragData1=col;
#endif
}
void sc_writeFragData2(vec4 col)
{
#if sc_FragDataCount>=3
    sc_FragData2=col;
#endif
}
void main()
{
#if (sc_DepthOnly)
{
return;
}
#endif
#if ((sc_StereoRenderingMode==1)&&(sc_StereoRendering_IsClipDistanceEnabled==0))
{
if (varClipDistance<0.0)
{
discard;
}
}
#endif
bool l9_0=((PreviewVertexSaved*1.0)!=0.0) ? true : false;
vec3 l9_1;
vec3 l9_2;
vec3 l9_3;
vec2 l9_4;
vec2 l9_5;
if (isProxyMode)
{
RayHitPayload l9_6=GetHitData(ivec2(gl_FragCoord.xy));
vec3 l9_7=l9_6.normalWS;
vec4 l9_8=l9_6.tangentWS;
if (noEarlyZ)
{
if (l9_6.id.x!=uint(instance_id))
{
return;
}
}
vec3 l9_9=l9_8.xyz;
l9_5=l9_6.uv1;
l9_4=l9_6.uv0;
l9_3=l9_7;
l9_2=cross(l9_7,l9_9)*l9_8.w;
l9_1=l9_9;
}
else
{
vec3 l9_10=normalize(varTangent.xyz);
vec3 l9_11=normalize(varNormal);
l9_5=varPackedTex.zw;
l9_4=varPackedTex.xy;
l9_3=l9_11;
l9_2=cross(l9_11,l9_10)*varTangent.w;
l9_1=l9_10;
}
mat3 l9_12=mat3(l9_1,l9_2,l9_3);
vec3 l9_13=l9_12*Port_Import_N049;
float l9_14=dot(l9_13,l9_13);
float l9_15;
if (l9_14>0.0)
{
l9_15=1.0/sqrt(l9_14);
}
else
{
l9_15=0.0;
}
vec3 l9_16=l9_13*l9_15;
vec3 l9_17=((sc_ViewMatrixArray[sc_GetStereoViewIndex()]*vec4(l9_16,0.0)).xyz*vec3(Port_Input1_N053))+vec3(Port_Input2_N053);
vec4 l9_18;
#if (additional_settings_btn_refl_texLayout==2)
{
float l9_19=l9_17.x;
sc_SoftwareWrapEarly(l9_19,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x);
float l9_20=l9_19;
float l9_21=l9_17.y;
sc_SoftwareWrapEarly(l9_21,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y);
float l9_22=l9_21;
vec2 l9_23;
float l9_24;
#if (SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)
{
bool l9_25;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_25=ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x==3;
}
#else
{
l9_25=(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0);
}
#endif
float l9_26=l9_20;
float l9_27=1.0;
sc_ClampUV(l9_26,additional_settings_btn_refl_texUvMinMax.x,additional_settings_btn_refl_texUvMinMax.z,l9_25,l9_27);
float l9_28=l9_26;
float l9_29=l9_27;
bool l9_30;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_30=ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y==3;
}
#else
{
l9_30=(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0);
}
#endif
float l9_31=l9_22;
float l9_32=l9_29;
sc_ClampUV(l9_31,additional_settings_btn_refl_texUvMinMax.y,additional_settings_btn_refl_texUvMinMax.w,l9_30,l9_32);
l9_24=l9_32;
l9_23=vec2(l9_28,l9_31);
}
#else
{
l9_24=1.0;
l9_23=vec2(l9_20,l9_22);
}
#endif
vec2 l9_33=sc_TransformUV(l9_23,(int(SC_USE_UV_TRANSFORM_additional_settings_btn_refl_tex)!=0),additional_settings_btn_refl_texTransform);
float l9_34=l9_33.x;
float l9_35=l9_24;
sc_SoftwareWrapLate(l9_34,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x,(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0)&&(!(int(SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)!=0)),l9_35);
float l9_36=l9_33.y;
float l9_37=l9_35;
sc_SoftwareWrapLate(l9_36,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y,(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0)&&(!(int(SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)!=0)),l9_37);
float l9_38=l9_37;
vec3 l9_39=sc_SamplingCoordsViewToGlobal(vec2(l9_34,l9_36),additional_settings_btn_refl_texLayout,additional_settings_btn_refl_texGetStereoViewIndex());
vec4 l9_40=texture(additional_settings_btn_refl_texArrSC,l9_39,0.0);
vec4 l9_41;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_41=mix(additional_settings_btn_refl_texBorderColor,l9_40,vec4(l9_38));
}
#else
{
l9_41=l9_40;
}
#endif
l9_18=l9_41;
}
#else
{
float l9_42=l9_17.x;
sc_SoftwareWrapEarly(l9_42,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x);
float l9_43=l9_42;
float l9_44=l9_17.y;
sc_SoftwareWrapEarly(l9_44,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y);
float l9_45=l9_44;
vec2 l9_46;
float l9_47;
#if (SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)
{
bool l9_48;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_48=ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x==3;
}
#else
{
l9_48=(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0);
}
#endif
float l9_49=l9_43;
float l9_50=1.0;
sc_ClampUV(l9_49,additional_settings_btn_refl_texUvMinMax.x,additional_settings_btn_refl_texUvMinMax.z,l9_48,l9_50);
float l9_51=l9_49;
float l9_52=l9_50;
bool l9_53;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_53=ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y==3;
}
#else
{
l9_53=(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0);
}
#endif
float l9_54=l9_45;
float l9_55=l9_52;
sc_ClampUV(l9_54,additional_settings_btn_refl_texUvMinMax.y,additional_settings_btn_refl_texUvMinMax.w,l9_53,l9_55);
l9_47=l9_55;
l9_46=vec2(l9_51,l9_54);
}
#else
{
l9_47=1.0;
l9_46=vec2(l9_43,l9_45);
}
#endif
vec2 l9_56=sc_TransformUV(l9_46,(int(SC_USE_UV_TRANSFORM_additional_settings_btn_refl_tex)!=0),additional_settings_btn_refl_texTransform);
float l9_57=l9_56.x;
float l9_58=l9_47;
sc_SoftwareWrapLate(l9_57,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x,(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0)&&(!(int(SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)!=0)),l9_58);
float l9_59=l9_56.y;
float l9_60=l9_58;
sc_SoftwareWrapLate(l9_59,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y,(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0)&&(!(int(SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)!=0)),l9_60);
float l9_61=l9_60;
vec3 l9_62=sc_SamplingCoordsViewToGlobal(vec2(l9_57,l9_59),additional_settings_btn_refl_texLayout,additional_settings_btn_refl_texGetStereoViewIndex());
vec4 l9_63=texture(additional_settings_btn_refl_tex,l9_62.xy,0.0);
vec4 l9_64;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_64=mix(additional_settings_btn_refl_texBorderColor,l9_63,vec4(l9_61));
}
#else
{
l9_64=l9_63;
}
#endif
l9_18=l9_64;
}
#endif
vec4 l9_65=vec4(Port_Import_N006)*l9_18;
vec3 l9_66=l9_12*Port_Import_N068;
float l9_67=dot(l9_66,l9_66);
float l9_68;
if (l9_67>0.0)
{
l9_68=1.0/sqrt(l9_67);
}
else
{
l9_68=0.0;
}
vec3 l9_69=l9_66*l9_68;
vec3 l9_70=((sc_ViewMatrixArray[sc_GetStereoViewIndex()]*vec4(l9_69,0.0)).xyz*vec3(Port_Input1_N073))+vec3(Port_Input2_N073);
vec4 l9_71;
#if (additional_settings_btn_refl_texLayout==2)
{
float l9_72=l9_70.x;
sc_SoftwareWrapEarly(l9_72,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x);
float l9_73=l9_72;
float l9_74=l9_70.y;
sc_SoftwareWrapEarly(l9_74,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y);
float l9_75=l9_74;
vec2 l9_76;
float l9_77;
#if (SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)
{
bool l9_78;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_78=ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x==3;
}
#else
{
l9_78=(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0);
}
#endif
float l9_79=l9_73;
float l9_80=1.0;
sc_ClampUV(l9_79,additional_settings_btn_refl_texUvMinMax.x,additional_settings_btn_refl_texUvMinMax.z,l9_78,l9_80);
float l9_81=l9_79;
float l9_82=l9_80;
bool l9_83;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_83=ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y==3;
}
#else
{
l9_83=(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0);
}
#endif
float l9_84=l9_75;
float l9_85=l9_82;
sc_ClampUV(l9_84,additional_settings_btn_refl_texUvMinMax.y,additional_settings_btn_refl_texUvMinMax.w,l9_83,l9_85);
l9_77=l9_85;
l9_76=vec2(l9_81,l9_84);
}
#else
{
l9_77=1.0;
l9_76=vec2(l9_73,l9_75);
}
#endif
vec2 l9_86=sc_TransformUV(l9_76,(int(SC_USE_UV_TRANSFORM_additional_settings_btn_refl_tex)!=0),additional_settings_btn_refl_texTransform);
float l9_87=l9_86.x;
float l9_88=l9_77;
sc_SoftwareWrapLate(l9_87,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x,(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0)&&(!(int(SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)!=0)),l9_88);
float l9_89=l9_86.y;
float l9_90=l9_88;
sc_SoftwareWrapLate(l9_89,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y,(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0)&&(!(int(SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)!=0)),l9_90);
float l9_91=l9_90;
vec3 l9_92=sc_SamplingCoordsViewToGlobal(vec2(l9_87,l9_89),additional_settings_btn_refl_texLayout,additional_settings_btn_refl_texGetStereoViewIndex());
vec4 l9_93=texture(additional_settings_btn_refl_texArrSC,l9_92,0.0);
vec4 l9_94;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_94=mix(additional_settings_btn_refl_texBorderColor,l9_93,vec4(l9_91));
}
#else
{
l9_94=l9_93;
}
#endif
l9_71=l9_94;
}
#else
{
float l9_95=l9_70.x;
sc_SoftwareWrapEarly(l9_95,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x);
float l9_96=l9_95;
float l9_97=l9_70.y;
sc_SoftwareWrapEarly(l9_97,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y);
float l9_98=l9_97;
vec2 l9_99;
float l9_100;
#if (SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)
{
bool l9_101;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_101=ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x==3;
}
#else
{
l9_101=(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0);
}
#endif
float l9_102=l9_96;
float l9_103=1.0;
sc_ClampUV(l9_102,additional_settings_btn_refl_texUvMinMax.x,additional_settings_btn_refl_texUvMinMax.z,l9_101,l9_103);
float l9_104=l9_102;
float l9_105=l9_103;
bool l9_106;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_106=ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y==3;
}
#else
{
l9_106=(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0);
}
#endif
float l9_107=l9_98;
float l9_108=l9_105;
sc_ClampUV(l9_107,additional_settings_btn_refl_texUvMinMax.y,additional_settings_btn_refl_texUvMinMax.w,l9_106,l9_108);
l9_100=l9_108;
l9_99=vec2(l9_104,l9_107);
}
#else
{
l9_100=1.0;
l9_99=vec2(l9_96,l9_98);
}
#endif
vec2 l9_109=sc_TransformUV(l9_99,(int(SC_USE_UV_TRANSFORM_additional_settings_btn_refl_tex)!=0),additional_settings_btn_refl_texTransform);
float l9_110=l9_109.x;
float l9_111=l9_100;
sc_SoftwareWrapLate(l9_110,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).x,(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0)&&(!(int(SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)!=0)),l9_111);
float l9_112=l9_109.y;
float l9_113=l9_111;
sc_SoftwareWrapLate(l9_112,ivec2(SC_SOFTWARE_WRAP_MODE_U_additional_settings_btn_refl_tex,SC_SOFTWARE_WRAP_MODE_V_additional_settings_btn_refl_tex).y,(int(SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)!=0)&&(!(int(SC_USE_UV_MIN_MAX_additional_settings_btn_refl_tex)!=0)),l9_113);
float l9_114=l9_113;
vec3 l9_115=sc_SamplingCoordsViewToGlobal(vec2(l9_110,l9_112),additional_settings_btn_refl_texLayout,additional_settings_btn_refl_texGetStereoViewIndex());
vec4 l9_116=texture(additional_settings_btn_refl_tex,l9_115.xy,0.0);
vec4 l9_117;
#if (SC_USE_CLAMP_TO_BORDER_additional_settings_btn_refl_tex)
{
l9_117=mix(additional_settings_btn_refl_texBorderColor,l9_116,vec4(l9_114));
}
#else
{
l9_117=l9_116;
}
#endif
l9_71=l9_117;
}
#endif
vec4 l9_118=vec4(Port_Import_N062)*l9_71;
vec2 l9_119=l9_4*Port_Input1_N009;
float l9_120=clamp(length(l9_119+Port_Input2_N009),0.0,1.0);
vec4 l9_121;
if (l9_120<Port_Position1_N003)
{
l9_121=mix(Port_Value0_N003,Port_Value1_N003,vec4(clamp(l9_120/Port_Position1_N003,0.0,1.0)));
}
else
{
vec4 l9_122;
if (l9_120<Port_Position2_N003)
{
l9_122=mix(Port_Value1_N003,Port_Value2_N003,vec4(clamp((l9_120-Port_Position1_N003)/(Port_Position2_N003-Port_Position1_N003),0.0,1.0)));
}
else
{
vec4 l9_123;
if (l9_120<Port_Position3_N003)
{
l9_123=mix(Port_Value2_N003,Port_Value3_N003,vec4(clamp((l9_120-Port_Position2_N003)/(Port_Position3_N003-Port_Position2_N003),0.0,1.0)));
}
else
{
l9_123=mix(Port_Value3_N003,Port_Value4_N003,vec4(clamp((l9_120-Port_Position3_N003)/(1.0-Port_Position3_N003),0.0,1.0)));
}
l9_122=l9_123;
}
l9_121=l9_122;
}
bool l9_124=PreviewEnabled==1;
bool l9_125;
if (l9_124)
{
l9_125=!l9_0;
}
else
{
l9_125=l9_124;
}
bool l9_126;
vec4 l9_127;
if (l9_125&&(3==PreviewNodeID))
{
vec4 l9_128=l9_121;
l9_128.w=1.0;
l9_127=l9_128;
l9_126=true;
}
else
{
l9_127=PreviewVertexColor;
l9_126=l9_0;
}
vec4 l9_129=mix(l9_65,l9_118,vec4(Port_Input2_N005))+l9_121;
vec2 l9_130=l9_5-Port_Center_N002;
vec2 l9_131=(l9_130*Port_Scale_N002)+Port_Center_N002;
vec4 l9_132;
#if (iconLayout==2)
{
float l9_133=l9_131.x;
sc_SoftwareWrapEarly(l9_133,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x);
float l9_134=l9_133;
float l9_135=l9_131.y;
sc_SoftwareWrapEarly(l9_135,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y);
float l9_136=l9_135;
vec2 l9_137;
float l9_138;
#if (SC_USE_UV_MIN_MAX_icon)
{
bool l9_139;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_139=ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x==3;
}
#else
{
l9_139=(int(SC_USE_CLAMP_TO_BORDER_icon)!=0);
}
#endif
float l9_140=l9_134;
float l9_141=1.0;
sc_ClampUV(l9_140,iconUvMinMax.x,iconUvMinMax.z,l9_139,l9_141);
float l9_142=l9_140;
float l9_143=l9_141;
bool l9_144;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_144=ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y==3;
}
#else
{
l9_144=(int(SC_USE_CLAMP_TO_BORDER_icon)!=0);
}
#endif
float l9_145=l9_136;
float l9_146=l9_143;
sc_ClampUV(l9_145,iconUvMinMax.y,iconUvMinMax.w,l9_144,l9_146);
l9_138=l9_146;
l9_137=vec2(l9_142,l9_145);
}
#else
{
l9_138=1.0;
l9_137=vec2(l9_134,l9_136);
}
#endif
vec2 l9_147=sc_TransformUV(l9_137,(int(SC_USE_UV_TRANSFORM_icon)!=0),iconTransform);
float l9_148=l9_147.x;
float l9_149=l9_138;
sc_SoftwareWrapLate(l9_148,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x,(int(SC_USE_CLAMP_TO_BORDER_icon)!=0)&&(!(int(SC_USE_UV_MIN_MAX_icon)!=0)),l9_149);
float l9_150=l9_147.y;
float l9_151=l9_149;
sc_SoftwareWrapLate(l9_150,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y,(int(SC_USE_CLAMP_TO_BORDER_icon)!=0)&&(!(int(SC_USE_UV_MIN_MAX_icon)!=0)),l9_151);
float l9_152=l9_151;
vec3 l9_153=sc_SamplingCoordsViewToGlobal(vec2(l9_148,l9_150),iconLayout,iconGetStereoViewIndex());
vec4 l9_154=texture(iconArrSC,l9_153,0.0);
vec4 l9_155;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_155=mix(iconBorderColor,l9_154,vec4(l9_152));
}
#else
{
l9_155=l9_154;
}
#endif
l9_132=l9_155;
}
#else
{
float l9_156=l9_131.x;
sc_SoftwareWrapEarly(l9_156,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x);
float l9_157=l9_156;
float l9_158=l9_131.y;
sc_SoftwareWrapEarly(l9_158,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y);
float l9_159=l9_158;
vec2 l9_160;
float l9_161;
#if (SC_USE_UV_MIN_MAX_icon)
{
bool l9_162;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_162=ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x==3;
}
#else
{
l9_162=(int(SC_USE_CLAMP_TO_BORDER_icon)!=0);
}
#endif
float l9_163=l9_157;
float l9_164=1.0;
sc_ClampUV(l9_163,iconUvMinMax.x,iconUvMinMax.z,l9_162,l9_164);
float l9_165=l9_163;
float l9_166=l9_164;
bool l9_167;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_167=ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y==3;
}
#else
{
l9_167=(int(SC_USE_CLAMP_TO_BORDER_icon)!=0);
}
#endif
float l9_168=l9_159;
float l9_169=l9_166;
sc_ClampUV(l9_168,iconUvMinMax.y,iconUvMinMax.w,l9_167,l9_169);
l9_161=l9_169;
l9_160=vec2(l9_165,l9_168);
}
#else
{
l9_161=1.0;
l9_160=vec2(l9_157,l9_159);
}
#endif
vec2 l9_170=sc_TransformUV(l9_160,(int(SC_USE_UV_TRANSFORM_icon)!=0),iconTransform);
float l9_171=l9_170.x;
float l9_172=l9_161;
sc_SoftwareWrapLate(l9_171,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x,(int(SC_USE_CLAMP_TO_BORDER_icon)!=0)&&(!(int(SC_USE_UV_MIN_MAX_icon)!=0)),l9_172);
float l9_173=l9_170.y;
float l9_174=l9_172;
sc_SoftwareWrapLate(l9_173,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y,(int(SC_USE_CLAMP_TO_BORDER_icon)!=0)&&(!(int(SC_USE_UV_MIN_MAX_icon)!=0)),l9_174);
float l9_175=l9_174;
vec3 l9_176=sc_SamplingCoordsViewToGlobal(vec2(l9_171,l9_173),iconLayout,iconGetStereoViewIndex());
vec4 l9_177=texture(icon,l9_176.xy,0.0);
vec4 l9_178;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_178=mix(iconBorderColor,l9_177,vec4(l9_175));
}
#else
{
l9_178=l9_177;
}
#endif
l9_132=l9_178;
}
#endif
float l9_179;
if ((float(iconEnabled)*1.0)!=0.0)
{
vec4 l9_180;
#if (iconLayout==2)
{
float l9_181=l9_131.x;
sc_SoftwareWrapEarly(l9_181,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x);
float l9_182=l9_181;
float l9_183=l9_131.y;
sc_SoftwareWrapEarly(l9_183,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y);
float l9_184=l9_183;
vec2 l9_185;
float l9_186;
#if (SC_USE_UV_MIN_MAX_icon)
{
bool l9_187;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_187=ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x==3;
}
#else
{
l9_187=(int(SC_USE_CLAMP_TO_BORDER_icon)!=0);
}
#endif
float l9_188=l9_182;
float l9_189=1.0;
sc_ClampUV(l9_188,iconUvMinMax.x,iconUvMinMax.z,l9_187,l9_189);
float l9_190=l9_188;
float l9_191=l9_189;
bool l9_192;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_192=ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y==3;
}
#else
{
l9_192=(int(SC_USE_CLAMP_TO_BORDER_icon)!=0);
}
#endif
float l9_193=l9_184;
float l9_194=l9_191;
sc_ClampUV(l9_193,iconUvMinMax.y,iconUvMinMax.w,l9_192,l9_194);
l9_186=l9_194;
l9_185=vec2(l9_190,l9_193);
}
#else
{
l9_186=1.0;
l9_185=vec2(l9_182,l9_184);
}
#endif
vec2 l9_195=sc_TransformUV(l9_185,(int(SC_USE_UV_TRANSFORM_icon)!=0),iconTransform);
float l9_196=l9_195.x;
float l9_197=l9_186;
sc_SoftwareWrapLate(l9_196,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x,(int(SC_USE_CLAMP_TO_BORDER_icon)!=0)&&(!(int(SC_USE_UV_MIN_MAX_icon)!=0)),l9_197);
float l9_198=l9_195.y;
float l9_199=l9_197;
sc_SoftwareWrapLate(l9_198,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y,(int(SC_USE_CLAMP_TO_BORDER_icon)!=0)&&(!(int(SC_USE_UV_MIN_MAX_icon)!=0)),l9_199);
float l9_200=l9_199;
vec3 l9_201=sc_SamplingCoordsViewToGlobal(vec2(l9_196,l9_198),iconLayout,iconGetStereoViewIndex());
vec4 l9_202=texture(iconArrSC,l9_201,0.0);
vec4 l9_203;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_203=mix(iconBorderColor,l9_202,vec4(l9_200));
}
#else
{
l9_203=l9_202;
}
#endif
l9_180=l9_203;
}
#else
{
float l9_204=l9_131.x;
sc_SoftwareWrapEarly(l9_204,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x);
float l9_205=l9_204;
float l9_206=l9_131.y;
sc_SoftwareWrapEarly(l9_206,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y);
float l9_207=l9_206;
vec2 l9_208;
float l9_209;
#if (SC_USE_UV_MIN_MAX_icon)
{
bool l9_210;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_210=ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x==3;
}
#else
{
l9_210=(int(SC_USE_CLAMP_TO_BORDER_icon)!=0);
}
#endif
float l9_211=l9_205;
float l9_212=1.0;
sc_ClampUV(l9_211,iconUvMinMax.x,iconUvMinMax.z,l9_210,l9_212);
float l9_213=l9_211;
float l9_214=l9_212;
bool l9_215;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_215=ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y==3;
}
#else
{
l9_215=(int(SC_USE_CLAMP_TO_BORDER_icon)!=0);
}
#endif
float l9_216=l9_207;
float l9_217=l9_214;
sc_ClampUV(l9_216,iconUvMinMax.y,iconUvMinMax.w,l9_215,l9_217);
l9_209=l9_217;
l9_208=vec2(l9_213,l9_216);
}
#else
{
l9_209=1.0;
l9_208=vec2(l9_205,l9_207);
}
#endif
vec2 l9_218=sc_TransformUV(l9_208,(int(SC_USE_UV_TRANSFORM_icon)!=0),iconTransform);
float l9_219=l9_218.x;
float l9_220=l9_209;
sc_SoftwareWrapLate(l9_219,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).x,(int(SC_USE_CLAMP_TO_BORDER_icon)!=0)&&(!(int(SC_USE_UV_MIN_MAX_icon)!=0)),l9_220);
float l9_221=l9_218.y;
float l9_222=l9_220;
sc_SoftwareWrapLate(l9_221,ivec2(SC_SOFTWARE_WRAP_MODE_U_icon,SC_SOFTWARE_WRAP_MODE_V_icon).y,(int(SC_USE_CLAMP_TO_BORDER_icon)!=0)&&(!(int(SC_USE_UV_MIN_MAX_icon)!=0)),l9_222);
float l9_223=l9_222;
vec3 l9_224=sc_SamplingCoordsViewToGlobal(vec2(l9_219,l9_221),iconLayout,iconGetStereoViewIndex());
vec4 l9_225=texture(icon,l9_224.xy,0.0);
vec4 l9_226;
#if (SC_USE_CLAMP_TO_BORDER_icon)
{
l9_226=mix(iconBorderColor,l9_225,vec4(l9_223));
}
#else
{
l9_226=l9_225;
}
#endif
l9_180=l9_226;
}
#endif
l9_179=l9_180.w;
}
else
{
l9_179=Port_Input2_N007;
}
vec4 l9_227=vec4(l9_179);
vec4 l9_228=mix(l9_129,l9_132,l9_227);
float l9_229=l9_228.w;
#if (sc_BlendMode_AlphaTest)
{
if (l9_229<alphaTestThreshold)
{
discard;
}
}
#endif
#if (ENABLE_STIPPLE_PATTERN_TEST)
{
if (l9_229<((mod(dot(floor(mod(gl_FragCoord.xy,vec2(4.0))),vec2(4.0,1.0))*9.0,16.0)+1.0)/17.0))
{
discard;
}
}
#endif
if (isProxyMode)
{
vec4 l9_230;
#if (sc_ProxyAlphaOne)
{
vec4 l9_231=l9_228;
l9_231.w=1.0;
l9_230=l9_231;
}
#else
{
l9_230=l9_228;
}
#endif
sc_writeFragData0(max(l9_230,vec4(0.0)));
return;
}
vec4 l9_232;
#if (sc_ProjectiveShadowsCaster)
{
float l9_233;
#if (((sc_BlendMode_Normal||sc_BlendMode_AlphaToCoverage)||sc_BlendMode_PremultipliedAlphaHardware)||sc_BlendMode_PremultipliedAlphaAuto)
{
l9_233=l9_229;
}
#else
{
float l9_234;
#if (sc_BlendMode_PremultipliedAlpha)
{
l9_234=clamp(l9_229*2.0,0.0,1.0);
}
#else
{
float l9_235;
#if (sc_BlendMode_AddWithAlphaFactor)
{
l9_235=clamp(dot(l9_228.xyz,vec3(l9_229)),0.0,1.0);
}
#else
{
float l9_236;
#if (sc_BlendMode_AlphaTest)
{
l9_236=1.0;
}
#else
{
float l9_237;
#if (sc_BlendMode_Multiply)
{
l9_237=(1.0-dot(l9_228.xyz,vec3(0.33333001)))*l9_229;
}
#else
{
float l9_238;
#if (sc_BlendMode_MultiplyOriginal)
{
l9_238=(1.0-clamp(dot(l9_228.xyz,vec3(1.0)),0.0,1.0))*l9_229;
}
#else
{
float l9_239;
#if (sc_BlendMode_ColoredGlass)
{
l9_239=clamp(dot(l9_228.xyz,vec3(1.0)),0.0,1.0)*l9_229;
}
#else
{
float l9_240;
#if (sc_BlendMode_Add)
{
l9_240=clamp(dot(l9_228.xyz,vec3(1.0)),0.0,1.0);
}
#else
{
float l9_241;
#if (sc_BlendMode_AddWithAlphaFactor)
{
l9_241=clamp(dot(l9_228.xyz,vec3(1.0)),0.0,1.0)*l9_229;
}
#else
{
float l9_242;
#if (sc_BlendMode_Screen)
{
l9_242=dot(l9_228.xyz,vec3(0.33333001))*l9_229;
}
#else
{
float l9_243;
#if (sc_BlendMode_Min)
{
l9_243=1.0-clamp(dot(l9_228.xyz,vec3(1.0)),0.0,1.0);
}
#else
{
float l9_244;
#if (sc_BlendMode_Max)
{
l9_244=clamp(dot(l9_228.xyz,vec3(1.0)),0.0,1.0);
}
#else
{
l9_244=1.0;
}
#endif
l9_243=l9_244;
}
#endif
l9_242=l9_243;
}
#endif
l9_241=l9_242;
}
#endif
l9_240=l9_241;
}
#endif
l9_239=l9_240;
}
#endif
l9_238=l9_239;
}
#endif
l9_237=l9_238;
}
#endif
l9_236=l9_237;
}
#endif
l9_235=l9_236;
}
#endif
l9_234=l9_235;
}
#endif
l9_233=l9_234;
}
#endif
l9_232=vec4(mix(sc_ShadowColor.xyz,sc_ShadowColor.xyz*l9_228.xyz,vec3(sc_ShadowColor.w)),sc_ShadowDensity*l9_233);
}
#else
{
vec4 l9_245;
#if (sc_RenderAlphaToColor)
{
l9_245=vec4(l9_229);
}
#else
{
vec4 l9_246;
#if (sc_BlendMode_Custom)
{
vec4 l9_247;
#if (sc_FramebufferFetch)
{
vec4 l9_248=sc_readFragData0_Platform();
vec4 l9_249;
#if (sc_UseFramebufferFetchMarker)
{
vec4 l9_250=l9_248;
l9_250.x=l9_248.x+_sc_framebufferFetchMarker;
l9_249=l9_250;
}
#else
{
l9_249=l9_248;
}
#endif
l9_247=l9_249;
}
#else
{
vec2 l9_251=sc_ScreenCoordsGlobalToView(gl_FragCoord.xy*sc_CurrentRenderTargetDims.zw);
int l9_252;
#if (sc_ScreenTextureHasSwappedViews)
{
l9_252=1-sc_GetStereoViewIndex();
}
#else
{
l9_252=sc_GetStereoViewIndex();
}
#endif
vec4 l9_253;
#if (sc_ScreenTextureLayout==2)
{
l9_253=texture(sc_ScreenTextureArrSC,sc_SamplingCoordsViewToGlobal(l9_251,sc_ScreenTextureLayout,l9_252),0.0);
}
#else
{
l9_253=texture(sc_ScreenTexture,sc_SamplingCoordsViewToGlobal(l9_251,sc_ScreenTextureLayout,l9_252).xy,0.0);
}
#endif
l9_247=l9_253;
}
#endif
vec4 l9_254;
#if (((sc_IsEditor&&sc_GetFramebufferColorInvalidUsageMarker)&&(!sc_BlendMode_Software))&&(!sc_BlendMode_ColoredGlass))
{
vec4 l9_255=l9_247;
l9_255.x=l9_247.x+_sc_GetFramebufferColorInvalidUsageMarker;
l9_254=l9_255;
}
#else
{
l9_254=l9_247;
}
#endif
vec3 l9_256=mix(l9_254.xyz,definedBlend(l9_254.xyz,l9_228.xyz).xyz,vec3(l9_229));
vec4 l9_257=vec4(l9_256.x,l9_256.y,l9_256.z,vec4(0.0).w);
l9_257.w=1.0;
l9_246=l9_257;
}
#else
{
vec4 l9_258;
#if (sc_BlendMode_MultiplyOriginal)
{
l9_258=vec4(mix(vec3(1.0),l9_228.xyz,vec3(l9_229)),l9_229);
}
#else
{
vec4 l9_259;
#if (sc_BlendMode_Screen||sc_BlendMode_PremultipliedAlphaAuto)
{
float l9_260;
#if (sc_BlendMode_PremultipliedAlphaAuto)
{
l9_260=clamp(l9_229,0.0,1.0);
}
#else
{
l9_260=l9_229;
}
#endif
l9_259=vec4(l9_228.xyz*l9_260,l9_260);
}
#else
{
l9_259=l9_228;
}
#endif
l9_258=l9_259;
}
#endif
l9_246=l9_258;
}
#endif
l9_245=l9_246;
}
#endif
l9_232=l9_245;
}
#endif
vec4 l9_261;
if (l9_124)
{
vec4 l9_262;
if (l9_126)
{
l9_262=l9_127;
}
else
{
l9_262=vec4(0.0);
}
l9_261=l9_262;
}
else
{
l9_261=l9_232;
}
vec4 l9_263;
#if (sc_ShaderComplexityAnalyzer)
{
l9_263=vec4(shaderComplexityValue/255.0,0.0,0.0,1.0);
}
#else
{
l9_263=vec4(0.0);
}
#endif
vec4 l9_264;
if (l9_263.w>0.0)
{
l9_264=l9_263;
}
else
{
l9_264=l9_261;
}
vec4 l9_265=outputMotionVectorsIfNeeded(varPos,max(l9_264,vec4(0.0)));
vec4 l9_266=clamp(l9_265,vec4(0.0),vec4(1.0));
#if (sc_OITDepthBoundsPass)
{
#if (sc_OITDepthBoundsPass)
{
float l9_267=clamp(viewSpaceDepth()/1000.0,0.0,1.0);
sc_writeFragData0(vec4(max(0.0,1.0-(l9_267-0.0039215689)),min(1.0,l9_267+0.0039215689),0.0,0.0));
}
#endif
}
#else
{
#if (sc_OITDepthPrepass)
{
sc_writeFragData0(vec4(1.0));
}
#else
{
#if (sc_OITDepthGatherPass)
{
#if (sc_OITDepthGatherPass)
{
vec2 l9_268=sc_ScreenCoordsGlobalToView(gl_FragCoord.xy*sc_CurrentRenderTargetDims.zw);
#if (sc_OITMaxLayers4Plus1)
{
if ((gl_FragCoord.z-texture(sc_OITFrontDepthTexture,l9_268).x)<=getFrontLayerZTestEpsilon())
{
discard;
}
}
#endif
int l9_269=encodeDepth(viewSpaceDepth(),texture(sc_OITFilteredDepthBoundsTexture,l9_268).xy);
float l9_270=packValue(l9_269);
int l9_277=int(l9_266.w*255.0);
float l9_278=packValue(l9_277);
sc_writeFragData0(vec4(packValue(l9_269),packValue(l9_269),packValue(l9_269),packValue(l9_269)));
sc_writeFragData1(vec4(l9_270,packValue(l9_269),packValue(l9_269),packValue(l9_269)));
sc_writeFragData2(vec4(l9_278,packValue(l9_277),packValue(l9_277),packValue(l9_277)));
#if (sc_OITMaxLayersVisualizeLayerCount)
{
sc_writeFragData2(vec4(0.0039215689,0.0,0.0,0.0));
}
#endif
}
#endif
}
#else
{
#if (sc_OITCompositingPass)
{
#if (sc_OITCompositingPass)
{
vec2 l9_281=sc_ScreenCoordsGlobalToView(gl_FragCoord.xy*sc_CurrentRenderTargetDims.zw);
#if (sc_OITMaxLayers4Plus1)
{
if ((gl_FragCoord.z-texture(sc_OITFrontDepthTexture,l9_281).x)<=getFrontLayerZTestEpsilon())
{
discard;
}
}
#endif
int l9_282[8];
int l9_283[8];
int l9_284=0;
for (int snapLoopIndex=0; snapLoopIndex==0; snapLoopIndex+=0)
{
if (l9_284<8)
{
l9_282[l9_284]=0;
l9_283[l9_284]=0;
l9_284++;
continue;
}
else
{
break;
}
}
int l9_285;
#if (sc_OITMaxLayers8)
{
l9_285=2;
}
#else
{
l9_285=1;
}
#endif
int l9_286=0;
for (int snapLoopIndex=0; snapLoopIndex==0; snapLoopIndex+=0)
{
if (l9_286<l9_285)
{
vec4 l9_287;
vec4 l9_288;
vec4 l9_289;
if (l9_286==0)
{
l9_289=texture(sc_OITAlpha0,l9_281);
l9_288=texture(sc_OITDepthLow0,l9_281);
l9_287=texture(sc_OITDepthHigh0,l9_281);
}
else
{
l9_289=vec4(0.0);
l9_288=vec4(0.0);
l9_287=vec4(0.0);
}
vec4 l9_290;
vec4 l9_291;
vec4 l9_292;
if (l9_286==1)
{
l9_292=texture(sc_OITAlpha1,l9_281);
l9_291=texture(sc_OITDepthLow1,l9_281);
l9_290=texture(sc_OITDepthHigh1,l9_281);
}
else
{
l9_292=l9_289;
l9_291=l9_288;
l9_290=l9_287;
}
if (any(notEqual(l9_290,vec4(0.0)))||any(notEqual(l9_291,vec4(0.0))))
{
int l9_293[8]=l9_282;
unpackValues(l9_290.w,l9_286,l9_293);
unpackValues(l9_290.z,l9_286,l9_293);
unpackValues(l9_290.y,l9_286,l9_293);
unpackValues(l9_290.x,l9_286,l9_293);
unpackValues(l9_291.w,l9_286,l9_293);
unpackValues(l9_291.z,l9_286,l9_293);
unpackValues(l9_291.y,l9_286,l9_293);
unpackValues(l9_291.x,l9_286,l9_293);
int l9_302[8]=l9_283;
unpackValues(l9_292.w,l9_286,l9_302);
unpackValues(l9_292.z,l9_286,l9_302);
unpackValues(l9_292.y,l9_286,l9_302);
unpackValues(l9_292.x,l9_286,l9_302);
}
l9_286++;
continue;
}
else
{
break;
}
}
vec4 l9_307=texture(sc_OITFilteredDepthBoundsTexture,l9_281);
vec2 l9_308=l9_307.xy;
int l9_309;
#if (sc_SkinBonesCount>0)
{
l9_309=encodeDepth(((1.0-l9_307.x)*1000.0)+getDepthOrderingEpsilon(),l9_308);
}
#else
{
l9_309=0;
}
#endif
int l9_310=encodeDepth(viewSpaceDepth(),l9_308);
vec4 l9_311;
l9_311=l9_266*l9_266.w;
vec4 l9_312;
int l9_313=0;
for (int snapLoopIndex=0; snapLoopIndex==0; snapLoopIndex+=0)
{
if (l9_313<8)
{
int l9_314=l9_282[l9_313];
int l9_315=l9_310-l9_309;
bool l9_316=l9_314<l9_315;
bool l9_317;
if (l9_316)
{
l9_317=l9_282[l9_313]>0;
}
else
{
l9_317=l9_316;
}
if (l9_317)
{
vec3 l9_318=l9_311.xyz*(1.0-(float(l9_283[l9_313])/255.0));
l9_312=vec4(l9_318.x,l9_318.y,l9_318.z,l9_311.w);
}
else
{
l9_312=l9_311;
}
l9_311=l9_312;
l9_313++;
continue;
}
else
{
break;
}
}
sc_writeFragData0(l9_311);
#if (sc_OITMaxLayersVisualizeLayerCount)
{
discard;
}
#endif
}
#endif
}
#else
{
#if (sc_OITFrontLayerPass)
{
#if (sc_OITFrontLayerPass)
{
if (abs(gl_FragCoord.z-texture(sc_OITFrontDepthTexture,sc_ScreenCoordsGlobalToView(gl_FragCoord.xy*sc_CurrentRenderTargetDims.zw)).x)>getFrontLayerZTestEpsilon())
{
discard;
}
sc_writeFragData0(l9_266);
}
#endif
}
#else
{
sc_writeFragData0(l9_265);
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif
}
#endif // #elif defined FRAGMENT_SHADER // #if defined VERTEX_SHADER
