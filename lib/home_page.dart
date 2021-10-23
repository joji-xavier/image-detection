import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? _image;
  bool _loading = false;
  List<dynamic>? _outputs;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

//Load the Tflite model
  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  classifyImage(image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Image Classification'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _image == null
                            ? Container()
                            : Image.file(
                                File(_image!.path),
                                fit: BoxFit.contain,
                              ),
                        const SizedBox(
                          height: 20,
                        ),
                        _outputs != null
                            ? Text(
                                '${_outputs![0]["label"]}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  background: Paint()..color = Colors.white,
                                ),
                              )
                            : Container()
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              gallery();
                            },
                            child: Text('Gallery')),
                        TextButton(
                            onPressed: () {
                              camera();
                            },
                            child: Text('Camera')),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

//input from camera
  Future camera() async {
    var image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
    classifyImage(image);
  }

  //input from gallery
  Future gallery() async {
    XFile? piture = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = piture;
    });
    classifyImage(piture);
  }
}
