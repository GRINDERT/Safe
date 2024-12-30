import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:otp/otp.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: const Icon(
                Icons.security_outlined,
                color: Colors.blue,
                size: 100,
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  VideoPlayerController? _controller;
  String? _selectedVideoPath;
  String _generatedCode = "";
  final String _secretKey = "JBSWY3DPEHPK3PXP";

  void _generateTOTP() {
    setState(() {
      _generatedCode = OTP.generateTOTPCodeString(
        _secretKey,
        DateTime.now().millisecondsSinceEpoch,
        interval: 5,
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'BiSafe',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            fontFamily: 'myfont',
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: _selectedIndex == 0
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Secure your identity',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: "myfont",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateTOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 80, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: "myfont",
                ),
              ),
              child: const Text('Generate a code'),
            ),
            const SizedBox(height: 20),
            if (_generatedCode.isNotEmpty)
              Text(
                'Your OTP: $_generatedCode',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const QRScanner()));
              },
              child: const Text('Scan QR Code'),
            ),
          ],
        )
            : _selectedIndex == 1
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verify videos',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: "myfont",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final video = await FilePicker.platform.pickFiles(
                  type: FileType.video,
                );

                if (video != null) {
                  setState(() {
                    _selectedVideoPath = video.files.single.path!;
                    _controller = VideoPlayerController.file(
                      File(_selectedVideoPath!),
                    )..initialize().then((_) {
                      setState(() {});
                      _controller!.play();
                    });
                  });
                  print('Vidéo sélectionnée : ${video.files.single.name}');
                } else {
                  print('Aucune vidéo sélectionnée');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 80, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: "myfont",
                ),
              ),
              child: const Text('Upload a video'),
            ),
            const SizedBox(height: 20),
            if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            else if (_selectedVideoPath != null)
              const Text("Chargement de la vidéo..."),
          ],
        )
            : const Text(
          'Accéder aux paramètres',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.vpn_key),
            label: 'Générer un code',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Uploader une vidéo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );
  }
}

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.blueAccent,
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController controller) {
          this.controller = controller;
          controller.scannedDataStream.listen((scanData) {
            if (scanData.code != null) {
              print('Scanned QR Code: ${scanData.code}');
              Navigator.pop(context); // Ferme le scanner après scan
            }
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
