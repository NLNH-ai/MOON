#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>

using namespace metal;

[[ stitchable ]] half4 moonSphereLighting(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float lightHorizontal,
    float lightDepth
) {
    float2 safeSize = max(size, float2(1.0));
    float2 diskPosition = ((position / safeSize) - 0.5) * 2.0;
    diskPosition.y = -diskPosition.y;

    float radiusSquared = dot(diskPosition, diskPosition);
    if (radiusSquared > 1.0) {
        return half4(0.0);
    }

    float surfaceDepth = sqrt(max(0.0, 1.0 - radiusSquared));
    float3 surfaceNormal = normalize(float3(diskPosition, surfaceDepth));
    float3 lightDirection = normalize(float3(lightHorizontal, 0.0, lightDepth));
    float diffuse = max(dot(surfaceNormal, lightDirection), 0.0);
    float illuminatedDiffuse = pow(diffuse, 0.70);

    float limbLight = smoothstep(0.0, 0.34, surfaceDepth);
    float earthshine = 0.024 + (0.018 * max(-lightDepth, 0.0));
    float lightLevel = earthshine + (illuminatedDiffuse * mix(0.98, 1.16, limbLight));
    float edgeAlpha = 1.0 - smoothstep(0.985, 1.0, radiusSquared);

    half4 source = layer.sample(position);
    source.rgb *= half(lightLevel * edgeAlpha);
    source.a *= half(edgeAlpha);
    return source;
}
