import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MapShimmer extends StatelessWidget {
  const MapShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Full Screen Map Background Shimmer with "Map-like" shapes
        Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Stack(
            children: [
              // Base background
              Container(color: Colors.white),
              
              // Simulate Roads/Blocks
              Positioned(
                top: 100, left: -20, right: -20,
                child: Container(height: 20, color: Colors.white, transform: Matrix4.rotationZ(0.2)),
              ),
              Positioned(
                bottom: 200, left: -20, right: -20,
                child: Container(height: 25, color: Colors.white, transform: Matrix4.rotationZ(-0.1)),
              ),
              Positioned(
                top: 0, bottom: 0, left: 100,
                child: Container(width: 20, color: Colors.white, transform: Matrix4.rotationZ(0.1)),
              ),
               Positioned(
                top: 150, left: 40,
                child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
              ),
               Positioned(
                bottom: 100, right: 40,
                child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
        ),

        // 2. Top Location Card Shimmer
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 100,
                          height: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Map Control Buttons Shimmer
        Positioned(
          top: 100,
          right: 20,
          child: Column(
            children: [
              _buildBtnShimmer(),
              const SizedBox(height: 12),
              _buildBtnShimmer(),
            ],
          ),
        ),

        // 4. Bottom Button Area Shimmer
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Shimmer.fromColors(
               baseColor: Colors.grey.shade300,
               highlightColor: Colors.grey.shade100,
               child: Container(
                 width: double.infinity,
                 height: 56,
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(30),
                 ),
               ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBtnShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
