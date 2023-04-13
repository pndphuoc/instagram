import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

import '../ultis/global_variables.dart';

class PostShimmer extends StatelessWidget {
  const PostShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade700,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: avatarInPostCardSize * 2,
                  width: avatarInPostCardSize * 2,
                  decoration: const BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 15, width: 60, decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)
                      ),),
                      const SizedBox(height: 3,),
                      Container(height: 15, width: 20, decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)
                      ),),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_horiz),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width - 50,
                  height: MediaQuery.of(context).size.width - 50
                )
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(height: 15, width: 40, decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                ),),
                const SizedBox(
                  width: 10,
                ),
                SvgPicture.asset(
                  "assets/ic_comment.svg",
                  height: 28,
                  width: 28,
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(height: 15, width: 20, decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                ),),
                const SizedBox(
                  width: 10,
                ),
                SvgPicture.asset(
                  "assets/ic_share.svg",
                  height: 28,
                  width: 28,
                ),
                const Expanded(child: SizedBox()),
                SvgPicture.asset(
                  "assets/ic_bookmark.svg",
                  height: 28,
                  width: 28,
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 15, width: double.infinity, decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)
                  ),),
                  const SizedBox(height: 3,),
                  Container(height: 15, width: 50, decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)
                  ),),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
