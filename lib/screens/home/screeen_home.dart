
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixelfy/screens/anuncios/banner.dart';
import 'package:pixelfy/screens/image_picker.dart';
import 'package:pixelfy/utils/cadenas.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final List<String> imageUrls = [
    'https://picsum.photos/400/300?random=1',
    'https://picsum.photos/400/300?random=2',
    'https://picsum.photos/400/300?random=3',
    'https://picsum.photos/400/300?random=4',
    'https://picsum.photos/400/300?random=5',
  ];

  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/6300978111", // ID de prueba de Google
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Error al cargar el banner: $error');
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Cadenas.get("app_name")),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              carrusel(),
              const SizedBox(height: 20),
              _buildGradientContainerwidth(Cadenas.get("collage"), Icons.collections),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGradientContainer(Cadenas.get("template"), Icons.ice_skating),
                  const SizedBox(width: 10),
                  _buildGradientContainer(Cadenas.get("edit"), Icons.ac_unit),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BannerAdWidget(),
      /*
      bottomNavigationBar: _isBannerAdLoaded
          ? SizedBox(
        height: _bannerAd.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd),
      )
          : const SizedBox.shrink(),

      */
    );
  }

  Widget _buildGradientContainer(String text, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.3,
      height: MediaQuery.of(context).size.height / 5,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffee600a), Color(0xffa1887f)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.white),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.lilitaOne(
              fontSize: 19,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGradientContainerwidth(String text, IconData icon) {
    return

      GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ImagePickerImage()),
          );
        },
          child:Container(

      width: MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 5,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffee600a), Color(0xffa1887f)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.white),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.lilitaOne(
              fontSize: 19,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ));
  }

  Widget carrusel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
      ),
      items: imageUrls.map((url) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
        );
      }).toList(),
    );
  }
}


