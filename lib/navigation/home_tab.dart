

typedef HomeTabSwitcher = void Function(int index);

HomeTabSwitcher? _switchHomeTab;

void registerHomeTabSwitcher(HomeTabSwitcher switcher) {
  _switchHomeTab = switcher;
}

void unregisterHomeTabSwitcher() {
  _switchHomeTab = null;
}

void requestHomeTab(int index) {
  _switchHomeTab?.call(index);
}
