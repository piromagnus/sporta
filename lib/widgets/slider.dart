import 'package:flutter/material.dart';

// Global variables

Map<int,String> intensityLabels = {
  1 : "Très facile, je pourrais le faire pendant des heures (ex : balade tranquille). Je peux repartir directement",
  2 : """Facile, c'est un peu plus facile mais je peux tenir quelques heures sans problèmes (ex : rando tranquille en montage).
        \nAprès une petit pause, je pourrais repartir rapidement""",
  3 : "Assez facile, je pourrais tenir encore quelques heures mais avec des pauses. Avec",
  4 : "Moyen-Facile, je pourrais tenir une heure ou deux mais tellement plus ",
  5 : "Moyen, je pourrais tenir une bonne heure sans trop d'effort mais après ça tape ",
  6 : "Assez difficile, ça commence à être dur là, mais c'est soutenable",
  7 : "Effort difficile, je suis bien essoufflé, les douleurs sont bien présentes mais je pourrais continuer encore ",
  8 : "Effort intense, là c'est chaud, je pourrais me motiver à en refaire une ou deux mais pas plus",
  9 : "Effort très intense, ça fait bien mal mais je tiens au mental, faudrait me forcer pour repartir",
  10 : "Effort max, je peux pas rien faire de plus, je m'arrête directement. Max reps, Resistance max",
};

const int sliderH = 50;


// Widgets

class IntensitySlider extends StatefulWidget {
  const IntensitySlider({
    super.key,
    required this.onChanged,
    this.intensity,
    this.sliderHeight=sliderH
    });

  final double? intensity;
  final int sliderHeight;
  final ValueChanged<double> onChanged;

  @override
  State<IntensitySlider> createState() => _IntensitySliderState();
}

class _IntensitySliderState extends State<IntensitySlider> {

  late double _intensity;

  @override
  initState() {
    super.initState();
    _intensity = widget.intensity ?? 1;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular((widget.sliderHeight * .3)),
              ),
              gradient: const LinearGradient(
                  colors: [
                    Colors.green,
                    //Colors.orange,
                    Colors.red,
                  ],
                  begin:  FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 1.00),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child : 
            Column(children: [ 
              SizedBox(height: widget.sliderHeight*.2,),
              SliderTheme(
            data : SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white.withOpacity(1),
                    inactiveTrackColor: Colors.white.withOpacity(.5),

                    trackHeight: 8.0,
                    thumbShape: CustomSliderThumbCircle(
                      thumbRadius: widget.sliderHeight * .4,
                      min: 1,
                      max: 10,
                    ),
                    overlayColor: Colors.redAccent.withOpacity(.4),
                    valueIndicatorColor: Colors.white.withOpacity(0),
                    activeTickMarkColor: Colors.red.shade200.withOpacity(.7),
                    inactiveTickMarkColor: Colors.red.shade200.withOpacity(.7),
                    showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
            
            value: _intensity,
            min : 1,
            max : 10,
            divisions: 9,
            label : _intensity.toString(),
            onChanged: (value) => setState ((() {_intensity=value;
            widget.onChanged(value);})))), 
          Padding(padding: EdgeInsets.symmetric(horizontal : widget.sliderHeight*.5),
              child:Text("$_intensity : ${intensityLabels[_intensity]}",
              softWrap: true,
              maxLines: 3,
              // overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize:  widget.sliderHeight*.5),)),
          SizedBox(height: widget.sliderHeight*.1,)]));
  }
}





// Themes and components



class CustomSliderThumbRect extends SliderComponentShape {
  final double thumbRadius;
  final int thumbHeight;
  final int min;
  final int max;

  const CustomSliderThumbRect({
    required this.thumbRadius,
    required this.thumbHeight,
    required this.min,
    required this.max,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: center, width: thumbHeight * 1.2, height: thumbHeight * .6),
      Radius.circular(thumbRadius * .4),
    );

    final paint = Paint()
      ..color = sliderTheme.activeTrackColor! //Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span =  TextSpan(
        style:  TextStyle(         
            fontSize: thumbHeight * .3,
            fontWeight: FontWeight.w700,
            color: sliderTheme.thumbColor,
            height: 1),
        text: getValue(value));
    TextPainter tp =  TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
    Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawRRect(rRect, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min+(max-min)*value).round().toString();
  }
}


class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final int min;
  final int max;

  const CustomSliderThumbCircle({
    required this.thumbRadius,
    this.min = 0,
    this.max = 10,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = Colors.red.shade700 //Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span =  TextSpan(
      style:  TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.w700,
        color: sliderTheme.thumbColor, //Text Color of Value on Thumb
      ),
      text: getValue(value),
    );

    TextPainter tp =  TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
    Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawCircle(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min+(max-min)*value).round().toString();
  }
}