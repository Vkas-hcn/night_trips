import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_trips/cus/BgEditDialog.dart';
import 'package:night_trips/data/DataSetGet.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../data/DataUtils.dart';
import '../data/LocalStorage.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  bool _isPlaying = false;
  int indexBg = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  int _remainingTime = 15 * 60; // 初始时间 30 分钟（单位：秒）
  int _volume = 50; // 音量 0-100
  int _maxTime = 60 * 120; // 上限时间 120 分钟
  int _minTime = 60 * 5; // 下限时间 5 秒
  double _currentVolume = 0.5; // 当前音量 [0.0, 1.0]
  void _onPlayStatusChanged(bool isPlaying) {
    setState(() {
      _isPlaying = isPlaying;
    });
  }

  @override
  void initState() {
    super.initState();
    setBgIndex();
  }

  void setBgIndex() async {
    indexBg = await LocalStorage().getBgIndex();
    int? time = await LocalStorage().getDjsTime();
    double volume = await LocalStorage().getVolumeTime();

    if (time > 0) {
      _remainingTime = time;
    }
    if (volume > 0) {
      _volume = volume.toInt();
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _releaseResources();
  }

  void _releaseResources() {
    try {
      _stopMusic();
    } catch (e, stackTrace) {
      // 记录异常信息
      print('Error stopping music: $e');
      print('Stack trace: $stackTrace');
    } finally {
      _audioPlayer.dispose();
    }
  }

  // 格式化时间为 "00:00:00"
  String get formattedTime {
    int hours = _remainingTime ~/ 3600;
    int minutes = (_remainingTime % 3600) ~/ 60;
    int seconds = _remainingTime % 60;
    return "${_pad(hours)}:${_pad(minutes)}:${_pad(seconds)}";
  }

  String _pad(int value) {
    return value.toString().padLeft(2, '0');
  }

  // 开始倒计时
  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _stopMusic(); // 倒计时结束后停止音乐
          _timer?.cancel();
          setState(() {});
        }
      });
    });
  }

  // 暂停倒计时
  void _pauseTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  // 调整倒计时时间
  void _adjustTime(double delta) {
    double deltaInSeconds = delta * 60;
    setState(() {
      _remainingTime = (deltaInSeconds.toInt()).clamp(_minTime, _maxTime);
    });
    LocalStorage().setDjsTime(_remainingTime);
  }

  // 调整音量
  void _adjustVolume(double delta) {
    setState(() {
      _volume = (delta.toInt()).clamp(0, 100);
      _currentVolume = _volume / 100.0;
      _audioPlayer.setVolume(_currentVolume);
    });
  }

  void setPlayMusic(String path) async {
    if (_isPlaying) {
      _pauseMusic();
    } else {
      _playMusic(path);
    }
  }

  void _playMusic(String path) async {
    print("object----path-----${path}");
    await _audioPlayer.play(AssetSource(path));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    setState(() {
      _isPlaying = true;
    });
    _startTimer();
  }

  // 暂停音乐
  void _pauseMusic() {
    _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
    _pauseTimer();
  }

  // 停止音乐
  void _stopMusic() {
    _audioPlayer.stop();
    try {
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
    }
    _pauseTimer();
  }

  void setMusicData() async {
    int bgindex = await LocalStorage().getMuIndex();
    String path = DataUtils.mp3List[bgindex];
    setPlayMusic(path);
  }

  void backRefFun() async {}

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomSheetContent(
          adjustTimeCallback: _adjustTime,
        );
      },
    );
  }

  void _showBottomVolume(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomVolumeContent(
          adjustTimeCallback: _adjustVolume,
        );
      },
    );
  }

  void _showBottomList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomListContent(
          playCallback: setPlayMusic,
          isPlaying: _isPlaying,
          onPlayStatusChanged: _onPlayStatusChanged,
        );
      },
    );
  }

  void showBgEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: BgEditDialog(
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 每行显示3个项目
                  mainAxisSpacing: 1.0, // 主轴间距
                  crossAxisSpacing: 1.0, // 交叉轴间距
                ),
                itemCount: DataUtils.imagesBg.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              print("object----indexBg=$index");
                              LocalStorage().setBgIndex(index);
                              setState(() {
                                indexBg = index;
                              });
                              Navigator.of(context).pop(); // 关闭弹框
                            },
                            child: CustomCircle(
                              img: DataUtils.imagesBg[index],
                            ),
                          ),
                        ),
                        indexBg == index
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(top: 12.0, right: 20),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Image.asset(
                                    'assets/images/ic_c_bg_t.webp',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  );
                },
              ),
            ),
            onClose: () {
              // 关闭回调
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(DataUtils.imagesBg[indexBg]),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 56, right: 20, left: 20, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Image.asset('assets/images/ic_back.webp'),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showBgEditDialog(context);
                          },
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset('assets/images/setting_t.webp'),
                          ),
                        ),
                        SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            _showBottomList(context);
                          },
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset('assets/images/setting_m.webp'),
                          ),
                        ),
                        SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            _showBottomSheet(context);
                          },
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child:
                                Image.asset('assets/images/setting_time.webp'),
                          ),
                        ),
                        SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            _showBottomVolume(context);
                          },
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset('assets/images/setting_v.webp'),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 123),
                Text(formattedTime,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 290),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      setMusicData();
                    });
                  },
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Image.asset(_isPlaying
                        ? 'assets/images/player_button_stop.webp'
                        : 'assets/images/player_button.webp'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCircle extends StatelessWidget {
  final String img;

  const CustomCircle({Key? key, required this.img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 151,
        height: 171,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FutureBuilder<Image>(
            future: DataSetGet.getImagePath(img),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return snapshot.data!;
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}

class BottomSheetContent extends StatefulWidget {
  final Function(double) adjustTimeCallback;

  BottomSheetContent({required this.adjustTimeCallback});

  @override
  BottomSheetContentState createState() => BottomSheetContentState();
}

class BottomSheetContentState extends State<BottomSheetContent> {
  double selectedValue = 15.0;
  double addValue = 5.0;

  void _onTimeChanged(double duration) {
    widget.adjustTimeCallback(duration);
  }

  void _increase() {
    setState(() {
      if (selectedValue + addValue > 120) {
        selectedValue = 120;
        return;
      }
      selectedValue += addValue;
    });
  }

  void _decrease() {
    setState(() {
      if (selectedValue > 0.0) {
        selectedValue -= addValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF02223B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          Row(
            children: [
              Spacer(),
              SizedBox(width: 24),
              const Text(
                'Playback Time',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              IconButton(
                color: Colors.white,
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "${selectedValue.toStringAsFixed(0)}min",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 加减按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: Colors.white),
                onPressed: _decrease,
              ),
              Container(
                width: 210,
                height: 8,
                child: Slider(
                  value: selectedValue,
                  min: 0,
                  max: 120,
                  divisions: 5,
                  label: selectedValue.toStringAsFixed(0),
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.white.withOpacity(0.3),
                  onChanged: (double value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: _increase,
              ),
            ],
          ),
          SizedBox(height: 20),
          // 确认按钮
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: GestureDetector(
              onTap: () {
                _onTimeChanged(selectedValue);
                Navigator.pop(context);
              },
              child: Container(
                width: 243,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF31429D),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: const Center(
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 56),
        ],
      ),
    );
  }
}

class BottomVolumeContent extends StatefulWidget {
  final Function(double) adjustTimeCallback;

  const BottomVolumeContent({super.key, required this.adjustTimeCallback});

  @override
  BottomVolumeContentState createState() => BottomVolumeContentState();
}

class BottomVolumeContentState extends State<BottomVolumeContent> {
  double selectedValue = 50.0;
  double addValue = 5.0;

  @override
  void initState() {
    super.initState();
    setVolume();
  }

  void setVolume() async {
    double volume = await LocalStorage().getVolumeTime();
    if(volume>0){
      setState(() {
        selectedValue = volume;
      });
    }
  }

  void _onTimeChanged(double duration) {
    widget.adjustTimeCallback(duration);
    LocalStorage().setVolumeTime(duration);
  }

  void _increase() {
    setState(() {
      if (selectedValue + addValue > 100) {
        selectedValue = 100;
        return;
      }
      selectedValue += addValue;
    });
  }

  void _decrease() {
    setState(() {
      if (selectedValue > 0.0) {
        selectedValue -= addValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF02223B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          Row(
            children: [
              Spacer(),
              SizedBox(width: 24),
              const Text(
                'Volume',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              IconButton(
                color: Colors.white,
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "${selectedValue.toStringAsFixed(0)}%", // 显示当前值
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: Colors.white),
                onPressed: _decrease,
              ),
              Container(
                width: 210,
                height: 8,
                child: Slider(
                  value: selectedValue,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: selectedValue.toStringAsFixed(0),
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.white.withOpacity(0.3),
                  onChanged: (double value) {
                    setState(() {
                      selectedValue = value;
                    });
                    _onTimeChanged(selectedValue);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: _increase,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: GestureDetector(
              onTap: () {
                _onTimeChanged(selectedValue);
                Navigator.pop(context);
              },
              child: Container(
                width: 243,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF31429D),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: const Center(
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 56),
        ],
      ),
    );
  }
}

class BottomListContent extends StatefulWidget {
  final Function(String) playCallback;
  final bool isPlaying;
  final ValueChanged<bool> onPlayStatusChanged;

  const BottomListContent(
      {super.key,
      required this.playCallback,
      required this.isPlaying,
      required this.onPlayStatusChanged});

  @override
  BottomListContentState createState() => BottomListContentState();
}

class BottomListContentState extends State<BottomListContent> {
  int selectedIndex = 0;
  int selectedIndexRihgt = 0;

  bool dialogState = false;

  void playCallback(String name) {
    widget.playCallback(name);
  }

  @override
  void initState() {
    super.initState();
    setSindex();
  }

  void setSindex() async {
    int? sindex = await LocalStorage().getMuIndex();
    setState(() {
      selectedIndex = sindex;
      selectedIndexRihgt = sindex;
      dialogState = widget.isPlaying;
    });
  }

  void playRight(int index) {
    if (selectedIndex != index) {
      dialogState = false;
    }
    setState(() {
      selectedIndex = index;
      selectedIndexRihgt = index;
    });
    widget.onPlayStatusChanged(dialogState);
    setState(() {
      dialogState = !dialogState;
    });
    playCallback(DataUtils.mp3List[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF02223B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              const SizedBox(width: 24),
              const Text(
                'Music',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: DataUtils.mp3List.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      LocalStorage().setMuIndex(index);
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(selectedIndex == index
                                ? 'assets/images/bg_mu_c.webp'
                                : 'assets/images/bg_mu_d_c.webp'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 16),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 12.0, top: 4, right: 8, left: 8),
                              child: Row(
                                children: [
                                  Text(
                                    DataUtils.mp3ListName[index],
                                    style: const TextStyle(
                                      fontFamily: 'ab',
                                      fontSize: 14,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if ((selectedIndexRihgt == index &&
                                      dialogState))
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Image.asset(
                                          'assets/images/ic_frame.webp'),
                                    ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      playRight(index);
                                    },
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Image.asset((selectedIndexRihgt ==
                                                  index &&
                                              dialogState)
                                          ? 'assets/images/player_button_stop.webp'
                                          : 'assets/images/player_button.webp'),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              widget.onPlayStatusChanged(false);
              setState(() {
                dialogState = false;
              });
              LocalStorage().setMuIndex(selectedIndex);
              playCallback(DataUtils.mp3List[selectedIndex]);
              Navigator.pop(context);
            },
            child: Container(
              width: 243,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF31429D),
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Center(
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 56),
        ],
      ),
    );
  }
}
