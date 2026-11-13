import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'أجبيتي الموسوعية',
      theme: ThemeData(
        primaryColor: const Color(0xFF5B0E2D),
        scaffoldBackgroundColor: const Color(0xFFF4EFE6),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isManualDarkMode = false;
  String _savedBookmark = "لا يوجد علامة محفوظة بعد";
  Timer? _alarmTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _lastTriggeredTime = "";

  @override
  void initState() {
    super.initState();
    _alarmTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkPrayerAlarm();
    });
  }

  void _checkPrayerAlarm() async {
    final now = DateTime.now();
    int hour = now.hour;
    String period = hour >= 12 ? "م" : "ص";
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    String minute = now.minute.toString().padLeft(2, '0');
    String currentTimeStr = "$hour:$minute $period";

    if (currentTimeStr == _lastTriggeredTime) return;

    for (int i = 0; i < _prayerTimes.length; i++) {
      if (_alarmStates[i] == true && _prayerTimes[i].trim() == currentTimeStr) {
        _lastTriggeredTime = currentTimeStr;
        await _audioPlayer.play(AssetSource('alarm.mp3.mp3'));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('حان الآن موعد ${_prayers[i]} - (${_prayerTimes[i]})'),
              backgroundColor: const Color(0xFFD4AF37),
            ),
          );
        }
        break;
      }
    }
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  final List<String> _prayers = [
    'صلاة باكر  (6 صباحا)',
    'صلاة الساعة الثالثة  (9 صباحاً)',
    'صلاة الساعة السادسة  (12 ظهراً)',
    'صلاة الساعة التاسعة (3 عصراً)',
    'صلاة الغروب (5 مساءً)',
    'صلاة النوم (6 مساءً)',
    'صلاة نصف الليل (بخدماتها الثلاث)',
  ];

  final List<String> _extraPrayers = [
    'صلاة قبل التناول والأسرار المقدسة',
    'صلاة بعد التناول المقدس',
    'صلاة قبل المذاكرة والامتحان للطلبة',
    'صلاة قبل وبعد الطعام',
  ];

  final List<bool> _alarmStates = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  final List<String> _prayerTimes = [
    "5:00 ص",
    "9:00 ص",
    "12:00 ظ",
    "3:00 ع",
    "5:00 م",
    "6:00 م",
    "12:00 ص"
  ];

  String _getGregorianDate() {
    DateTime now = DateTime.now();
    List<String> months = [
      "يناير",
      "فبراير",
      "مارس",
      "أبريل",
      "مايو",
      "يونيو",
      "يوليو",
      "أغسطس",
      "سبتمبر",
      "أكتوبر",
      "نوفمبر",
      "ديسمبر"
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }

  String _getCurrentCopticDate() {
    DateTime now = DateTime.now();
    int day = now.day;
    int month = now.month;
    int copticDay = 1;
    String copticMonth = "";

    if (month == 11) {
      if (day <= 9) {
        copticDay = day + 21;
        copticMonth = "بابة";
      } else {
        copticDay = day - 9;
        copticMonth = "هاتور";
      }
    } else {
      copticDay = now.day;
      copticMonth = "بابة";
    }
    return "$copticDay $copticMonth";
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        _isManualDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF4EFE6);
    final Color cardColor =
        _isManualDarkMode ? const Color(0xFF334155) : Colors.white;
    final Color textColor =
        _isManualDarkMode ? Colors.white : const Color(0xFF0F172A);

    final List<Widget> screens = [
      Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          color: bgColor,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(12.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text('🔖 آخر قراءة محفوظة: $_savedBookmark',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text('الصلوات الأساسية المتاحة:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              fontSize: 16)),
                    ),
                    ...List.generate(_prayers.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFD4AF37), width: 1.5),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.auto_stories,
                              color: Color(0xFFD4AF37)),
                          title: Text(_prayers[index],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Color(0xFFD4AF37)),
                          onTap: () {
                            if (index <= 6) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReadingScreen(
                                        prayerIndex: index,
                                        prayerName: _prayers[index],
                                        onSaveBookmark: (title) => setState(
                                            () => _savedBookmark = title))),
                              );
                            }
                          },
                        ),
                      );
                    }),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Text('الصلوات الطقسية المتممة:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              fontSize: 16)),
                    ),
                    ...List.generate(_extraPrayers.length, (index) {
                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                                color: Color(0xFFD4AF37), width: 1)),
                        child: ListTile(
                          leading: const Icon(Icons.menu_book,
                              color: Color(0xFF1A237E)),
                          title: Text(_extraPrayers[index],
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.arrow_forward,
                              color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReadingScreen(
                                      prayerIndex: index + 10,
                                      prayerName: _extraPrayers[index],
                                      onSaveBookmark: (title) => setState(
                                          () => _savedBookmark = title))),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12.0),
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFD4AF37), width: 1.5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الميلادي: ${_getGregorianDate()}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    Text('القبطي: ${_getCurrentCopticDate()}',
                        style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFD4AF37), width: 1.5)),
              child: const Row(
                children: [
                  Icon(Icons.access_alarm, color: Color(0xFFD4AF37), size: 28),
                  SizedBox(width: 15),
                  Text('منبهات الصلوات التلقائية:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _prayers.length,
              itemBuilder: (context, index) {
                return Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side:
                          const BorderSide(color: Color(0xFFD4AF37), width: 1)),
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    leading: Icon(Icons.notifications_active,
                        color: _alarmStates[index]
                            ? const Color(0xFFD4AF37)
                            : Colors.grey),
                    title: Text(_prayers[index],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor)),
                    subtitle: Text('تنبيه يومي ثابت: ${_prayerTimes[index]}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: Switch(
                      value: _alarmStates[index],
                      activeThumbColor: const Color(0xFFD4AF37),
                      onChanged: (bool value) =>
                          setState(() => _alarmStates[index] = value),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('أجبيتي',
            style: TextStyle(
                color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isManualDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: const Color(0xFFD4AF37)),
            onPressed: () =>
                setState(() => _isManualDarkMode = !_isManualDarkMode),
          )
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF0F172A),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'أجبيتي'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'المنبهات'),
        ],
      ),
    );
  }
}

