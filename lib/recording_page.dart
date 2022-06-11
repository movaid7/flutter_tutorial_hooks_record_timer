import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RecordingPage extends HookWidget {
  const RecordingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recording'),
        ),
        body: SizedBox(
          width: double.infinity,
          child: HookBuilder(builder: (_) {
            final recording = useState(false);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleButton(recording),
                const SizedBox(height: 35),
                _ElapsedTimeLabel(recording),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ElapsedTimeLabel extends HookWidget {
  const _ElapsedTimeLabel(this.recording);
  final ValueNotifier<bool> recording;

  @override
  Widget build(BuildContext context) {
    final tickerProvider = useSingleTickerProvider();
    final duration = useState(Duration.zero);
    final ticker = useMemoized(() {
      return tickerProvider.createTicker((elapsed) => duration.value = elapsed);
    });

    useEffect(() {
      recording.value ? ticker.start() : ticker.stop();
      return null;
    }, [recording.value]);

    useEffect(() => () => ticker.dispose(), []);

    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: recording.value,
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Text(
          duration.value.toString().substring(2, 10),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends HookWidget {
  const _CircleButton(this.recording);

  final ValueNotifier<bool> recording;

  @override
  Widget build(BuildContext context) {
    debugPrint('_CircleButton rebuilt.');
    // add animation controller to the hook
    final controller =
        useAnimationController(duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    final animation = useMemoized(
        () => Tween<double>(begin: 2.0, end: 20).animate(controller));

    return SizedBox(
      height: 100,
      width: 100,
      child: AnimatedBuilder(
        animation: animation,
        child: MaterialButton(
            textColor: Colors.white,
            onPressed: () => recording.value = !recording.value,
            color: Colors.red.shade900,
            shape: const CircleBorder(),
            child: AnimatedSwitcher(
              // https://stackoverflow.com/a/70396971/6122673
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: recording.value
                  ? const Icon(
                      Icons.stop_rounded,
                      size: 35,
                      key: ValueKey('icon1'),
                    )
                  : const Icon(
                      Icons.mic,
                      size: 35,
                      key: ValueKey('icon2'),
                    ),
            )),
        builder: (context, child) {
          return Container(
            decoration: ShapeDecoration(shape: const CircleBorder(), shadows: [
              if (recording.value)
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  spreadRadius: animation.value,
                  blurRadius: animation.value,
                ),
            ]),
            child: child,
          );
        },
      ),
    );
  }
}
