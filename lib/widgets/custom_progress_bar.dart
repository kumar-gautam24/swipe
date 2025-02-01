import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double progress;
  final bool isIndeterminate;

  const CustomProgressIndicator({
    super.key,
    this.progress = 0.0,
    this.isIndeterminate = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isIndeterminate) {
      return Center(
        child: SpinKitDoubleBounce(
          color: Theme.of(context).primaryColor,
          size: 50.0,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
