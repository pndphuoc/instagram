import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/provider/home_screen_provider.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/add_ai_post_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/post_view_model.dart';
import 'package:instagram/widgets/animation_widgets/show_up_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AddAIPostScreen extends StatefulWidget {
  const AddAIPostScreen({Key? key}) : super(key: key);

  @override
  State<AddAIPostScreen> createState() => _AddAIPostScreenState();
}

class _AddAIPostScreenState extends State<AddAIPostScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableProvider<AddAIPostViewModel>(
      create: (context) => AddAIPostViewModel(),
      builder: (context, child) => Scaffold(
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Prompt",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                _buildPromptTextField(context),
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Size of generated photos: ",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromRGBO(246, 200, 200, 1.0)),
                          borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Selector<AddAIPostViewModel, String>(
                        selector: (_, viewModel) => viewModel.label,
                        builder: (context, value, child) => Text(
                          value,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color:
                                      const Color.fromRGBO(246, 200, 200, 1.0)),
                        ),
                      ),
                    )
                  ],
                ),
                _buildSizeSlider(context),
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Number of photos",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Selector<AddAIPostViewModel, double>(
                      builder: (context, value, child) => Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    const Color.fromRGBO(246, 200, 200, 1.0)),
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Text(
                          value.toInt().toString(),
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color:
                                      const Color.fromRGBO(246, 200, 200, 1.0)),
                        ),
                      ),
                      selector: (_, viewModel) => viewModel.numberOfPhotos,
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                _buildNumberOfPhotosSlider(context),
                const SizedBox(
                  height: 10,
                ),
                _buildGenerateButton(context),
                const SizedBox(
                  height: 20,
                ),
                _buildGeneratedPhotosGridView(context),
                const SizedBox(
                  height: 10,
                ),
                _buildShareToAISpaceCheckBox(context),
                const SizedBox(
                  height: 20,
                ),
                _buildShareButton(context),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text("AI photos generation",
          style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildPromptTextField(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return Selector<AddAIPostViewModel, TextEditingController>(
      selector: (_, addAIPostViewModel) =>
          addAIPostViewModel.textEditingController,
      builder: (context, value, child) => TextField(
        controller: value,
        maxLines: null,
        decoration: InputDecoration(
            hintText: "Prompt",
            border: inputBorder,
            focusedBorder: inputBorder,
            enabledBorder: inputBorder,
            filled: true,
            contentPadding: const EdgeInsets.all(8)),
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    return Selector<AddAIPostViewModel, bool>(
      builder: (context, value, child) => SizedBox(
        height: 40,
        width: MediaQuery.of(context).size.width,
        child: value
            ? const SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(179, 204, 227, 1.0),
                ))
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    backgroundColor: const Color.fromRGBO(179, 204, 227, 1.0)),
                onPressed: () {
                  context.read<AddAIPostViewModel>().onGenerateButtonTap();
                },
                child: Text(
                  "Generate photo",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.black54),
                )),
      ),
      selector: (_, viewModel) => viewModel.isGenerating,
    );
  }

  Widget _buildSizeSlider(BuildContext context) {
    return Consumer<AddAIPostViewModel>(
      builder: (context, viewModel, child) => Slider(
        value: viewModel.sliderValue,
        max: 3,
        divisions: 2,
        min: 1,
        activeColor: const Color.fromRGBO(246, 200, 200, 1.0),
        thumbColor: const Color.fromRGBO(246, 200, 200, 1.0),
        onChanged: (value) => viewModel.onSizeSliderChanged(value),
      ),
    );
  }

  Widget _buildNumberOfPhotosSlider(BuildContext context) {
    return Selector<AddAIPostViewModel, double>(
      builder: (context, value, child) => Slider(
        value: value,
        max: 4,
        divisions: 3,
        min: 1,
        activeColor: const Color.fromRGBO(246, 200, 200, 1.0),
        onChanged: (value) => context
            .read<AddAIPostViewModel>()
            .onNumberOfPhotosSliderChanged(value),
      ),
      selector: (_, viewModel) => viewModel.numberOfPhotos,
    );
  }

  Widget _buildGeneratedPhotosGridView(BuildContext context) {
    return Selector<AddAIPostViewModel, List<String>>(
      builder: (context, value, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          value.isNotEmpty
              ? Text(
                  "Generated photos:",
                  style: Theme.of(context).textTheme.titleMedium,
                )
              : Container(),
          const SizedBox(
            height: 10,
          ),
          GridView.builder(
              shrinkWrap: true,
              itemCount: value.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1),
              itemBuilder: (context, index) =>
                  _buildGeneratedPhoto(context, value[index])),
        ],
      ),
      selector: (_, viewModel) => viewModel.generatedPhotos,
    );
  }

  Widget _buildGeneratedPhoto(BuildContext context, String url) {
    return GestureDetector(
      onTap: () {
        context.read<AddAIPostViewModel>().onPhotoTap(url);
      },
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: url,
            placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade900,
                highlightColor: Colors.grey.shade700,
                child: Container(
                  color: Colors.white,
                  height: double.infinity,
                  width: double.infinity,
                )),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Selector<AddAIPostViewModel, List<String>>(
              selector: (_, viewModel) => viewModel.selectedPhotos,
              builder: (context, value, child) => Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                      color: value.contains(url)
                          ? const Color.fromRGBO(246, 200, 200, 1.0)
                          : Colors.transparent),
                  child: value.contains(url)
                      ? Center(
                          child: Text(
                          "${value.indexOf(url) + 1}",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Colors.black54),
                        ))
                      : Container()),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return Selector<AddAIPostViewModel, List<String>>(
      builder: (context, value, child) => value.isNotEmpty
          ? ShowUp(
              delay: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 40,
                child: Selector<AddAIPostViewModel, bool>(selector: (_, viewModel) => viewModel.isUploading,
                  builder: (context, value, child) => !value ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(246, 200, 200, 1.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    onPressed: () {
                      context.read<AddAIPostViewModel>().onShareButtonTap(
                          context.read<CurrentUserViewModel>().user!.username,
                          context.read<CurrentUserViewModel>().user!.avatarUrl).then((value) {
                        if (value == null) {
                          Fluttertoast.showToast(msg: "An error has occurred");
                        } else {
                          Fluttertoast.showToast(msg: 'Upload successful');
                          context.read<PostViewModel>().posts = [value, ...context.read<PostViewModel>().posts];
                          context.read<HomeScreenProvider>().currentIndex = 0;
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      });
                    },
                    child: Text(
                      "Share",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                  ) : const CircularProgressIndicator(),
                ),
              ),
            )
          : Container(),
      selector: (_, viewModel) => viewModel.selectedPhotos,
    );
  }

  Widget _buildShareToAISpaceCheckBox(BuildContext context) {
    return Selector<AddAIPostViewModel, List<String>>(
      selector: (_, viewModel) => viewModel.generatedPhotos,
      builder: (context, value, child) => value.isNotEmpty ? Row(
        children: [
          Selector<AddAIPostViewModel, bool>(
            builder: (context, value, child) => Checkbox(
              value: value,
              activeColor: const Color.fromRGBO(246, 200, 200, 1.0),
              checkColor: Colors.black54,
              onChanged: (value) => context
                  .read<AddAIPostViewModel>()
                  .onShareToAISpaceChanged(value!),
            ),
            selector: (_, viewModel) => viewModel.isShareToAISpace,
          ),
          Text(
            "Also share to AI Space",
            style: Theme.of(context).textTheme.labelLarge,
          )
        ],
      ) : Container(),
    );
  }
}
