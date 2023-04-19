import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class ConversationCardShimmer extends StatelessWidget {
  const ConversationCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 30;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade700,
      child: Container(
      width: MediaQuery.of(context).size.width,
      padding:
      const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: avatarSize,
            backgroundColor: Colors.white,
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),

                  height: 15,
                  width: 80,
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          height: 15,
                          width: 120,
                        ),),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      height: 15,
                      width: 20,
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          InkWell(
            onTap: () {},
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
    ),
       );
  }
}
