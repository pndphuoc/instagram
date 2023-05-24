import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserInformationShimmer extends StatelessWidget {
  const UserInformationShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 30;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade700,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: avatarSize * 2,
              height: avatarSize * 2,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                  color: Colors.white
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                        color: Colors.white
                    ),
                    width: 50,
                    height: 15,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      color: Colors.white
                    ),
                    width: 80,
                    height: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
