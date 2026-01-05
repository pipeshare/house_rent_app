import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/home/utils/home_constants.dart';

class HomeHeader extends StatelessWidget {
  final bool showSearchBar;
  final bool isMapMode;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;

  const HomeHeader({
    super.key,
    required this.showSearchBar,
    required this.isMapMode,
    required this.searchController,
    required this.searchFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: HomeConstants.animationDuration,
      child: Opacity(
        opacity: isMapMode ? 0 : 1.0,
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              AnimatedContainer(
                duration: HomeConstants.animationDuration,
                height: showSearchBar
                    ? MediaQuery.of(context).size.height * 0.048 + 20
                    : 0,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: SearchBar(
                    controller: searchController,
                    focusNode: searchFocusNode,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