class ReadingScreen extends StatefulWidget {
  final int prayerIndex;
  final String prayerName;
  final Function(String) onSaveBookmark;
  const ReadingScreen(
      {super.key,
      required this.prayerIndex,
      required this.prayerName,
      required this.onSaveBookmark});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  double _fontSize = 22.0;
  late PageController _pageController;
  int _currentPageIndex = 0;
  late List<Map<String, String>> _activePages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _activePages = _getPrayerPages(widget.prayerIndex);
  }

  List<Map<String, String>> _getPrayerPages(int index) {
    switch (index) {
      case 0:
        return _bakerTextData;
      case 1:
        return _thirdTextData;
      case 2:
        return _sixthTextData;
      case 3:
        return _ninthTextData;
      case 4:
        return _sunsetTextData;
      case 5:
        return _sleepTextData;
      case 6:
        return _midnightTextData;
      case 10:
        return _extraPrayersData1;
      case 11:
        return _extraPrayersData1;
      case 12:
        return _extraPrayersData2;
      case 13:
        return _extraPrayersData3;
      default:
        return [
          {'title': 'قريباً', 'text': 'جاري جلب نصوص الساعة المختارة حرفياً...'}
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNight = widget.prayerName.contains('النوم') ||
        widget.prayerName.contains('الليل');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: DropdownButton<int>(
              value: _currentPageIndex,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down,
                  color: Color(0xFFD4AF37), size: 24),
              style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              dropdownColor: const Color(0xFF0F172A),
              items: List.generate(_activePages.length, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(_activePages[index]['title']!),
                );
              }),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentPageIndex = newValue;
                  });
                  _pageController.animateToPage(newValue,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                }
              },
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_add, color: Colors.amber),
              onPressed: () {
                String currentTitle =
                    "${widget.prayerName} - ${_activePages[_currentPageIndex]['title']!}";
                widget.onSaveBookmark(currentTitle);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('تم حفظ مكان قراءتكِ بنجاح: $currentTitle')));
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _activePages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _activePages[index];
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isNight
                            ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                            : [
                                const Color(0xFFFDFBF7),
                                const Color(0xFFF4EFE6)
                              ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 95.0),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isNight
                              ? Colors.black.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.3),
                              width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              page['text']!,
                              style: TextStyle(
                                fontSize: _fontSize,
                                height: 1.7,
                                color: isNight
                                    ? const Color(0xFFFFF8FAFC)
                                    : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 30.0, bottom: 15.0),
                              child: Center(
                                child: Text(
                                  'All rights reserved by the developer TA ®',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 25,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoomInBtn',
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: const Color(0xFFD4AF37),
                    shape: const CircleBorder(
                        side: BorderSide(color: Color(0xFFD4AF37), width: 1)),
                    onPressed: () => setState(() {
                      if (_fontSize < 45) _fontSize += 2;
                    }),
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    heroTag: 'zoomOutBtn',
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: const Color(0xFFD4AF37),
                    shape: const CircleBorder(
                        side: BorderSide(color: Color(0xFFD4AF37), width: 1)),
                    onPressed: () => setState(() {
                      if (_fontSize > 14) _fontSize -= 2;
                    }),
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, String>> _bakerTextData = [
  {
    'title': '١. مقدمة كل ساعة والصلاة الربانية وصلاة الشكر',
    'text':
        'بِاسْمِ الآبِ وَالابْنِ وَالرُّوحِ الْقُدُسِ الإِلَهِ الْوَاحِدِ، آمِينَ.\n\nكيرياليصون (يا رب ارحم). كيرياليصون. كيرياليصون. يا رب بارك. آمين.\n\nالمجد للآب والابن والروح القدس، الآن وكل أوان وإلى دهر الدهور، آمين.\n\nالصلاة الربانية:\nأبانا الذي في السماوات، ليتقدس اسمك، ليأت ملكوتك، لتكن مشيئتك كما في السماء كذلك على الأرض. خبزنا الذي للغد أعطنا اليوم، واغفر لنا ذنوبنا كما نغفر نحن أيضاً للمذنبين إلينا، ولا تدخلنا في تجربة، لكن نجنا من الشرير، بالمسيح يسوع ربنا، لأن لك الملك والقوة والمجد إلى الأبد. آمين.\n\nصلاة الشكر:\nفلنشكر صانع الخيرات الرحوم الله، أبا ربنا وإلهنا ومخلصنا يسوع المسيح، لأنه سترنا وأعاننا، وحفظنا وقبلنا إليه وأشفق علينا وعضدنا، وأتى بنا إلى هذه الساعة. هو أيضاً فلنسأله أن يحفظنا في هذا اليوم المقدس وكل أيام حياتنا بكل سلام، الضابط الكل الرب إلهنا.\n\nأيها السيد الرب الإله ضابط الكل أبا ربنا وإلهنا ومخلصنا يسوع المسيح، نشكرك على كل حال ومن أجل كل حال وفي كل حال، لأنك سترتنا وأعنتنا وحفظتنا وقبلتنا إليك وأشفقت علينا وعضدتنا وأتيت بنا إلى هذه الساعة.\n\nمن أجل هذا نسأل ونطلب من صلاحك يا محب البشر، امنحنا أن نكمل هذا اليوم المقدس وكل أيام حياتنا بكل سلام مع خوفك. كل حسد، وكل تجربة، وكل فعل الشيطان، ومؤامرة الناس الأشرار، وقيام الأعداء الخفيين والظاهرين، انزعها عنا وعن سائر شعبك، وعن موضعك المقدس هذا. أما الصالحات والنافعات فارزقنا إياها، لأنك أنت الذي أعطيتنا السلطان أن ندوس الحيات والعقارب وكل قوة العدو. ولا تدخلنا في تجربة، لكن نجنا من الشرير بالنعمة والرأفات ومحبة البشر اللواتي لابنك الوحيد ربنا وإلهنا ومخلصنا يسوع المسيح، هذا الذي من قبله المجد والإكرام والعز والسجود تليق بك معه مع الروح القدس المحيي المساوي لك الآن وكل أوان وإلى دهر الدهور. آمين.'
  },
  {
    'title': '٢. المزمور الخمسون وبدء الصلاة (هلم نسجد والبولس والأمانة)',
    'text':
        'المزمور الخمسون:\nارحمني يا الله كعظيم رحمتك، ومثل كثرة رأفتك امحُ إثمي. اغسلني كثيراً من إثمي ومن خطيتي طهرني، لأني عارف بإثمي وخطيتي أمامي في كل حين. لك وحدك أخطأت، والشر قدامك صنعت، لكي تتبرر في أقوالك وتغلب إذا حوكمت. لأني هاأنذا بالإثم حُبل بي، وبالخطايا ولدتني أمي. لأنك هكذا قد أحببت الحق، إذ أوضحت لي غوامض حكمتك ومستوراتها. تنضح عليّ بزوفاك فأطهر، تغسلني فأبيض أكثر من الثلج. تسمعني سروراً وفرحاً، فتبتهج عظامي المنحقة. اصرف وجهك عن خطاياي، وامحُ كل آثامي. قلباً نقياً اخلق فيّ يا الله، وروحاً مستقيماً جدد في أحشائي. لا تطرحني من قدام وجهك، وروحك القدوس لا تنزعه مني. امنحني بهجة خلاصك، وبروح مدبر عضدني. فأعلم الأثمة طرقك، والمنافقون إليك يرجعون. نجني من الدماء يا الله إله خلاصي، فيبتهج لساني ببرك. يا رب افتح شفتيّ، فيخبر فمي بتسبيحك. لأنك لو آثرت الذبيحة لكنت الآن أعطي، ولكنك لا تسر بالمحرقات. فالذبيحة لله روح منسحق، القلب المنكسر والمتواضع لا يرذله الله. أحسن يا رب بمسرتك إلى صهيون، ولتبنَ أسوار أورشليم. حينئذ تسر بذبائح البر قرباناً ومحرقات، حينئذ يقربون على مذابحك العجول. هللويا.\n\nبدء الصلاة: هلم نسجد:\nهلم نسجد هلم نسأل المسيح إلهنا. هلم نسجد، هلم نطلب من المسيح ملكنا. هلم نسجد، هلم نتضرع إلى المسيح مخلصنا. يا ربنا يسوع المسيح كلمة الله إلهنا، بشفاعة القديسة مريم وجميع قديسيك، احفظنا ولنبدأ بدءا حسنا. ارحمنا كإرادتك إلى الأبد. الليل عبر، نشكرك يا رب ونسأل أن تحفظنا في هذا اليوم بغير خطية وأنقذنا.\n\nالبولس من رسالة أفسس (4: 1-5):\nأسألكم أنا الأسير في الرب أن تسلكوا كما يحق للدعوة التي دعيتم إليها، بكل تواضع القلب والوداعة وطول الأناة، محتملين بعضكم بعضا بالمحبة، مسرعين إلى حفظ وحدانية الروح برباط الصلح الكامل لكي تكونوا جسدًا واحدًا وروحًا واحدا، كما دعيتم في رجاء دعوتكم الواحد. ربٍّ واحد. وإيمان واحد. ومعمودية واحدة.\n\nمن إيمان الكنيسة:\ واحد هو الروح القدس المعزى الواحد بأقنومه، منبثق من الآب، يطهر كل البرية. يعلمنا أن نسجد للثالوث القدوس بلاهوت واحد وطبيعة واحدة، نسبحه ونباركه إلى الأبد. آمين.بدء صلاة باكر:\ باكر من النهار المبارك، أقدمها للمسيح ملكي وإلهي، وأرجوه أن يغفر لي خطاياي.'
  },
  {
    'title': '٣. مزامير باكر (1 و 2 و 3)',
    'text':
        ' (1) المزمور الأول\nطوبى للرجل الذي لم يسلك في مشورة المنافقين. وفى طريق الخطاة لم يقف، وفى مجلس المستهزئِينَ لم يجلس. لكن في ناموس الرب إرادته، وفى ناموسه يلهج نهارا وليلا. فيكون كالشجرة المغروسة على مجارى المياه التي تعطى ثمرها في حينه. وورقها لا ينتثر، وكل ما يصنع ينجح فيه. ليس كذلك المنافقون، ليس كذلك. لكنهم كالهباء الذي تذريه الريح عن وجه الأرض. فلهذا لا يقوم المنافقون في الدينونة، ولا الخطاة في مجمع الصديقين. لأن الرب يعرف طريق الأبرار، وأما طريق المنافقين فتباد. هلليلويا.\n\n(2) المزمور الثاني\nلماذا ارتجت الأمم، وتفكرت الشعوب في الباطل. قام ملوك الأرض وتآمر الرؤساء معا على الرب وعلى مسيحه قائلين: لنقطع أغلالهما، ولنطرح عنا نيرهما. الساكن في السموات يضحك بهم، والرب يستهزئ بهم. حينئذ يكلمهم بغضبه، وبرجزه يرجفهم. أنا أقمته ملكا على صهيون جبل قدسه، لأكرز بأمر الرب. الرب قال لي: أنت ابني، وأنا اليوم ولدتك. اسألني فأعطيك الأمم ميراثك، وسلطانك إلى أقطار الأرض. لترعاهم بقضيب من حديد. ومثل آنية الفخار تسحقهم. فالآن أيها الملوك افهموا، وتأدبوا يا جميع قضاة الأرض اعبدوا الرب بخشية. وهللوا له برعدة. الزموا الأدب لئلا يغضب الرب فتضلوا عن طريق الحق. عندما يتقد غضبه بسرعة، طوبى لجميع المتكلين عليه هلليلويا.\n\n(3) المزمور الثالث\nيا رب لماذا كثر الذين يحزنونني، كثيرون قاموا علي. كثيرون يقولون لنفسي، ليس له خلاص بإلهه. أنت يا رب أنت هو ناصري، مجدي ورافع رأسي. بصوتي إلى الرب صرخت. فاستجاب لي من جبل قدسه. أنا اضطجعت ونمت، ثم استيقظت لأن الرب ناصري. فلا أخاف من ربوات الجموع المحيطين بي القائمين على. قم يا رب خلصني يا إلهي، لأنك ضربت كل من يعاديني باطلا. أسنان الخطاة سحقتها. للرب الخلاص وعلى شعبه بركته. هلليلويا.'
  },
  {
    'title': '٤. مزامير باكر (4 و 5 و 6)',
    'text':
        '(4) المزمور الرابع\nإذ دعوتُ استجبتَ لي يا إله بري. في الشدة فرجت عنى. تراءف على يا رب واسمع صلاتي. يا بني البشر، حتى متى تثقل قلوبكم؟ لماذا تحبون الباطل وتبتغون الكذب؟ اعلموا أن الرب قد جعل صفيه عجبا. الرب يستجيب لي إذا ما صرخت إليه. اغضبوا ولا تخطئوا، الذي تقولونه في قلوبكم اندموا عليه في مضاجعكم. اذبحوا ذبيحة البر، وتوكلوا على الرب. كثيرون يقولون: من يرينا الخيرات؟ قد أضاء علينا نور وجهك يا رب. أعطيت سرورا لقلبي أوفر من الذين كثرت حنطتهم وخمرهم وزيتهم. فبالسلامة أضطجع أيضا وأنام، لأنك أنت وحدك يا رب أسكنتني على الرجاء هلليلويا.\n\n(5) المزمور الخامس\nأنصت يا رب لكلماتي، واسمع صراخي. أصغ إلى صوت طلبتي يا ملكي وإلهي، لأني إليك أصلى. يا رب بالغداة تسمع صوتي، بالغداة أقف أمامك وتراني. لأنك إله لا تشاء الإثم، ولا يساكنك من يصنع الشر. ولا يثبت مخالفو الناموس أمام عينيك. يا رب أبغضت جميع فاعلي الإثم، وتهلك كل الناطقين بالكذب. رجل الدماء والغاش يرذله الرب. أما أنا فبكثرة رحمتك أدخل بيتك، وأسجد قدام هيكل قدسك بمخافتك. اهدني يا رب ببرك. من أجل أعدائي سهل أمامي طريقك. لأن ليس في أفواههم صدق. باطل هو قلبهم. حنجرتهم قبر مفتوح. وبألسنتهم قد غشوا. فدنهم يا لله. وليسقطوا من جميع مؤامراتهم وككثرة نفاقهم استأصلهم، لأنهم قد أغضبوك يا رب. وليفرح جميع المتكلين عليك، إلى الأبد يسرون وتحل فيهم. ويفتخر بك كل الذين يحبون اسمك. لأنك أنت باركت الصديق يا رب. كما بترس المسرة كللتنا. هلليلويا.\n\n(6) المزمور السادس\nيا رب لا تبكتني بغضبك، ولا تؤدبني بسخطك. ارحمني يا رب فإني ضعيف، اشفني يا رب فإن عظامي قد اضطربت ونفسي قد انزعجت جدا. وأنت يا رب فإلي متى؟ عد ونج نفسي، وأحيني من أجل رحمتك. لأنه ليس في الموت من يذكرك ولا في الجحيم من يعترف لك. تعبت في تنهدي. أعوم كل ليلة سريري، وبدموعي أبل فراشي. تعكرت من الغضب عيناي. شاخت من سائر أعدائي . ابعدوا عنى يا جميع فاعلي الإثم. لأن الرب قد سمع صوت بكائي. الرب سمع تضرعي، الرب لصلاتي قبل، فليَخزَ وليضطرب جدا جميع أعدائي، وليرتدوا إلى ورائهم بالخزي سريعا جدا. هلليلويا.'
  },
  {
    'title': '٥. مزامير باكر (7 و 8 و 11 و 12)',
    'text':
        '(7) المزمور الثامن\nأيها الرب ربنا، ما أعجب اسمك في الأرض كلها! لأنه قد ارتفع عظم جلالك فوق السموات. من أفواه الأطفال والرضعان هيأت سبحا، من أجل أعدائك، لتسكت عدوا ومنتقما. لأني أرى السموات أعمال أصابعك. القمر والنجوم أنت أسستها. من هو الإنسان حتى تذكره، أو ابن الإنسان حتى تفتقده؟! أنقصته قليلا عن الملائكة. بالمجد والكرامة توجته، وعلى أعمال يديك أقمته. كل شيء أخضعت تحت قدميه، الغنم والبقر جميعا وأيضا بهائم الحقل، وطيور السماء وأسماك البحر السالكة في البحار. أيها الرب ربنا. ما أعجب اسمك في الأرض كلها. هلليلويا.\n\n(8) المزمور الحادي عشر\nخلصني يا رب فإن البار قد فني، وقد قلت الأمانة من بنى البشر. تكلم كل واحد مع قريبه بالأباطيل. شفاه غاشة في قلوبهم وبقلوبهم تخاطبوا. يستأصل الرب جميع الشفاه الغاشة، واللسانَ الناطق بالعظائم. الذين قالوا: نعظم ألسنتنا شفاهنا معنا، فمن هو رب علينا؟! من أجل شقاء المساكين وتنهد البائسين الآن أقوم، يقول الرب، أصنع الخلاص علانية. كلام الرب كلام نقي، فضة محماة مجربة في الأرض، قد صفيت سبعة أضعاف. وأنت يا رب تنجينا وتحفظنا من هذا الجيل وإلى الدهر. المنافقون حولنا يمشون. مثل ارتفاعك أكثرت أعمار بنى البشر. هلليلويا.\n\n(9) المزمور الثاني عشر\nإلى متى يا رب تنساني؟ إلى الانقضاء؟ حتى متى تصرف وجهك عني؟ إلى متى أردد هذه المشورات في نفسي، وهذه الأوجاع في قلبي النهار كله؟ إلى متى يرتفع عدوى علي؟ انظر واستجب لي يا ربي وإلهي. أنر عيني لئلا أنام نوم الموت، لئلا يقول عدوي: إني قد قويت عليه. الذين يحزنونني يتهللون إن أنا زللت. أما أنا فعلى رحمتك توكلت. يبتهج قلبي بخلاصك. أسبح الرب المحسنَ إلي، وأرتل لاسم الرب العلي. هلليلويا.'
  },
  {
    'title': '٦. مزامير باكر (14 و 15 و 18 و 24 و 26)',
    'text':
        '(10) المزمور الرابع عشر\nيا رب من يسكن في مسكنك، ومن يحل في جبل قدسك؟ السالك بلا عيب والفاعل البر، والمتكلم بالحق في قلبه، الذي لا يغش بلسانه، ولا يصنع بقريبه سوءا، ولا يقبل عارا على جيرانه. فاعل الشر مرذول أمامه، ويمجد الذين يتقون الرب. الذي يحلف لقريبه ولا يغدر به. ولا يعطى فضته بالربا، ولا يقبل الرشوة على الأبرياء. الذي يصنع هذا لا يتزعزع إلى الأبد. هلليلويا.\n\n(11) المزمور الخامس عشر\nاحفظني يا رب فإني عليك توكلت. قلت للرب: أنت ربي، ولا تحتاج إلى صلاحي. أظهر عجائبه لقديسيه الذين في أرضه، وصنع فيهم كل مشيئاته. كثرت أمراضهم الذين أسرعوا وراء آخر. لا أجمع مجامعهم من الدماء، ولا أذكر أسماءهم بشفتي. الرب هو نصيب ميراثي وكأسي. أنت الذي ترد إلى ميراثي. حبال المساحة وقعت لي في أرض خصبة، وإن ميراثي لثابت لي. أبارك الرب الذي أفهمني. وأيضا إلى الليل تنذرني كليتاي. تقدمت فرأيت الرب أمامي في كل حين، لأنه عن يميني لكي لا أتزعزع. من أجل هذا فرح قلبي وتهلل لساني. وأيضا جسدي يسكن على الرجاء. لأنك لا تترك نفسي في الجحيم. ولا تدع قدوسك يرى فسادا. قد عرفتني سبل الحياة. تملأني فرحا مع وجهك. البهجة في يمينك إلى الانقضاء. هلليلويا.\n\n(12) المزمور الثامن عشر\nالسموات تحدث بمجد الله، والفلك يخبر بعمل يديه. يوم إلى يوم يبدي قولا. وليل إلى ليل يظهر علما. لا قول ولا كلام. لا تسمع أصواتهم، في كل الأرض خرج منطقهم. وإلى أقصى المسكونة بلغت أقوالهم. جعل في الشمس مظلته. وهى مثل العريس الخارج من خدره. تتهلل مثل الجبار الذي يسرع في طريقه. من أقصى السماء خروجها، ومنتهاها إلى أقصى السماء ولا شيء يختفي من حرارتها. ناموس الرب بلا عيب، يرد النفوس. شهادة الرب صادقة، تعلم الأطفال. فرائض الرب مستقيمة، تفرح القلب. وصية الرب مضيئة، تنير العينين عن بعد. خشية الرب زكية، دائمة إلى أبد الأبد. أحكام الرب أحكام حق وعادلة معا. شهوة قلبه مختارة. أفضل من الذهب والحجر الكثير الثمن، وأحلى من العسل والشهد. عبدك يحفظها، وفى حفظها ثواب عظيم. الهفوات من يشعر بها؟ من الخطايا المستترة يا رب طهرني، ومن الغرباء احفظ عبدك حتى لا يتسلطوا على، فحينئذ أكون بلا عيب، وأتنقى من خطية عظيمة. وتكون جميع أقوال فمي وفكر قلبي مرضية أمامك في كل حين. يا رب أنت معيني ومخلصي. هلليلويا.\n\n(13) المزمور الرابع والعشرون\nإليك يا رب رفعت نفسي، يا إلهي عليك توكلت. فلا تخزني إلى الأبد، ولا تشْمت بي أعدائي. لأن جميع الذين ينتظرونك لا يخزون. ليخز الذين يصنعون الإثم باطلا. أظهر لي يا رب طرقك، وعلمني سبلك. اهدني إلى عدلك وعلمني. لأنك أنت هو الله مخلصي، وإياك انتظرت النهار كله. اذكر يا رب رأفاتك ومراحمك، لأنها ثابتة منذ الأزل. خطايا شبابي وجهالاتي لا تذكر. كرحمتك اذكرني أنت من أجل صلاحك يا رب. الرب صالح ومستقيم، لذلك يرشد الذين يخطئون في الطريق. يهدى الودعاء في الحكم، يعلم الودعاء طرقه. جميع طرق الرب رحمة وحق لحافظي عهده وشهاداته. من أجل اسمك يا رب اغفر لي خطيتي لأنها كثيرة. من هو الإنسان الخائف الرب، يرشده في الطريق التي ارتضاها. نفسه في الخيرات تثبت، ونسله يرث الأرض. الرب عز لخائفيه، واسم الرب لأتقيائه. ولهم يعلن عهده. عيناي تنظران إلى الرب في كل حين، لأنه يجتذب من الفخ رجلي. انظر إلى وارحمني، لأني ابن وحيد وفقير أنا. أحزان قلبي قد كثرت، أخرجني من شدائدي. انظر إلى ذلي وتعبي. واغفر لي جميع خطاياي. انظر إلى أعدائي فإنهم قد كثروا وأبغضوني ظلما. احفظ نفسي ونجني، لا أخزى لأني عليك توكلت. الذين لا شر فيهم والمستقيمون لصقوا بي، لأني انتظرتك يا رب. يا الله أنقذ إسرائيل من جميع شدائده. هلليلويا.\n\n(14) المزمور السادس والعشرون\nالرب نوري وخلاصي ممن أخاف؟! الرب حصن حياتي ممن أجزع؟! عندما يقترب الأشرار منى ليأكلوا لحمي، مضايقي وأعدائي عثروا وسقطوا. إن يحاربني جيش فلن يخاف قلبي. وإن قام على قتال ففي هذا أنا أطمئن. واحدة سألت من الرب وإياها ألتمس. أن أسكن في بيت الرب كلَّ أيام حياتي. لكي أنظر نعيم الرب، وأتفرس في هيكله المقدس. لأنه أخفاني في خيمته. في يوم شدتي، سترني بستر مظلته. وعلى صخرة رفعني. والآن هوذا قد رفع رأسي على أعدائي. طفت وذبحت في مظلته ذبيحة التهليل، أسبح وأرتل للرب. استمع يا رب صوتي الذي به دعوتك. ارحمني واستجب لي فإنه لك قال قلبي: طلبت وجهك، ووجهك يا رب ألتمس. لا تحجب وجهك عنى، ولا تنبذ بغضبك عبدك. كن لي معينا، لا تخذلني ولا ترفضني يا الله مخلصي. فإن أبى وأمي قد تركاني، وأما الرب فقبلني. علمني يا رب طريقك، واهدني في سبيل مستقيم من أجل أعدائي. لا تسلمني إلى أيدي مضايقي، لأنه قد قام على شهود زور، وكذبوا علي ظلما. وأنا أؤمن أنى أعاين خيرات الرب في أرض الأحياء. انتظر الربّ، تقوَّ وليتشدد قلبك وانتظر الرب. هلليلويا.'
  },
  {
    'title': '٧. مزامير باكر (62 و 66 و 69 و 112 و 142)',
    'text':
        '(15) المزمور الثاني والستون\nيا الله إلهي إليك أبكر، عطشت إليك نفسي. يشتاق إليك جسدي، في أرض مقفرة وموضع غير مسلوك ومكان بلا ماء. هكذا ظهرت لك في القدس، لأرى قوّتك ومجدك. لان رحمتك أفضل من الحياة. شفتاي تسبحانِك. لذلك أباركك في حياتي، وباسمك أرفع يدي. فتشبع نفسي كما من شحم ودسم. بشفاه الابتهاج نبارك اسمك. كنت أذكرك على فراشي، وفى أوقات الأسحار كنت أرتل لك. لأنك صرت لي عونا, وبظل جناحيك أبتهج. التحقت نفسي وراءك، ويمينك عضدتني. أما الذين طلبوا نفسي للهلاك، فيدخلون في أسافل الأرض. ويُدفعون إلى يد السيف، ويكونون أنصبة للثعالب. أما الملك فيفرح بالله، ويفتخر كل من يحلف به. لأن أفواه المتكلمين بالظلم تُسَدُّ. هلليلويا.\n\n(16) المزمور السادس والستون\nليتراءف الله علينا ويباركنا، وليظهر وجهه علينا ويرحمنا. لتعرَف في الأرض طريقك، وفى جميع الأمم خلاصك. فلتعترف لك الشعوب يا الله، فلتعترف لك الشعوب كلها. لتفرح الأمم وتبتهج، لأنك تحكم في الشعوب بالاستقامة، وتهدى الأمم في الأرض. فلتعترف لك الشعوب يا الله، فلتعترف لك الشعوب جميعا. الأرض أعطت ثمرتها، فليباركنا الله إلهنا. ليباركنا الله، فلتخشه جميع أقطار الأرض. هلليلويا.\n\n(17) المزمور التاسع والستون\nاللهم التفت إلى معونتي، يا رب أسرع وأعنى. ليَخزَ ويخجل طالبو نفسي، وليرتد إلى خلف ويخجل الذين يبتغون لي الشر. وليرجع بالخزي سريعا القائلون لي: نِعِمَّا نِعِمَّا. وليبتهج ويفرح بك جميع الذين يلتمسونك، وليقل في كل حين محبو خلاصك: فليتعظم الرب. وأما أنا فمسكين وفقير، اللهم أعنى. أنت معيني ومخلصي يا رب فلا تبطئ.هلليلويا.\n\n(18) المزمور المائة والثاني عشر\nسبحوا الرب أيها الفتيان، سبحوا اسم الرب. ليكن اسم الرب مباركا من الآن وإلى الأبد. من مشارق الشمس إلى مغاربها باركوا اسم الرب. الرب عالٍ على كل الأمم، فوق السموات مجده. من مثل الرب إلهنا؟!‍ الساكن في الأعالي، الناظِر إلى المتواضعين في السماء وعلى الأرض. المقيم المسكين من التراب، الرافع البائس من المِزْبَلة لكي يُجلسه مع رؤساء شعبه. الذي يجعل العاقرَ ساكنة في بيت، أم أولادٍ فرحة. هلليلويا.\n\n(19) المزمور المائة والثاني والأربعون\nيا رب اسمع صلاتي. أنصت إلى طلبتي بحقك. استجب لي بعدلك. ولا تدخل في المحاكمة مع عبدك، فإنه لن يتزكى قدامك كل حي. لأن العدو قد اضطهد نفسي، وأذل في الأرض حياتي. أجلسَني في الظلمات مثل الموتى منذ الدهر، أضجر في روحي، اضطرب في قلبي. تذكرت الأيام الأولى ولهجت في كل أعمالك، وفى صنائع يديك كنت أتأمل. بسطت إليك يدي، صارت نفسي لك مثل أرض بلا ماء. استجب لي يا رب عاجلا، فقد فنيت روحي. لا تحجب وجهك عنني، فأشابه الهابطين في الجب. فلأسمع في الغدوات رحمتك، فإني عليك توكلت. عرفني يا رب الطريق التي أسلك فيها، لأني إليك رفعت نفسي. أنقذني من أعدائي يا رب، فإني لجأت إليك. علمني أن أصنع مشيئتك، لأنك أنت هو إلهي. روحك القدوس فليهدني إلى الاستقامة، من أجل اسمك يا رب تحييني. بحقك تخرج من الشدة نفسي، وبرحمتك تستأصل أعدائي. وتهلك جميع مضايقي نفسي، لأني أنا هو عبدك أنا. هلليلويا.'
  },
  {
    'title': '٨. إنجيل باكر (يوحنا 1: 1-17)',
    'text':
        'من إنجيل معلمنا يوحنا البشير، بركاته علينا جميعاً، آمين:\n\nفي البدء كان الكلمة، والكلمة كان عندَ الله. وكان الكلمة الله، هذا كان في البدء عند الله. كل شيء به كان، وبغيره لم يكن شيء مما كان. فيه كانت الحياة، والحياة كانت نورَ الناس، والنور أضاء في الظلمة، والظلمة لم تدركه.\n\nكان إنسان مرسل من الله اسمه يوحنا، هذا جاء للشهادة ليشهد للنور ليؤمن الكل بواسطته. لم يكن هو النور بل ليشهد للنور، كان النورُ الحقيقي الذي ينير كل إنسان آتيا إلى العالم. كان في العالم، وكُوِّنَ العالم به، ولم يعرفه العالم. إلى خاصته جاء، وخاصته لم تقبله. وأما الذين قبلوه فأعطاهم سلطانًا أن يصيروا أبناء الله، الذين يؤمنون باسمه، الذين ولدوا ليس من دم، ولا من مشيئة جسد، ولا من مشيئة رجل، لكن من الله ولدوا.\n\nوالكلمة صار جسدًا وحل بيننا ورأينا مجده مثل مجد ابن وحيد لأبيه مملوءًا نعمة وحقًا. يوحنا شهد له وصرخ قائلًا: هذا هو الذي قلت عنه إن الذي يأتي بعدى كان قبلي، لأنه كان أقدم منى. ونحن جميعا أخذنا من ملئه، ونعمة عوضًا عن نعمة. لأن الناموس بموسى أعطى. أما النعمة والحق فبيسوع المسيح صارا. والمجد لله دائمًا أبديًا أمين.'
  },
  {
    'title': '٩. قطع صلاة باكر النهارية بحسب طقس الكنيسة',
    'text':
        'القطع الطقسية لباكر:\nأيها النور الحقيقي الذي يضئ لكل إنسان آت إلى العالم، أتيت إلى العالم بمحبتك للبشر، وكل الخليقة تهللت بمجيئك. خلصت أبانا آدم من الغواية، وعتقت أمنا حواء من طلقات الموت، وأعطيتنا روح البنوة، نسبحك ونباركك قائلين: المجد للآب والابن والروح القدس.\n\nإذا ما دخل إلينا وقت الصباح أيها المسيح إلهنا النور الحقيقي، فلتشرق فينا الحواس المضيئة والأفكار النورانية. ولا تغطينا ظلمة الآلام، لكي نسبحك عقليا مع داود قائلين: "سبقت عيناي وقت السحر لأتلو في جميع أقوالك". اسمع أصواتنا كعظيم رحمتك، ونجنا أيها الرب إلهنا بتحننك. الآن وكل أوان وإلى دهر الداهرين آمين.\n\nأنت هي أم النور المكرمة، من مشارق الشمس إلى مغاربها يقدمون لك تمجيدات يا والدة الإله السماء الثانية، لأنك أنت هي الزهرة النيرة غير المتغيرة والأم الباقية عذراء، لأن الآب اختارك، والروح القدس ظللك، والابن تنازل وتجسد منك. فاسأليه أن يعطى الخلاص للعالم الذي خلقه، وأن ينجيَّه من التجارب. نسبحه تسبيحا جديدا ونباركه الآن وكل أوان وإلى الأبد. أمين.\n\nكيرياليسون (يا رب ارحم) ٤١ مرة بخوف إلهي وخشوع تام.'
  },
  {
    'title': '١٠. تسبحة الملائكة، التقديسات الثلاث، والسلام لكِ وبدء الإيمان',
    'text':
        'تسبحة الملائكة والتقديس:\nالمجد لله في الأعالي وعلى الأرض السلام وفى الناس المسرة. نسبحك. نباركك. نخدمك. نسجد لك. نعترف لك. ننطق بمجدك. نشكرك من أجل عظم مجدك، أيها الرب المالك على السموات، الله الآب ضابط الكل، والرب الابن الواحد الوحيد يسوع المسيح، والروح القدس. أباركك كل يوم، وأسبح اسمك القدوس إلى الأبد وإلى أبد الأبد. آمين.\nتفضل يا رب أن تحفظنا في هذا اليوم بغير خطية. مبارك أنت أيها الرب إله آبائنا، ومتزايد اسمك بركة ومجدًا إلى الأبد. آمين.\n\nالثلاث تقديسات الأرثوذكسية:\nقدوس الله، قدوس القوى، قدوس الحي الذي لا يموت، الذي ولد من العذراء، ارحمنا. قدوس الله، قدوس القوى، قدوس الحي الذي لا يموت، الذي صلب عنا، ارحمنا. قدوس الله، قدوس القوى، قدوس الحي الذي لا يموت، الذي قام من الأموات وصعد إلى السموات، ارحمنا.\nالمجد للآب والابن والروح القدس، الآن وكل أوان وإلى دهر الدهور آمين. أيها الثالوث القدوس ارحمنا. يا رب اغفر لنا خطايانا. يا رب اغفر لنا آثامنا. يا رب افتقد واشف أمراض شعبك من أجل اسمك القدوس. يا رب ارحم، يا رب ارحم، يا رب ارحم. أبانا الذي في السموات...\n\nالسلام لكِ وعظمة أم النور:\nالسلام لك. نسألك أيتها القديسة الممتلئة مجدا العذراء كل حين، والدة الإله أم المسيح، أصعدي صلواتنا إلى ابنك الحبيب ليغفر لنا خطايانا. السلام للتي ولدت لنا النور الحقيقي المسيح إلهنا، العذراء القديسة... نعظمك يا أم النور الحقيقي، ونمجدك أيتها العذراء القديسة.'
  },
  {
    'title': '١١. قانون الإيمان، قدوس قدوس، والتحاليل والطلبة الختامية لباكر',
    'text':
        'بدء قانون الإيمان الأرثوذكسي المقر بالكامل:\nبالحقيقة نؤمن بإله واحد، الله الآب، ضابط الكل، خالق السماء والأرض، ما يُرَى وما لا يرى. ونؤمن برب واحد يسوع المسيح، ابن الله الوحيد، المولود من الآب قبل كل الدهور... نعم نؤمن بالروح القدس، الرب المحيي المنبثق من الآب... ونعترف بمعمودية واحدة لمغفرة الخطايا. وننتظر قيامة الأموات وحياة الدهر الآتي. أمين.\n\nقدوس قدوس قدوس رب الصباؤوت. السماء والأرض مملوءتان من مجدك وكرامتك. ارحمنا يا الله الآب ضابط الكل. أيها الثالوث القدوس ارحمنا. أيها الرب إله القوات كن معنا، لأنه ليس لنا معين في شدائدنا وضيقاتنا سواك. حل واغفر واصفح لنا يا الله عن سيئاتنا...\n\nالتحليل الأول لباكر:\nأيها الرب إله القوات، الكائن قبل الدهور والدائم إلى الأبد، الذي خلق الشمس لضياء النهار، والليل راحة لكل البشر، نشكرك يا ملك الدهور لأنك أجزتنا هذا الليل بسلام وأتيت بنا إلى هذه الساعة المقدسة... تفضل يا رب واحفظنا في هذا اليوم بغير خطية...\n\nالتحليل الثاني والآخر لباكر:\nيا الله مخرج النور، مظهر ضياء النهار، صانع الصبح، ومبدئ المساء. اقبل تضرعنا وشكرنا المسيحي غير المرذول... املأ قلوبنا بالفرح والسرور لنسلك في وصاياك المقدسة.\n\nطلبة آخر كل ساعة لباكر:\nارحمنا يا الله ثم ارحمنا. يا من في كل وقت وكل ساعة، في السماء وعلى الأرض، مسجود له وممجد. المسيح إلهنا الصالح، الطويل الروح، الكثير الرحمة، الجزيل التحنن، الذي يحب الصديقين ويرحم الخطاة الذين أولهم أنا. الذي لا يشاء موت الخاطئ مثل ما يرجع ويحيا. الداعي الكل إلى الخلاص لأجل الموعد بالخيرات المنتظرة. يا رب اقبل منا في هذه الساعة وكل ساعة طلباتنا. سهل حياتنا، وأرشدنا إلى العمل بوصاياك. قدس أرواحنا. طهر أجسامنا. قوم أفكارنا. نق نياتنا. اشف أمراضنا واغفر خطايانا. ونجنا من كل حزن رديء ووجع قلب. أحطنا بملائكتك القديسين، لكي نكون بمعسكرهم محفوظين ومرشدين، لنصل إلى اتحاد الإيمان وإلى معرفة مجدك غير المحسوس وغير المحدود، فإنك مبارك إلى الأبد. أمين.\n\nاللهم اجعلنا مستحقين أن نقول بشكر:\nأبانا الذي في السموات...'
  }
];
final List<Map<String, String>> _thirdTextData = [
  {
    'title': '١. مقدمة كل ساعة، الصلاة الربانية، وصلاة الشكر',
    'text':
        'بِاسْمِ الآبِ وَالابْنِ وَالرُّوحِ الْقُدُسِ الإِلَهِ الْوَاحِدِ، آمِينَ.\n\nكيرياليصون (يا رب ارحم). كيرياليصون. كيرياليصون. يا رب بارك. آمين.\n\nالمجد للآب والابن والروح القدس، الآن وكل أوان وإلى دهر الدهور، آمين.\n\nالصلاة الربانية:\nأبانا الذي في السماوات، ليتقدس اسمك، ليأت ملكوتك، لتكن مشيئتك كما في السماء كذلك على الأرض. خبزنا الذي للغد أعطنا اليوم، واغفر لنا ذنوبنا كما نغفر نحن أيضاً للمذنبين إلينا، ولا تدخلنا في تجربة، لكن نجنا من الشرير، بالمسيح يسوع ربنا، لأن لك الملك والقوة والمجد إلى الأبد. آمين.\n\nصلاة الشكر الطقسية:\nفلنشكر صانع الخيرات الرحوم الله، أبا ربنا وإلهنا ومخلصنا يسوع المسيح، لأنه سترنا وأعاننا، وحفظنا وقبلنا إليه وأشفق علينا وعضدنا، وأتى بنا إلى هذه الساعة. هو أيضاً فلنسأله أن يحفظنا في هذا اليوم المقدس وكل أيام حياتنا بكل سلام، الضابط الكل الرب إلهنا.\n\nأيها السيد الرب الإله ضابط الكل أبا ربنا وإلهنا ومخلصنا يسوع المسيح، نشكرك على كل حال ومن أجل كل حال وفي كل حال، لأنك سترتنا وأعنتنا وحفظتنا وقبلتنا إليك وأشفقت علينا وعضدتنا وأتيت بنا إلى هذه الساعة.\n\nمن أجل هذا نسأل ونطلب من صلاحك يا محب البشر، امنحنا أن نكمل هذا اليوم المقدس وكل أيام حياتنا بكل سلام مع خوفك. كل حسد، وكل تجربة، وكل فعل الشيطان، ومؤامرة الناس الأشرار، وقيام الأعداء الخفيين والظاهرين، انزعها عنا وعن سائر شعبك، وعن موضعك المقدس هذا. أما الصالحات والنافعات فارزقنا إياها، لأنك أنت الذي أعطيتنا السلطان أن ندوس الحيات والعقارب وكل قوة العدو. ولا تدخلنا في تجربة، لكن نجنا من الشرير بالنعمة والرأفات ومحبة البشر اللواتي لابنك الوحيد ربنا وإلهنا ومخلصنا يسوع المسيح، هذا الذي من قبله المجد والإكرام والعز والسجود تليق بك معه مع الروح القدس المحيي المساوي لك الآن وكل أوان وإلى دهر الدهور. آمين.'
  },
  {
    'title': '٢. المزمور الخمسون وبدء صلاة الساعة الثالثة',
    'text':
        'المزمور الخمسون (مزمور التوبة):\nارحمني يا الله كعظيم رحمتك، ومثل كثرة رأفتك امحُ إثمي. اغسلني كثيراً من إثمي ومن خطيتي طهرني، لأني عارف بإثمي وخطيتي أمامي في كل حين. لك وحدك أخطأت، والشر قدامك صنعت، لكي تتبرر في أقوالك وتغلب إذا حوكمت. لأني هاأنذا بالإثم حُبل بي، وبالخطايا ولدتني أمي. لأنك هكذا قد أحببت الحق، إذ أوضحت لي غوامض حكمتك ومستوراتها. تنضح عليّ بزوفاك فأطهر، تغسلني فأبيض أكثر من الثلج. تسمعني سروراً وفرحاً، فتبتهج عظامي المنحقة. اصرف وجهك عن خطاياي، وامحُ كل آثامي. قلباً نقياً اخلق فيّ يا الله، وروحاً مستقيماً جدد في أحشائي. لا تطرحني من قدام وجهك، وروحك القدوس لا تنزعه مني. امنحني بهجة خلاصك، وبروح مدبر عضدني. فأعلم الأثمة طرقك، والمنافقون إليك يرجعون. نجني من الدماء يا الله إله خلاصي، فيبتهج لساني ببرك. يا رب افتح شفتيّ، فيخبر فمي بتسبيحك. لأنك لو آثرت الذبيحة لكنت الآن أعطي، ولكنك لا تسر بالمحرقات. فالذبيحة لله روح منسحق، القلب المنكسر والمتواضع لا يرذله الله. أحسن يا رب بمسرتك إلى صهيون، ولتبنَ أسوار أورشليم. حينئذ تسر بذبائح البر قرباناً ومحرقات، حينئذ يقربون على مذابحك العجول. هللويا.\n\nبدء صلاة الساعة الثالثة:\nصلاة الساعة الثالثة من النهار المبارك، أقدمها للمسيح ملكي وإلهي، وأرجوه أن يغفر لي خطاياي. من مزامير معلمنا داود داود النبي بركاته علينا آمين. هلم نسجد هلم نسأل المسيح إلهنا.'
  },
  {
    'title': '٣. مزامير الساعة الثالثة (19 و 22 و 23)',
    'text':
        '(1) المزمور التاسع عشر\nيستجيب لك الرب في يوم شدتك، ينصرك اسم إله يعقوب. يرسل لك عونا من قدسه، ومن صهيون يعضدك. يذكر جميع ذبائحك، ويستسمن محرقاتك. يعطيك الرب حسب قلبك، ويتمم كل مشورتك. نعترف لك يا رب بخلاصك، وباسم إلهنا ننمو. يكمل الرب كل سؤالك. الآن علمت أن الرب قد خلص مسيحه، واستجاب له من سماء قدسه بجبروت خلاص يمينه. هؤلاء بمركبات وهؤلاء بخيل، ونحن باسم الرب إلهنا ننمو. هم عثروا وسقطوا، ونحن قمنا وانتصبنا. يا رب خلص مَلِكك واستجب لنا يوم ندعوك. هلليلويا.\n\n(2) المزمور الثاني والعشرون\nالرب يرعاني فلا يعوزني شيء. في مراع خضر يسكنني، إلى ماء الراحة يوردني. يرد نفسي. يهدني إلى سبل البر من أجل اسمه. إن سلكت في وسط ظلال الموت فلا أخاف شرا، لأنك أنت معي. عصاك وعكازك هما يعزيانني. هيأت قدامى مائدة تجاه مضايقي. مسحت بالزيت رأسي، وكأسك روتني بقوة. ورحمتك تدركني جميع أيام حياتي، ومسكني في بيت الرب إلى مدى الأيام. هلليلويا.\n\n(3) المزمور الثالث والعشرون\nللرب الأرض وملؤها، المسكونة وجميع الساكنين فيها. هو على البحار أسسها، وعلى الأنهار هيأها. من يصعد إلى جبل الرب، أو من يقوم في موضع قدسه؟ الطاهر اليدين، النقي القلب. الذي لم يحمل نفسه إلى الباطل ولم يحلف بالغش. هذا ينال بركة من الرب، ورحمة من الله مخلصه، هذا هو جيل الذين يطلبون الرب ويبتغون وجه إله يعقوب. ارفعوا أيها الرؤساء أبواكم، وارتفعي أيتها الأبواب الدهرية، فيدخل ملك المجد. من هو هذا ملك المجد؟ الرب العزيز القدير، الرب القوى في الحروب. ارفعوا أيها الرؤساء أبوابكم، وارتفعي أيتها الأبواب الدهرية، فيدخل ملك المجد. من هو هذا ملك المجد؟ رب القوات، هذا هو ملك المجد. هلليلويا.'
  },
  {
    'title': '٤. مزامير الساعة الثالثة (25 و 28 و 29 و 33)',
    'text':
        '(4) المزمور الخامس والعشرون\nاحكم لي يا رب فإني بدعتي سلكت، وعلى الرب توكلت فلا أضعف. اختبرني يا رب وجربنى، نقِّ قلبي وكليتي. لأن رحمتك أمام عيني، وقد ارتضيت بحقك. لم أجلس مع محفل باطل، ومع مخالفي الناموس لم أدخل. أبغضتُ مجمع الأشرار، ومع المنافقين لم أجلس. أغسل يدي بالنقاوة، وأطوف بمذبحك يا رب. لأسَمِّع صوت تسبيحك، وأنطق بجميع عجائبك. يا رب أحببت جمال بيتك، وموضع مسكن مجدك. فلا تهلك مع المنافقين نفسي، ولا مع رجال الدماء حياتي. الذين في أيديهم الإثم، ويمينهم امتلأت رشوة. أما أنا فبدعتي سلكت. أنقذني وارحمني لأن رجلي وقفت في الاستقامة. في الجماعات أباركك يا رب. هلليلويا.\n\n(5) المزمور الثامن والعشرون\nقدموا للرب يا أبناء الله. قدموا للرب أبناء الكباش. قدموا للرب مجدا وكرامة. قدموا للرب مجدا لاسمه. اسجدوا للرب في دار قدسه. صوت الرب على المياه. إله المجد أرعدَ. الرب على المياه الكثيرة. صوت الرب بقوة. صوت الرب بجلال عظيم. صوت الرب يحطم الأرز. الرب يكسر أرز لبنان ويسحقها مثل عجلٍ، لبنان، وسِريون، مثل ابن وحيد القرن. صوت الرب يقطع لهيب النار. صوت الرب يزلزل القفر. الرب يزلزل برية قادش. صوت الرب يولد الأيائل ويكشف الغابات. وفى هيكله المقدس كل واحد ينطق بالمجد. الرب يسكن في الطوفان، الرب يجلس ملكا إلى الأبد. الرب يعطى شعبه قوة، الرب يبارك شعبه بالسلام. هلليلويا.\n\n(6) المزمور التاسع والعشرون\nأعظمك يا رب لأنك احتضنتني، ولم تشمت بي أعدائي. أيها الرب إلهي، صرخت إليك فشفيتني. يا رب أصعدتَ من الجحيم نفسي، وخلصتني من الهابطين في الجب. رتلوا للرب يا جميع قديسيه، واعترفوا لذكر قدسه. لأن سخطا في غضبه، وحياة في رضاه. في العشاء يحل البكاء، وفى الصباح السرور. أنا قلت في نعيمي لا أتزعزع إلى الأبد، يا رب بمسرتك أعطيتَ جمالي قوة. صرفت وجهك عنى، فصرتُ قلقا. إليك يا رب أصرخ، وإلى إلهي أتضرع. أية منفعة من دمى إذا هبطتُ إلى الجحيم؟ هل يعترف لك التراب أو يخبر بحقك؟ سمع الرب فرحمني، الرب صار لي عونا. حولت نوحي إلى فرح لي، مزقت مسحي ومنطقتني سرورا. لكي ترتل لك نفسي ولا يحزن قلبي. أيها الرب إلهي إلى الأبد أعترف لك. هلليلويا.\n\n(7) المزمور الثالث والثلاثون\nأبارك الرب في كل وقت، وفى كل حين تسبحته في فمي، بالرب تفتخر نفسي، يسمع الودعاء فيفرحون. عظموا الرب معي، لنرفع اسمه جميعا. طلبتُ إلى الرب فاستجاب لي، ومن جميع مخاوفي نجاني. تقدموا إليه واستنيروا، ووجوهكم لا تشقى. هذا المسكين صرخ فاستمعه الرب، ومن جميع ضيقاته خلصه. يعسكر ملاك الرب حول كل خائفيه وينجيهم. ذوقوا وانظروا ما أطيبَ الربَ! طوبى للإنسان المتكل عليه. اتقوا الرب يا جميع قديسيه، فإن الذين يتقونه لا يعوزهم شيء. الأغنياء افتقروا وجاعوا، أما الذين يبتغون الرب فلا يعوزهم أي خير. هلم أيها البنون استمعوا لي، فأعلمكم مخافة الرب. من هو الإنسان الذي يهوى الحياة، ويحب أن يرى أياما صالحة؟ صن لسانك عن الشر، وشفتيك عن النطق بالغش. حد عن الشر واصنع الخير، اطلب السلامة واتبعها. فإن عيني الرب على الصديقين، وأذنيه مصغيتان إلى طلبتهم. وجْه الرب ضد صانعي الشر، ليمحو من الأرض ذكرهم. الصديقون صرخوا والرب استجاب لهم، ومن جميع شدائدهم نجاهم. قريب هو الرب من منسحقي القلب، ويخلص المتواضعين بالروح. كثيرة هي أحزان الصديقين، ومن جميعها ينجيهم الرب. يحفظ الرب جميع عظامهم، وواحدة منها لا تنكسر. يموت الخطاة بشرهم، ومبغضو الصديق يندمون. الرب ينقذ نفوس عبيده، ولا يندم جميع المتكلين عليه. هلليلويا.'
  },
  {
    'title': '٥. مزامير الساعة الثالثة (40 و 42 و 44 و 45 و 46)',
    'text':
        '(8) المزمور الأربعون\nطوبى لمن يتعطف على المسكين، في يوم الشر ينجيه الرب. الرب يحفظه ويحييه، ويجعله في الأرض مغبوطا، ولا يسلمه لأيدي أعدائه. الرب يعينه على سرير وجعه، إنك رتبت مضجعه كله في مرضه. أنا قلت يا رب ارحمني، اشف نفسي لأني قد أخطأتُ إليك. أعدائي تقوّلوا على شرا: متى يموت ويباد اسمه؟ الذي دخل ليراني كان يتكلم بالرياء، وقلبه يضمر له شرا، ثم كان يخرج خارجا ويتكلم علىّ. تهامس على جميع أعدائي، وتشاوروا على بالسوء. وكلاما مخالفا للناموس رتبوا علىّ، قالوا: "ألا يعود الراقد أن يقوم؟" حتى إنسان سلامتي الذي وثقت به، الذي أكل خبزي رفع علىّ عقبه. وأنت يا رب ارحمني وأقمني فأجازيهم. بهذا علمت أنك هويتني، لأن عدوي لن يسر بي. أما أنا فمن أجل دعتي قبلتني، وثبتني أمامك إلى الأبد. مبارك الرب إله إسرائيل، من الأزل وإلى الأبد يكون. هلليلويا.\n\n(9) المزمور الثاني والأربعون\nاحكم لي يا رب وانتقم لمظلمتي، من أمة غير بارة. ومن إنسان ظالم وغاش نجني، لأنك أنت هو إلهي وقوتي. لماذا أقصيتني؟ ولماذا أسلك كئيبا من مضايقة عدوي؟ أرسل نورك وحقك، فإنهما يهديانني ويصعدانني إلى جبلك المقدس وإلى مسكنك. فأدخل إلى مذبح الله، تجاه وجه الله الذي يفرح شبابي. أعترف لك بالقيثارة يا الله إلهي. لماذا أنت حزينة يا نفسي، ولماذا تزعجينني؟ توكلي على الله فإني أعترف له، خلاص وجهي هو إلهي. هلليلويا.\n\n(10) المزمور الرابع والأربعون\nفاض قلبي بكلام صالح. إني أخبر الملكَ بأفعالي، لساني قلمُ كاتبٍ ماهر. إنك أبرع جمالا من بنى البشر. وقد انسكبت النعمة على شفتيك، فلذلك باركك الله إلى الدهر. تقلد سيفك على فخدك أيها القوى جلالك وجمالك. استله وانجح واملك من أجل الحق والدعة والعدل، وتهديك بالعجب يمينك. نبلك مسنونة في قلب أعداء الملك أيها الجبار، الشعوب تحتك يسقطون. كرسيك يا الله إلى دهر الدهر، قضيب الاستقامة هو قضيب ملكك. لأنك أحببتَ البر وأبغضتَ الإثم. من أجل هذا مسحك الله إلهك بزيت البهجة أفضلَ من رفقائك. المر والميعة والسليخة طيب ثيابك. من قصور العاج التي أبهجتك. بنات الملوك في تكريمك. قامت الملكة عن يمينك، مشتملة بثوب موشى بالذهب، مزينة بأنواع كثيرة. اسمعي يا ابنتي وانظري وأميلي أذنك، وانسَيْ شعبك وبيت أبيك. فإن الملكَ قد اشتهى حسنك، لأنه هو ربك وله تسجدين. وله تسجد بنات صورَ بالهدايا، ويترجّى وجهَه أغنياءُ شعب الأرض. كل مجد ابنة الملك من داخل، مشتملة بأطراف موشاة بالذهب، مزينة بأشكال كثيرة. تدخُل إلى الملك عذارى في إثرها، جميع قريباتها إليه يُقدَّمْن. يَبْلغن بفرح وابتهاج، يَدخُلن إلى هيكل الملك. ويكون لك أبناءٌ عوضا عن آبائك، تقيمهم رؤساء على سائر الأرض، ويذكرون اسمك جيلا بعد جيل. من أجل ذلك تعترف لك الشعوب يا الله إلى الدهر، وإلى دهر الدهور. هلليلويا.\n\n(11) المزمور الخامس والأربعون\nإلهنا ملجأنا وقوتنا، ومعيننا في شدائدنا التي أصابتنا جدا. لذلك لا نخشى إذا تزعزعت الأرض، وانقلبت الجبال إلى قلب البحار. تعج المياه وتجيش، وتتزعزع الجبال بعزته. مجارى الأنهار تفرح مدينة الله. لقد قدس العلي مسكنه، والله في وسطها فلن تتزعزع. يعين الله وجهها. اضطربت الأمم، وماجت الممالك. أبدى صوته، فتزلزلت الأرض. الرب إله القوات معنا، ناصرنا هو إله يعقوب. هلم فانظروا أعمال الرب، التي جعلها آيات على الأرض. الذي ينزع الحروب من أقاصي الأرض. يسحق قسيهم ويكسر سلاحهم، ويحرق أتراسهم بالنار. ثابروا واعلموا أنى أنا هو الله، أرترف بين الأمم وأتعالى في الأرض. الرب إله القوات معنا، ناصرنا هو إله يعقوب. هلليلويا.\n\n(12) المزمور السادس والأربعون\nيا جميع الأمم صفقوا بأيديكم، هللوا لله بصوت الابتهاج. لأن الرب عال ومرهوب، ملك كبير على كافة الأرض. أخضع الشعوب لنا، والأمم تحت أقدامنا، اختارنا ميراثا له، جمال يعقوب الذي أحبه. صعد الله بتهليل، والرب بصوت البوق. رتلوا لإلهنا رتلوا، رتلوا لمليكنا رتلوا، لأن الرب هو ملك الأرض كلها. رتلوا بفهم لأن الرب قد ملك على جميع الأمم. الله جلس على كرسيه المقدس. رؤساء الشعوب اجتمعوا مع إله إبراهيم، لأن أعزاء الله قد ارتفعوا في الأرض جدا. هلليلويا.'
  },
  {
    'title': '٦. إنجيل الساعة الثالثة والقطع والتحليل القانوني والطلبة',
    'text':
        'من إنجيل معلمنا يوحنا البشير بركاته علينا، آمين:\n\n(إنجيل يوحنا 14: 26-15: 3)\nمتى جاء المعزى الروح القدس الذي سيرسله الآب باسمي، فهو يعلمكم كل شيء ويذكركم بكل ما قلته لكم. سلامي أترك لكم. سلامي أنا أعطيكم. ليس كما يعطى العالمُ أعطيكم. لا تضطرب قلوبكم ولا جزع. سمعتم أنى قلت لكم إني أمضى ثم آتى إليكم. لو كنتم تحبونني لكنتم تفرحون لأني أمضى إلى الآب، لأن أبى أعظمُ منى. وقد قلتُ لكم الآن قبل أن يكون، حتى متى كان تؤمنون. لست أكلمكم كلاما كثيرا بعد، لأن رئيس هذا العالم آتٍ وليس له في شيءٌ. لكن لكي يعلمَ العالمُ أنني أحب أبى، وكما أوصاني أبى هكذا أفعل، قوموا ننطلق من ههنا. أنا هو الكرمة الحقيقية وأبى الكرام. كل غصن فيّ لا يأتي بثمر يقطعه. وكل ما يأتي بثمر ينقيه ليأتي بثمر أكثر. وأنتم من قبْل أنقياءُ من أجل الكلام الذي كلمتكم به. اثبتوا فيَّ وأنا أيضا فيكم. (والمجد لله دائمًا).\n\nالقطع الطقسية الكبرى للملك السمائي مفرودة:\nروحك القدوس يا رب الذي أرسلته على تلاميذك القديسين ورسلك المكرمين في الساعة الثالثة، هذا لا تنزعه منا أيها الصالح، لكن جدده في أحشائنا. قلبا نقيا اخلق فيَّ يا الله، وروحا مستقيما جدد في أحشائي. لا تطرحني من قدام وجهك، وروحك القدوس لا تنزعه منى. (المجد للآب والابن والروح القدس).\nأيها الرب الذي أرسلتَ روح قدسك على تلاميذك القديسين ورسلك المكرمين في الساعة الثالثة، هذا لا تنزعه منا أيها الصالح. لكن نسألك أن تجدده في أحشائنا، يا ربنا يسوع المسيح ابن الله الكلمة، روحًا مستقيمًا ومحييًا، روح النبوءة والعفة، روح القداسة والعدالة والسلطة، أيها القادر على كل شيء، لأنك أنت هو ضياء نفوسنا. يا من يضئ لكل إنسان آت إلى العالم، ارحمنا. (الآن وكل أوان وإلى دهر الداهرين آمين).\nيا والدة الإله أنت هي الكرمة الحقيقية الحاملة عنقود الحياة، نسألك أيتها المملوءة نعمة، مع الرسل، من أجل خلاص نفوسنا. مبارك الرب إلهنا. مبارك الرب يوما فيوما، يهيئ طريقنا لأنه إله خلاصنا (الآن وكل أوان وإلى دهر الداهرين آمين).\nأيها الملك السمائي المعزى، روح الحق، الحاضر في كل مكان والمالئ الكل، كنز الصالحات، ومعطى الحياة، هلم تفضل وحل فينا، وطهرنا من كل دنس أيها الصالح، وخلص نفوسنا. (المجد للآب والابن والروح القدس).\nكما كنت مع تلاميذك أيها المخلص وأعطيتهم السلام، هلم أيضا كن معنا وامنحنا سلامك وخلصنا ونج نفوسنا. (الآن وكل أوان وإلى دهر الداهرين آمين).\nإذا ما وقفنا في هيكلك المقدس نحسب كالقيام في السماء. يا والدة الإله، أنت هي باب السماء، افتحي لنا باب الرحمة.\nكيرياليسون (يا رب ارحم) 41 مرة.\n\nقدوس قدوس قدوس رب الصباؤوت. السماء والأرض مملوءتان من مجدك وكرامتك. ارحمنا يا الله الآب ضابط الكل. أيها الثالوث القدوس ارحمنا. أيها الرب إله القوات كن معنا، لأنه ليس لنا معين في شدائدنا وضيقاتنا سواك. حل واغفر واصفح لنا يا الله عن سيئاتنا...\n\nالتحليل الكنسي المعتمد للثالثة:\nيا إله كل الرأفات ورب كل عزاء، الذي عزانا كل حين بعزاء روحك القدوس، نشكرك لأنك أقمتنا للصلاة في هذه الساعة المقدسة، التي فيها أفضت نعمة روحك القدوس بغنى على تلاميذك القديسين ورسلك المكرمين الطوباويين مثل ألسنة نار. نسأل ونطلب منك يا محب البشر، اقبل إليك صلواتنا، واغفر خطايانا، وأرسل علينا نعمة روحك القدوس، وطهرنا من كل دنس الجسد والروح، وانقلنا إلى سيرة روحانية، لكي نسلك بالروح ولا نكمل شهوة الجسد. واجعلنا مستحقين أن نخدمك بطهارة وبر كل أيام حياتنا. لأنه يليق بك المجد والكرامة والعزة، مع أبيك الصالح والروح القدس، الآن وكل أوان وإلى الأبد أمين.\n\nطلبة تصلى آخر كل ساعة:\nارحمنا يا الله ثم ارحمنا. يا من في كل وقت وكل ساعة، في السماء وعلى الأرض، مسجود له وممجد. المسيح إلهنا الصالح، الطويل الروح، الكثير الرحمة، الجزيل التحنن، الذي يحب الصديقين ويرحم الخطاة الذين أولهم أنا. الذي لا يشاء موت الخاطئ مثل ما يرجع ويحيا. الداعي الكل إلى الخلاص لأجل الموعد بالخيرات المنتظرة. يا رب اقبل منا في هذه الساعة وكل ساعة طلباتنا. سهل حياتنا، وأرشدنا إلى العمل بوصاياك. قدس أرواحنا. طهر أجسامنا. قوم أفكارنا. نق نياتنا. اشف أمراضنا واغفر خطايانا. ونجنا من كل حزن رديء ووجع قلب. أحطنا بملائكتك القديسين، لكي نكون بمعسكرهم محفوظين ومرشدين، لنصل إلى اتحاد الإيمان وإلى معرفة مجدك غير المحسوس وغير المحدود، فإنك مبارك إلى الأبد. أمين.\nاللهم اجعلنا مستحقين أن نقول بشكر: أبانا الذي في السموات...'
  }
];

final List<Map<String, String>> _sixthTextData = [
  {
    'title': '١. مقدمة كل ساعة، الصلاة الربانية، وصلاة الشكر',
    'text':
        'بِاسْمِ الآبِ وَالابْنِ وَالرُّوحِ الْقُدُسِ الإِلَهِ الْوَاحِدِ، آمِينَ.\n\nكيرياليصون (يا رب ارحم). كيرياليصون. كيرياليصون. يا رب بارك. آمين.\n\nالمجد للآب والابن والروح القدس، الآن وكل أوان وإلى دهر الدهور، آمين.\n\nالصلاة الربانية:\nأبانا الذي في السماوات، ليتقدس اسمك، ليأت ملكوتك، لتكن مشيئتك كما في السماء كذلك على الأرض. خبزنا الذي للغد أعطنا اليوم، واغفر لنا ذنوبنا كما نغفر نحن أيضاً للمذنبين إلينا، ولا تدخلنا في تجربة، لكن نجنا من الشرير، بالمسيح يسوع ربنا، لأن لك الملك والقوة والمجد إلى الأبد. آمين.\n\nصلاة الشكر الطقسية:\nفلنشكر صانع الخيرات الرحوم الله، أبا ربنا وإلهنا ومخلصنا يسوع المسيح، لأنه سترنا وأعاننا، وحفظنا وقبلنا إليه وأشفق علينا وعضدنا، وأتى بنا إلى هذه الساعة. هو أيضاً فلنسأله أن يحفظنا في هذا اليوم المقدس وكل أيام حياتنا بكل سلام، الضابط الكل الرب إلهنا.\n\nأيها السيد الرب الإله ضابط الكل أبا ربنا وإلهنا ومخلصنا يسوع المسيح، نشكرك على كل حال ومن أجل كل حال وفي كل حال، لأنك سترتنا وأعنتنا وحفظتنا وقبلتنا إليك وأشفقت علينا وعضدتنا وأتيت بنا إلى هذه الساعة.\n\nمن أجل هذا نسأل ونطلب من صلاحك يا محب البشر، امنحنا أن نكمل هذا اليوم المقدس وكل أيام حياتنا بكل سلام مع خوفك. كل حسد، وكل تجربة، وكل فعل الشيطان، ومؤامرة الناس الأشرار، وقيام الأعداء الخفيين والظاهرين، انزعها عنا وعن سائر شعبك، وعن موضعك المقدس هذا. أما الصالحات والنافعات فارزقنا إياها، لأنك أنت الذي أعطيتنا السلطان أن ندوس الحيات والعقارب وكل قوة العدو. ولا تدخلنا في تجربة، لكن نجنا من الشرير بالنعمة والرأفات ومحبة البشر اللواتي لابنك الوحيد ربنا وإلهنا ومخلصنا يسوع المسيح، هذا الذي من قبله المجد والإكرام والعز والسجود تليق بك معه مع الروح القدس المحيي المساوي لك الآن وكل أوان وإلى دهر الدهور. آمين.'
  },
  {
    'title': '٢. المزمور الخمسون وبدء صلاة الساعة السادسة',
    'text':
        'المزمور الخمسون (مزمور التوبة):\nارحمني يا الله كعظيم رحمتك، ومثل كثرة رأفتك امحُ إثمي. اغسلني كثيراً من إثمي ومن خطيتي طهرني، لأني عارف بإثمي وخطيتي أمامي في كل حين. لك وحدك أخطأت، والشر قدامك صنعت، لكي تتبرر في أقوالك وتغلب إذا حوكمت. لأني هاأنذا بالإثم حُبل بي، وبالخطايا ولدتني أمي. لأنك هكذا قد أحببت الحق، إذ أوضحت لي غوامض حكمتك ومستوراتها. تنضح عليّ بزوفاك فأطهر، تغسلني فأبيض أكثر من الثلج. تسمعني سروراً وفرحاً، فتبتهج عظامي المنحقة. اصرف وجهك عن خطاياي، وامحُ كل آثامي. قلباً نقياً اخلق فيّ يا الله، وروحاً مستقيماً جدد في أحشائي. لا تطرحني من قدام وجهك، وروحك القدوس لا تنزعه مني. امنحني بهجة خلاصك، وبروح مدبر عضدني. فأعلم الأثمة طرقك، والمنافقون إليك يرجعون. نجني من الدماء يا الله إله خلاصي، فيبتهج لساني ببرك. يا رب افتح شفتيّ، فيخبر فمي بتسبيحك. لأنك لو آثرت الذبيحة لكنت الآن أعطي، ولكنك لا تسر بالمحرقات. فالذبيحة لله روح منسحق، القلب المنكسر والمتواضع لا يرذله الله. أحسن يا رب بمسرتك إلى صهيون، ولتبنَ أسوار أورشليم. حينئذ تسر بذبائح البر قرباناً ومحرقات، حينئذ يقربون على مذابحك العجول. هللويا.\n\nبدء صلاة الساعة السادسة:\nتسبحة الساعة السادسة من النهار المبارك، أقدمها للمسيح ملكي وإلهي، وأرجوه أن يغفر لي خطاياي. من مزامير داود النبي بركاته علينا آمين. هلم نسجد هلم نسأل المسيح إلهنا.'
  },
  {
    'title': '٣. مزامير الساعة السادسة (53 و 56 و 60 و 62)',
    'text':
        '(1) المزمور الثالث والخمسون\nاللهم باسمك خلصني، وبقوتك احكم لي. استمع يا الله صلاتي، وأنصت إلى كلام فمي. فإن الغرباء قد قاموا علي، والأقوياء طلبوا نفسي. لم يجعلوا الله أمامهم. هوذا الله عوني، والرب ناصر نفسي، يرد الشرور على أعدائي، بحقك استأصلهم. فأذبح لك طائعا، وأعترف لاسمك يا رب فإنه صالح. لأنك من جميع الشدائد نجيتني، وبأعدائي نظرت عيناي. هلليلويا.\n\n(2) المزمور السادس والخمسون\nارحمني يا الله ارحمني، فإنه عليك توكلتْ نفسي. وبظل جناحيك أعتصم، إلى أن يعبر الإثم. أصرخ إلى الله العلي، الإله المحسن إلى. أرسل من السماء فخلصني، وجعل العار على الذين يطأونني. أرسل الله رحمته وحقه، وخلص نفسي من بين الأشبال إذ نمت مضطربا. أسنان أبناء البشر سلاح وسهام، ولسانهم سيف مرهف. اللهم ارتفع على السموات، وليرتفع مجدك على سائر الأرض. نصبوا لرجلي فخاخا وأحنوا نفسي، حفروا قدام وجهي حفرة فسقطوا فيها. مستعد قلبي يا الله، مستعد قلبي، أسبح وأرتل في تمجيدي. استيقظ يا مجدي، استيقظ أيها المزمار والقيثارة. أنا أستيقظ مبكرا. أعترف لك في الشعوب يا رب، وأرتل لك في الأمم. لأن رحمتك قد عظمت إلى السموات، وإلى السحاب عدلك. اللهم ارتفع على السموات، وليرتفع مجدك على سائر الأرض. هلليلويا.\n\n(3) المزمور الستون\nاستمع يا الله طلبتي، وأصغ إلى صلاتي. من أقاصي الأرض صرخت إليك، عندما ضجر قلبي. على الصخرة رفعتني وأرشدتني. صرتَ رجائي، وبرجا حصينا في وجه العدو. فأسكن في مسكنك إلى الدهر، وأستظل بستر جناحيك. لأنك أنت يا الله استمعت صلواتي، أعطيت ميراثا لخائفي اسمك. تزيد الملك أياما على أيامه، وسنينَ على سنيّه. إلى جيل فجيل، ويدوم إلى الأبد قدام الله. رحمتك وحقك يحفظانه. هكذا أرتل لاسمك إلى دهر الدهور، لأفي نذوري يوما فيوما. هلليلويا.\n\n(4) المزمور الثاني والستون\nيا الله إلهي، إليك أبكر، عطشت إليك نفسي. يشتاق إليك جسدي، في أرض مقفرة وموضع غير مسلوك ومكان بلا ماء. هكذا ظهرت لك في القدس، لأرى قوتك ومجدك. لأن رحمتك أفضل من الحياة، شفتاي تسبحانك. لذلك أباركك في حياتي، وباسمك أرفع يدي. فتشبع نفسي كما من شحم ودسم. بشفاه الابتهاج نبارك اسمك. كنت أذكرك على فراشي، وفى أوقات الأسحار كنت أرتل لك. لأنك صرت لي عونا، وبظل جناحيك أبتهج. التحقت نفسي وراءك، ويمينك عضدتني. أما الذين طلبوا نفسي للهلاك، فيدخلون في أسافل الأرض. ويدفعون إلى يد السيف، ويكونون أنصبة للثعالب. أما الملك فيفرح بالله، ويفتخر كل من يحلف به. لأن أفواه المتكلمين بالظلم تسد. هلليلويا.'
  },
  {
    'title': '٤. مزامير الساعة السادسة (66 و 69 و 83 و 84)',
    'text':
        '(5) المزمور السادس والستون\nليتراءف الله علينا ويباركنا، وليظهر وجهه علينا ويرحمنا. لتعرف في الأرض طريقك، وفى جميع الأمم خلاصك. فلتعترف لك الشعوب يا الله، فلتعترف لك الشعوب كلها. لتفرح الأمم وتبتهج، لأنك تحكم في الشعوب بالاستقامة، وتهدى الأمم في الأرض. فلتعترف لك الشعوب يا الله، فلتعترف لك الشعوب جميعا. الأرض أعطت ثمرتها، فليباركنا الله إلهنا. ليباركنا الله، فلتخشه جميع أقطار الأرض. هلليلويا.\n\n(6) المزمور التاسع والستون\nاللهم التفت إلى معونتي، يا رب أسرع وأعنى. ليخزى ويخجل طالبو نفسي، وليرتدَّ إلى خلف ويخجل الذين يبتغون لي الشر. وليرجع بالخزي سريعا القائلون لي: نِعِمَّا نِعِمَّا. وليبتهج ويفرح بك جميع الذين يلتمسونك، وليقل في كل حين محبو خلاصك: فليتعظم الرب. وأما أنا فمسكين وفقير، اللهم أعنى. أنت معيني ومخلصي يا رب فلا تبطئ. هلليلويا.\n\n(7) المزمور الثالث والثمانون\nمساكنك محبوبة يا رب إله القوات. تشتاق وتذوب نفسي للدخول إلى ديار الرب. قلبي وجسمي قد ابتهجا بالإله الحي. لأن العصفور وجد له بيتا، واليمامة عشا لتضع فيه أفراخها. مذابحَك يا رب اله القوات، ملكي وإلهي. طوبى لكل الساكنين في بيتك، يباركونك إلى الأبد. طوبى للرجل الذي نصرته من عندك يا رب، رتب مصاعد في قلبه. في وادي البكاء، في المكان الذي قرره. لأن البركات يعطاها واضع الناموس. يسيرون من قوة إلى قوة، يتجلى إله الآلهة في صهيونَ. أيها الرب إله القوات استمع لصلاتي، أنصت يا إله يعقوب. وانظر أيها الإله ناصرنا، واطلع إلى وجه مسيحك. لأن يوما صالحا في ديارك خير من آلاف. اخترت لنفسي أن أطرَح على باب بيت الله، أفضل من أن أسكن في مظال الخطاة. لأن الرب الإله يحب الرحمة والحق، ويعطى مجدا ونعمة. الرب لا يمنع الخيرات عن السالكين بالدعة. يا رب إله القوات، طوبى للإنسان المتكل عليك. هلليلويا.\n\n(8) المزمور الرابع والثمانون\nرضيتَ يا رب عن أرضك، رددتَ سبى يعقوب. غفرتَ آثام شعبك، سترتَ جميع خطاياهم. حللتَ كل رجزك، رجعتَ عن سخط غضبك. ردَّنا يا إله خلاصنا، واصرف غضبك عنا. هل إلى الأبد تغضب علينا، أو تواصل رجزك من جيل إلى جيل؟ أنت يا الله تعود فتعيد لنا الحياة، وشعبك يفرح بك. أرنا يا رب رحمتك، وأعطنا خلاصك. إني أسمع ما يتكلم به الرب الإله، لأنه يتكلم بالسلام لشعبه ولقديسيه، وللذين رجعوا إليه بكل قلوبهم. لأن خلاصه قريب من جميع خائفيه، ليسكن المجد في أرضنا. الرحمة والحق تلاقيا، البر والسلام تلاثما. الحق من الأرض أشرق، والبر من السماء تطلع. لأن الرب يعطى الخيرات، وأرضنا تعطى ثمرها. البر أمامه يسلك ويطأ في طريق خطواته. هلليلويا.'
  },
  {
    'title': '٥. مزامير الساعة السادسة (85 و 86 و 90 و 92)',
    'text':
        '(9) المزمور الخامس والثمانون\nأمل يا رب أذنك واستمعني، لأني مسكين وبائس أنا. احفظ نفسي لأني بار، يا إلهي خلص عبدك المتكل عليك. ارحمني يا رب، لأني إليك أصرخ اليوم كله. فرح نفس عبدك، لأني إليك يا رب رفعت نفسي. لأنك أنت يا رب صالح ووديع، ورحمتك كثيرة لكافة المستغيثين بك. أنصت يا رب إلي صلاتي، وأصغ إلى صوت تضرعي. في يوم شدتي إليك صرختُ فأجبتني. فليس لك شبيه في الآلهة يا رب، ولا من يصنع كأعمالك. كل الأمم الذين خلقتهم يأتون ويسجدون أمامك يا رب، ويمجدون اسمك. لأنك أنت عظيم وصانع العجائب، أنت وحدك الإله العظيم. اهدني يا رب إلى طريقك فأسلك في حقك، ليفرح قلبي عند خوفه من اسمك. أعترف لك أيها الرب إلهي من كل قلبي، وأمجد اسمك إلى الأبد. لأن رحمتك عظيمة على، وقد نجيت نفسي من الجحيم السفلي. اللهم إن مخالفي الناموس قد قاموا علىّ ومجمع الأعزاء طلبوا نفسي، ولم يسبقوا أن يجعلوك أمامهم. وأنت أيها الرب الإله أنت رؤوف ورحيم. أنت طويل الروح، وكثير الرحمة وصادق. انظر إلي وارحمني. أعطِ عزة لعبدك، وخلص ابن أمتك. اصنع معي آية صالحة، ليرى ذلك مبغضي فيخزوا. لأنك أنت يا رب أعنتني وعزيتني. هلليلويا.\n\n(10) المزمور السادس والثمانون\nأساساته في الجبال المقدسة. يحب الرب أبواب صهيون، أفضل من جميع مساكن يعقوب. أعمال مجيدة قد قيلت عنك يا مدينة الله. أذكر رَهَبَ وبابل اللتين تعرفانني. هوذا القبائل الغريبة وصور وشعب الحبشة، هؤلاء كانوا هناك. صهيون الأم تقول إن إنسانا وإنسانا ولد فيها، وهو العلي الذي أسسها إلى الأبد. الرب يحدّث في كتب الشعوب والرؤساء، أولئك الذين ولدوا فيها. لأن سكنى الفرحين جميعهم فيكِ. هلليلويا.\n\n(11) المزمور التسعون\nالساكن في عون العَليّ، يستريح في ظل إله السماء. يقول للرب أنت هو ناصري وملجأي، إلهي فأتكل عليه. لأنه ينجيك من فخ الصياد، ومن كلمة مقلقة. في وسط منكبيه يظللك، وتحت جناحيه تعتصم، عدله يحيط بك كالسلاح. فلا تخشى من خوف الليل، ولا من سهم يطير في النهار. ولا من أمر يسلك في الظلمة، ولا من سقطة وشيطان الظهيرة. يسقط عن يسارك ألوف، وعن يمينك ربوات، وأما أنت فلا يقتربون إليك. بل بعينيك تتأمل، ومجازاة الخطاة تبصر. لأنك أنت يا رب رجائي. جعلتَ العليَّ ملجأك. فلا تصيبك الشرور، ولا تدنو ضربة من مسكنك. لأنه يوصى ملائكته بك، ليحفظوك في سائر طرقك. وعلى أيديهم يحملونك، لئلا تعثر بحجر رجلك. تطأ الأفعى وملكَ الحيات، وتسحق الأسد والتنين. لأنه على أتكل فأنجيه، أرَفعه (أستره) لأنه عرف اسمي. يدعوني فأستجيب له. معه أنا في الشدة، أنقذه وأمجده. ومن طول الأيام أشبعه، وأريه خلاصي. هلليلويا.\n\n(12) المزمور الثاني والتسعون\nالرب قد ملك، ولبس الجلال. لبس الرب القوة، وتمنطق بها. لأنه ثبت المسكونة فلن تتزعزع. كرسيك ثابت منذ البدء، وأنت هو منذ الأزل. رفعت الأنهار يا رب، رفعت الأنهار صوتها. ترفع الأنهار صوتها، من صوت مياه كثيرة. عجيبة هي أهوال البحر، وعجيب هو الرب في الأعالي. شهاداته صادقة جدا، لبيتك ينبغي التقديس يا رب طول الأيام. هلليلويا.'
  },
  {
    'title': '٦. الإنجيل والقطع والتحليل وطلبة الختام للسادسة',
    'text':
        'من إنجيل معلمنا متى البشير بركاته علينا، آمين:\n\n(إنجيل متى 5: 1-16)\nفلما أبصر الجموع صعد إلى الجبل. وعندما جلس تقدم إليه تلاميذه، ففتح فاه وعلمهم قائلا:\nطوبى للمساكين بالروح، لأن لهم ملكوت السموات.\nطوبى للجياع والعطاش إلى البر لأنهم يُشبعون.\nطوبى للرحماء لأنهم يُرحمون.\nطوبى لأنقياء القلب لأنهم يعاينون الله.\nطوبى لصانعي السلام، لأنهم يُدعَون أبناءَ الله.\nطوبى لكم إذا طردوكم وعيروكم وقالوا فيكم من أجلي كل شر كاذبين. افرحوا وتهللوا لأن أجركم عظيم في السموات...\nأنتم مِلح الأرض، فإذا فسد المِلح فبماذا يُملح؟.. أنتم نور العالم. لا يمكن أن تخفى مدينة كائنة على جبل. هكذا فليضئ نوركم قدام الناس، لكي يروا أعمالكم الصالحة فيمجدوا أباكم الذي في السموات. (والمجد لله دائما).\n\nالقطع مفرودة بالكامل:\nيا من في اليوم السادس وفى الساعة السادسة سمرت على الصليب، من أجل الخطية التي تجرأ عليها أبونا أدم في الفردوس، مزق صك خطايانا أيها المسيح إلهنا وخلصنا. عشية وباكر ووقت الظهر، كلامي أقوله فيسمع صوتي، ويخلص نفسي بسلام. (المجد للآب والابن والروح القدس).\nيا يسوع المسيح إلهنا الذي سمرتَ على الصليب في الساعة السادسة، وقتلت الخطية بالخشبة، وأحييت الميت بموتك، الذي هو الإنسان الذي خلقته بيديك. اقتل أوجاعنا بآلامك الشافية المحيية، وأنقذ عقولنا من طياشة الأعمال الهيولية والشهوات العالمية، إلى تذكر أحكامك السمائية كرأفتك. (الآن وكل أوان وإلى دهر الداهرين آمين).\nإذ ليس لنا دالة ولا حجة ولا معذرة من أجل كثرة خطايانا، فنحن بك نتوسل إلى الذي ولد منك يا والدة الإله العذراء. لأن كثيرة هي شفاعتك عند مخلصنا. أيتها الأم الطاهرة، لا تدركي الخطاة من شفاعتك، لأنه رحوم وقادر على خلاصنا. أعنا يا الله مخلصنا من أجل مجد اسمك. (الآن وكل أوان وإلى دهر الداهرين آمين).\nصنعت خلاصا في وسط الأرض كلها أيها المسيح إلهنا، عندما بسطت يديك الطاهرتين على عود الصليب. فلهذا كل الأمم تصرخ قائلة: المجد لك يا رب. (المجد للآب والابن والروح القدس).\nنسجد لشخصك غير الفاسد أيها الصالح، طالبين مغفرة خطايانا أيها المسيح إلهنا. نصرخ إليك ونشكرك لأنك ملأت الكل فرحا، أيها المخلص لما أتيت لتعين العالم، يا رب المجد لك. (الآن وكل أوان وإلى دهر الداهرين آمين).\nأنت هي الممتلئة نعمة يا والدة الإله العذراء. نعظمك لأن من قبل صليب ابنك انهبط الجحيم وبطل الموت. أمواتا كنا فنهضنا، واستحققنا الحياة الأبدية. من أجل هذا نمجد بشكر غيرَ المائت المسيح إلهنا.\nكيرياليسون (يا رب ارحم) ٤١ مرة بخشوع تام.\n\nقدوس قدوس قدوس رب الصباؤوت. السماء والأرض مملوءتان من مجدك وكرامتك. ارحمنا يا الله الآب ضابط الكل. أيها الثالوث القدوس ارحمنا. أيها الرب إله القوات كن معنا، لأنه ليس لنا معين في شدائدنا وضيقاتنا سواك. حل واغفر واصفح لنا يا الله عن سيئاتنا...\n\nالتحليل الطقسي المعتمد للساعة السادسة:\nنشكرك يا ملكنا ضابط الكل أبا ربنا وإلهنا مخلصنا يسوع المسيح ونمجدك، لأنك جعلت أوقات الآلام أبنك الوحيد أوقات عزاء وصلاة. اقبل إليك تضرعنا، وامح عنا صك خطايانا المكتوبة علينا, كما مزقته في هذه الساعة المقدسة بصليب ابنك الوحيد يسوع المسيح ربنا ومخلص نفوسنا، هذا الذي به هدمتَ كل قوة العدو. أعطنا يا الله وقتا بهيا، وسيرة بلا عيب، وحياة هادئة، لنرضي اسمك القدوس المسجود له، ونقف أمام المنبر المخوف العادل الذي لابنك الوحيد يسوع المسيح ربنا بغير وقوع في دينونة، ونمجدك مع كافة قديسيك. أنت الآب غير المبتدئ والابن المساوي لك، والروح القدس المحيى، الآن وكل أوان وإلى دهر الدهور كلها. أمين.\n\nطلبة تصلى آخر كل ساعة:\nارحمنا يا الله ثم ارحمنا. يا من في كل وقت وكل ساعة، في السماء وعلى الأرض، مسجود له وممجد. المسيح إلهنا الصالح، الطويل الروح، الكثير الرحمة، الجزيل التحنن، الذي يحب الصديقين ويرحم الخطاة الذين أولهم أنا. الذي لا يشاء موت الخاطئ مثل ما يرجع ويحيا. الداعي الكل إلى الخلاص لأجل الموعد بالخيرات المنتظرة. يا رب اقبل منا في هذه الساعة وكل ساعة طلباتنا. سهل حياتنا، وأرشدنا إلى العمل بوصاياك. قدس أرواحنا. طهر أجسامنا. قوم أفكارنا. نق نياتنا. اشف أمراضنا واغفر خطايانا. ونجنا من كل حزن رديء ووجع قلب. أحطنا بملائكتك القديسين، لكي نكون بمعسكرهم محفوظين ومرشدين، لنصل إلى اتحاد الإيمان وإلى معرفة مجدك غير المحسوس وغير المحدود، فإنك مبارك إلى الأبد. أمين.\nاللهم اجعلنا مستحقين أن نقول بشكر: أبانا الذي في السموات...'
  }
];

final List<Map<String, String>> _ninthTextData = [
  {
    'title': '١. مقدمة كل ساعة، الصلاة الربانية، وصلاة الشكر',
    'text':
        'بِاسْمِ الآبِ وَالابْنِ وَالرُّوحِ الْقُدُسِ الإِلَهِ الْوَاحِدِ، آمِينَ.\n\nكيرياليصون (يا رب ارحم). كيرياليصون. كيرياليصون. يا رب بارك. آمين.\n\nالمجد للآب والابن والروح القدس، الآن وكل أوان وإلى دهر الدهور، آمين.\n\nالصلاة الربانية:\nأبانا الذي في السماوات، ليتقدس اسمك، ليأت ملكوتك، لتكن مشيئتك كما في السماء كذلك على الأرض. خبزنا الذي للغد أعطنا اليوم، واغفر لنا ذنوبنا كما نغفر نحن أيضاً للمذنبين إلينا، ولا تدخلنا في تجربة، لكن نجنا من الشرير، بالمسيح يسوع ربنا، لأن لك الملك والقوة والمجد إلى الأبد. آمين.\n\nصلاة الشكر الطقسية:\nفلنشكر صانع الخيرات الرحوم الله، أبا ربنا وإلهنا ومخلصنا يسوع المسيح، لأنه سترنا وأعاننا، وحفظنا وقبلنا إليه وأشفق علينا وعضدنا، وأتى بنا إلى هذه الساعة. هو أيضاً فلنسأله أن يحفظنا في هذا اليوم المقدس وكل أيام حياتنا بكل سلام، الضابط الكل الرب إلهنا.\n\nأيها السيد الرب الإله ضابط الكل أبا ربنا وإلهنا ومخلصنا يسوع المسيح، نشكرك على كل حال ومن أجل كل حال وفي كل حال، لأنك سترتنا وأعنتنا وحفظتنا وقبلتنا إليك وأشفقت علينا وعضدتنا وأتيت بنا إلى هذه الساعة.\n\nمن أجل هذا نسأل ونطلب من صلاحك يا محب البشر، امنحنا أن نكمل هذا اليوم المقدس وكل أيام حياتنا بكل سلام مع خوفك. كل حسد، وكل تجربة، وكل فعل الشيطان، ومؤامرة الناس الأشرار، وقيام الأعداء الخفيين والظاهرين، انزعها عنا وعن سائر شعبك، وعن موضعك المقدس هذا. أما الصالحات والنافعات فارزقنا إياها، لأنك أنت الذي أعطيتنا السلطان أن ندوس الحيات والعقارب وكل قوة العدو. ولا تدخلنا في تجربة، لكن نجنا من الشرير بالنعمة والرأفات ومحبة البشر اللواتي لابنك الوحيد ربنا وإلهنا ومخلصنا يسوع المسيح، هذا الذي من قبله المجد والإكرام والعز والسجود تليق بك معه مع الروح القدس المحيي المساوي لك الآن وكل أوان وإلى دهر الدهور. آمين.'
  },
  {
    'title': '٢. المزمور الخمسون وبدء صلاة الساعة التاسعة (بدء الصلاة)',
    'text':
        'المزمور الخمسون (مزمور التوبة):\nارحمني يا الله كعظيم رحمتك، ومثل كثرة رأفتك امحُ إثمي. اغسلني كثيراً من إثمي ومن خطيتي طهرني، لأني عارف بإثمي وخطيتي أمامي في كل حين. لك وحدك أخطأت، والشر قدامك صنعت، لكي تتبرر في أقوالك وتغلب إذا حوكمت. لأني هاأنذا بالإثم حُبل بي، وبالخطايا ولدتني أمي. لأنك هكذا قد أحببت الحق، إذ أوضحت لي غوامض حكمتك ومستوراتها. تنضح عليّ بزوفاك فأطهر، تغسلني فأبيض أكثر من الثلج. تسمعني سروراً وفرحاً، فتبتهج عظامي المنحقة. اصرف وجهك عن خطاياي، وامحُ كل آثامي. قلباً نقياً اخلق فيّ يا الله، وروحاً مستقيماً جدد في أحشائي. لا تطرحني من قدام وجهك، وروحك القدوس لا تنزعه مني. امنحني بهجة خلاصك، وبروح مدبر عضدني. فأعلم الأثمة طرقك، والمنافقون إليك يرجعون. نجني من الدماء يا الله إله خلاصي، فيبتهج لساني ببرك. يا رب افتح شفتيّ، فيخبر فمي بتسبيحك. لأنك لو آثرت الذبيحة لكنت الآن أعطي، ولكنك لا تسر بالمحرقات. فالذبيحة لله روح منسحق، القلب المنكسر والمتواضع لا يرذله الله. أحسن يا رب بمسرتك إلى صهيون، ولتبنَ أسوار أورشليم. حينئذ تسر بذبائح البر قرباناً ومحرقات، حينئذ يقربون على مذابحك العجول. هللويا.\n\nبدء صلاة الساعة التاسعة:\nتسبحة الساعة التاسعة من النهار المبارك، أقدمها للمسيح ملكي وإلهي، وأرجوه أن يغفر لي خطاياي. من مزامير داود النبي بركاته علينا آمين. هلم نسجد هلم نسأل المسيح إلهنا.'
  },
  {
    'title': '٣. مزامير الساعة التاسعة (95 و 96 و 97 و 98)',
    'text':
        '(1) المزمور الخامس والتسعون\nهلموا نرتل للرب، ونصرخ لله مخلصنا. نتقدم أمام وجهه بالاعتراف، وبالمزامير نصرخ إليه. لأن الرب إله عظيم، وملك كبير على كل الآلهة. لأن بيده أقطار الأرض، ورؤوس الجبال له. لأن له البحر وهو صنعه، ويداه جبلتا اليابسة. هلموا نسجد ونركع له، ونبكي أمام الرب الذي صنعنا، لأنه هو إلهنا ونحن شعب مرعاه وغنم يده. هلليلويا.\n\n(2) المزمور السادس والتسعون\nرتلوا للرب تسبحة جديدة، رتلي للرب يا كل الأرض. رتلوا للرب وباركوا اسمه، بشروا من يوم إلى يوم بخلاصه. حدثوا في الأمم بمجده، وفي جميع الشعوب بعجائبه. لأن الرب عظيم ومسبح جداً، مرهوب على كل الآلهة. لأن كل آلهة الأمم شياطين، وأما الرب فقد صنع السموات. الجلال والبهاء قدامه، الطهر والعظم الجليل في مقدسه. هلليلويا.\n\n(3) المزمور السابع والتسعون\nالرب قد ملك فلتتبجح الأرض، ولتفرح الجزائر الكثيرة. سحاب وضباب حوله، العدل والقضاء قوام كرسيه. قدامه تسير النار، وتحرق أعداءه المحيطين به. أضاءت بروقه المسكونة، رأت الأرض فتزلزلت. ذابت الجبال مثل الشمع من وجه الرب، من وجه رب الأرض كلها. أخبرت السموات بعدله، ورأى جميع الشعوب مجده. هلليلويا.\n\n(4) المزمور الثامن والتسعون\nرتلوا للرب تسبحة جديدة، لأن الرب قد صنع عجائب. خلصت له يمينه، وذراعه المقدسة. أعلن الرب خلاصه، وقدام الأمم كشف عدله. ذكر رحمته ليعقوب، وحقه لبيت إسرائيل. رأت سائر أقطار الأرض خلاص إلهنا. اصرخوا لله يا كل الأرض، سبحوا وهللوا ورتلوا. رتلوا للرب بالقيثارة وصوت المزمور. بأبواق لدن وصوت بوق القرن، اصرخوا أمام الملك الرب. هلليلويا.'
  },
  {
    'title': '٤. مزامير الساعة التاسعة (99 و 100 و 109 و 110)',
    'text':
        '(5) المزمور التاسع والتسعون\nالرب قد ملك فلتغضب الشعوب، الجالس على الشاروبيم فلتتزلزل الأرض. الرب في صهيون عظيم، ومتعال على كل الشعوب. فليعترفوا لاسمك العظيم لأنه مرهوب وقدوس. وكرامة الملك تحب القضاء، أنت هيأت الاستقامة، أنت صنع القضاء والعدل في يعقوب. ارفعوا الرب إلهنا واسجدوا لموطئ قدميه فإنه قدوس. موسى وهارون في كهنته، وصموئيل في الذين يدعون باسمه، كانوا يدعون الرب وهو كان يستجيب لهم. هلليلويا.\n\n(6) المزمور المائة\nاصرخي لله يا كل الأرض، اعبدوا الرب بالفرح. ادخلوا أمامه بالتهليل، اعلموا أن الرب هو الإله، هو صنعنا ونحن له، شعب ورعية مرعاه. ادخلوا أبوابه بالاعتراف، ودياره بالتسابيح. اعترفوا له وباركوا اسمه، لأن الرب صالح وإلى الأبد رحمته، وإلى جيل فجيل حقه. هلليلويا.\n\n(7) المزمور المائة والتاسع\nقال الرب لربي: اجلس عن يميني، حتى أضع أعداءك تحت موطئ قدميك. عصا قوة يرسل لك الرب من صهيون، وتسود في وسط أعدائك. معك الرئاسة في يوم قوتك، في بهاء القديسين من البطن قبل كوكب الصبح ولدتك. حلف الرب ولن يندم: إنك أنت هو الكاهن إلى الأبد على طقس ملكي صادق. الرب عن يمينك يسحق في يوم غضبه ملوكاً. يقضي بين الأمم، يملأ جثثاً، يسحق رؤوساً على أرض كثيرة. من الساقية في الطريق يشرب، لذلك يرفع رأسه. هلليلويا.\n\n(8) المزمور المائة والعاشر\nأعترف لك يا رب من كل قلبي، في مجلس المستقيمين وفي جماعتهم. عظيمة هي أعمال الرب، ومبتغاة في جميع مشيئاته. جلال وبهاء عمله، وعدله دائم إلى دهر الدهور. صنع ذكراً لعجائبه، رحيم ورؤوف هو الرب. أعطى طعاماً لخائفيه، يذكر إلى الأبد عهده. أخبر شعباً بقوة أعماله، ليعطيهم ميراث الأمم. أعمال يديه حق وقضاء، وكل وصاياه صادقة، ثابتة إلى دهر الدهور، مصنوعة بالحق والاستقامة. أرسل خلاصاً لشعبه، أمر بعهده إلى الأبد، قدوس ومرهوب اسمه. رأس الحكمة مخافة الرب، وفطنة صالحة لكل من يعمل بها، وتسبحته دائمة إلى دهر الدهور. هلليلويا.'
  },
  {
    'title': '٥. مزامير الساعة التاسعة (١١١ و ١١٢ و ١١٤ و ١١٥)',
    'text':
        '(9) المزمور المائة والحادي عشر\nطوبى للرجل الخائف الرب، المسرور جداً بوصاياه. نسله يكون قوياً في الأرض، جيل المستقيمين يبارك. مجد وغنى في بيته، وعدله قائم إلى دهر الدهور. أشرق في الظلمة نور للمستقيمين، هو رحيم ورؤوف وعادل. صالح هو الرجل الذي يتراءف ويقرض، ويدبر أقواله بالقضاء، لأنه لا يتزعزع إلى الأبد. الصديق يكون في ذكر أبدي، من خبر سوء لا يخاف. مستعد قلبه ليتكل على الرب، ثابت قلبه فلا يتزعزع، حتى يرى بأعدائه. فرّق وأعطى المساكين، عدله قائم إلى دهر الدهور، قرنه ينتصب بالمجد. الخاطئ يرى فيغضب، يصر بأسنانه ويذوب، شهوة الخطاة تبيد. هلليلويا.\n\n(10) المزمور المائة والثاني عشر\nسبحوا الرب أيها الفتيان، سبحوا اسم الرب. ليكن اسم الرب مباركاً من الآن وإلى الأبد. من مشارق الشمس إلى مغاربها مسبح اسم الرب. الرب عالٍ على كل الأمم، وفوق السموات مجده. من مثل الرب إلهنا الساكن في الأعالي، الناظر إلى المتواضعين في السماء وعلى الأرض؟ المقيم المسكين من التراب، الرافع البائس من المزبلة، لكي يجلسه مع رؤساء شعبه. الذي يجعل العاقر ساكنة في بيت، أم أولاد فرحة. هلليلويا.\n\n(11) المزمور المائة والرابع عشر\nأحببت لأن الرب يسمع صوت تضرعي، لأنه أمال أذنه إلي في أيامي فأدعوه. لأن أوجاع الموت قد اكتنفتني، وشدائد الجحيم قد أصابتني. وجدت ضيقاً وحزناً وباسم الرب دعوت: يا رب نج نفسي. الرب رحيم وعادل، وإلهنا يرحم. الرب يحفظ الأطفال، اتضعت فخلصني. ارجعي يا نفسي إلى راحتك، لأن الرب قد أحسن إليك. لأنه أنقذ نفسي من الموت، وعني من الدموع، ورجلي من الزلل. أرضي الرب في كورة الأحياء. هلليلويا.\n\n(12) المزمور المائة والخامس عشر\nآمنت ولذلك تكلمت، وأنا اتضعت جداً. أنا قلت في حيرتي: كل إنسان كاذب. بماذا أكافئ الرب عن كل ما أعطاني؟ كأس الخلاص آخذ، وباسم الرب أدعو. أوفي نذوري للرب قدام كل شعبه. :عزيز أمام الرب موت قديسيه. يا رب أنا عبدك، أنا عبدك وابن أمتك، قطعت قيودي. فلك أذبح ذبيحة التسبيح، وباسم الرب أدعو. أوفي نذوري للرب في ديار بيت الرب، في وسطك يا أورشليم. هلليلويا.'
  },
  {
    'title': '٦. إنجيل الساعة التاسعة والقطع والتحليل والطلبة الختامية',
    'text':
        'من إنجيل معلمنا لوقا البشير، بركاته علينا جميعاً، آمين:\n\n(إنجيل لوقا 9: 10-17)\nولما رجع الرسل حدثوه بما فعلوا، فأخذهم وانصرف منفردًا إلى موضع خلاء لمدينة تسمى بيت صيدا. فالجموع إذ علموا تبعوه، فقبلهم وكلمهم عن ملكوت الله، والمحتاجون إلى الشفاء شفاهم. وابتدأ النهار يميل، فتقدم الاثنا عشر وقالوا له: "اصرف الجمع ليذهبوا إلى القرى والضياع المحيطة فيستريحوا ويجدوا طعامًا، لأننا هنا في موضع خلاء". فقال لهم: "أعطوهم أنتم ليأكلوا". فقالوا: "ليس عندنا أكثر من خمسة أرغفة وسمكتين، إلا أن نذهب ونبتاع طعامًا لهذا الشعب كله". لأنهم كانوا نحو خمسة آلاف رجل. فقال لتلاميذه: "أتكئوهم رفاقًا خمسين خمسين". ففعلوا هكذا وأتكأوا الجميع. فأخذ الأرغفة الخمسة والسمكتين، ونظر إلى السماء وباركهن ثم كسر وأعطى التلاميذ ليقدموا للجمع. فأكلوا وشبعوا جميعهم، ثم رُفِعَ ما فضل عنهم من الكِسر اثنتا عشرة قفة. (والمجد لله دائما).\n\nالقطع الطقسية كاملة ومفرودة:\nيا من ذاق الموت بالجسد في وقت الساعة التاسعة من أجلنا نحن الخطاة، أمت حواسنا الجسدية أيها المسيح إلهنا ونجنا. لتصعد طلبتي قدامك يا رب، كقولك فهمني. لتدخل طلبتي إلى إمامتك، ككلمتك أحيني. (المجد للآب والابن والروح القدس).\nعندما أسلمتَ الروح في يدي الآب يا من علقتَ على الصليب في الساعة التاسعة، وهديتَ اللص اليمين المصلوب معك ليدخل الفردوس، لا تغفل عني أيها الصالح، ولا ترذلني أنا الضال، بل قدس نفسي وأنر عقلي، واجعلني شريكاً في نعيم فردوسك كرأفتك. (الآن وكل أوان وإلى دهر الداهرين آمين).\nيا من ولدتِ المخلص من أجل خلاصنا، أيتها العذراء الطاهرة الطوباوية، نسألك أن تشفعي من أجلنا، لأنكِ أنتِ شفيقة وجذابة وجديرة بالقبول عند ابنكِ الحبيب. ابسطي يديكِ الشافعتين نحو ربنا يسوع المسيح لكي يتراءف علينا ويتحنن وينقذ نفوسنا من الهلاك.\nكيرياليسون (يا رب ارحم) ٤١ مرة بخشوع ويقظة تامة.\n\nقدوس قدوس قدوس رب الصباؤوت. السماء والأرض مملوءتان من مجدك وكرامتك. ارحمنا يا الله الآب ضابط الكل. أيها الثالوث القدوس ارحمنا. أيها الرب إله القوات كن معنا، لأنه ليس لنا معين في شدائدنا وضيقاتنا سواك. حل واغفر واصفح لنا يا الله عن سيئاتنا...\n\nالتحليل القانوني المعتمد للساعة التاسعة:\nأيها السيد الرب يسوع المسيح إلهنا، يا من قطع مؤامرة العدو بصليبه، ونفخ في وجه تلاميذه ورسله الأطهار قائلاً: "اقبلوا الروح القدس، من غفرتم خطاياهم غفرت لهم، ومن أمسكتموها أُمسِكَت". أنت يا رب من قِبل رسلك المكرمين الأطهار وهبتَ كهنتك القديسين الخدمة الطاهرة في كنيستك المقدسة ليغفروا الخطايا على الأرض. نسأل ونطلب من صلاحك يا محب البشر من أجل عبدكِ الشاخص أمامكِ، امنحه مغفرة خطاياه، وامحُ آثامه وذنوبه الخفية والظاهرة. طهر قلبه، وقدس روحه، وعافِ بدنه، واجعله مستحقاً لملكوتك، بصلوات والدة الإله الطاهرة مريم وبحق كافة القديسين. أمين.\n\nطلبة تصلى آخر كل ساعة:\nارحمنا يا الله ثم ارحمنا. يا من في كل وقت وكل ساعة، في السماء وعلى الأرض، مسجود له وممجد. المسيح إلهنا الصالح، الطويل الروح، الكثير الرحمة، الجزيل التحنن، الذي يحب الصديقين ويرحم الخطاة الذين أولهم أنا. الذي لا يشاء موت الخاطئ مثل ما يرجع ويحيا. الداعي الكل إلى الخلاص لأجل الموعد بالخيرات المنتظرة. يا رب اقبل منا في هذه الساعة وكل ساعة طلباتنا. سهل حياتنا، وأرشدنا إلى العمل بوصاياك. قدس أرواحنا. طهر أجسامنا. قوم أفكارنا. نق نياتنا. اشف أمراضنا واغفر خطايانا. ونجنا من كل حزن رديء ووجع قلب. أحطنا بملائكتك القديسين، لكي نكون بمعسكرهم محفوظين ومرشدين، لنصل إلى اتحاد الإيمان وإلى معرفة مجدك غير المحسوس وغير المحدود، فإنك مبارك إلى الأبد. أمين.\nاللهم اجعلنا مستحقين أن نقول بشكر: أبانا الذي في السموات...'
  }
];

final List<Map<String, String>> _sunsetTextData = [
  {
    'title': '١. مقدمة كل ساعة، الصلاة الربانية، وصلاة الشكر',
    'text':
        'بِاسْمِ الآبِ وَالابْنِ وَالرُّروحِ الْقُدُسِ الإِلَهِ الْوَاحِدِ، آمِينَ.\n\nكيرياليصون (يا رب ارحم). كيرياليصون. كيرياليصون. يا رب بارك. آمين.\n\nالمجد للآب والابن والروح القدس، الآن وكل أوان وإلى دهر الدهور، آمين.\n\nالصلاة الربانية:\nأبانا الذي في السماوات، ليتقدس اسمك، ليأت ملكوتك، لتكن مشيئتك كما في السماء كذلك على الأرض. خبزنا الذي للغد أعطنا اليوم، واغفر لنا ذنوبنا كما نغفر نحن أيضاً للمذنبين إلينا، ولا تدخلنا في تجربة، لكن نجنا من الشرير، بالمسيح يسوع ربنا، لأن لك الملك والقوة والمجد إلى الأبد. آمين.\n\nصلاة الشكر الطقسية:\nفلنشكر صانع الخيرات الرحوم الله، أبا ربنا وإلهنا ومخلصنا يسوع المسيح، لأنه سترنا وأعاننا، وحفظنا وقبلنا إليه وأشفق علينا وعضدنا، وأتى بنا إلى هذه الساعة. هو أيضاً فلنسأله أن يحفظنا في هذا اليوم المقدس وكل أيام حياتنا بكل سلام، الضابط الكل الرب إلهنا.\n\nأيها السيد الرب الإله ضابط الكل أبا ربنا وإلهنا ومخلصنا يسوع المسيح، نشكرك على كل حال ومن أجل كل حال وفي كل حال، لأنك سترتنا وأعنتنا وحفظتنا وقبلتنا إليك وأشفقت علينا وعضدتنا وأتيت بنا إلى هذه الساعة.\n\nمن أجل هذا نسأل ونطلب من صلاحك يا محب البشر، امنحنا أن نكمل هذا اليوم المقدس وكل أيام حياتنا بكل سلام مع خوفك. كل حسد، وكل تجربة، وكل فعل الشيطان، ومؤامرة الناس الأشرار، وقيام الأعداء الخفيين والظاهرين، انزعها عنا وعن سائر شعبك، وعن موضعك المقدس هذا. أما الصالحات والنافعات فارزقنا إياها، لأنك أنت الذي أعطيتنا السلطان أن ندوس الحيات والعقارب وكل قوة العدو. ولا تدخلنا في تجربة، لكن نجنا من الشرير بالنعمة والرأفات ومحبة البشر اللواتي لابنك الوحيد ربنا وإلهنا ومخلصنا يسوع المسيح، هذا الذي من قبله المجد والإكرام والعز والسجود تليق بك معه مع الروح القدس المحيي المساوي لك الآن وكل أوان وإلى دهر الدهور. آمين.'
  },
  {
    'title': '٢. المزمور الخمسون وبدء صلاة الغروب',
    'text':
        'المزمور الخمسون (مزمور التوبة):\nارحمني يا الله كعظيم رحمتك، ومثل كثرة رأفتك امحُ إثمي. اغسلني كثيراً من إثمي ومن خطيتي طهرني، لأني عارف بإثمي وخطيتي أمامي في كل حين. لك وحدك أخطأت، والشر قدامك صنعت، لكي تتبرر في أقوالك وتغلب إذا حوكمت. لأني هاأنذا بالإثم حُبل بي، وبالخطايا ولدتني أمي. لأنك هكذا قد أحببت الحق، إذ أوضحت لي غوامض حكمتك ومستوراتها. تنضح عليّ بزوفاك فأطهر، تغسلني فأبيض أكثر من الثلج. تسمعني سروراً وفرحاً، فتبتهج عظامي المنحقة. اصرف وجهك عن خطاياي، وامحُ كل آثامي. قلباً نقياً اخلق فيّ يا الله، وروحاً مستقيماً جدد في أحشائي. لا تطرحني من قدام وجهك، وروحك القدوس لا تنزعه مني. امنحني بهجة خلاصك، وبروح مدبر عضدني. فأعلم الأثمة طرقك، والمنافقون إليك يرجعون. نجني من الدماء يا الله إله خلاصي، فيبتهج لساني ببرك. يا رب افتح شفتيّ، فيخبر فمي بتسبيحك. لأنك لو آثرت الذبيحة لكنت الآن أعطي، ولكنك لا تسر بالمحرقات. فالذبيحة لله روح منسحق، القلب المنكسر والمتواضع لا يرذله الله. أحسن يا رب بمسرتك إلى صهيون، ولتبنَ أسوار أورشليم. حينئذ تسر بذبائح البر قرباناً ومحرقات، حينئذ يقربون على مذابحك العجول. هللويا.\n\nبدء صلاة الغروب:\nتسبحة الساعة الحادية عشرة من النهار المبارك، أقدمها للمسيح ملكي وإلهي، وأرجوه أن يغفر لي خطاياي. من مزامير داود النبي بركاته علينا آمين. هلم نسجد هلم نسأل المسيح إلهنا.'
  },
  {
    'title': '٣. مزامير صلاة الغروب (116 و 117 و 119 و 120)',
    'text':
        '(1) المزمور المائة والسادس عشر\nسبحوا الرب يا جميع الأمم، ولتباركه كافة الشعوب. لأن رحمته قد ثبتت علينا، وحق الرب يدوم إلى الأبد. هلليلويا.\n\n(2) المزمور المائة والسابع عشر\nاعترفوا للرب لأنه صالح، وأن إلى الأبد رحمته. فليقل بيت إسرائيل إنه صالح، وأن إلى الأبد رحمته. فليقل بيت هارون إنه صالح، وأن إلى الأبد رحمته. فليقل عابدو الرب إلهنا إنه صالح، وأن إلى الأبد رحمته. في ضيقي صرخت إلى الرب، فاستجاب لي وأخرجني إلى الرحب. الرب عوني فلا أخاف ماذا يصنع بي الإنسان. هلليلويا.\n\n(3) المزمور المائة والتاسع عشر\nإلى الرب في ضيقي صرخت فاستجاب لي. يا رب نج نفسي من الشفاه الغاشة ومن اللسان الكذاب. ماذا تعطى وماذا تزداد من اللسان الغاش؟ سهام الأقوياء مسنونة مع جمر البرية. الويل لي لأن غربتي قد طالت علي، وسكنت في مساكن قيدار. طويلاً سكنت نفسي مع مبغضي السلام. كنت صاحب سلام وعندما كنت أكلمهم كانوا يحاربونني باطلاً. هلليلويا.\n\n(4) المزمور المائة والعشرون\nرفعت عيني إلى الجبال من حيث يأتي عوني. معونتي من عند الرب الذي صنع السماء والأرض. لا يدع رجلك تزل، ولا ينعس حارسك. هوذا لا ينعس ولا ينام حارس إسرائيل. الرب يحفظك، الرب يظلل على يدك اليمنى. فلا تحرقك الشمس بالنهار ولا القمر بالليل. الرب يحفظك من كل سوء، الرب يحفظ نفسك. الرب يحفظ دخولك وخروجك من الآن وإلى الأبد. هلليلويا.'
  },
  {
    'title': '٤. مزامير صلاة الغروب (121 و 122 و 123 و 124 و 128)',
    'text':
        '(5) المزمور المائة الحادي والعشرون\nفرحت بالقائلين لي إلى بيت الرب نذهب. وقفت أرجلنا في ديارك يا أورشليم. أورشليم المبنية كمدينة متصلة ببعضها. لأن هناك صعدت القبائل، قبائل الرب شهادة لإسرائيل، ليعترفوا لاسم الرب. لأن هناك جلست كراسي القضاء، كراسي بيت داود. اسألوا السلامة لأورشليم والخصب لمحبك. ليكن السلام في حصونك والخصب في أبراجك الرغدة. من أجل إخوتي وأقربائي تكلمت بالسلامة من أجلك، ومن أجل بيت الرب إلهنا التمست لك الخيرات. هلليلويا.\n\n(6) المزمور المائة والثاني والعشرون\nإليك رفعت عيني يا ساكن السماء. هوذا كعيون العبيد إلى أيدي مواليهم، وكعيني الأمة إلى يدي سيدتها، كذلك أعيننا نحو الرب إلهنا حتى يتراءف علينا. ارحمنا يا رب ارحمنا، فإننا كثيراً ما امتلأنا هواناً، وكثيراً ما امتلأت نفوسنا عاراً من المخصبين وإهانة من المستكبرين. هلليلويا.\n\n(7) المزمور المائة والثالث والعشرون\nلولا أن الرب كان معنا، ليقل إسرائيل: لولا أن الرب كان معنا عندما قام الناس علينا، لابتلعونا ونحن أحياء، عند احتدام غضبهم علينا. إذن لغرقنا في الماء، ولعبرت نفوسنا السيل، بل لعبرت نفوسنا الماء الذي لا لجام له. مبارك الرب الذي لم يسلمنا فريسة لأسنانهم. نجت أنفسنا مثل العصفور من فخ الصيادين، الفخ انكسر ونحن نجونا. معونتنا باسم الرب الذي صنع السماء والأرض. هلليلويا.\n\n(8) المزمور المائة والرابع والعشرون\nالمتوكلون على الرب مثل جبل صهيون، لا يتزعزع إلى الأبد الساكن في أورشليم. الجبال حولها، والرب حول شعبه من الآن وإلى الأبد. لأن الرب لا يترك عصا الخطاة تستقر على نصيب الصديقين، لكي لا يمد الصديقون أيديهم إلى الإثم. أحسن يا رب إلى الصالحين والمستقيمي القلوب. أما الذين يميلون إلى العثرات فيأخذهم الرب مع فاعلي الإثم، والسلام على إسرائيل. هلليلويا.\n\n(9) المزمور المائة والثامن والعشرون\nكثيراً ما حاربوني منذ صباي، ليقل إسرائيل: كثيراً ما حاربوني منذ صباي، وإنهم لم يقدروا علي. على ظهري جلدني الخطاة وأطالوا إثمهم. الرب عادل هو يقطع أعناق الخطاة. فليخز وليرتد إلى الوراء كل الذين يبغضون صهيون. وليكونوا كعشب السطوح الذي يبس قبل أن يقطع، الذي لم يملأ الحاصد منه يده ولا الواضع في الغرائر حضنه. ولا قال المارون: بركة الرب عليكم، باركناكم باسم الرب. هلليلويا.'
  },
  {
    'title': '٥. مزامير صلاة الغروب (129 و 130 و 131 و 133)',
    'text':
        '(10) المزمور المائة والتاسع والعشرون\nمن الأعماق صرخت إليك يا رب، يا رب استمع صوتي. لتكن أذناك مصغيتين إلى صوت تضرعي. إن كنت للآثام راصداً يا رب، يا رب من يثبت؟ لأن من عندك المغفرة. من أجل اسمك صبرت لك يا رب، صبرت نفسي لناموسك. توكلت نفسي على الرب من محرس الصبح إلى الليل. من محرس الصبح فليتكل إسرائيل على الرب. لأن الرحمة من عند الرب، وعظيم هو خلاصه، وهو يفدي إسرائيل من كل آثامه. هلليلويا.\n\n(11) المزمور المائة والثلاثون\nيا رب لم يرتفع قلبي، ولم تستعلِ عيناي، ولم أسلك في العظائم ولا في العجائب التي هي فوقي. إن كنت لم أتضع لكن رفعت نفسي، مثل الفطيم من اللبن على أمه، كذلك الجزاء على نفسي. فليتكل إسرائيل على الرب من الآن وإلى الأبد. هلليلويا.\n\n(12) المزمور المائة الحادي والثلاثون\nاذكر يا رب داود وكل دَعَتهِ. كيف حلف للرب ونذر لإله يعقوب: إني لا أدخل مسكن بيتي، ولا أصعد على سرير فراشي، ولا أعطي عيني نوماً ولا لأجفاني نعاساً، ولا راحة لصدغي، إلى أن أجد موضعاً للرب ومسكناً لإله يعقوب. هوذا قد سمعنا به في إفراتة، ووجدناه في موضع الغابة. ندخل إلى مساكنه ونسجد في الموضع الذي فيه استقرت قدماه. قم يا رب إلى راختك أنت وتابوت موضع قدسك. كهنتك يلبسون البر، وأبرارك يبتهجون. من أجل داود عبدك لا ترد وجه مسيحك. حلف الرب لداود حقاً ولم يخلف: من ثمرة بطنك أضع على كرسيك...\n\n(13) المزمور المائة والثالث والثلاثون\nهوذا باركوا الرب يا عبيد الرب، القائمين في بيت الرب في ديار بيت إلهنا. في الليالي ارفعوا أيديكم إلى القدس وباركوا الرب. يبارككم الرب من صهيون، الذي صنع السماء والأرض. هلليلويا.'
  },
  {
    'title': '٦. الإنجيل والقطع والتحليل والطلبة الختامية للغروب',
    'text':
        'من إنجيل معلمنا لوقا البشير، بركاته علينا جميعاً، آمين:\n\n(إنجيل لوقا 4: 38-41)\nولما قام من المجمع دخل بيت سمعان، وكانت حماة سمعان قد أخذتها حمى شديدة، فسألوه من أجلها. فوقف فوقها وانتهر الحمى فتركتها، وفي الحال قامت وصارت تخدمهم. وعند غروب الشمس، كان كل الذين عندهم مرضى بأنواع أمراض كثيرة يحضرونهم إليه، فوضع يديه على كل واحد منهم فبسط الشفاء لهم. وكانت الشياطين تخرج من كثيرين وهي تصرخ وتقول: "أنت هو المسيح ابن الله!" فكان ينتهرهم ولا يدعهم يتكلمون، لأنهم علموا أنه هو المسيح. (والمجد لله دائماً).\n\nالقطع الطقسية لغروب الشمس مفرودة:\nإذا ما تأملت في كثرة أعمالي الرديئة المكتوبة، تأخذني الرعدة والخوف من يوم الدينونة الرهيب المخوف. ولكنني إذ ألتفت إلى محبتك للبشر أصرخ إليك مثل داود قائلاً: ارحمني يا الله كعظيم رحمتك. (المجد للآب والابن والروح القدس).\nأيها المخلص الحنون، أسرع وافتح لي أحضانك الأبوية الدافئة، لأنني قد بددت حياتي وأيامي في الشهوات والملذات العالمية الضارة، وقد عبر النهار وتولى. فالآن لا تغفل عن قلبي المنسحق البائس، بل ارحمني واقبلني إليك كرأفتك. (الآن وكل أوان وإلى دهر الداهرين آمين).\nلكل ذي إثم وتوبة قدمتِ شفاعة يا والدة الإله الطاهرة المعظمة السماء الثانية. نسألك مع الرسل والقديسين أن تتضرعي إلى ابنك الحبيب ليحفظنا بسلام ويغفر خطايانا في هذا المساء المبارك.\nكيرياليسون (يا رب ارحم) ٤١ مرة بخوف وتدبير إلهي.\n\nقدوس قدوس قدوس رب الصباؤوت. السماء والأرض مملوءتان من مجدك وكرامتك. ارحمنا يا الله الآب ضابط الكل. أيها الثالوث القدوس ارحمنا. أيها الرب إله القوات كن معنا سواك. حل واغفر واصفح لنا يا الله عن سيئاتنا...\n\nالتحليل الكنسي المعتمد لصلاة الغروب:\nنشكرك يا رب العطايا الجزيلة، الرحوم، أبا ربنا وإلهنا ومخلصنا يسوع المسيح، لأنك أجزتنا هذا النهار بسلام بغير عثرة، وأتيت بنا إلى المساء شاكرين، وجعلتنا مستحقين أن ننظر نور المساء. اقبل إليك تضرعنا وشكرنا المسيحي في هذا المساء، وامنحنا في هذه الليلة المقبلة سلامة نقية وعفة من كل طياشة فكرية وأفعال مظلمة شيطانية، لكي نجوزها بسلام مع خوفك، ونسبح اسمك القدوس مع أبيك الصالح والروح القدس المحيي المساوي لك، الآن وكل أوان وإلى دهر الدهور كلها. أمين.\n\nطلبة تصلى آخر كل ساعة:\nارحمنا يا الله ثم ارحمنا. يا من في كل وقت وكل ساعة، في السماء وعلى الأرض، مسجود له وممجد. المسيح إلهنا الصالح، الطويل الروح، الكثير الرحمة، الجزيل التحنن، الذي يحب الصديقين ويرحم الخطاة الذين أولهم أنا. الذي لا يشاء موت الخاطئ مثل ما يرجع ويحيا. الداعي الكل إلى الخلاص لأجل الموعد بالخيرات المنتظرة. يا رب اقبل منا في هذه الساعة وكل ساعة طلباتنا. سهل حياتنا، وأرشدنا إلى العمل بوصاياك. قدس أرواحنا. طهر أجسامنا. قوم أفكارنا. نق نياتنا. اشف أمراضنا واغفر خطايانا. ونجنا من كل حزن رديء ووجع قلب. أحطنا بملائكتك القديسين، لكي نكون بمعسكرهم محفوظين ومرشدين، لنصل إلى اتحاد الإيمان وإلى معرفة مجدك غير المحسوس وغير المحدود، فإنك مبارك إلى الأبد. أمين.\nاللهم اجعلنا مستحقين أن نقول بشكر: أبانا الذي في السموات...'
  }
];

final List<Map<String, String>> _sleepTextData = [
  {
    'title': '١. مقدمة كل ساعة، الصلاة الربانية، وصلاة الشكر',
    'text':
        'بِاسْمِ الآبِ وَالابْنِ وَالرُّوحِ الْقُدُسِ الإِلَهِ الْوَاحِدِ، آمِينَ.\n\nكيرياليصون (يا رب ارحم). كيرياليصون. كيرياليصون. يا رب بارك. آمين.\n\nالمجد للآب والابن والروح القدس، الآن وكل أوان وإلى دهر الدهور، آمين.\n\nالصلاة الربانية:\nأبانا الذي في السماوات، ليتقدس اسمك، ليأت ملكوتك، لتكن مشيئتك كما في السماء كذلك على الأرض. خبزنا الذي للغد أعطنا اليوم، واغفر لنا ذنوبنا كما نغفر نحن أيضاً للمذنبين إلينا، ولا تدخلنا في تجربة، لكن نجنا من الشرير، بالمسيح يسوع ربنا، لأن لك الملك والقوة والمجد إلى الأبد. آمين.\n\nصلاة الشكر الطقسية:\nفلنشكر صانع الخيرات الرحوم الله، أبا ربنا وإلهنا ومخلصنا يسوع المسيح، لأنه سترنا وأعاننا، وحفظنا وقبلنا إليه وأشفق علينا وعضدنا، وأتى بنا إلى هذه الساعة. هو أيضاً فلنسأله أن يحفظنا في هذا اليوم المقدس وكل أيام حياتنا بكل سلام، الضابط الكل الرب إلهنا.\n\nأيها السيد الرب الإله ضابط الكل أبا ربنا وإلهنا ومخلصنا يسوع المسيح، نشكرك على كل حال ومن أجل كل حال وفي كل حال، لأنك سترتنا وأعنتنا وحفظتنا وقبلتنا إليك وأشفقت علينا وعضدتنا وأتيت بنا إلى هذه الساعة.\n\nمن أجل هذا نسأل ونطلب من صلاحك يا محب البشر، امنحنا أن نكمل هذا اليوم المقدس وكل أيام حياتنا بكل سلام مع خوفك. كل حسد، وكل تجربة، وكل فعل الشيطان، ومؤامرة الناس الأشرار، وقيام الأعداء الخفيين والظاهرين، انزعها عنا وعن سائر شعبك، وعن موضعك المقدس هذا. أما الصالحات والنافعات فارزقنا إياها، لأنك أنت الذي أعطيتنا السلطان أن ندوس الحيات والعقارب وكل قوة العدو. ولا تدخلنا في تجربة، لكن نجنا من الشرير بالنعمة والرأفات ومحبة البشر اللواتي لابنك الوحيد ربنا وإلهنا ومخلصنا يسوع المسيح، هذا الذي من قبله المجد والإكرام والعز والسجود تليق بك معه مع الروح القدس المحيي المساوي لك الآن وكل أوان وإلى دهر الدهور. آمين.'
  },
  {
    'title': '٢. المزمور الخمسون وبدء صلاة النوم التعبدية',
    'text':
        'المزمور الخمسون (مزمور التوبة):\nارحمني يا الله كعظيم رحمتك، ومثل كثرة رأفتك امحُ إثمي. اغسلني كثيراً من إثمي ومن خطيتي طهرني، لأني عارف بإثمي وخطيتي أمامي في كل حين. لك وحدك أخطأت، والشر قدامك صنعت، لكي تتبرر في أقوالك وتغلب إذا حوكمت. لأني هاأنذا بالإثم حُبل بي، وبالخطايا ولدتني أمي. لأنك هكذا قد أحببت الحق، إذ أوضحت لي غوامض حكمتك ومستوراتها. تنضح عليّ بزوفاك فأطهر، تغسلني فأبيض أكثر من الثلج. تسمعني سروراً وفرحاً، فتبتهج عظامي المنحقة. اصرف وجهك عن خطاياي، وامحُ كل آثامي. قلباً نقياً اخلق فيّ يا الله، وروحاً مستقيماً جدد في أحشائي. لا تطرحني من قدام وجهك، وروحك القدوس لا تنزعه مني. امنحني بهجة خلاصك، وبروح مدبر عضدني. فأعلم الأثمة طرقك، والمنافقون إليك يرجعون. نجني من الدماء يا الله إله خلاصي، فيبتهج لساني ببرك. يا رب افتح شفتيّ، فيخبر فمي بتسبيحك. لأنك لو آثرت الذبيحة لكنت الآن أعطي، ولكنك لا تسر بالمحرقات. فالذبيحة لله روح منسحق، القلب المنكسر والمتواضع لا يرذله الله. أحسن يا رب بمسرتك إلى صهيون، ولتبنَ أسوار أورشليم. حينئذ تسر بذبائح البر قرباناً ومحرقات، حينئذ يقربون على مذابحك العجول. هللويا.\n\nبدء صلاة النوم:\nتسبحة الساعة الثانية عشرة من النهار المبارك، أقدمها للمسيح ملكي وإلهي، وأرجوه أن يغفر لي خطاياي. من مزامير داود النبي بركاته علينا آمين. هلم نسجد هلم نسأل المسيح إلهنا.'
  },
  {
    'title': '٣. مزامير صلاة النوم (129 و 130 و 131 و 132)',
    'text':
        '(1) المزمور المائة والتاسع والعشرون\nمن الأعماق صرخت إليك يا رب، يا رب استمع صوتي. لتكن أذناك مصغيتين إلى صوت تضرعي. إن كنت للآثام راصداً يا رب، يا رب من يثبت؟ لأن من عندك المغفرة. من أجل اسمك صبرت لك يا رب، صبرت نفسي لناموسك. توكلت نفسي على الرب من محرس الصبح إلى الليل. من محرس الصبح فليتكل إسرائيل على الرب. لأن الرحمة من عند الرب، وعظيم هو خلاصه، وهو يفدي إسرائيل من كل آثامه. هلليلويا.\n\n(2) المزمور المائة والثلاثون\nيا رب لم يرتفع قلبي، ولم تستعلِ عيناي، ولم أسلك في العظائم ولا في العجائب التي هي فوقي. إن كنت لم أتضع لكن رفعت نفسي، مثل الفطيم من اللبن على أمه، كذلك الجزاء على نفسي. فليتكل إسرائيل على الرب من الآن وإلى الأبد. هلليلويا.\n\n(3) المزمور المائة الحادي والثلاثون\nاذكر يا رب داود وكل دَعَتهِ. كيف حلف للرب ونذر لإله يعقوب: إني لا أدخل مسكن بيتي، ولا أصعد على سرير فراشي، ولا أعطي عيني نوماً ولا لأجفاني نعاساً، ولا راحة لصدغي، إلى أن أجد موضعاً للرب ومسكناً لإله يعقوب. هوذا قد سمعنا به في إفراتة، ووجدناه في موضع الغابة. ندخل إلى مساكنه ونسجد في الموضع الذي فيه استقرت قدماه. قم يا رب إلى راحتك أنت وتابوت موضع قدسك. كهنتك يلبسون البر، وأبرارك يبتهج الخائفون الرب...\n\n(4) المزمور المائة والثاني والثلاثون\nهوذا ما أحسن وما أجمل أن يسكن الإخوة معاً! كالطيب الكائن على الرأس الذي ينزل على اللحية، لحيّة هارون النازلة على جيب قميصه. ومثل ندى حرمون المنحدر على جبل صهيون. لأن هناك أمر الرب بالبركة والحياة إلى الأبد. هلليلويا.'
  },
  {
    'title': '٤. مزامير صلاة النوم (133 و 137 و 140 و 141 و 145 و 146)',
    'text':
        '(5) المزمور المائة والثالث والثلاثون\nهوذا باركوا الرب يا عبيد الرب، القائمين في بيت الرب في ديار بيت إلهنا. في الليالي ارفعوا أيديكم إلى القدس وباركوا الرب. يبارككم الرب من صهيون، الذي صنع السماء والأرض. هلليلويا.\n\n(6) المزمور المائة والسابع والثلاثون\nأعترف لك يا رب من كل قلبي، لأنك استمعت كل كلمات فمي. أمام الملائكة أرتل لك، وأسجد قدام هيكل قدسك. وأعترف لاسمك على رحمتك وحقك، لأنك عظّمت اسمك القدوس على الكل. في اليوم الذي أدعوك فيه أجبني سريعا، تكاثر العز في نفسي بقوة. فليعترف لك يا رب كل ملوك الأرض، لأنهم سمعوا سائر كلمات فمك، وليرتلوا في طرق الرب لأن مجد الرب عظيم. لأن الرب عال ويعاين المتواضعين، والأشياء المرتفعة يعرفها من بعيد. إن سلكت في وسط الضيق تحييني، على رجز الأعداء مددت يدك وخلصتني يمينك. الرب يجازي عني، يا رب رحمتك دائمة إلى الأبد، أعمال يديك لا تتركها. هلليلويا.\n\n(7) المزمور المائة والأربعون\nيا رب إليك صرخت فاستمع لي، أنصت إلى صوت تضرعي عندما أصرخ إليك. لتستقم صلاتي كالبخور قدامك، وليكن رفع يدي كذبيحة مسائية. ضع يا رب حارساً لفمي وباباً حصيناً لشفتيّ، لئلا يميل قلبي إلى كلام الشر، فيصنع أعذاراً في الخطايا مع الناس فاعلي الإثم، ولا أشترك مع مختاريهم. فليؤدبني الصديق برحمة وبوبخني، أما زيت الخاطئ فلا يدهن رأسي...\n\n(8) المزمور المائة والحادي والأربعون\nبصوتي إلى الرب صرخت، بصوتي إلى الرب تضرعت. أسكب أمامه صلاتي، وبضيقي قدامه أخبر. عند فناء روحي مني وأنت تعرف سبلي. في الطريق التي كنت أسلك فيها أخفوا لي فخاً. تأملت عن اليمين وأبصرت، فلم يكن من يعرفني. ضاع المهرب مني ولم يوجد من يطلب نفسي. صرخت إليك يا رب وقلت: أنت هو رجائي ونصيبي في أرض الأحياء. أنصت إلى طلبتي فإني قد اتضعت جداً، نجني من الذين يضطهدونني لأنهم قد قووا علي. أخرج من الحبس نفسي لكي أعترف لاسمك يا رب، إياي ينتظر الصديقون حتى تجازيني. هلليلويا.\n\n(9) المزمور المائة والخامس والأربعون\nسبحي يا نفسي الرب، أسبح الرب في حياتي، وأرتل لإلهي ما دمت حياً. لا تتكلوا على الرؤساء ولا على بني البشر الذين ليس عندهم خلاص. تخرج روحهم فيعودون إلى أرضهم، في ذلك اليوم تهلك سائر أفكارهم. طوبى لمن إله يعقوب معينه، ورجاؤه على الرب إلهه الذي صنع السماء والأرض والبحر وكل ما فيها. الحافظ الحق إلى الأبد، الصانع الحكم للمظلومين، المعطي الطعام للجياع. الرب يحل الموثقين، الرب يحكم العميان، الرب يقوّم المنحنين، الرب يحب الصديقين، الرب يحفظ الغرباء، ويعضد اليتيم والأرملة، ويبيد طرق الخطاة. يملك الرب إلى الأبد، إلهك يا صهيون من جيل إلى جيل. هلليلويا.\n\n(10) المزمور المائة والسادس والأربعون\nسبحوا الرب فإن المزمور صالح، ولإلهنا يلذ التسبيح. الرب يبني أورشليم، ويجمع متفرقي إسرائيل. الشافي المنكسري القلوب، والذين عصب جراحهم. العادّ كثرة الكواكب، ولكلها يعطي أسماء. عظيم هو ربنا وعظيمة هي قوته، ولا إحصاء لفهمه. الرب يرفع الودعاء، ويضع الخطاة إلى الأرض. ابدأوا للرب بالاعتراف، رتلوا لإلهنا بالقيثارة. المتسربل بالسموات سحاباً، المهيئ للأرض مطراً، المنبت العشب في الجبال، والخضرة لخدمة البشر. المعطي للبهائم طعامها، ولأفراخ الغربان التي تدعوه. لا يشاء قوة الخيل، ولا يسر بساقي الرجل. يسر الرب بخائفيه، وبالراجين رحمته. هلليلويا.'
  },
  {
    'title': '٥. مزمور ١٤٧ وإنجيل صلاة النوم الطقسي (لوقا 2)',
    'text':
        '(11) المزمور المائة والسابع والأربعون\nسبحي الرب يا أورشليم، سبحي إلهك يا صهيون. لأنه قد قوّى مغاليق أبوابك، وبارك بنيك فيك. الذي جعل تخومك سلاماً، ويملأك من شحم الحنطة. الذي يرسل كلمته إلى الأرض، فيسرع قوله جداً. المعطي الثلج كالصوف، المذرّي الضباب كالرماد. ويلقي جمده ككسر، قدام وجه برده من يثبت؟ يرسل كلمته فتذيبها، تهب روحه فتسيل المياه. المخبر كلمته ليعقوب، وفرائضه وأحكامه لإسرائيل. لم يصنع هكذا بكل الأمم، وأحكامه لم يعلنها لهم. هلليلويا.\n\nمن إنجيل معلمنا لوقا البشير، بركاته علينا جميعاً، آمين:\n(إنجيل لوقا 2: 29-32)\nالآن يا سيدي تطلق عبدك بسلام حسب قولك، لأن عيني قد أبصرتا خلاصك، الذي أعددته قدام وجه جميع الشعوب. نوراً تجلى للأمم، ومجداً لشعبك إسرائيل. (والمجد لله دائماً).\n\nالقطع لصلوات النوم الطقسية مفرودة:\nهوذا أنا عتيد أن أقف أمام الديان العادل مرعوباً ومرتعباً من كثرة ذنوبي، لأن العمر المنقضي في الملاهي يستوجب الدينونة. لكن توبي يا نفسي ما دمتِ في الأرض ساكنة، لأن التراب في القبر لا يسبح، ومن بين الموتى ليس من يذكر الرب ولا في الجحيم من يشكر. بل اصرخي للمسيح إلهنا مستغيثة: يا رب أنر عينيّ لئلا أنام نوم الموت، ارحمني وخلصني. (المجد للآب والابن والروح القدس).\nلو كان العمر ثابتاً وهذا العالم باقياً لكان لكِ يا نفسي عذر واضح. لكن إذا انكشفت أفعالكِ الرديئة وسيئاتكِ المستترة أمام الديان العادل، فأي جواب تحجين به وأنتِ على سرير البطالة ضاجعة وفي تهاون الملاهي عائشة؟ بل اصرخي للمسيح مستغيثة من الأعماق: يا رب لا تدني في خطاياي بل ارحمني وخلصني. (الآن وكل أوان وإلى دهر الداهرين آمين).'
  },
  {
    'title': '٦. تتمة القطع، التحاليل والطلبة الختامية لصلاة النوم',
    'text':
        'أيتها العذراء الطاهرة الطوباوية، ظليلي بجناحيكِ الشافعتين على عبدكِ البائس الخاطئ، وامنعي عني طياشة الأفكار الرديئة الشيطانية في هذا المساء، وأقيمي نفسي الميتة للصلاة والتسبيح، لأنكِ أنتِ هي باب السماء والرحمة الممتلئة مجداً. آمين.\n\nتسبحة الملائكة والثلاث تقديسات وقانون الإيمان المكتمل بالكامل صامتون بخشوع.\nكيرياليسون (يا رب ارحم) ٤١ مرة.\n\nقدوس قدوس قدوس رب الصباؤوت. السماء والأرض مملوءتان من مجدك وكرامتك. ارحمنا يا الله الآب ضابط الكل. أيها الثالوث القدوس ارحمنا. أيها الرب إله القوات كن معنا سواك. حل واغفر واصفح لنا يا الله عن سيئاتنا...\n\nالتحليل الكنسي الأول لصلاة النوم:\nأيها السيد الرب يسوع المسيح ابن الله الحي، الذي أضاء لنا النهار والليل راحة لكل البشر، نشكرك لأنك أجزتنا هذا اليوم بسلام وأتيت بنا إلى بداية الليل شاكرين. نسألك يا محب البشر، اغفر لنا خطايانا التي صنعناها في هذا النهار بمعرفة وبغير معرفة، بالقول وبالفعل وبالفكر وبسائر حواسنا. وامنحنا في هذه الليلة المقبلة سلامة نقية، ونوماً هادئاً بغير قلق، وأنقذنا من طوارق الشياطين والأحلام الرديئة المخوفة. وأقظنا في السحر مستعدين للعمل بوصاياك وخدمتك بطهارة، لأنك أنت هو مبارك إلى الأبد أمين.\n\nالتحليل الثاني لصلاة النوم:\nأيها الرب الإله الرؤوف الرحيم، صانع الصالحات الرحوم، تفضل واقبل صلواتنا وتضرعنا في هذا المساء، وامنحنا عقلاً مستيقظاً، وفكراً نزيهاً طاهراً، وسيرة مرضية، لتكمل أيام حياتنا بكل خوفك العظيم... [نص طلبة آخر كل ساعة المفرود بالتمام والكمال].\n\nاللهم اجعلنا مستحقين أن نقول بشكر:\nأبانا الذي في السموات...'
  }
];

final List<Map<String, String>> _midnightTextData = [
  {
    'title': '١. الافتتاحية، الصلاة الربانية، وصلاة الشكر ',
    'text':
        'بِاسْمِ الآبِ وَالابْنِ وَالرُّوحِ الْقُدُسِ الإِلَهِ الْوَاحِدِ، آمِينَ.\n\nكيرياليصون (يا رب ارحم). كيرياليصون. كيرياليصون. يا رب بارك. آمين.\nالمجد للآب والابن والروح القدس، الآن وكل أوان وإلى دهر الدهور، آمين.\n\nالصلاة الربانية:\nأبانا الذي في السماوات، ليتقدس اسمك، ليأت ملكوتك، لتكن مشيئتك كما في السماء كذلك على الأرض. خبزنا الذي للغد أعطنا اليوم، واغفر لنا ذنوبنا كما نغفر نحن أيضاً للمذنبين إلينا، ولا تدخلنا في تجربة، لكن نجنا من الشرير، بالمسيح يسوع ربنا، لأن لك الملك والقوة والمجد إلى الأبد. آمين.\n\nصلاة الشكر الطقسية :\nفلنشكر صانع الخيرات الرحوم الله، أبا ربنا وإلهنا ومخلصنا يسوع المسيح، لأنه سترنا وأعاننا، وحفظنا وقبلنا إليه وأشفق علينا وعضدنا، وأتى بنا إلى هذه الساعة. هو أيضاً فلنسأله أن يحفظنا في هذه الليلة المقدسة وكل أيام حياتنا بكل سلام، الضابط الكل الرب إلهنا.\n\nأيها السيد الرب الإله ضابط الكل أبا ربنا وإلهنا ومخلصنا يسوع المسيح، نشكرك على كل حال ومن أجل كل حال وفي كل حال، لأنك سترتنا وأعنتنا وحفظتنا وقبلتنا إليك وأشفقت علينا وعضدتنا وأتيت بنا إلى هذه الساعة.\n\nمن أجل هذا نسأل ونطلب من صلاحك يا محب البشر، امنحنا أن نكمل هذه الليلة المقدسة وكل أيام حياتنا بكل سلام مع خوفك. كل حسد، وكل تجربة، وكل فعل الشيطان، ومؤامرة الناس الأشرار، وقيام الأعداء الخفيين والظاهرين، انزعها عنا وعن سائر شعبك، وعن موضعك المقدس هذا. أما الصالحات والنافعات فارزقنا إياها، لأنك أنت الذي أعطيتنا السلطان أن ندوس الحيات والعقارب وكل قوة العدو. ولا تدخلنا في تجربة، لكن نجنا من الشرير بالنعمة والرأفات ومحبة البشر اللواتي لابنك الوحيد ربنا وإلهنا ومخلصنا يسوع المسيح، هذا الذي من قبله المجد والإكرام والعز والسجود تليق بك معه مع الروح القدس المحيي المساوي لك الآن وكل أوان وإلى دهر الدهور. آمين.'
  },
// ====================================================================
// صلاة نصف الليل - الجزء الثاني (٢. المزمور الخمسون وقوموا يا بني النور)
// ====================================================================
  {
    'title': '٢. المزمور الخمسون (مزمور التوبة)',
    'text':
        'ارحمني يا الله كعظيم رحمتك، ومثل كثرة رأفتك امحُ إثمي. اغسلني كثيراً من إثمي ومن خطيتي طهرني، لأني عارف بإثمي وخطيتي أمامي في كل حين. لك وحدك أخطأت، والشر قدامك صنعت، لكي تتبرر في أقوالك وتغلب إذا حوكمت. لأني هاأنذا بالإثم حُبل بي، وبالخطايا ولدتني أمي. لأنك هكذا قد أحببت الحق، إذ أوضحت لي غوامض حكمتك ومستوراتها. تنضح عليّ بزوفاك فأطهر، تغسلني فأبيض أكثر من الثلج. تسمعني سروراً وفرحاً، فتبتهج عظامي المنحقة. اصرف وجهك عن خطاياي، وامحُ كل آثامي. قلباً نقياً اخلق فيّ يا الله، وروحاً مستقيماً جدد في أحشائي. لا تطرحني من قدام وجهك، وروحك القدوس لا تنزعه مني. امنحني بهجة خلاصك، وبروح مدبر عضدني. فأعلم الأثمة طرقك، والمنافقون إليك يرجعون. نجني من الدماء يا الله إله خلاصي، فيبتهج لساني ببرك. يا رب افتح شفتيّ، فيخبر فمي بتسبيحك. لأنك لو آثرت الذبيحة لكنت الآن أعطي، ولكنك لا تسر بالمحرقات. فالذبيحة لله روح منسحق، القلب المنكسر والمتواضع لا يرذله الله. أحسن يا رب بمسرتك إلى صهيون، ولتبنَ أسوار أورشليم. حينئذ تسر بذبائح البر قرباناً ومحرقات، حينئذ يقربون على مذابحك العجول. هللويا.'
  },
  {
    'title': '٣. تسبحة قوموا يا بني النور  ',
    'text':
        'قوموا يا بني النور لنسبح رب القوات، لكي ينعم علينا بخلاص نفوسنا، عندما نقف أمامك جسديا انزع من عقولنا نوم الغفلة. أعطنا يا رب يقظة لكي نفهمَ كيف نقف أمامك وقت الصلاة، ونرسلَ لك إلي فوقُ التمجيدَ اللائق، ونفوزَ بغفران خطايانا الكثيرة. (المجد لك يا محب البشر)\n\nها باركوا الرب يا عبيد الرب، القائمين في بيت الرب، في ديار إلهنا. في الليالي ارفعوا أيديكم إلي القدس، وباركوا الرب. يبارككم الرب من صهيون، الذي خلق السماء والأرض. (المجد لك يا محب البشر)\n\nفلتدن وسيلتي قدامك يا رب، كقولك فهمني. فلتدخل طلبتي إلى حضرتك يا رب، ككلمتك أحيني. تفيض شفتاي السبح، إذا ما علمتني حقوقك. لساني ينطق بأقوالك، لأن جميع وصاياك عادلة. لتكن يدك لتخلصني لأنني اشتهيت وصاياك. اشتقت إلي خلاصك يا رب، وناموسك هو تلاوتي. تحيا نفسي وتسبحك، وأحكامك تعينني. ضللتُ مثل الخروف الضال، فاطلب عبدك، فإني لوصاياك لم أنسَ.\n\nالمجد للآب والابن والروح القدس الآن وكل أوان والى دهر الدهور آمين. المجد للآب والابن والروح القدس، منذ الآن والى أبد الآباد كلها آمين. المجد لك يا محب البشر الصالح. السلام لأمك العذراء مع جميع قديسيك. المجد لك أيها الثالوث القدوس ارحمنا.\n\nفليقم الله، وليتبدد جميع أعدائه، وليهرب من قدام وجهه كل مبغضي اسمه القدوس. وأما شعبك فليكن بالبركة ألوف ألوف وربوات ربوات، يصنعون إرادتك. يا رب افتح شفتي ولينطق فمي بتسبيحك. أمين. هلليلويا.\n\nصلاة الخدمة الأولى من الليل المبارك، أقدمها للمسيح ملكي وإلهي، وأرجوه أن يغفر لي خطاياي.'
  },
  {
    'title': '٤. (المزمور الثالث 3)  ',
    'text':
        'يا رب لماذا كثر الذين يحزنونني، كثيرون قاموا علي. كثيرون يقولون لنفسي، ليس له خلاص بإلهه. أنت يا رب أنت هو ناصري، مجدي ورافع رأسي. بصوتي إلى الرب صرخت. فاستجاب لي من جبل قدسه. أنا اضطجعت ونمت، ثم استيقظت لأن الرب ناصري. فلا أخاف من ربوات الجموع المحيطين بي القائمين على. قم يا رب خلصني يا إلهي، لأنك ضربت كل من يعاديني باطلا. أسنان الخطاة سحقتها. للرب الخلاص وعلى شعبه بركته. هلليلويا.'
  },
  {
    'title': '٥. (المزمور السادس 6)  ',
    'text':
        'يا رب لا تبكتني بغضبك، ولا تؤدبني بسخطك. ارحمني يا رب فإني ضعيف، اشفني يا رب فإن عظامي قد اضطربت ونفسي قد انزعجت جدا. وأنت يا رب فإلى متى؟ عد ونج نفسي، وأحيني من أجل رحمتك. لأنه ليس في الموت من يذكرك ولا في الجحيم من يعترف لك. تعبت في تنهدي. أعوم كل ليلة سريري، وبدموعي أبل فراشي. تعكرت من الغضب عيناي. شاخت من سائر أعدائي . ابعدوا عنى يا جميع فاعلي الإثم. لأن الرب قد سمع صوت بكائي. الرب سمع تضرعي، الرب لصلاتي قبل، فليَخزَ وليضطرب جدا جميع أعدائي، وليرتدوا إلى ورائهم بالخزي سريعا جدا. هلليلويا.'
  },
  {
    'title': '٦. (المزمور الثاني عشر 12)  ',
    'text':
        'إلى متى يا رب تنساني؟ إلى الانقضاء؟ حتى متى تصرف وجهك عني؟ إلى متى أردد هذه المشورات في نفسي، وهذه الأوجاع في قلبي النهار كله؟ إلى متى يرتفع عدوى علي؟ انظر واستجب لي يا ربي وإلهي. أنر عيني لئلا أنام نوم الموت، لئلا يقول عدوي: إني قد قويت عليه. الذين يحزنونني يتهللون إن أنا زللت. أما أنا فعلى رحمتك توكلت. يبتهج قلبي بخلاصك. أسبح الرب المحسنَ إلي، وأرتل لاسم الرب العلي. هلليلويا.'
  },
  {
    'title': '٧. (المزمور التاسع والستون 69)  ',
    'text':
        'اللهم التفت إلى معونتي، يا رب أسرع وأعنى. ليَخزَ ويخجل طالبو نفسي، وليرتد إلى خلف ويخجل الذين يبتغون لي الشر. وليرجع بالخزي سريعا القائلون لي: نِعِمَّا نِعِمَّا. وليبتهج ويفرح بك جميع الذين يلتمسونك، وليقل في كل حين محبو خلاصك: فليتعظم الرب. وأما أنا فمسكين وفقير، اللهم أعنى. أنت معيني ومخلصي يا رب فلا تبطئ. هلليلويا.'
  },
  {
    'title': '٨. (المزمور الخامس والثمانون 85)  ',
    'text':
        'أمل يا رب أذنك واستمعني، لأني مسكين وبائس أنا. احفظ نفسي لأني بار، يا إلهي خلص عبدك المتكل عليك. ارحمني يا رب، لأني إليك أصرخ اليوم كله. فرح نفس عبدك، لأني إليك يا رب رفعت نفسي. لأنك أنت يا رب صالح ووديع، ورحمتك كثيرة لكافة المستغيثين بك. أنصت يا رب إلي صلاتي، وأصغ إلى صوت تضرعي. في يوم شدتي إليك صرختُ فأجبتني. فليس لك شبيه في الآلهة يا رب، ولا من يصنع كأعمالك. كل الأمم الذين خلقتهم يأتون ويسجدون أمامك يا رب، ويمجدون اسمك. لأنك أنت عظيم وصانع العجائب، أنت وحدك الإله العظيم. اهدني يا رب إلى طريقك فأسلك في حقك، ليفرح قلبي عند خوفه من اسمك. أعترف لك أيها الرب إلهي من كل قلبي، وأمجد اسمك إلى الأبد. لأن رحمتك عظيمة على، وقد نجيت نفسي من الجحيم السفلي. اللهم إن مخالفي الناموس قد قاموا علىّ ومجمع الأعزاء طلبوا نفسي، ولم يسبقوا أن يجعلوك أمامهم. وأنت أيها الرب الإله أنت رؤوف ورحيم. أنت طويل الروح، وكثير الرحمة وصادق. انظر إلي وارحمني. أعطِ عزة لعبدك، وخلص ابن أمتك. اصنع معي آية صالحة، ليرى ذلك مبغضي فيخزوا. لأنك أنت يا رب أعنتني وعزيتني. هلليلويا.'
  },
  {
    'title': '٩. (المزمور التسعون 90)  ',
    'text':
        'الساكن في عون العَليّ، يستريح في ظل إله السماء. يقول للرب أنت هو ناصري وملجأي، إلهي فأتكل عليه. لأنه ينجيك من فخ الصياد، ومن كلمة مقلقة. في وسط منكبيه يظللك، وتحت جناحيه تعتصم، عدله يحيط بك كالسلاح. فلا تخشى من خوف الليل، ولا من سهم يطير في النهار. ولا من أمر يسلك في الظلمة، ولا من سقطة وشيطان الظهيرة. يسقط عن يسارك ألوف، وعن يمينك ربوات، وأما أنت فلا يقتربون إليك. بل بعينيك تتأمل، ومجازاة الخطاة تبصر. لأنك أنت يا رب رجائي. جعلتَ العليَّ ملجأك. فلا تصيبك الشرور، ولا تدنو ضربة من مسكنك. لأنه يوصى ملائكته بك، ليحفظوك في سائر طرقك. وعلى أيديهم يحملونك، لئلا تعثر بحجر رجلك. تطأ الأفعى وملكَ الحيات، وتسحق الأسد والتنين. لأنه على أتكل فأنجيه، أرَفعه (أستره) لأنه عرف اسمي. يدعوني فأستجيب له. معه أنا في الشدة، أنقذه وأمجده. ومن طول الأيام أشبعه، وأريه خلاصي. هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - (المزمور المائة والسادس عشر) كاملاً لوحده
// ====================================================================
  {
    'title': '١٠. (المزمور المائة والسادس عشر 116) ',
    'text':
        'سبحوا الرب يا جميع الأمم، ولتباركه كافة الشعوب. لأن رحمته قد ثبتت علينا، وحق الرب يدوم إلى الأبد. هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - (المزمور المائة والسابع عشر) كاملاً لوحده
// ====================================================================
  {
    'title': '١١. (المزمور المائة والسابع عشر 117) ',
    'text':
        'اعترفوا للرب لأنه صالح، وأن إلى الأبد رحمته. فليقل بيت إسرائيل إنه صالح، وأن إلى الأبد رحمته. فليقل بيت هارون إنه صالح، وأن إلى الأبد رحمته. فليقل عابدو الرب إلهنا إنه صالح، وأن إلى الأبد رحمته. في ضيقي صرخت إلى الرب، فاستجاب لي وأخرجني إلى الرحب. الرب عوني فلا أخاف ماذا يصنع بي الإنسان. الرب ناصري، فسأرى بأعدائي. التكلان على الرب خير من التكلان على البشر. الرجاء بالرب خير من الرجاء بالرؤساء. كل الأمم أحاطوا بي، وباسم الرب انتقمت منهم. أحاطوا بي واكتنفوني، وباسم الرب قهرتهم. أحاطوا بي مثل النحل حول الشهد، والتهبوا كنار في شوك، وباسم الرب انتقمت منهم. دفعت وطرحت لأقسط، والرب عضدني. قوتي وتسبحتي هو الرب، وقد صار لي خلاصا. صوت التهليل والخلاص في مساكن الأبرار. يمين الرب صنعت قوة، يمين الرب رفعتني، يمين الرب صنعت قوة. لا أموت بل أحيا وأحدث بأعمال الرب. تأديبا أدبني الرب، وإلى الموت لم يسلمني. افتحوا لي أبواب البر، لأدخل فيها وأعترف للرب. هذا هو باب الرب، والصديقون يدخلون فيه. أعترف لك لأنك استجبت لي وصمت لي خلاصا. الحجر الذي رذله البناؤون، هذا صار رأسا للزاوية. من قِبل الرب كان هذا، وهو عجيب في أعيننا. هذا هو اليوم الذي صنعه الرب، فلنبتهج ونفرح فيه. يا رب خلصنا، يا رب سهل طريقنا. مبارك الآتي باسم الرب، باركناكم من بيت الرب. الله الرب أضاء علينا. رتبوا عيدا بضحايا كثيفة تصل إلى قرون المذبح. إلهي أنت فأعترف لك، إلهي أنت فأرفعك. أعترف لك لأنك استجبت لي وصِرت لي خلاصا. اعترفوا للرب لأنه صالح، وأن إلى الأبد رحمته. هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - المزمور الكبير ١١٨ - الجزء الأول (القطع ١-٨)
// ====================================================================
  {
    'title': '١٢. مزمور 118 (القطع من 1 إلى 8) ',
    'text':
        '(القطعة 1) (ذكصاسي فيلا نيثروبي: المجد لك يا محب البشر طوبى للذين هم بلا عيب في الطريق، السالكين في ناموس الرب. طوبى للذين يفحصون عن شهاداته، ومن كل قلوبهم يطلبونه. لأن فاعلي الإثم لم يسلكوا في طرقه. أنت أمرت أن تحفظ وصاياك جداً. ليت طرقي تستقيم لحفظ حقوقك. حينئذ لا أخزى إذا ما نظرت إلى كل وصاياك. أعترف لك باستقامة قلب، إذا ما تعلمت أحكام عدلك. حقوقك أحفظ، فلا ترفضني إلى الغاية.\n\n(القطعة 2) بم يصحح الشاب طريقه؟ بحفظه أقوالك. من كل قلبي طلبتك، فلا تطرحني من وصاياك. خَبأتُ كلامك في قلبي لكيلا أخطئ إليك. مبارك أنت يا رب، علمني حقوقك. بشفتيّ أظهرت كل أحكام فمك. في طريق شهاداتك تنعمت كما في كل غنى. بوصاياك ألهج، وأتبين طرقك. بحقوقك أتدرب، ولا أنسى كلامك.\n\n(القطعة 3) اصنع فضلاً مع عبدك فأحيا وأحفظ أقوالك. اكشف عن عيني فأتأمل عجائب من ناموسك. غريب أنا في الأرض، فلا تخفِ عني وصاياك. تقت نفسي إلى اشتهاء أحكامك في كل حين. انتهرت المتكبرين الملاعين الحائدين عن وصاياك. انزع عني العار والإهانة فإني لشهاداتك ابتغيت. لأن الرؤساء جلسوا وتقاولوا عليّ، أما عبدك فكان يلهج في حقوقك. لأن شهاداتك هي درسي، ومشوراتي هي حقوقك.\n\n(القطعة 4) لَصقت بالتراب نفسي، فأحيني ككلمتك. أظهرتُ طرقي فاستجبت لي، علمني حقوقك. طريق عدلك فهمني, فألهج في عجائبك. نعست نفسي من الحزن، فثبتني في أقوالك. طريق الظلم أبعد عني، وبناموسك ارحمني. طريق الحق اخترتُ، وأحكامك لم أنسَ. لصقتُ بشهاداتك يا رب فلا تخزني. في طريق وصاياك سعيتُ عندما وسعت قلبي.\n\n(القطعة 5) ضع لي يا رب ناموساً في طريق حقوقك فأتتبعها في كل حين. فهمني فأبحث عن ناموسك وأحفظه بكل قلبي. اهدني في سبيل وصاياك فإني إياها هويت. أمل قلبي إلى شهاداتك لا إلى الطمع. اردد عيني لكي لا تنظرا الباطل، وفي طريقك أحيني. ثبت قولك لعبدك في خوفك. انزع عني العار الذي حذرت منه، فإن أحكامك حلوة. هاأنذا قد اشتهيت وصاياك، فأحيني ببرك .\n\n(القطعة 6) ولتأتِ عليّ رحمتك يا رب وخلاصك كقولك، فأجيب حاملي عاري بكلمة لأني توكلت على أقوالك. ولا تنزع من فمي قول الحق إلى الغاية لأني بأحكامك توكلت. وأحفظ ناموسك في كل حين، إلى الأبد وإلى دهر الدهور. وكنت أسلك في الاتساع لأني لوصاياك ابتغيت. وتكلمت بشهاداتك قدام الملوك ولم أخزَ. ولهجت بوصاياك التي أحببتها جداً. ورفعت يدي إلى وصاياك التي وددتها، ولهجت في فرائضك.\n\n(القطعة 7) اذكر لعبدك كلامك الذي جعلتني عليه أتكل. هذا الذي عزاني في ذلي، لأن قولك أحياي. المستكبرون نامسوا عليّ جداً، أما أنا فعن ناموسك لم أمل. تذكرت أحكامك يا رب منذ الأزل فتعزيت. الكآبة أخذتني من أجل الخطاة الذين تركوا ناموسك. حقوقك كانت لي مزامير في موضع غربتي. تذكرت في الليل اسمك يا رب وحفظت ناموسك. هذا صار لي لأني لِحسني ابتغيت.\n\n(القطعة 8) نصيبي أنت يا رب، قلتُ أن أحفظ وصاياك. تضرعتُ إلى وجهك بكل قلبي، ارحمني كقولك. :تفكرت في طرقك، ورددت رجلي إلى شهاداتك. تهيأت ولم أتوانَ  لحفظ وصاياك. حبال الخطاة التفت عليّ، أما ناموسك فلم أنسَه. في نصف الليل كنت أقوم لأعترف لك على أحكام عدلك. شريك أنا لكل خائفيك والحافظين وصاياك. من رحمتك يا رب امتلأت الأرض، فعلمني عدلك.'
  },
  // ====================================================================
// صلاة نصف الليل - المزمور الكبير ١١٨ - الجزء الثاني (القطع ٩-١٥)
// ====================================================================
  {
    'title': '١٣. مزمور 118 (القطع من 9 إلى 15) ',
    'text':
        '(القطعة 9) خيراً صنعت مع عبدك يا رب كقولك. صلاحاً وأدباً ومعرفة علمني، لأني بوصاياك آمنت. قبل أن أُذَل أنا جهلت، فمن أجل هذا حفظت قولك. صالح أنت يا رب، فبصلاحك علمني حقوقك. كثر عليّ ظلم المتكبرين، وأنا بكل قلبي أفحص عن وصاياك. تجبن مثل اللبن قلبهم، وأنا لناموسك وددت. خير لي أنك أذللتني لكيما أتعلم حقوقك. خير لي ناموس فمك أكثر من ألوف ذهب وفضة.\n\n(القطعة 10) يداك صنعتاني وجبلتاني، فهمني فأتعلم وصاياك. خائفورك يرونني فيفرحون، لأني بأقوالك توكلت. قد علمت يا رب أن أحكامك عادلة، وبالحق أذللتني. فلتكن رحمتك لتعزيتي كقولك لعبدك. لتأتني رأفتك فأحيا، لأن ناموسك هو درسي. فليخز المتكبرون لأنهم جاروا عليّ بلا سبب، وأنا ألهج في وصاياك. ليرجع إليّ خائفوك والذين يعرفون شهاداتك. ليكن قلبي بلا عيب في حقوقك لكي لا أخزى.\n\n(القطعة 11) تقت نفسي إلى خلاصك، وبأقوالك توكلت. كلت عيناي من انتظار قولك قائلتين: متى تعزيني؟ لأني صرت كزق في جليد، وحقوقك لم أنسَها. كم هي أيام عبدك؟ متى تصنع لي حكماً من الذين يضطهدونني؟ نقل لي مخالفو الناموس أساطير، ولكن ليس كناموسك يا رب. كل وصاياك حق، وبلا سبب اضطهدوني فأعني. قريباً أفنوني من الأرض، وأنا لم أترك وصاياك. كرحمتك أحيني، فأحفظ شهادات فمك.\n\n(القطعة 12) إلى الأبد يا رب كلمتك ثابتة في السماء، وإلى جيل فجيل حقك. أسست الأرض فهي ثابتة بجهتك. بأمرك يستمر النهار لأن كل الأشياء متعبدة لك. لولا أن ناموسك هو درسي، لكنت قد هلكت في ذلي. إلى الأبد لا أنسى وصاياك، لأنك بها أحييتني. لك أنا فخلصني، لأني لحقوقك ابتغيت. إياي انتظر الخطاة ليهلكوني، ولقد فهمت شهاداتك. لكل تمام رأيت نهاية، أما وصيتك فواسعة جداً.\n\n(القطعة 13) محبوب هو ناموسك يا رب، النهار كله هو درسي. أكثر من أعدائي فهمتني وصيتك لأنها ثابتة معي إلى الأبد. أكثر من الذين يعلمونني فهمت لأن شهاداتك هي درسي. أكثر من الشيوخ فهمت لأنني لوصاياك ابتغيت. من كل طريق رديء منعت رجلي لكي أحفظ أقوالك. عن أحكامك لم أمل لأنك وضعت لي ناموساً. ما أحلى أقوالك في حلقي، أفضل من العسل والشهد في فمي! من وصاياك تفطنت، فمن أجل هذا أبغضت كل طريق ظلم لأن ناموسك نور لخطواتي.\n\n(القطعة 14) سراج لرجلي كلامك ونور لسبيلي. حلفت وأقمت أن أحفظ أحكام عدلك. أذللت جداً يا رب، فأحيني كقولك. أذواق فمي باركها يا رب، وأحكامك علمني. نفسي في يديك كل حين، وناموسك لم أنسَه. وضع الخطاة لي فخاً، ولم أضل عن وصاياك. ورثت شهاداتك إلى الأبد لأنها بهجة قلبي. عطفت قلبي لأصنع حقوقك إلى الأبد من أجل المكافأة.\n\n(القطعة 15) لمخالفي الناموس أبغضت، وناموسك أحببت. معيني وناصري أنت، وبأقوالك توكلت. ابعدوا عني أيها الأشرار، فأفحص عن وصايا إلهي. عضدني كقولك فأحيا، ولا تخيب رجائي. أعني فأخلص، وأدرس في حقوقك كل حين. رذلت سائر الحائدين عن حقوقك لأن فكرهم ظلم. عصاة حسبت سائر خطاة الأرض، فمن أجل هذا أحببت شهاداتك في كل حين. سمر خوفك في لحمي، لأني من أحكامك جزعت.'
  },
// ====================================================================
// صلاة نصف الليل - المزمور الكبير ١١٨ - الجزء الثالث (القطع ١٦-٢٢)
// ====================================================================
  {
    'title': '١٤. مزمور 118 (القطع من 16 إلى 22) ',
    'text':
        '(القطعة 16) صنعت قضاء وعدلاً، فلا تسلمني إلى الذين يظلمونني. كن كفيلاً لعبدك في الخير لكيلا يجور عليّ المتكبرون. كلت عيناي من انتظار خلاصك وقول عدلك. اصنع مع عبدك كرحمتك، وحقوقك علمني. عبدك أنا فهمني، فأعرف شهاداتك. وقت عمل للرب، فقد نقضوا ناموسك. لأجل هذا أحببت وصاياك أفضل من الذهب والجوهر. لأجل هذا إزاء كل وصاياك تقومت، وكل طريق ظلم أبغضت.\n\n(القطعة 17) عجيبة هي شهاداتك، من أجل هذا فحصت عنها نفسي. إعلان أقوالك ينير الصغار ويفهمهم. فتحت فمي واجتذبت لي روحاً، لأني لوصاياك اشتقت. انظر إليّ وارحمني، كحكم محبي اسمك. خطواتي سددها كقولك، فلا يتسلط عليّ أي إثم. أنقذني من ظلم الناس، فأحفظ وصاياك. أضئ بوجهك على عبدك، وعلمني حقوقك. غدران مياه جرت من عينيّ، لأنهم لم يحفظوا ناموسك.\n\n(القطعة 18) عادل أنت يا رب، وأحكامك مستقيمة. أوصيت كثيراً بالعدل والملء في شهاداتك. أهلكني حسد بيتك لأن أعدائي نسوا كلامك. قولك محصّ جداً، وعبدك أحبه. صغير أنا ومحتقر، وحقوقك لم أنسَها. عدلك عدل أبدي إلى الأبد، وناموسك حق. ضيقات وشدائد أصابتني، ووصاياك هي درسي. عادلة هي شهاداتك إلى الأبد، فهمني فأحيا.\n\n(القطعة 19) صرخت من كل قلبي فاستجب لي يا رب، حقوقك أفحص عنها. صرخت إليك فخلصني، لأحفظ شهاداتك. سبقت في غير أوانها وصرخت، وبكلامك توكلت. سبقت عيناي وقت السحر لأتلو في جميع أقوالك. اسمع صوتي يا رب كرحمتك، وبأحكامك أحيني. اقترب الذين يطردونني بالإثم، وعن ناموسك ابتعدوا. قريب أنت يا رب، وكل طرقك حق. منذ البدء عرفتُ من شهاداتك أنك إلى الأبد أسستها.\n\n(القطعة 20) انظر إلى ذلي وأنقذني، فإني لم أنسَ ناموسك. ارفع دعواي ونجني، من أجل كلامك أحيني. بعيد هو خلاص الخطاة لأنهم لم يفحصوا عن حقوقك. رأفاتك كثيرة يا رب، كأحكامك أحيني. كثيرون هم الذين يضطهدونني ويحزنونني، وعن شهاداتك لم أمل. رأيت الذين لا يفهمون فاكتأبت، لأنهم لأقوالك لم يحفظوا. انظر يا رب فإني لوصاياك أحببت، بكثرة رحمتك أحيني. بدء أقوالك حق، وإلى الأبد كل أحكام عدلك.\n\n(القطعة 21) ملوك اضطهدوني بلا سبب، ومن أقوالك جزع قلبي. أبتهج أنا بأقوالك كمن وجد غنائم كثيرة. أبغضت الظلم ورذلته، أما ناموسك فأحببته. سبع مرات في اليوم سبحتك على أحكام عدلك. فليكن سلام عظيم للذين يحبون ناموسك، وليس لهم عثرة. انتظرت خلاصك يا رب، ووصاياك أحببتها. حفظت نفسي شهاداتك، وأحبتها جداً. حفظت وصاياك وشهاداتك، وكل طرقي أمامك يا رب.\n\n(القطعة 22) لتدنُ طلبتي قدامك يا رب، كقولك فهمني. لتدخل طلبتي إلى إمامتك، ككلمتك أحيني. لتسبّحْ شفتاي إذا ما علمتني حقوقك. ينطق لساني بأقوالك، لأن جميع وصاياك عادلة. لتكن يدك لتخليصي، لأني لوصاياك اخترت. اشتقت إلى خلاصك يا رب، وناموسك هو درسي. تحيا نفسي وتسبحك، وأحكامك تعينني. ضللت مثل الخروف الضال، فاطلب عبدك فإني لوصاياك لم أنسَ.'
  },
  // ====================================================================
// صلاة نصف الليل - إنجيل الخدمة الأولى (متى ٢٥: ١-١٣) كاملاً لوحده
// ====================================================================
  {
    'title': '١٥. إنجيل الخدمة الأولى (متى 25: 1-13)',
    'text':
        'من إنجيل معلمنا متى البشير، بركاته علينا جميعاً، آمين:\n\nحينئذ يشبه ملكوت السموات عشر عذارى أخذن مصابيحهن وخرجن للقاء العريس. وكان خمس منهن جاهلات وخمس حكيمات. فأخذت الجاهلات مصابيحهن ولم يأخذن معهن زيتاً، وأما الحكيمات فأخذن زيتاً في أوعيتهن مع مصابيحهن. ولما أبطأ العريس نعسن جميعاً ونمن.\n\nوفي نصف الليل صار صراخ: هوذا العريس قد أقبل، فاخرجن للقائه! حينئذ قامت تلك العذارى جميعاً وأصلحن مصابيحهن. فقالت الجاهلات للحكيمات: أعطيننا من زيتكن فإن مصابيحنا تنطفئ. فأجابت الحكيمات قائلات: لعل لا يكفي لنا ولكن، فاذهبن بالأحرى إلى الباعة وابتعن لكن.\n\nولما ذهبن ليبتعن جاء العريس، والمستعدات دخلن معه إلى العرس وأُغلق الباب. وأخيراً جاءت بقية العذارى قائلات: يا رب يا رب افتح لنا. فأجاب وقال: الحق أقول لكن إني لا أعرفكن. فاسهروا إذاً لأنكم لا تعرفون اليوم ولا الساعة التي يأتي فيها ابن الإنسان. (والمجد لله دائماً).'
  },
// ====================================================================
// صلاة نصف الليل - قطع الخدمة الأولى الطقسية الموسوعية كاملة باليوناني المفرود
// ====================================================================
  {
    'title': '١٦. قطع الخدمة الأولى الطقسية ',
    'text':
        'القطع الطقسية للخدمة الأولى   :\n\nها هو ذا العريس يأتي في نصف الليل، طوبى للعبد الذي يجده مستيقظا. أما الذي يجده متغافلا، فإنه غير مستحق المضي معه. فانظري يا نفسي لئلا تثقلي نوما، فتلقي خارج الملكوت. بل اسهري واصرخي قائلة: قدوس قدوس قدوس أنت يا الله، من أجل والدة الإله ارحمنا.\n(ذوكصابتري كيه إيو كي آجيو ابنيفماتي Doxa Patri ke Uiw ke `agiw `Pneumati - المجد للآب والابن والروح القدس).\n\nتفهمي يا نفسي ذلك اليومَ الرهيب واستيقظي، وأضيئي مصباحك بزيت البهجة. لأنك لا تعلمين متى يأتي نحوك الصوت القائل: ها هو ذا العريس قد أقبل. فانظري يا نفسي لا تنعسي، لئلا تقفي خارجا قارعة مثل الخمس العذارى الجاهلات، بل اسهري متضرعة لكي تلتقي المسيح الرب بدهن دسم، وينعم عليك بعرس مجده الإلهي الحقيقي.\n(كي نين، كي آ إي، كي ايستوس إي أوناس تون إي أونون آمين Ke nun ke `a`i ke ic touc `e`wnac twn `e`wnwn `amyn - الآن وكل أوان وإلى دهر الداهرين آمين).\n\nأنت هي سور خلاصنا يا والدة الإله العذراء الحصن المنيع غير المنثلم أبطلي مشورة المعاندين، وحزن عبيدك رديه إلى فرح وحصني مدينتنا (ديرنا) وعن ملوكنا (رؤسائنا) حاربي، وتشفعي عن سلام العالم، لأنك أنت هي رجاؤنا يا والدة الإله.\n(كي نين، كي آ إي، كي ايستوس إي أوناس تون إي أونون آمين Ke nun ke `a`i ke ic touc `e`wnac twn `e`wnwn `amyn - الآن وكل أوان وإلى دهر الداهرين آمين).\n\nأيها الملك السمائي المعزى، روح الحق، الحاضر في كل مكان والمالئ الكل، كنز الصالحات، ومعطى الحياة، هلم تفضل وحل فينا، وطهرنا من كل دنس أيها الصالح، وخلص نفوسنا.\n(ذوكصابتري كيه إيو كي آجيو ابنيفماتي Doxa Patri ke Uiw ke `agiw `Pneumati - المجد للآب والابن والروح القدس).\n\nكما كنت مع تلاميذك أيها المخلص وأعطيتهم السلام، هلم أيضا كن معنا وامنحنا سلامك وخلصنا ونج نفوسنا.\n(كي نين، كي آ إي، كي ايستوس إي أوناس تون إي أونون آمين Ke nun ke `a`i ke ic touc `e`wnac twn `e`wnwn `amyn - الآن وكل أوان وإلى دهر الداهرين آمين).\n\nإذا ما وقفنا في هيكلك المقدس نحسب كالقيام في السماء. يا والدة الإله، أنت هي باب السماء، افتحي لنا باب الرحمة.\n\nكيرياليصون (يا رب ارحم) Kuri`e `ele`hcon نرددها بخشوع تام ويقظة كاملة ٤١ مرة.'
  },
  // ====================================================================
// صلاة نصف الليل - تسبحة قدوس قدوس قدوس الختامية كاملة لوحدها
// ====================================================================
  {
    'title': '١٧. تسبحة قدوس قدوس قدوس والطلبة الختامية',
    'text':
        'قدوس، قدوس، قدوس، رب الصباؤوت. السماء والأرض مملوءتان من مجدك وكرامتك. ارحمنا يا الله الآب ضابط الكل. أيها الثالوث القدوس ارحمنا. أيها الرب إله القوات كن معنا، لأنه ليس لنا معين في شدائدنا وضيقاتنا سواك.\n\nحل واغفر واصفح لنا يا الله عن سيئاتنا، التي صنعناها بإرادتنا والتي صنعناها بغير إرادتنا، التي فعلناها بمعرفة والتي فعلناها بغير معرفة، الخفية والظاهرة. يا رب اغفرها لنا، من أجل اسمك القدوس الذي دعي علينا. كرحمتك يا رب وليس كخطايانا.\n\n....واجعلنا مستحقين أن نقول بشكر: أبانا الذي في السموات...'
  },
  // ====================================================================
// صلاة نصف الليل - الخدمة الثانية: بدء الصلاة
// ====================================================================
  {
    'title': '١٩. الخدمة الثانية: بدء الصلاة',
    'text':
        'بدء صلاة الخدمة الثانية:\n\nتسبحة الخدمة الثانية من نصف الليل المبارك، أقدمها للمسيح ملكي والهي، وأرجوه أن يغفر لي خطاياي.\n\nتتلى مزامير صلاة الغروب ما عدا المزموران الأولان رقميّ 116 و117 كما يلي:'
  },

  // ====================================================================
// صلاة نصف الليل - الخدمة الثانية: المزمور ١١٩ كاملاً
// ====================================================================
  {
    'title': '٢٠. الخدمة الثانية: (المزمور 119) ',
    'text':
        'المزمور المائة والتاسع عشر:\n\nإليك يا رب صرخت في حزني فاستجبت لي. يا رب نج نفسي من الشفاه الظالمة ومن اللسان الغاش. ماذا تعطى وماذا تزاد من اللسان الغاش. سهام الأقوياء مرهفة مع جمر البرية. ويل لي فإن غربتي قد طالت عليّ، وسكنت في مساكن قيدار. طويلا سكنتْ نفسي في الغربة، ومع مبغضي السلام كنت صاحب سلام، وحين كنت أكلمهم كانوا يقاتلونني باطلا هلليلويا.'
  },

  // ====================================================================
// صلاة نصف الليل - الخدمة الثانية: المزمور ١٢٠ كاملاً لوحده
// ====================================================================
  {
    'title': '٢١. الخدمة الثانية: (المزمور 120) ',
    'text':
        'المزمور المائة والعشرون:\n\nرفعت عيني إلى الجبال، من حيث يأتي عوني. معونتي من عند الرب الذي صنع السماء والأرض. لا يسلم رجلك للزلل، فما ينعس حافظك. هوذا لا ينعس ولا ينام حارس إسرائيل. الرب يحفظك. الرب يظلل على يدك اليمنى، فلا تحرقك الشمس بالنهار ولا القمر بالليل. الرب يحفظك من كل سوء. الرب يحفظ نفسك. الرب يحفظ دخولك وخروجك، من الآن والي الأبد هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثانية: المزمور ١٢١ كاملاً لوحده
// ====================================================================
  {
    'title': '٢٢. الخدمة الثانية: (المزمور 121) ',
    'text':
        'المزمور المائة والحادي والعشرون:\n\nفرحت بالقائلين لي إلى بيت الرب نذهب. وقفت أرجلنا في ديار أورشليم، أورشليم المبنية مثل مدينة متصلة بعضها ببعض. لأن هناك صعدت القبائل، قبائل الرب، شهادة لإسرائيل، يعترفون لاسم الرب. هناك نصبت كراسي للقضاء كراسي بيت داود.\n\nاسألوا السلام لأورشليم والخصبَ لمحبيك. ليكن السلام في حصنك والخصب في أبراجك الرصينة. من أجل اخوتي وأقربائي تكلمت من أجلك بالسلام، ومن أجل بيت الرب إلهنا التمست لك الخيرات هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثانية: المزمور ١٢٢ كاملاً لوحده
// ====================================================================
  {
    'title': '٢٣. الخدمة الثانية: (المزمور 122) ',
    'text':
        'المزمور المائة والثاني والعشرون:\n\nإليك رفعت عينيّ يا ساكن السماء. فها هما مثل عيون العبيد إلى أيدي مواليهم، ومثل عيني الأمة إلى يدي سيدتها. كذلك أعيننا نحو الرب إلهنا حتى يتراءف علينا. ارحمنا يا رب ارحمنا، فإننا كثيرا ما امتلأنا هوانا، وكثيرا ما امتلأت نفوسنا العار اردده على المخصبين والهوان على المتعظمين هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثانية: المزمور ١٢٣ كاملاً لوحده
// ====================================================================
  {
    'title': '٢٤. الخدمة الثانية: (المزمور 123) ',
    'text':
        'المزمور المائة والثالث والعشرون:\n\nلولا أن الربَّ كان معنا ـ ليقل إسرائيل ـ لولا أن الرب كان معنا عندما قام الناس علينا، لابتلعونا ونحن أحياء، عند سخط غضبهم علينا. إذا لغرقنا في الماء وعبرت نفوسنا السيل، بل جازت نفوسنا الماء الذي لا نهاية له. مبارك الرب الذي لم يسلمنا فريسة لأسنانهم. نجت أنفسنا مثل العصفور من فخ الصيادين، الفخ انكسر ونحن نجونا، عوننا باسم الرب الذي صنع السماء والأرض هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثانية: المزمور ١٢٤ كاملاً لوحده
// ====================================================================
  {
    'title': '٢٥. الخدمة الثانية: (المزمور 124) ',
    'text':
        'المزمور المائة والرابع والعشرون:\n\nالمتوكلون على الرب مثل جبل صهيون لا يتزعزع إلى الأبد، الساكن in أورشليم. الجبال حولها، والرب حول شعبه من الآن والى الأبد. الرب لا يترك عصا الخطاة تستقر على نصيب الصديقين، لكي لا يمد الصديقون أيديهم إلى الإثم.\n\nأحسن يا رب إلى الصالحين والى المستقيمي القلوب. أما الذين يميلون إلى العثرات فينزعهم الرب مع فعلة الإثم. والسلام على إسرائيل هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثانية: المزمور ١٢٥ كاملاً لوحده
// ====================================================================
  {
    'title': '٢٦. الخدمة الثانية: (المزمور 125) ',
    'text':
        'المزمور المائة والخامس والعشرون:\n\nإذا ما رد الرب سبي صهيون صرنا فرحين. حينئذ امتلأ فمنا فرحا ولساننا تهليلا. حينئذ يقال في الأمم إن الرب قد عظم الصنيع معهم. عظم الرب الصنيع معنا فصرنا فرحين. اردد يا رب سبينا مثل السيول في الجنوب. الذين يزرعون بالدموع يحصدون بالابتهاج. سيرا كانوا يسيرون وهم باكون حاملين بذارهم، ويعودون بالفرح حاملين أغمارهم هلليلويا.'
  },
  // ====================================================================
// صلاة نصف الليل - الخدمة الثانية: المزمور ١٢٦ كاملاً لوحده
// ====================================================================
  {
    'title': '٢٧. الخدمة الثانية: (المزمور 126) ',
    'text':
        'المزمور المائة والسادس والعشرون:\n\nإن لم يبن الرب البيتَ فباطلا تعب البناءون، وإن لم يحرس الرب المدينة فباطلا سهر الحراس. باطل هو لكم التبكير. انهضوا من بعد جلوسكم يا آكلي الخبز بالهموم، فإنه يمنح أحباءه نوما.\n\nالبنون ميراث من الرب أجرة ثمرة البطن. كالسهام بيد القوي كذلك أبناء المتيقظين. مغبوط هو الرجل الذي يملا جعبته منهم. حينئذ لا يخزون إذا كلموا أعداءهم في الأبواب هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثانية: المزمور ١٢٧ كاملاً لوحده
// ====================================================================
  {
    'title': '٢٨. الخدمة الثانية: (المزمور 127) ',
    'text':
        'المزمور المائة والسابع والعشرون:\n\nطوبى لجميع الذين يتقون الرب السالكين في طرقه. تأكل من ثمرة أتعابك تصير مغبوطا ويكون لك الخير. امرأتك تصير مثلَ كرمة مخصبة في جوانب بيتك. بنوك مثل غروس الزيتون الجدد حول مائدتك. هكذا يُبارَك الإنسان المتقي الربَّ. يباركك الرب من صهيون، وتبصر خيرات أورشليم جميع أيام حياتك، وترى بني بنيك، والسلام على إسرائيل. هللويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثانية: المزمور ١٢٨ كاملاً لوحده
// ====================================================================
  {
    'title': '٢٩. الخدمة الثانية: (المزمور 128) ',
    'text':
        'المزمور المائة والثامن والعشرون:\n\nمرارا كثيرة حاربوني منذ صباي ـ ليقل إسرائيل ـ مرارا كثيرة قاتلوني منذ شبابي، وإنهم لم يقدروا علي. على ظهري جلدني الخطاة وأطالوا إثمهم. الرب صدّيق هو، يقطع أعناق الخطاة. فليخز وليرتد إلى الوراء كل الذين يبغضون صهيون، وليكونوا مثل عشب السطوح الذي ييبَس قبل أن يقطع، الذي لم يملأ الحاصد منه يده، ولا الذي يجمع الغمورَ حضنه. ولم يقلْ المجتازون إن بركة الرب عليكم. باركناكم باسم الرب هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثانية: إنجيل لوقا ٧ كاملاً لوحده
// ====================================================================
  {
    'title': '٣٠. إنجيل الخدمة الثانية (لوقا 7: 36-50)',
    'text':
        'من إنجيل معلمنا لوقا البشير، بركاته علينا جميعاً، آمين:\n\nثم سأله أحد الفريسيين أن يأكل معه. فلما دخل بيت الفريسي اتكأ. وإذا امرأة في المدينة كانت خاطئة. فلما علمتْ أنه متكئ في بيت الفريسي، أخذت قارورة طيب ووقفتْ من ورائه عند رجليه باكية، وبدأت تبل قدميه بدموعها وتمسحهما بشعر رأسها، وكانت تقبل قدميه وتدهنهما بالطيب. فلما رأى الفريسي الذي دعاه ذلك قال محدثا نفسه: لو كان هذا نبيا لعلم من هي هذه المرأة التي لمسته، وما حالها، إنها خاطئة.\n\nفأجاب يسوع وقال له: يا سمعان عندي كلمة أقولها لك. فقال: قل يا معلم. قال: كان لدائن مدينان على الواحد خمسمائة دينار وعلى الآخر خمسون، وإذ لم يكن لهما ما يوفيان سامحهما كليهما. فمن منهما يحبه أكثر؟ أجاب سمعان وقال: أظنُّ الذي سامحه بالأكثر. فقال له: بالصواب حكمتَ.\n\nثم التفت إلى المرأة وقال لسمعان: أترى هذه المرأة؟ دخلتُ بيتك وماء لرجلي لم تعطِ، أما هي فقد غسلتْ بالدموع رجلي ومسحتهما بشعرها. لم تقبل فمي، أما هي فمنذ دخلتُ بيتك لم تكف عن تقبيل قدمي. بزيت لم تدهن رأسي، أما هي فقد دهنت بالطيب قدمي. من أجل ذلك أقول لك إن خطاياها الكثيرة مغفورة لها، لأنها أحبت كثيرا. والذي يغفر له قليل يحب قليلا. ثم قال لها: مغفورة لك خطاياك. فبدأ المتكئون يقولون في نفوسهم: من هو هذا الآخر الذي يغفر الخطايا؟! فقال للمرأة: إن إيمانك قد خلصكِ، فاذهبي بسلام (والمجد لله دائما.)'
  },
// ====================================================================
// صلاة نصف الليل - قطع الخدمة الثانية كاملة ومطولة لوحدها مع كيرياليسون
// ====================================================================
  {
    'title': '٣١. قطع الخدمة الثانية الطقسية ',
    'text':
        'القطع الطقسية للخدمة الثانية   :\n\nأعطني يا رب ينابيع دموع كثيرة، كما أعطيت منذ القديم للمرأة الخاطئة. واجعلني مستحقا أن أبل قدميك اللتين أعتقتاني من طريق الضلالة. وأقدم لك طيبا فائقا، وأقتني لي عمرا نقيا بالتوبة. لكي أسمع أنا ذلك الصوت الممتلئ فرحًا: إن إيمانك خلصك.\n(ذوكصابتري كيه إيو كي آجيو ابنيفماتي Doxa Patri ke Uiw ke `agiw `Pneumati - المجد للآب والابن والروح القدس).\n\nإذا ما تفطنت في كثرة أعمالي الرديئة ويأتي على قلبي فكر تلك الدينونة الرهيبة تأخذني رعدة، فأهرب إليك يا الله محب البشر. فلا تصرف وجهك عني، متضرعا إليك يا من أنت وحدك بلا خطية، أنعم على نفسي المسكينة بتخشع قبل أن يأتي الانقضاء وخلصني.\n(كي نين، كي آ إي، كي ايستوس إي أوناس تون إي أونون آمين Ke nun ke `a`i ke ic touc `e`wnac twn `e`wnwn `amyn - الآن وكل أوان وإلى دهر الداهرين آمين).\n\nالسموات تطوبك أيتها الممتلئة نعمة، العروس التي بلا زواج. ونحن أيضا نمجد ميلادك غير المدرك. يا والدة الإله يا أم الرحمة والخلاص، تشفعي من أجل خلاص نفوسنا.\n(كي نين، كي آ إي, كي ايستوس إي أوناس تون إي أونون آمين Ke nun ke `a`i ke ic touc `e`wnac twn `e`wnwn `amyn - الآن وكل أوان وإلى دهر الداهرين آمين).\n\nأيها الملك السمائي المعزى، روح الحق، الحاضر في كل مكان والمالئ الكل، كنز الصالحات، ومعطى الحياة، هلم تفضل وحل فينا، وطهرنا من كل دنس أيها الصالح، وخلص نفوسنا.\n(ذوكصابتري كيه إيو كي آجيو ابنيفماتي Doxa Patri ke Uiw ke `agiw `Pneumati - المجد للآب والابن والروح القدس).\n\nكما كنت مع تلاميذك أيها المخلص وأعطيتهم السلام، هلم أيضا كن معنا وامنحنا سلامك وخلصنا ونج نفوسنا.\n(كي نين، كي آ إي، كي ايستوس إي أوناس تون إي أونون آمين Ke nun ke `a`i ke ic touc `e`wnac twn `e`wnwn `amyn - الآن وكل أوان وإلى دهر الداهرين آمين).\n\nإذا ما وقفنا في هيكلك المقدس نحسب كالقيام في السماء. يا والدة الإله، أنت هي باب السماء، افتحي لنا باب الرحمة.\n\nكيرياليصون (يا رب ارحم) Kuri`e `ele`hcon نرددها بخشوع تام ويقظة كاملة ٤١ مرة.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثانية: الثلاث تقديسات الكبرى والمطولة لوحدها
// ====================================================================
  {
    'title': '٣٢. الخدمة الثانية: الثلاث تقديسات الكبرى والطلبة',
    'text':
        'الثلاث تقديسات الطقسية الكبرى:\n\nقدوس الله، قدوس القوى، قدوس الحي الذي لا يموت، الذي ولد من العذراء، ارحمنا. قدوس الله، قدوس القوى، قدوس الحي الذي لا يموت، الذي صلب عنا، ارحمنا. قدوس الله، قدوس القوى، قدوس الحي الذي لا يموت، الذي قام من الأموات وصعد إلى السموات، ارحمنا. المجد للآب والابن والروح القدس، الآن وكل أوان وإلى دهر الدهور. أمين. أيها الثالوث القدوس ارحمنا. أيها الثالوث القدوس ارحمنا. أيها الثالوث القدوس ارحمنا.\n\nيا رب اغفر لنا خطايانا. يا رب اغفر لنا آثامنا. يا رب اغفر لنا زلاتنا. يا رب افتقد مرضى شعبك، اشفهم من أجل اسمك القدوس. آباؤنا وإخوتنا الذين رقدوا، يا رب نيح نفوسهم. يا من هو بلا خطية، يا رب ارحمنا. يا من بلا خطية، يا رب أعنا، واقبل طلباتنا إليك. لأن لك المجد والعزة والتقديس المثلث. يا رب ارحم. يا رب ارحم يا رب بارك. أمين.\n\nواجعلنا مستحقين أن نقول بشكر: أبانا الذي في السموات...'
  },
  // ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: بدء الصلاة
// ====================================================================
  {
    'title': '٣٣. الخدمة الثالثة: بدء الصلاة',
    'text':
        'بدء صلاة الخدمة الثالثة:\n\nتسبحة الخدمة الثالثة من نصف الليل المبارك، أقدمها للمسيح ملكي والهي، وأرجوه أن يغفر لي خطاياي.\n\nتتلى مزامير صلاة النوم كما يلي:'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٢٩ كاملاً لوحده
// ====================================================================
  {
    'title': '٣٤. الخدمة الثالثة: (المزمور 129) ',
    'text':
        'المزمور المائة والتاسع والعشرون:\n\nمن الأعماق صرخت إليك يا رب، يا رب استمع صوتي. لتكن أذناك مصغيتين إلى صوت تضرعي. إن كنت للآثام راصدا يا رب، يا رب من يثبت لأن من عندك المغفرة. من أجل اسمك صبرْتُ لك يا رب، صبرَتْ نفسي لناموسك. انتظرت نفسي الرب من محرس الصبح إلى الليل. من محرس الصبح فلينتظر إسرائيل الرب. لأن الرحمة من عند الرب. عظيم هو خلاصه وهو يفتدي إشانته إسرائيل من كل آثامه هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٣٠ كاملاً لوحده
// ====================================================================
  {
    'title': '٣٥. الخدمة الثالثة: (المزمور 130) ',
    'text':
        'المزمور المائة والثلاثون:\n\nيا رب لم يرتفع قلبي، ولم تستعلِ عيناي، ولم أسلك في العظائم ولا في العجائب التي هي أعلى مني. فان كنت لم أتضع لكن رفعت صوتي مثل الفطيم من اللبن على أمه، كذلك المجازاة على نفسي. فليتكل إسرائيل على الرب من الآن والى الأبد هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٣١ كاملاً لوحده
// ====================================================================
  {
    'title': '٣٦. الخدمة الثالثة: (المزمور 131) ',
    'text':
        'المزمور المائة والحادي والثلاثون:\n\nاذكر يا رب داود وكل دعته، كيف أقسم للرب ونذر لإله يعقوب: إني لا أدخل إلى مسكن بيتي، ولا أصعد على سرير فراشي، ولا أعطى لعيني نوما، ولا لأجفاني نعاسا، ولا راحة لصدغيَّ، إلى أن أجد موضعا للرب ومسكنا لإله يعقوبَ. ها قد سمعنا به في افراته ووجدناه في موضع الغابة. فلندخل إلى مساكنه ونسجد في الموضع الذي فيه استقرت قدماه.\n\nقم يا رب إلى راحتك أنت وتابوت موضع قدسك. كهنتك يلبسون البر وأبرارك يبتهجون. من أجل داود عبدك لا ترد وجهك عن مسيحك. حلف الرب لداود حقا ولا يخلف: لأجعَلنَّ من ثمرة بطنك على كرسيك. إن حفظ بنوك عهدي وشهاداتي التي أعلمهم إياها، فبنوهم أيضا يجلسون إلى الأبد على كرسيك. لأن الرب اختار صهيون ورضيها مسكننا له. هذا هو موضع راحتي إلى أبد الأبد، ههنا أسكن لأني أردته. لصيدها أبارك بركة، لمساكينها أشبع خبزا، لكهنتها ألبس الخلاص وأبرارها يبتهجون ابتهاجا. هناك أقيم قرنا لداود. هيأتُ سراجا لمسيحي. لأعدائه ألبس الخزي وعليه يزهر قدسي هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٣٢ كاملاً لوحده
// ====================================================================
  {
    'title': '٣٧. الخدمة الثالثة: (المزمور 132) ',
    'text':
        'المزمور المائة والثاني والثلاثون:\n\nهوذا ما أحسن وما أحلي أن يسكن الاخوة معا. كالطيب الكائن على الرأس الذي ينزل على اللحية، لحية هارون النازلة على جيب قميصه. ومثل ندى حرمون المنحدر على جبل صهيون. لأن هناك أمر الرب بالبركة والحياة إلى الأبد هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٣٣ كاملاً لوحده
// ====================================================================
  {
    'title': '٣٨. الخدمة الثالثة: (المزمور 133) ',
    'text':
        'المزمور المائة والثالث والثلاثون:\n\nها باركوا الربَّ يا عبيدَ الرب، القائمين في بيت الرب في ديار إلهنا. في الليالي ارفعوا أيديكم إلى القدس وباركوا الرب. يبارككم الرب من صهيون الذي خلق السماء والأرض هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٣٦ كاملاً لوحده
// ====================================================================
  {
    'title': '٣٩. الخدمة الثالثة: (المزمور 136) ',
    'text':
        'المزمور المائة والسادس والثلاثون:\n\nعلى أنهار بابل هناك جلسنا، فبكينا عندما تذكرنا صهيون. على الصفصاف في وسطها علقنا قيثاراتنا، لأنه هناك سألنا الذين سبونا أقوالَ التسبيح. والذين استاقونا إلى هناك قالوا: سبحوا لنا تسبحة من تسابيح صهيون.\n\nكيف نسبِّح تسبحة الرب في أرض غريبة. إن نسيتك يا أورشليم أنسَ يميني، ويلتصق لساني بحنكي إن لم أذكرك، إن لم أفضل أورشليم في ابتداء فرحي.\n\nاذكر يا رب بني أدوم في يوم أورشليم القائلين: انقضوا انقضوا حتى الأساس منها. يا بنت بابل الشقية طوبى لمن يكافئك مكافأتك التي جازيتينا. طوبى لمن يمسك أطفالك ويدفنهم عند الصخرة هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٣٧ كاملاً لوحده
// ====================================================================
  {
    'title': '٤٠. الخدمة الثالثة: (المزمور 137) ',
    'text':
        'المزمور المائة والسابع والثلاثون:\n\nأعترف لك يا رب من كل قلبي لأنك استمعت كل كلمات فمي. أمام الملائكة أرتل لك وأسجد قدام هيكلك المقدس، وأعترف لاسمك على رحمتك وحقك، لأنك قد عظمت اسمك القدوس على الكل. اليوم الذي أدعوك فيه أجبني بسرعة. تكثر التطلع على نفسي بقوة.\n\nفليعترف لك يا رب كل ملوك الأرض. لأنهم قد سمعوا سائر كلمات فمك وليسبحوا في طرق الرب. لأن مجد الرب عظيم لأن الرب عال ويعاين المتواضعات والكائنات يعرفها من بعد. إن سلكت في وسط الشدة فإنك تحييني. على رجز الأعداء مددت يدك وخلصتني يمينك. الرب يجازي عني، يا رب رحمتك دائمة إلى الأبد. أعمال يديك يا رب لا تتركها هلليلويا.'
  },
  // ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٤٠ كاملاً لوحده
// ====================================================================
  {
    'title': '٤١. الخدمة الثالثة: (المزمور 140) ',
    'text':
        'المزمور المائة والأربعون:\n\nيا رب إليك صرخت فاستمع لي. أنصت إلى صوت تضرعي، إذا ما صرختُ إليك. لتستقم صلاتي كالبخور قدامك. وليكن رفع يدي كذبيحة مسائية. ضع يا رب حافظا لفمي، وبابا حصينا لشفتي. ولا تمل قلبي إلى كلام الشر، فيتعلل بعلل في الخطايا مع أناس فاعلي الإثم، ولا أتفق مع مختاريهم.\n\nفليؤدبني الصديق برحمة ويوبخني. أما زيت الخاطئ فلا يدهن رأسي، لأن صلاتي أيضا بمسرة. قد ابتُلِع أقوياؤهم عند الصخرة، يسمعون كلماتي لأنهم استلذوا. مثل شحم الأرض انشقوا على الأرض. تبددت عظامهم عند الجحيم، لأن عيوننا إليك يا رب، يا رب عليك توكلت فلا تقتل نفسي. احفظني من الفخ الذي قد نصبوه لي. ومن شكوك فاعلي الإثم. يسقط الخطاة في شبكتهم، وأكون أنا وحدي حتى يجوزَ الإثم هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٤١ كاملاً لوحده
// ====================================================================
  {
    'title': '٤٢. الخدمة الثالثة: (المزمور 141) ',
    'text':
        'المزمور المائة والحادي والأربعون:\n\nبصوتي إلى الرب صرختُ، بصوتي إلى الرب تضرعتُ. أسكب أمامه توسلي. أبث لديه ضيقي، عند فناء روحي مني وأنت علمتَ سبلي. في الطريق التي أسلك أخفوا لي فخا، تأملت عن اليمين وأبصرت فلم يكن من يعرفني. ضاع المهرب مني وليس من يسأل عن نفسي.\n\nفصرختُ إليك يا رب وقلت: أنت هو رجائي وحظي في أرض الأحياء. أنصت إلى طلبتي فإنني قد تذللتُ جدا. نجني من الذين يضطهدونني لأنهم قد اعتزوا أكثر مني. أخرج من الحبس نفسي، لكي أشكر اسمك يا رب. إياي ينتظر الصديقون حتى تجازيني هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٤٥ كاملاً لوحده
// ====================================================================
  {
    'title': '٤٣. الخدمة الثالثة: (المزمور 145) ',
    'text':
        'المزمور المائة والخامس والأربعون:\n\nسبحي يا نفسي الربَّ، أسبح الرب في حياتي وأرتل لإلهي ما دمت موجودا. لا تتكلوا على الرؤساء ولا على بني البشر الذين ليس عندهم خلاص. تخرج روحهم فيعودون إلى ترابهم. في ذلك اليوم تهلك كافة أفكارهم.\n\nطوبى لمن إله يعقوب معينه. واتكاله على الرب إلهه، الذي صنع السماء والأرض والبحر وكل ما فيها. الحافظ العدل إلى الدهر، الصانع الحكم للمظلومين المعطي الطعام للجياع. الرب يحل المربوطين الرب يقيم الساقطين. الرب يُحَكِّم العميان. الرب يحب الصديقين. الرب يحفظ الغرباء، ويعضد اليتيم والأرملة. ويبيد طرق الخطاة. يملك الرب إلى الدهر، وإلهك يا صهيون من جيل إلى جيل هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٤٦ كاملاً لوحده
// ====================================================================
  {
    'title': '٤٤. الخدمة الثالثة: (المزمور 146) ',
    'text':
        'المزمور المائة والسادس والأربعون:\n\nسبحوا الرب فان المزمور جيد، ولإلهنا يلذ التسبيح. الرب يبني أورشليم. الرب يجمع متفرقي إسرائيل. الرب يشفي المنكسري القلوب، ويجبر جميع كسرهم. المحصي كثرة الكواكب، ولكافتها يعطي أسماء. عظيم هو الرب وعظيمة هي قوته، ولا إحصاء لفهمه. الرب يرفع الودعاء ويذل الخطاة إلى الأرض.\n\nابتدئوا للرب بالاعتراف، رتلوا لإلهنا بالقيثارة. الذي يجلل السماء بالغمام، الذي يهيئ للأرض المطر، الذي يُنبت العشب على الجبال، والخضرة لخدمة البشر، ويعطي البهائم طعامها، ولفراخ الغربان التي تدعوه. لا يؤْثر قوة الفرس ولا يسر بساقي الرجل، بل يسر الرب بخائفيه وبالراجين رحمته هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: المزمور ١٤٧ كاملاً لوحده
// ====================================================================
  {
    'title': '٤٥. الخدمة الثالثة: (المزمور 147) ',
    'text':
        'المزمور المائة والسابع والأربعون:\n\nسبحي الرب يا أورشليم، سبحي إلهك يا صهيون. لأنه قد قوى مغاليق أبوابك وبارك بنيك فيك. الذي جعل تخومَك في سلام، ويملأك من شحم الحنطة. الذي يرسل كلمته إلى الأرض فيرسل قوله عاجلا جدا. المعطي الثلج كالصوف، المذري الضباب كالرماد، ويلقي الجليد مثل الفتات. قدام وجه برْدِه من يقوم. يرسل كلمته فتذيبه، تهب ريحه فتسيل المياه. المخبر كلمته ليعقوب وفرائضه وأحكامه لإسرائيل. لم يصنع هكذا بكل الأمم، وأحكامُه لم يوضحها لهم هلليلويا.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: إنجيل لوقا ١٢ كاملاً لوحده
// ====================================================================
  {
    'title': '٤٦. إنجيل الخدمة الثالثة (لوقا 12: 32-46)',
    'text':
        'من إنجيل معلمنا لوقا البشير، بركاته علينا جميعاً، آمين:\n\nلا تخف أيها القطيع الصغير، فإن أباكم قد سر أن يعطيكم الملكوت. بيعوا أمتعتكم وأعطوا صدقة، واصنعوا لكم أكياسا لا تبلى، وكنزا في السموات لا يفنى، حيث لا يدنو منه سارق ولا يفسده سوس. لأنه حيث يكون كنزكم، هناك يكون قلبكم أيضا. لتكن أحقاؤكم ممنطقة ومصابيحكم موقدة وأنتم أيضا تشبهون أناسا ينتظرون سيدهم، متى يرجع من العرس، حتى إذا جاء وقرع يفتحون له للوقت.\n\nطوبى لأولئك العبيد الذين إذا جاء سيدهم يجدهم ساهرين. الحق أقول لكم إنه يتمنطق ويتكئهم ويقوم فيخدمهم. وإذا جاء في الهزيع الثاني أو جاء في الهزيع الثالث ووجدهم يصنعون هكذا، فطوبى لأولئك العبيد. وهذا اعلموه: أنه لو كان رب البيت يعلم في أية ساعة يأتي السارق، لكان يسهر ولا يدع بيته يُنقب. فكونوا أنتم أيضا مستعدين. فإنه في ساعة لا تعرفونها يأتي ابن الإنسان.\n\nفقال له بطرس: يا رب ألنا قلتَ هذا أم قلته للجميع ؟ فقال الرب: من هو الوكيل الأمين الحكيم الذي يقيمه سيده على عبيده ليعطيهم طعامهم في حينه ؟ طوبى لذلك العبد الذي إذا جاء سيده يجده يفعل هكذا. حقا أقول لكم إنه يقيمه على جميع أمواله. ولكن إن قال ذلك العبد الرديء في قلبه إن سيدي يبطئ في قدومه، فيبدأ يضرب العبيد والإماء ويأكل ويشرب ويسكر، يأتي سيد ذلك العبد في اليوم الذي لا يتوقعه وفي الساعة التي لا يعرفها، فيشقه من وسطه، ويجعل نصيبه مع عديمي الإيمان (والمجد لله دائما).'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: قطع صلاة النوم كاملة مع كيرياليسون
// ====================================================================
  {
    'title': '٤٧. قطع الخدمة الثالثة الطقسية كاملة',
    'text':
        'القطع الطقسية للخدمة الثالثة   :\n\nبعين متحننة يا رب انظر إلى ضعفى، فعما قليل تفنى حياتي، وبأعمالي ليس لي خلاص. فلهذا أسال: بعين رحيمة يا رب انظر إلى ضعفى وذلي ومسكنتي وغربتي، ونجني.\n(ذوكصابتري كيه إيو كي آجيو ابنيفماتي Doxa Patri ke Uiw ke `agiw `Pneumati - المجد للآب والابن والروح القدس).\n\nبما أن الديان حاضر، اهتمي يا نفسي وتيقظي وتفهمي تلك الساعة المخوفة. فإنه ليس رحمة في الدينونة لمن لم يستعمل الرحمة. فلهذا أشفق عليّ أيها المخلص، فإنك أنت هو محب البشر وحدك.\n(كي نين، كي آ إي، كي ايستوس إي أوناس تون إي أونون آمين Ke nun ke `a`i ke ic touc `e`wnac twn `e`wnwn `amyn - الآن وكل أوان وإلى دهر الداهرين آمين).\n\nيا باب الحياة العقلي، يا والدة الإله المكرمة، خلصي الذين التجأوا إليك بإيمان من الشدائد، لكي نمجد ميلادك الطاهر في كل شيء من أجل خلاص نفوسنا.\n(كي نين، كي آ إي، كي ايستوس إي أوناس تون إي أونون آمين Ke nun ke `a`i ke ic touc `e`wnac twn `e`wnwn `amyn - الآن وكل أوان وإلى دهر الداهرين آمين).\n\nأيها الملك السمائي المعزى، روح الحق، الحاضر في كل مكان والمالئ الكل، كنز الصالحات، ومعطى الحياة، هلم تفضل وحل فينا، وطهرنا من كل دنس أيها الصالح، وخلص نفوسنا.\n(ذوكصابتري كيه إيو كي آجيو ابنيفماتي Doxa Patri ke Uiw ke `agiw `Pneumati - المجد للآب والابن والروح القدس).\n\nكما كنت مع تلاميذك أيها المخلص وأعطيتهم السلام، هلم أيضا كن معنا وامنحنا سلامك وخلصنا ونج نفوسنا.\n(كي نين، كي آ إي، كي ايستوس إي أوناس تون إي أونون آمين Ke nun ke `a`i ke ic touc `e`wnac twn `e`wnwn `amyn - الآن وكل أوان وإلى دهر الداهرين آمين).\n\nإذا ما وقفنا في هيكلك المقدس نحسب كالقيام في السماء. يا والدة الإله، أنت هي باب السماء، افتحي لنا باب الرحمة.\n\nكيرياليصون (يا رب ارحم) Kuri`e `ele`hcon نرددها بخشوع تام ويقظة كاملة ٤١ مرة.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: الثلاث تقديسات وفصل الآن تطلق عبدك
// ====================================================================
  {
    'title': '٤٨. الثلاث تقديسات وفصل الآن تطلق عبدك بسلام',
    'text':
        'الثلاث تقديسات الطقسية الكبرى:\n\nقدوس الله، قدوس القوى، قدوس الحي الذي لا يموت، الذي ولد من العذراء، ارحمنا. قدوس الله، قدوس القوى، قدوس الحي الذي لا يموت، الذي صلب عنا، ارحمنا. قدوس الله، قدوس القوى، قدوس الحي الذي لا يموت، الذي قام من الأموات وصعد إلى السموات، ارحمنا. المجد للآب والابن والروح القدس، الآن وكل أوان وإلى دهر الدهور. أمين. أيها الثالوث القدوس ارحمنا. أيها الثالوث القدوس ارحمنا. أيها الثالوث القدوس ارحمنا.\n\nيا رب اغفر لنا خطايانا. يا رب اغفر لنا آثامنا. يا رب اغفر لنا زلاتنا. يا رب افتقد مرضى شعبك، اشفهم من أجل اسمك القدوس. آباؤنا وإخوتنا الذين رقدوا، يا رب نيح نفوسهم. يا من هو بلا خطية، يا رب ارحمنا. يا من بلا خطية، يا رب أعنا، واقبل طلباتنا إليك. لأن لك المجد والعزة والتقديس المثلث. يا رب ارحم. يا رب ارحم يا رب بارك. أمين.\n\nواجعلنا مستحقين أن نقول بشكر: أبانا الذي في السموات...\n\nفصل من إنجيل لوقا ص٢: ٢٩-٣٢\nالآن يا سيدي، تطلق عبدك بسلام حسب قولك، لأن عيني قد أبصرتا خلاصك الذي أعددته قدام جميع الشعوب. نورًا تجلى للأمم، ومجدا لشعبك إسرائيل. والمجد لله دائما.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: قانون الإيمان الأرثوذكسي كاملاً
// ====================================================================
  {
    'title': '٤٩. قانون الإيمان المقدس الأرثوذكسي',
    'text':
        'قانون الإيمان المقدس الأرثوذكسي :\n\nبالحقيقة نؤمن بإله واحد، الله الآب، ضابط الكل، خالق السماء والأرض، ما يُرَى وما لا يرى.\n\nنؤمن برب واحد يسوع المسيح، ابن الله الوحيد، المولود من الآب قبل كل الدهور، نور من نور، إله حق من إله حق، مولود غير مخلوق، مساو للآب في الجوهر، الذي به كان كل شيء. هذا الذي من أجلنا نحن البشر، ومن أجل خلاصنا، نزل من السماء، وتجسد من الروح القدس ومن مريم العذراء، وتأنس. وصلب عنا على عهد بيلاطس البنطي. وتألم وقبر وقام من بين الأموات في اليوم الثالث كما في الكتب، وصعد إلى السموات، وجلس عن يمين أبيه، وأيضا يأتي في مجده ليدين الأحياء والأموات، الذي ليس لملكه انقضاء.\n\nنعم نؤمن بالروح القدس، الرب المحيى المنبثق من الآب. نسجد له ونمجده مع الآب والابن، الناطق في الأنبياء.\n\nوبكنيسة واحدة مقدسة جامعة رسولية.\n\nونعترف بمعمودية واحدة لمغفرة الخطايا.\n\nوننتظر قيامة الأموات وحياة الدهر الآتي. أمين.\n\nكيرياليسون (يا رب ارحم) Kuri`e `ele`hcon نرددها بخشوع تام ٤١ مرة.'
  },
// ====================================================================
// صلاة نصف الليل - الخدمة الثالثة: قدوس قدوس قدوس وتحليل الخدمة الثالثة
// ====================================================================
  {
    'title': '٥٠. تسبحة قدوس قدوس قدوس والتحليل الختامي الثالث',
    'text':
        'قدوس، قدوس، قدوس، رب الصباؤوت. السماء والأرض مملوءتان من مجدك وكرامتك. ارحمنا يا الله الآب ضابط الكل. أيها الثالوث القدوس ارحمنا. أيها الرب إله القوات كن معنا، لأنه ليس لنا معين في شدائدنا وضيقاتنا سواك.\n\nحل واغفر واصفح لنا يا الله عن سيئاتنا، التي صنعناها بإرادتنا والتي صنعناها بغير إرادتنا، التي فعلناها بمعرفة والتي فعلناها بغير معرفة، الخفية والظاهرة. يا رب اغفرها لنا، من أجل اسمك القدوس الذي دعي علينا. كرحمتك يا رب وليس كخطايانا.\n\nواجعلنا مستحقين أن نقول بشكر: أبانا الذي في السموات...\n\nتحليل الخدمة الثالثة الختامي:\nأيها السيد الرب يسوع المسيح، ابن الله الحي الأزلي، أنر عقولنا لنفهم أقوالك المحيية. وأنهضنا من ظلمة الخطية القاتلة للنفس. واجعلنا أهلا أن نكون مستقيمين في عمل الخير. وفى وقت مجيئك لتدين العالم، فلنستحق سماع ذلك الصوت المملوء فرحا، القائل: تعالوا إلى يا مبارَكي أبى، رثوا الملك المعد لكم من قبل إنشاء العالم. نعم يا رب، سهل لنا أن نكون في تلك الساعة بغير خوف ولا اضطراب ولا سقوط في الدينونة. ولا تجازنا من أجل كثرة آثامنا، لأنك وحدك المتحنن الطويل الأناة الكثير الرحمة، بشفاعة سيدتنا والدة الإله القديسة مريم، وشفاعة جميع مصاف قديسيك. أمين.'
  },
// ====================================================================
// صلاة نصف الليل - الختام الكلي: طلبة تصلى آخر كل ساعة وقفل المصفوفة
// ====================================================================
  {
    'title': '٥١. طلبة تصلى آخر كل ساعة والختام الكلي للمصفوفة',
    'text':
        'طلبة تصلى آخر كل ساعة :\n\nارحمنا يا الله ثم ارحمنا. يا من في كل وقت وكل ساعة، في السماء وعلى الأرض، مسجود له وممجد. المسيح إلهنا الصالح، الطويل الروح، الكثير الرحمة، الجزيل التحنن، الذي يحب الصديقين ويرحم الخطاة الذين أولهم أنا. الذي لا يشاء موت الخاطئ مثل ما يرجع ويحيا. الداعي الكل إلى الخلاص لأجل الموعد بالخيرات المنتظرة.\n\nيا رب اقبل منا في هذه الساعة وكل ساعة طلباتنا. سهل حياتنا، وأرشدنا إلى العمل بوصاياك. قدس أرواحنا. طهر أجسامنا. قوم أفكارنا. نق نياتنا. اشف أمراضنا واغفر خطايانا. ونجنا من كل حزن رديء ووجع قلب. أحطنا بملائكتك القديسين، لكي نكون بمعسكرهم محفوظين ومرشدين، لنصل إلى اتحاد الإيمان وإلى معرفة مجدك غير المحسوس وغير المحدود، فإنك مبارك إلى الأبد. أمين.\n\nاللهم اجعلنا مستحقين أن نقول بشكر وبنوة حقيقية:\nأبانا الذي في السموات...'
  },
  // ====================================================================
// صلاة نصف الليل - الختام: التحليل الكبير لنصف الليل (الجزء الأول)
// ====================================================================
  {
    'title': '٥٢. التحليل الكبير لنصف الليل (تحليل الكهنة - 1)',
    'text':
        'التحليل الكبير لنصف الليل (تحليل الكهنة - الجزء الأول):\n\nنسألك ونشكرك، أيها السيد الرب يسوع المسيح، ابن الله الحي الأزلي، الكائن في النور قبل كل الدهور، نور من نور:\n\nأنر يا رب عقولنا وقلوبنا، وأضيء أفهامنا، لنفهم كلامك المحيي. وأقمنا من ظلمة الخطية القاتلة للنفس. واجعلنا مستحقين أن نكون مستقيمين في عمل الخير والصلاح. وفي وقت مجيئك الثاني المرهوب، لتدين فيه العالم، فلنستحق سماع ذلك الصوت المملوء فرحا وبهجة، وعزاء وسرورا، ونعيما من فمك الإلهي القائل: "تعالوا إلي يا مبارَكي أبي، رثوا الملك المعد لكم قبل إنشاء العالم". نعم أيها الرب إلهنا: وفقنا أن نكون في ذلك اليوم، وتلك الساعة، بغير خوف ولا عيب ولا انزعاج، ولا سقوط ولا انحراف. ولا تؤاخذنا يا رب بكثرة آثامنا. اصفح يا رب عن جميع سيئاتنا وزلاتنا، وغلطاتنا وهفواتنا.\n\nوارفع يا رب عنا وعن جميع العالم، الموت والغلاء، والوباء والفناء، والجلاء وسيف الأعداء، ومؤامرة الشياطين، وشر الحريق والغرق، ومقاومة الأشرار وكيد الفجار، وجور السلطان. وأبطل مؤامرة المعاندين لنا.\n\nاللهم إنك ربنا وإلهنا، تراءف علينا، ولا تطرحنا في بحار المهالك ولا عقاب المسالك. لكن نجنا واحفظنا واسترنا. وأنهضنا من الملل والضجر والتواني والكسل. ولا تدع العدو الشيطان يطغينا بوسع الأمل. بل نبه عقولنا، وأيقظ قلوبنا من نوم الغفلة وتسويف العمر باطلا. اللهم اترك آثامنا واصفح عن زلاتنا. ولا تذكر خطايانا ولا سيئاتنا، ولا تغضب علينا ولا يدم غضبك إلى الأبد. ارحمنا يا رب ثم ارحمنا، فإننا ضعفاء ومساكين، وفي بحار الخطايا غارقين. فإليك نصرخ ولك نسجد وبك نعترف وإليك نرغب. لا تقطع رجاءنا يا سيدي من رحمتك، ولا تغلق باب رحمتك في وجوهنا. بل بفضلك خلصنا، وإلى رحمتك وفقنا، وصوتك الفرح أسمعنا.\n\nاللهم اترك آثامنا واصفح عن زلاتنا. ولا تذكر خطايانا ولا سيئاتنا، ولا تغضب علينا ولا يدم غضبك إلى الأبد. ارحمنا يا رب ثم ارحمنا، فإننا ضعفاء ومساكين، وفي بحار الخطايا غارقين. فإليك نصرخ ولك نسجد وبك نعترف وإليك نرغب. لا تقطع رجاءنا يا سيدي من رحمتك، ولا تغلق باب رحمتك في وجوهنا. بل بفضلك خلصنا، وإلى رحمتك وفقنا، وصوتك الفرح أسمعنا.'
  },
// ====================================================================
// صلاة نصف الليل - الختام: التحليل الكبير لنصف الليل (الجزء الثاني)
// ====================================================================
  {
    'title': '٥٣. التحليل الكبير لنصف الليل (تحليل الكهنة - 2)',
    'text':
        'التحليل الكبير لنصف الليل (تحليل الكهنة - الجزء الثاني):\n\nاللهم طهرنا وطهر قلوبنا من الأفكار الخبيثة، النجسة الرديئة. وأبطل عنا يا رب وعن كل شعبك، كل الأحلام والخيالات، والهواجس الشيطانية. أقمنا يا الله من كل سقطة وبلية. ثبت فينا يا الله الصبر والرجاء والمحبة والإيمان الأرثوذكسي. واحسبنا من خرافك اليمينية. وأجلسنا مع الذين يتكئون في وليمتك السمائية. واغفر لنا كل إثم وذنب وخطية. وحصّنا بحصن جنود ملائكتك النورانية. فإنه ليس لنا خلاص إلا برحمتك واتكالنا عليك، وإيماننا بك. ورجائنا فيك.\n\nاقبل منا يا رب دعاءنا في هذا الوقت الحاضر، وكل الأوقات. وكل الذين أمرونا وأوصونا أن نذكرهم في الصلوات والقداسات والقناديل والتذكارات، الأحياء منهم والأموات. اذكرنا يا رب نحن وإياهم بالصالحات، في أورشليم السمائية، في ملكوت السموات.\n\nامح يا رب سيئاتنا والذين أساءوا إلينا اترك لهم ولنا. برحمتك يا رب خلص نفوسنا أجمعين. يا رب خلص شعبك. بارك ميراثك. ارعهم وسسهم إلى الأبد. خلص الذين في الشدائد، والضيقات والأحزان. حل المأسورين من رباط الشياطين. أشبع الجياع من الخيرات. عزِّ صغيري القلوب والنفوس. أقم الساقطين. ثبت القائمين. رد الضالين، عل الأرامل والأيتام، أسعف المعوزين. أعطِ بركة لثمار الأرض، مزاجا طيبا للهواء، نموا للأشجار، صعودا كاملا لمياه الأنهار، بارك في الندى والأمطار. أعط قناعة للمحتاجين. أوف عن المديونين. اجمع شتات المتفرقين، اقبل توبة التائبين، اقبل اعتراف المعترفين. أعط فهما للموعوظين. احكم يا رب للمظلومين.\n\nاملأ قلوبنا فرحا وبهجة وعزاء وسرورا ونعيما لكي ما إذا نلنا كفافنا في كل شيء، نتناهى في الأعمال الصالحة المرضية. بارك يا رب في الغلات بالبركات السمائية. بارك يا رب إكليل هذه السنة بصلاحك. بارك يا رب الباذر والزارع، والغارس والحاصد، كما باركت لبني إسرائيل في غلات العام السادس.\n\nبارك يا رب في اجتماعنا هذا، وكل اجتماع الشعوب الأرثوذكسيين. واحفظ لنا وعلينا، حياة وقيام أبينا السيد الأب البطريرك أنبا.. ..، بطريرك هذا الزمان، خلصه يا رب وخلص شعبه من جميع البلايا والتجارب والأحزان. وكذلك شركاءه في الخدمة الرسولية. آباءنا المطارنة، وآباءنا الأساقفة، وآباءنا القمامصة وآباءنا القسوس، وإخوتنا الشمامسة وآباءنا الرهبان، وإخوتنا العلمانيين، والذين أتوا وحضروا واشتركوا معنا في هذه الصلاة. وكل صلوات الأرثوذكسيين الآن طالبين مغفرة خطاياهم، ورحمة لنفوسهم، باركنا وباركهم، حاللنا وحاللهم، اغفر خطايانا وخطاياهم، الماضية والمستأنفة، الذاتية وغير الذاتية، الليلة والنهارية، الظاهرة والخفية.'
  },
  // ====================================================================
// صلاة نصف الليل - الختام: التحليل الكبير (تحليل الكهنة) - الجزء الثالث والأخير
// ====================================================================
  {
    'title':
        '٥٤. التحليل الكبير لنصف الليل (تحليل الكهنة) - الجزء الثالث والختام',
    'text':
        'تابع التحليل الكبير لنصف الليل (الجزء الثالث):\n\nأدم يا رب عمار المجامع، والكنائس المقدسة، والبراري الأرثوذكسية، والشيوخ الساكنين فيها، وخدامها ومدبريها، ومن بها، واجعل الأمن والسلام والطمأنينة بينهم. وأخضع العدو الشرير تحت أقدامنا وأقدامهم. ولا تجعل له فينا ولا فيهم نصيبا، لا بضربة شمال ولا بضربة يمين. واحفظهم بيدك العالية وذراعك الحصينة. نجنا يا سيدي من التجارب الرديئة، والأشراك المنصوبة المرئية وغير المرئية.\n\nاذكر يا رب آباءنا وأمهاتنا واخوتنا، وأهلنا وأقاربنا ومعلمينا، وأولادنا الروحيين (والجسديين)، وسائر بني المعمودية أجمعين. اذكر يا رب الذين لهم معنا تعب وشركة. اذكر يا رب الذين أكلنا وشربنا من كدهم وتعبهم، وآوونا في منازلهم. وأعطونا من أيديهم. عوضهم يا رب عوض الفانيات بالباقيات، والأرضيات بالسمائيات. املأ بيوتهم ومخازنهم من كل الخيرات، عوضهم يا رب عوض الواحد، ثلاثين وستين ومائة، وغفران خطاياهم في ملكوت السموات. اذكر يا رب الذين أحسنوا إلينا وإلى إخوتنا المساكين، بجميع وجوه الحسنات. محبة فيك وإكراما لاسمك القدوس، باركهم.\n\nاذكر يا رب المهتمين بالصعائد والقرابين والمحرقات والخمر والزيت، والبكور والبخور، والستور والنذور وكتب القراءة وكل أواني المذبح جميعا. عوضهم يا رب عن عطاياهم بغفران خطاياهم. وهب لهم في هذا الدهر الحاضر الحياة الهنيئة وفي الدهر الآتي الحياة الأبدية.\n\nاذكر يا رب آباءنا وإخوتنا الذين سبقوا فرقدوا وتنيحوا في الإيمان المستقيم بالمسيح. نيح يا رب نفوسهم أجمعين، في أحضان آبائنا القديسين إبراهيم وإسحق ويعقوب، في كورة الأحياء، في فردوس النعيم. أما نحن الأحياء فأعنا على خلاص نفوسنا، ودبر حياتنا حسب إرادتك الصالحة.\n\nتفضل يا رب اذكر حقارتي وذلي وضعفي، أنا الخاطئ الشقي غير المستحق الوقوف بين يديك من أجل كثرة خطاياي وذنوبي، لا ترذلني. أقم يا رب قرن خلاص شعبك بإشارة صليبك المحيي. فرجك يا رب عند الشدة وعونك يا رب عند الكرب والذلة. خلصنا يا رب وخلص كل من في شدة. ومرضى شعبك اشفهم.\n\nواجعل يا رب شعبك المسيحيين الحاضرين معنا والغائبين عنا، أن يكونوا مباركين محاللين من فمك الإلهي. من مشارق الشمس إلى مغاربها ومن الشمال إلى اليمين. واقبلنا إليك كما قبلت اللص اليمين، وأنت على خشبة الصليب، ووهبت له فردوس النعيم .\n\nاذكر يا رب الأيتام والأرامل، والمنقطعين والعاجزين، والذين ليس لهم أحد يذكرهم. اذكرنا يا رب نحن وإياهم في أورشليم السمائية. اذكر يا رب القائمين والقاعدين، والراقدين والمطروحين، والمسافرين في البر والبحر والهواء، والسهل والوعر والأودية، والطرقات ورؤوس الجبال، والتلال والمغاير. والذين في المطابق والسجون، والذين في السبي والنفي، والمأسورين والمربوطين برباط السلاطين والشياطين. ردهم وأت بهم الجميع إلى الميناء، سالمين غانمين، كاسبين رابحين، معافي النفس والجسد والروح.\n\nواجعل يا ربي يسوع المسيح صلاتنا هذه أن تكون مقبولة أمامك بغير رياء ولا كبرياء، ولا عظمة ولا افتخار ولا عيب. أعنا يا الله على رضاك. أعنا على العمل بوصاياك. أعنا على سكرات الموت وما قبل الموت وما بعد الموت. لأنك أنت إله صالح طويل الروح، كثير الرحمة والتحنن. اللهم اجعل باب بيعتك مفتوحا أمام وجوهنا على ممر الدهور والأزمان، وإلى آخر كل زمان. ارحمنا يا الله كعظيم رحمتك.\n\nبشفاعات ذات الشفاعات، معدن الطهر والجود والبركات، سيدتنا كلنا، وفخر جنسنا، العذراء البتول الزكية القديسة مريم، والشهيد المكرم مار مرقس الإنجيلي الرسول كاروز الديار المصرية، وكافة الملائكة والآباء والأنبياء، والرسل والشهداء والقديسين والسواح والعباد، والنساك المجاهدين، والذين أرضوا الرب بأعمالهم الصالحة منذ آدم إلى آخر الدهور.\n\nولك نسجد أيها الثالوث القدوس الاب والإبن والروح القدس الآن وكل أوان وإلى دهر الداهرين أمين.\n\nاللهم اجعلنا مستحقين أن نقول بشكر:\nأبانا الذي في السموات...'
  },
];

final List<Map<String, String>> _extraPrayersData1 = [
  {
    'title': 'صلاة قبل التناول المقدس',
    'text':
        'يا رب إني غير مستحق أن تدخل تحت سقف بيتي لأني إنسان خاطئ، فقل كلمة أولًا لتبرأ نفسي. قل لنفسي: مغفورة لك خطاياك. إني مقفر وخال من كل صلاح، وليس لي سوى تحننك ورأفتك ومحبتك للبشر. وأنت قد تنازلت من سماء مجدك غير المدرك إلى ذلنا، وارتضيت أن تولد في مذود البقر. فلا ترفض يا مخلصي القدوس أن تقبل إلى نفسي الذليلة الحقيرة التي تنتظر حضورك البهي. إنك لم تستنكف من دخول بيت الأبرص لتشفيه، فاسمح يا إلهي بالدخول إلى نفسي لتطهرها. لم تمنع الخاطئة من تقبيل قدميك فلا تحرمني من الدنو منك لتناول جسدك الطاهر ودمك الأقدس. بل فليصر تناولي للاشتراك معك، ولإبادة كل ما هو دنس، ولإماتة أهوائي الدنيئة، وللعمل بوصاياك المحيية، ولشفاء نفسي وجسدي من كل خطية، ولقبول مواهبك، ولسكنى نعمتك، ولحلول روحك، وللاتحاد بك، والثبات فيك، لأحيا لمجد اسمك القدوس. آمين..'
  },
  {
    'title': 'صلاة بعد التناول المقدس',
    'text':
        'قد امتلأ قلبي فرحًا، ولساني تهليلًا. فلتعظم نفسي الرب، وتبتهج روحي بالله مخلصي. لقد أقبلت إليك يا رب لِتُلْبِسْني حلة نقية للدخول إلى عرسك. فليكن اتحادي بك اليوم دائمًا. لأني به أزداد في الفضيلة ثباتًا ونموًا. ويشتد إيماني. ويتقوَّى رجائي. فَلْيَصِر تناولي علامة للخلاص، ولباسًا للنعمة، وحلة للميلاد الجديد، وطهارة وقداسة للنفس والجسد والروح، ونقاوة للحب، وفرحًا وسرورًا أبديًا ، ولجواب حسن القبول أمام منبرك الرهيب. إني أسلم ذاتي بين حنوك، فاجعلني واحدًا معك، وسَيِّرني تحت إرادتك. استدع إليك عقلي وحواسي وإرادتي لتباركها فتكون طوع مشيئتك. أحيي قلبي وأيقظ ضميري. شتت جميع خيالات العدو. وقل للزوابع أن تسكت. سر معي وهدئ روعي. ارو عطشى، وأضرِم لهيب محبتك في قلبي. تلاف بحنو ورفق كل ما ينقصني. امكث معي لأن النهار قد مال. ورافقني إلى أنْ ينسم النهار، فإنك وحدك غايتي وسعادتي، أنت وحدك يا رب إلى الأبد. آمين..'
  }
];

final List<Map<String, String>> _extraPrayersData2 = [
  {
    'title': 'صلاة قبل المذاكرة والدراسة',
    'text':
        'أيها السيد الرب يسوع المسيح، يا كنز الحكمة ومصدر الفهم والمشورة، الكاشف للمستورات ومبدي الضياء العقلاني. أرسل نورا حقيقيا من لدن روحك القدوس لينير عقلي وفهمي، واطرد عني كل غفلة وتشتت وكسل وهيولية. هب لي يا رب فِطنة وعقلاً مستيقظاً، وذكاءً صالحاً مستوعباً لكي أفهم وأدرس دروسي بكل دقة وأمانة، واجعل هذه العلوم سبباً لتمجيد اسمك القدوس وخدمة عائلتي ومجتمعي، لأنك أنت هو نور العقول وواهب الفهم، ولك نسجد ونرتل إلى الأبد. أمين.'
  },
  {
    'title': 'صلاة قبل دخول الامتحان',
    'text':
        'يا رب، ها أنا أتقدم لأداء هذا الامتحان، وأعلم أن ضعفي وفقري شديد، ولكن رحمتك ومعونتك أعظم من كل ضيقة. يا رب، كن معي في هذه الساعة، سهل لي الإجابة، املأ قلبي بالهدوء والسكينة والنظام، واطرد عني الخوف والقلق والاضطراب. ذكّرني بكل ما درستُ وقرأتُ، وافتح ذهني لأكتب الصواب والبر الحقيقي، واجعل النجاح والتفوق نصيبي بمشيتك المقدسة، لأنك أنت هو معيني وملجأي الحصين في الشدائد. أمين.'
  }
];

final List<Map<String, String>> _extraPrayersData3 = [
  {
    'title': 'صلاة قبل الطعام',
    'text':
        'أعين الكل تترجاك يا رب، لأنك أنت الذي تعطيهم طعامهم في أوانه الصالح. تفتح يدك الطاهرة فتملأ كل حي غبطة وسروراً. بارك يا رب هذا الطعام والشراب الموضوعين أمامنا، واجعلهما قوة وبنياناً لأجسادنا لخدمتك بطهارة وبر. اشفِ المرضى، وأطعم الجياع والمعوزين، واجعل قلوبنا مملوءة دائماً بالسرور والابتهاج والشكر لك في كل حال ومن أجل كل حال، لأنك أنت هو معطي الطعام لكل ذي جسد، تبارك اسمك القدوس إلى الأبد. أمين.'
  },
  {
    'title': 'صلاة بعد الطعام',
    'text':
        'نشكرك يا رب لأنك أطعمتنا من خيراتك الأرضية، واشبعت أجسادنا من بركتك التلقائية الصالحة. ونسألك يا رب يا محب البشر، كما أطعمتنا وأشبعت أجسادنا من هذا الطعام الزائل، لا تحرمنا من طعامك الروحي غير الزائل وكلمتك المحيية السمائية. اجعلنا مستحقين أن نشترك في مائدتك السمائية وفي ملكوتك الأبدي، ولا تحرمنا من نعيم فردوسك، لأنك أنت هو الصالح والبار والمبارك إلى الأبد ود دهر الدهور كلها. أمين.'
  }
];
