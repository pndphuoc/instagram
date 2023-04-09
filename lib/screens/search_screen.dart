import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/search_result.dart';
import 'package:instagram/provider/home_screen_provider.dart';
import 'package:instagram/route/route_name.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/elastic_view_model.dart';
import 'package:instagram/view_model/post_view_model.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../view_model/current_user_view_model.dart';

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
                  await elastic.searchData('users', {
                    'match_phrase_prefix': {'username': _searchController.text}
                  });
                  setState(() {});
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
                fillColor: secondaryColor,
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

  Widget searchResultCard(BuildContext context, SearchResult result) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: result.uid),));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: CachedNetworkImageProvider(result.photoUrl),
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              result.username,
              style: Theme.of(context).textTheme.titleMedium,
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
