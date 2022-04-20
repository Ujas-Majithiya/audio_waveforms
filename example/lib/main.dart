import 'package:audio_waveforms_example/chat_bubble.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Audio Waveforms',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver{
  late final RecorderController recorderController;
  late final PlayerController playerController;
  late final PlayerController playerController2;
  String? path;
  String? musicFile;
  String? musicFile2;
  bool isPlaying = false;
  bool isPlaying2 = false;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    recorderController = RecorderController()
      ..encoder = Encoder.aac
      ..sampleRate = 16000;
    playerController2 = PlayerController();
    playerController = PlayerController()
      ..addListener(() {if (mounted) setState(() {});
      });
    _getDir();
    _pickFile();
  }

  ///For this example, use this record from mic and directly provide that
  /// path to also generate waveforms from file
  void _getDir() async {
    final dir = await getApplicationDocumentsDirectory();
    path = "${dir.path}/music.aac";
  }

  void _pickFile() async {
    await Future.delayed(const Duration(seconds: 3)).whenComplete(() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        musicFile = result.files.single.path;
        await playerController.preparePlayer(musicFile!);
      } else {
        print("File not picked");
      }
    });
  }

  void _pickFile2() async {
    await Future.delayed(const Duration(seconds: 0)).whenComplete(() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        musicFile2 = result.files.single.path;
        await playerController2.preparePlayer(musicFile2!);
      } else {
        print("File not picked");
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    recorderController.disposeFunc();
    playerController.disposeFunc();
    playerController2.disposeFunc();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.detached){
      recorderController.disposeFunc();
      playerController.disposeFunc();
      playerController2.disposeFunc();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252331),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252331),
        elevation: 0,
        title: const Text('Jonathan'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ChatBubble(text: 'Hey', isSender: true),
            const ChatBubble(text: 'What\'s up?'),
            const ChatBubble(text: 'Can you share that audio?', isSender: true),
            const ChatBubble(text: 'sure'),
            if (playerController.playerState != PlayerState.stopped) ...[
              WaveBubble(
                playerController: playerController,
                onTap: () async {
                  // if (playerController2.playerState == PlayerState.playing) {
                  //    playerController2.pausePlayer();
                  // }
                  playerController.playerState == PlayerState.playing
                      ? playerController.pausePlayer()
                      : playerController.playerState == PlayerState.paused
                          ? playerController.resumePlayer()
                          : playerController.playerState == PlayerState.resumed
                              ? playerController.pausePlayer()
                              : playerController.startPlayer();
                },
              ),
              const ChatBubble(
                  text: 'That was cool, hear this!', isSender: true),
            ],
            if (playerController2.playerState != PlayerState.stopped) ...[
              WaveBubble(
                playerController: playerController2,
                isSender: true,
                onTap: () async {
                  // if (playerController.playerState == PlayerState.playing) {
                  //   playerController.pausePlayer();
                  // }
                  playerController2.playerState == PlayerState.playing
                      ? playerController2.pausePlayer()
                      : playerController2.playerState == PlayerState.paused
                          ? playerController2.resumePlayer()
                          : playerController2.playerState == PlayerState.resumed
                              ? playerController2.pausePlayer()
                              : playerController2.startPlayer();
                },
              ),
            ],
            const Spacer(),
            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isRecording
                      ? AudioWaveforms(
                          enableGesture: true,
                          size: const Size(250, 50),
                          waveController: recorderController,
                          waveStyle: const WaveStyle(
                            waveColor: Colors.white,
                            extendWaveform: true,
                            showMiddleLine: false,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: const Color(0xFF1E1B26),
                          ),
                          padding: const EdgeInsets.only(left: 18),
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                        )
                      : Row(
                          children: [
                            Container(
                              width: 200,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1B26),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: const EdgeInsets.only(left: 18),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: const TextField(
                                decoration: InputDecoration(
                                  hintText: "Type Something...",
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _pickFile2();
                              },
                              icon: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () async {
                    if (isRecording) {
                      await recorderController.stop(false);
                    } else {
                      await recorderController.record(path);
                    }
                    setState(() {
                      isRecording = !isRecording;
                    });
                  },
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  color: Colors.white,
                  iconSize: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
