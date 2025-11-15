import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/main.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      top: false,
      child: _BottomNavContainer(),
    );
  }
}

class _BottomNavContainer extends StatelessWidget {
  const _BottomNavContainer();

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.white,
      elevation: 0,
      child: SizedBox(
        height: 64,
        child: _NavItemsRow(),
      ),
    );
  }
}

class _NavItemsRow extends StatelessWidget {
  const _NavItemsRow();

  @override
  Widget build(BuildContext context) {
    final state = InheritedNavData.of(context);
    return Row(
      children: List.generate(
        state.items.length,
            (index) => _NavItem(index: index),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;

  const _NavItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final state = InheritedNavData.of(context);
    final item = state.items[index];
    final isActive = index == state.currentIndex;

    return Expanded(
      child: _NavItemButton(
        item: item,
        isActive: isActive,
        onTap: () => state.onTap(index),
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItemButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = isActive ? primary : Colors.black54;

    return InkWell(
      onTap: onTap,
      splashColor: primary.withOpacity(0.1),
      highlightColor: primary.withOpacity(0.05),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavIcon(),
          SizedBox(height: 2),
          _NavLabel(),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon();

  @override
  Widget build(BuildContext context) {
    final state = InheritedNavData.of(context);
    final itemState = InheritedNavItem.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final color = itemState.isActive ? primary : Colors.black54;

    return Icon(itemState.item.icon, color: color, size: 24);
  }
}

class _NavLabel extends StatelessWidget {
  const _NavLabel();

  @override
  Widget build(BuildContext context) {
    final state = InheritedNavData.of(context);
    final itemState = InheritedNavItem.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final color = itemState.isActive ? primary : Colors.black54;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        itemState.item.label,
        maxLines: 1,
        overflow: TextOverflow.fade,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: itemState.isActive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

// Optimized version using InheritedWidget for efficient rebuilds
class OptimizedAppBottomNav extends StatefulWidget {
  const OptimizedAppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<OptimizedAppBottomNav> createState() => _OptimizedAppBottomNavState();
}

class _OptimizedAppBottomNavState extends State<OptimizedAppBottomNav> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: InheritedNavData(
        items: widget.items,
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        child: const Material(
          color: Colors.white,
          elevation: 0,
          child: SizedBox(
            height: 64,
            child: _OptimizedNavItemsRow(),
          ),
        ),
      ),
    );
  }
}

class _OptimizedNavItemsRow extends StatelessWidget {
  const _OptimizedNavItemsRow();

  @override
  Widget build(BuildContext context) {
    final state = InheritedNavData.of(context);
    return Row(
      children: List.generate(
        state.items.length,
            (index) => InheritedNavItem(
          item: state.items[index],
          isActive: index == state.currentIndex,
          onTap: () => state.onTap(index),
          child: const Expanded(
            child: _OptimizedNavItemContent(),
          ),
        ),
      ),
    );
  }
}

class _OptimizedNavItemContent extends StatelessWidget {
  const _OptimizedNavItemContent();

  @override
  Widget build(BuildContext context) {
    final itemState = InheritedNavItem.of(context);

    return InkWell(
      onTap: itemState.onTap,
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _OptimizedNavIcon(),
          SizedBox(height: 2),
          _OptimizedNavLabel(),
        ],
      ),
    );
  }
}

class _OptimizedNavIcon extends StatelessWidget {
  const _OptimizedNavIcon();

  @override
  Widget build(BuildContext context) {
    final itemState = InheritedNavItem.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final color = itemState.isActive ? primary : Colors.black54;

    return Icon(itemState.item.icon, color: color, size: 24);
  }
}

class _OptimizedNavLabel extends StatelessWidget {
  const _OptimizedNavLabel();

  @override
  Widget build(BuildContext context) {
    final itemState = InheritedNavItem.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final color = itemState.isActive ? primary : Colors.black54;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        itemState.item.label,
        maxLines: 1,
        overflow: TextOverflow.fade,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: itemState.isActive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

// Ultra-minimal version for maximum performance
class MinimalAppBottomNav extends StatelessWidget {
  const MinimalAppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      top: false,
      child: Material(
        color: Colors.white,
        elevation: 0,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;
              final color = isActive ? primary : Colors.black54;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, color: color, size: 24),
                        const SizedBox(height: 2),
                        FittedBox(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// InheritedWidget for efficient state management
class InheritedNavData extends InheritedWidget {
  const InheritedNavData({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required super.child,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static InheritedNavData of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<InheritedNavData>();
    assert(result != null, 'No InheritedNavData found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedNavData oldWidget) {
    return items != oldWidget.items ||
        currentIndex != oldWidget.currentIndex ||
        onTap != oldWidget.onTap;
  }
}

class InheritedNavItem extends InheritedWidget {
  const InheritedNavItem({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
    required super.child,
  });

  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  static _NavItemState of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<InheritedNavItem>();
    assert(result != null, 'No InheritedNavItem found in context');
    return _NavItemState(
      item: result!.item,
      isActive: result.isActive,
      onTap: result.onTap,
    );
  }

  @override
  bool updateShouldNotify(InheritedNavItem oldWidget) {
    return item != oldWidget.item ||
        isActive != oldWidget.isActive ||
        onTap != oldWidget.onTap;
  }
}

// Immutable state class for nav items
class _NavItemState {
  const _NavItemState({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;
}

// Cached version for even better performance
class CachedAppBottomNav extends StatelessWidget {
  const CachedAppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: _BottomNavCache(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
        child: const _CachedNavContent(),
      ),
    );
  }
}

class _CachedNavContent extends StatelessWidget {
  const _CachedNavContent();

  @override
  Widget build(BuildContext context) {
    final cache = _BottomNavCache.of(context);

    return Material(
      color: Colors.white,
      elevation: 0,
      child: SizedBox(
        height: 64,
        child: Row(
          children: List.generate(
            cache.items.length,
                (index) => _CachedNavItem(index: index),
          ),
        ),
      ),
    );
  }
}

class _CachedNavItem extends StatelessWidget {
  final int index;

  const _CachedNavItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final cache = _BottomNavCache.of(context);
    final item = cache.items[index];
    final isActive = index == cache.currentIndex;

    return Expanded(
      child: _NavItemCache(
        item: item,
        isActive: isActive,
        onTap: () => cache.onTap(index),
        child: const _CachedNavItemContent(),
      ),
    );
  }
}

class _CachedNavItemContent extends StatelessWidget {
  const _CachedNavItemContent();

  @override
  Widget build(BuildContext context) {
    final itemCache = _NavItemCache.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final color = itemCache.isActive ? primary : Colors.black54;

    return InkWell(
      onTap: itemCache.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(itemCache.item.icon, color: color, size: 24),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(
              itemCache.item.label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: itemCache.isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavCache extends InheritedWidget {
  const _BottomNavCache({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required super.child,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static _BottomNavCache of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_BottomNavCache>()!;
  }

  @override
  bool updateShouldNotify(_BottomNavCache oldWidget) {
    return items != oldWidget.items ||
        currentIndex != oldWidget.currentIndex ||
        onTap != oldWidget.onTap;
  }
}

class _NavItemCache extends InheritedWidget {
  const _NavItemCache({
    required this.item,
    required this.isActive,
    required this.onTap,
    required super.child,
  });

  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  static _NavItemCache of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NavItemCache>()!;
  }

  @override
  bool updateShouldNotify(_NavItemCache oldWidget) {
    return item != oldWidget.item ||
        isActive != oldWidget.isActive ||
        onTap != oldWidget.onTap;
  }
}