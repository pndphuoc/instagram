import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MessageShimmer extends StatelessWidget {
  final bool isOwnMessage;

  const MessageShimmer({Key? key, required this.isOwnMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isOwnMessage? _buildOwnMessageShimmer(context) : _buildReceivedMessageShimmer(context);
  }

  Widget _buildOwnMessageShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade700,
      child: Container(
        height: 15,
        width: getRandomNumber(context),
        color: Colors.white,
      ),);
  }

  Widget _buildReceivedMessageShimmer(BuildContext context) {
    const double avatarSize = 15;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade700,
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          Container(
            width: avatarSize * 2,
            height: avatarSize * 2,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            height: 15,
            width: getRandomNumber(context),
            color: Colors.white,
          ),
        ],
      ),);
  }

  double getRandomNumber(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double halfScreenWidth = screenWidth / 2;
    Random random = Random();
    double randomNumber = random.nextDouble() * halfScreenWidth;
    return randomNumber;
  }
}

