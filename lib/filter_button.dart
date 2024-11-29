import 'package:flutter/material.dart';

enum FilterState { all, income, expenses }

class FilterButton extends StatelessWidget {
  final FilterState filterState;
  final Function(FilterState) onFilterChanged;

  FilterButton({required this.filterState, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    Icon icon;
    Color iconColor;

    switch (filterState) {
      case FilterState.all:
        icon = Icon(Icons.filter_list);
        iconColor = Colors.blue;
        break;
      case FilterState.income:
        icon = Icon(Icons.arrow_upward);
        iconColor = Colors.green;
        break;
      case FilterState.expenses:
        icon = Icon(Icons.arrow_downward);
        iconColor = Colors.red;
        break;
    }

    return IconButton(
      icon: icon,
      color: iconColor,
      onPressed: () {
        onFilterChanged(_getNextFilterState(filterState));
      },
    );
  }

  FilterState _getNextFilterState(FilterState currentState) {
    switch (currentState) {
      case FilterState.all:
        return FilterState.income;
      case FilterState.income:
        return FilterState.expenses;
      case FilterState.expenses:
        return FilterState.all;
    }
  }
}
