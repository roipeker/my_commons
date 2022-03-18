part of obs;

/// Widget that provides different Builders according to
/// current [state].
class ObsStateBuilder<T> extends StatelessWidget {
  final ObsState<T> state;
  final Widget Function(ObsState<T>) builder;
  final Widget Function(String error)? onError;
  final Widget Function()? onEmpty;
  final Widget Function()? onLoading;

  const ObsStateBuilder({
    Key? key,
    required this.state,
    required this.builder,
    this.onError,
    this.onEmpty,
    this.onLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obs(() {
      if (state.isEmpty && onEmpty != null) {
        return onEmpty!();
      }
      if (state.isError && onError != null) {
        return onError!(state.errorText);
      }
      if (state.isLoading && onLoading != null) {
        return onLoading!();
      }
      return builder(state);
    });
  }
}

/// Extension to return different Widgets based on [ObsState]
extension FutureStatusExt<T> on ObsState<T> {
  Widget build(
      Widget Function(ObsState<T>) onData, {
        Widget Function(String errorText)? onError,
        Widget Function()? onLoading,
        Widget Function()? onEmpty,
      }) {
    return Obs(() {
      if (isEmpty && onEmpty != null) {
        return onEmpty();
      }
      if (isError && onError != null) {
        return onError(errorText);
      }
      if (isLoading && onLoading != null) {
        return onLoading();
      }
      return onData(this);
    });
  }
}