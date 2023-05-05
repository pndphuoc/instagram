import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/ultis/colors.dart';


class ConfirmDialog extends StatefulWidget {
  final String? imageUrl;
  final String confirmText;
  final String description;
  final bool isUnfollow;
  final String confirmButtonText;

  const ConfirmDialog(
      {super.key,
      this.imageUrl, required this.confirmText, required this.description, required this.confirmButtonText, this.isUnfollow = true});

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Dialog(
        backgroundColor: secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              widget.isUnfollow ?
              CircleAvatar(
                backgroundImage: widget.imageUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(widget.imageUrl!)
                    : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
                radius: 40,
              ) : Container(),
              const SizedBox(height: 10,),
              Column(
                children: [
                  Text(widget.confirmText, style: Theme.of(context).textTheme.titleLarge,),
                  const SizedBox(height: 10,),
                  Text(widget.description, textAlign: TextAlign.center,),
                ], ),

              const SizedBox(height: 20,),
              /*ElevatedButton(onPressed: (){},
                  style: ElevatedButton.styleFrom(),
                  child: const Text("Unfollow")),
              ElevatedButton(onPressed: (){}, child: const Text("Cancel")),*/
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                child: Container(
                    decoration: const BoxDecoration(
                        border: Border(top: BorderSide(width: 1, color: Colors.white10))
                    ),
                    width: double.infinity,
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(widget.confirmButtonText, style: GoogleFonts.readexPro(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),)),
              ),
              InkWell(
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                onTap: (){
                  Navigator.of(context).pop(false);
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(width: 1, color: Colors.white10))
                  ),
                    width: double.infinity,
                    height: 40,
                    alignment: Alignment.center,
                    child: Text("Cancel", style: Theme.of(context).textTheme.bodyMedium,)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
