import 'package:flutter/material.dart';

/// 可折叠区域组件 - 用于渐进式展示内容
class ExpandableSection extends StatefulWidget {
  final String title;
  final Widget Function(bool expanded) builder;
  final IconData expandedIcon;
  final IconData collapsedIcon;
  final bool initiallyExpanded;
  final Color? accentColor;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.builder,
    this.expandedIcon = Icons.expand_less,
    this.collapsedIcon = Icons.expand_more,
    this.initiallyExpanded = false,
    this.accentColor,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header - 始终显示
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
              bottom: Radius.circular(_expanded ? 0 : 12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? widget.expandedIcon : widget.collapsedIcon,
                    color: accentColor,
                  ),
                ],
              ),
            ),
          ),
          // Content - 可折叠
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _expanded ? null : 0,
            child: Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: widget.builder(_expanded),
            ),
          ),
        ],
      ),
    );
  }
}

/// 可折叠列表项
class ExpandableListItem extends StatefulWidget {
  final Widget header;
  final List<Widget> children;
  final bool initiallyExpanded;
  final IconData expandedIcon;
  final IconData collapsedIcon;

  const ExpandableListItem({
    super.key,
    required this.header,
    required this.children,
    this.initiallyExpanded = false,
    this.expandedIcon = Icons.expand_less,
    this.collapsedIcon = Icons.expand_more,
  });

  @override
  State<ExpandableListItem> createState() => _ExpandableListItemState();
}

class _ExpandableListItemState extends State<ExpandableListItem> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(_expanded),
      children: [
        // Header
        InkWell(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Row(
            children: [
              Expanded(child: widget.header),
              Icon(
                _expanded ? widget.expandedIcon : widget.collapsedIcon,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
        // Children
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: _expanded
              ? Column(
                  key: ValueKey('expanded_${widget.key}'),
                  children: widget.children.map((child) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: child,
                    );
                  }).toList(),
                )
              : const SizedBox.shrink(key: ValueKey('collapsed_${widget.key}')),
        ),
      ],
    );
  }
}

/// 设置项分组组件
class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool showDivider;

  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider) const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// 可折叠的设置组
class ExpandableSettingsGroup extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final IconData icon;
  final bool initiallyExpanded;

  const ExpandableSettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.icon = Icons.settings,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableSettingsGroup> createState() => _ExpandableSettingsGroupState();
}

class _ExpandableSettingsGroupState extends State<ExpandableSettingsGroup> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
              bottom: Radius.circular(_expanded ? 0 : 12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          // Children
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _expanded ? null : 0,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Column(
                children: widget.children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 高级功能提示组件
class AdvancedFeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final Widget child;
  final bool initiallyExpanded;

  const AdvancedFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<AdvancedFeatureCard> createState() => _AdvancedFeatureCardState();
}

class _AdvancedFeatureCardState extends State<AdvancedFeatureCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
              bottom: Radius.circular(_expanded ? 0 : 12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _expanded ? null : 0,
            child: Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
