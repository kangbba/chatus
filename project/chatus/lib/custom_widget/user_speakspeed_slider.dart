import 'package:flutter/material.dart';

class UserSpeakSpeedSlider extends StatefulWidget {
  final double presenterSpeakIdleLimit;
  final ValueChanged<double> onChanged;

  const UserSpeakSpeedSlider({
    Key? key,
    required this.presenterSpeakIdleLimit,
    required this.onChanged,
  }) : super(key: key);

  @override
  _UserSpeakSpeedSliderState createState() => _UserSpeakSpeedSliderState();
}

class _UserSpeakSpeedSliderState extends State<UserSpeakSpeedSlider> {
  @override
  Widget build(BuildContext context) {
    final min = 1000;
    final max = 4000;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '매우빠름',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '${(widget.presenterSpeakIdleLimit.roundToDouble() * 0.001).toStringAsFixed(2)}초',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '매우느림',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Slider(
          value: widget.presenterSpeakIdleLimit,
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: (max - min) ~/ 100,
          label: '${(widget.presenterSpeakIdleLimit.roundToDouble() * 0.001).toStringAsFixed(2)}초',
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
