import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_summary_information.dart';
import 'package:instagram/screens/profile_screens/profile_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/elastic_view_model.dart';
import 'package:instagram/widgets/animation_widgets/show_right.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Consumer<ElasticViewModel>(
        builder: (context, value, child) {
          return ListView.builder(
            itemCount: value.searchResults.length,
            itemBuilder: (context, index) {
              return searchResultCard(context, value.searchResults[index]);
            },
          );
        },
      )
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: SizedBox(
        height: kToolbarHeight - 20,
        child: Consumer<ElasticViewModel>(
          builder: (context, elastic, child) {
            return TextField(
              autofocus: true,
              onChanged: (value) async {
                if (_debounce?.isActive ?? false) _debounce?.cancel();

                _debounce = Timer(const Duration(milliseconds: 300), () async {
                  await elastic.searchData(value);
                });
              },
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: Colors.grey,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                counterStyle: Theme.of(context).textTheme.bodyMedium,
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                hintText: "Search",
              ),
            );
          },
        ),
      ),
    );
  }

  Widget searchResultCard(BuildContext context, UserSummaryInformation result) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: result.userId),));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: result.avatarUrl.isNotEmpty ? CachedNetworkImageProvider(result.avatarUrl) : defaultAvatar,
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.username,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5,),
                Text(
                  result.displayName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const Spacer(),
            /*InkWell(
              onTap: (){},
              child: const Icon(Icons.close, size: 20, color: Colors.grey,),
            ),*/
          ],
        ),
      ),
    );
  }
}
