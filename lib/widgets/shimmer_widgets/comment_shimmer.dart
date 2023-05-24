import 'package:flutter/material.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:shimmer/shimmer.dart';

class CommentShimmer extends StatefulWidget {
  const CommentShimmer({Key? key}) : super(key: key);

  @override
  State<CommentShimmer> createState() => _CommentShimmerState();
}

class _CommentShimmerState extends State<CommentShimmer> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade700,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: avatarInPostCardSize * 2,
              width: avatarInPostCardSize * 2,
              decoration:
                  const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                          flex: 5,
                          child: Container(
                            height: 15,
                            width: 90,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 15,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Container(
                    height: 15,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 17,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 15,
                      width: 20,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)
                      ),
                    )
                    ,
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
