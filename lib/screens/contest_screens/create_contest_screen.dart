import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/models/contest.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/contest_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/prize.dart';

class CreateContestScreen extends StatefulWidget {
  const CreateContestScreen({Key? key}) : super(key: key);

  @override
  State<CreateContestScreen> createState() => _CreateContestScreenState();
}

class _CreateContestScreenState extends State<CreateContestScreen> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<CreateContestViewModel>(
      create: (context) => CreateContestViewModel(),
      builder: (context, child) => Scaffold(
        appBar: _appBar(context),
        body: SafeArea(
          child: _buildInformationFields(context),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text(
        "Create photo contest",
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildInputField(
      BuildContext context, String name, TextEditingController controller,
      {bool isMultiLines = false, Color outlineBorderColor = secondaryColor}) {
    final inputBorder = OutlineInputBorder(
        borderSide:
            Divider.createBorderSide(context, width: 2, color: outlineBorderColor));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            disabledBorder: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: inputBorder,
          ),
          maxLines: isMultiLines ? null : 1,
        ),
      ],
    );
  }

  Widget _buildInformationFields(BuildContext context) {
    return Consumer<CreateContestViewModel>(
      builder: (context, contestViewModel, child) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                  context, "Name of contest", contestViewModel.nameController),
              const SizedBox(height: 10),
              _buildInputField(
                  context, "Topic", contestViewModel.topicController),
              const SizedBox(
                height: 10,
              ),
              _buildInputField(
                  context, "Content", contestViewModel.contentController,
                  isMultiLines: true),
              const SizedBox(
                height: 10,
              ),
              _buildDateSelector(context, contestViewModel),
              const SizedBox(
                height: 10,
              ),
              _buildAwardMethodSelector(context, contestViewModel),
              const SizedBox(
                height: 10,
              ),
              _buildInputField(
                  context, "Rules", contestViewModel.rulesController,
                  isMultiLines: true),
              const SizedBox(
                height: 10,
              ),
              _buildBannerImagePick(context, contestViewModel),
              const SizedBox(
                height: 10,
              ),
              _buildPrizesBlock(context, contestViewModel),
              const SizedBox(
                height: 20,
              ),
              _buildCreateButton(context, contestViewModel)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerImagePick(
      BuildContext context, CreateContestViewModel contestViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Banner photo",
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(
          height: 5,
        ),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: contestViewModel.banner == null
              ? GestureDetector(
                  onTap: () => contestViewModel.imagePicker(),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: secondaryColor, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        size: 50,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Image.file(
                      contestViewModel.banner!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                            onTap: () => contestViewModel.imagePicker(),
                            child: const Icon(
                              Icons.change_circle_outlined,
                              size: 30,
                            )))
                  ],
                ),
        )
      ],
    );
  }

  Widget _buildPrizesBlock(
      BuildContext context, CreateContestViewModel contestViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Prizes",
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(
          height: 5,
        ),
        ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(
            height: 2,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: contestViewModel.prizes.length,
          itemBuilder: (context, index) =>
              _prizeBlock(context, contestViewModel.prizes[index]),
        ),
        const SizedBox(
          height: 3,
        ),
        InkWell(
          onTap: () async  {
            final result = await _addPrizeTap(contestViewModel);
            if (result != null) {
              contestViewModel.createPrize(result);
            }
          },
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(color: secondaryColor, width: 2),
                borderRadius: BorderRadius.circular(10)),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 30,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildAwardMethodSelector(BuildContext context, CreateContestViewModel createContestViewModel) {
    return Selector<CreateContestViewModel, int>(builder: (context, value, child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Award method", style: Theme.of(context).textTheme.labelLarge,),
        const SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  createContestViewModel.onChangeAwardMethod(AwardMethod.interaction['code']);
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: value == AwardMethod.interaction['code'] ? primaryColor : mobileBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    border: Border.all(
                      width: 2,
                      color: secondaryColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AwardMethod.interaction['name'],
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  createContestViewModel.onChangeAwardMethod(AwardMethod.selfDetermined['code']);
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: value == AwardMethod.selfDetermined['code'] ? primaryColor : mobileBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    border: Border.all(
                      width: 2,
                      color: secondaryColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AwardMethod.selfDetermined['name'],
                      style:  Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
        ,
      ],
    ), selector: (context, createContest) => createContest.awardMethod,);
  }

  Widget _prizeBlock(
    BuildContext context,
    Prize prize,
  ) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController awardController = TextEditingController();
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(color: secondaryColor, width: 2),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
              child: Text(
                prize.name,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: null,
              )),
          const VerticalDivider(
            color: secondaryColor,
            width: 2,
          ),
          Expanded(
              child: Row(
            children: [
              const Icon(
                Icons.attach_money_rounded,
                size: 20,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                prize.award ?? "",
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: null,
              ),
            ],
          ))
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, CreateContestViewModel contestViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Timeline", style: Theme.of(context).textTheme.labelLarge,),
        const SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  contestViewModel.onStartDateTap(context);
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    border: Border.all(
                      width: 2,
                      color: secondaryColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      contestViewModel.startDate == null ? 'Start date' : DateFormat('yyyy-MM-dd').format(contestViewModel.startDate!),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  contestViewModel.onEndDateTap(context);
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    border: Border.all(
                      width: 2,
                      color: secondaryColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      contestViewModel.endDate == null ? 'End date' : DateFormat('yyyy-MM-dd').format(contestViewModel.endDate!),
                      style:  Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
,
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context, CreateContestViewModel contestViewModel) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: contestViewModel.isCreating ? const SizedBox(height: 50, width: 50, child: CircularProgressIndicator()) : ElevatedButton(
          onPressed: () async {
            final bool result = await contestViewModel.createContest();
            if (result) {
              Fluttertoast.showToast(msg: 'Create photo contest successful');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            )
          ),
          child: Text(
            "Create contest",
            style: Theme.of(context).textTheme.titleLarge,
          )),
    );
  }

  _addPrizeTap(CreateContestViewModel contestViewModel) {
    return showDialog(context: context, builder: (context) => _buildAddPrizeDialog(context, contestViewModel));
  }

  Widget _buildAddPrizeDialog(BuildContext context, CreateContestViewModel contestViewModel) {
    return ScaleTransition(
      scale: _animation,
      child: Dialog(
        backgroundColor: secondaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildInputField(context, "Name", contestViewModel.newPrizeName, outlineBorderColor: Colors.white30, isMultiLines: true),
                const SizedBox(height: 10,),
                _buildInputField(context, "Award", contestViewModel.newPrizeAward, outlineBorderColor: Colors.white30, isMultiLines: true),
                const SizedBox(height: 20,),
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(onPressed: (){
                      final Prize newPrize = Prize(name: contestViewModel.newPrizeName.text, award: contestViewModel.newPrizeAward.text);
                      Navigator.pop(context, newPrize);
                    },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          )
                        ),
                        child: Text("Add", style: Theme.of(context).textTheme.titleMedium,)))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
