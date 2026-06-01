#!/bin/bash

# 1. إنشاء هيكل المجلدات النظيف المتوافق مع الفلاتر
echo "📁 جاري إنشاء المجلدات..."
mkdir -p lib
mkdir -p .github/workflows
mkdir -p android/app
mkdir -p android/app/src/main

# 2. إنشاء ملف pubspec.yaml
echo "📝 جاري إنشاء pubspec.yaml..."
cat << 'EOF' > pubspec.yaml
name: detox
description: "A minimalist 150-day detox tracker application."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
EOF

# 3. إنشاء كود التطبيق الأساسي (lib/main.dart)
echo "📝 جاري إنشاء كود التطبيق..."
cat << 'EOF' > lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MinimalistMinimalApp());
}

class MinimalistMinimalApp extends StatelessWidget {
  const MinimalistMinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff121212),
        primaryColor: Colors.white,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentDay = 1;
  final int _targetDays = 150;
  
  final List<String> _habits = [
    "ترك الهاتف غير الضروري",
    "الابتعاد عن الذكاء الاصطناعي",
    "قطع الإنترنت الزائد",
    "التعافي من الإباحية"
  ];

  Map<String, bool> _todayStatus = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentDay = prefs.getInt('current_day') ?? 1;
      for (var habit in _habits) {
        _todayStatus[habit] = prefs.getBool('status_$habit') ?? false;
      }
    });
  }

  Future<void> _toggleHabit(String habit) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _todayStatus[habit] = !(_todayStatus[habit] ?? false);
      prefs.setBool('status_$habit', _todayStatus[habit]!);
    });
  }

  Future<void> _nextDay() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentDay < _targetDays) {
      setState(() {
        _currentDay++;
        for (var habit in _habits) {
          _todayStatus[habit] = false;
          prefs.setBool('status_$habit', false);
        }
        prefs.setInt('current_day', _currentDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "اليوم $_currentDay من $_targetDays",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "${((_currentDay / _targetDays) * 100).toStringAsFixed(1)}% من الرحلة اكتملت",
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: Table(
                  border: TableBorder.all(color: Colors.grey[800]!, width: 1),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(1),
                  },
                  children: _habits.map((habit) {
                    bool isDone = _todayStatus[habit] ?? false;
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            habit,
                            style: TextStyle(
                              fontSize: 18, 
                              color: isDone ? Colors.grey : Colors.white,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _toggleHabit(habit),
                          child: Container(
                            height: 56,
                            alignment: Alignment.center,
                            color: isDone ? Colors.white.withOpacity(0.05) : Colors.transparent,
                            child: Icon(
                              isDone ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                              color: isDone ? Colors.green : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  onPressed: _nextDay,
                  child: const Text(
                    "إنهاء اليوم والانتقال للتالي",
                    style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

# 4. إعدادات الأندرويد لضمان نجاح الـ Build (Gradle & Manifest)
echo "⚙️ إعداد ملفات الأندرويد الضرورية للبناء..."

cat << 'EOF' > android/build.gradle
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}
tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
EOF

cat << 'EOF' > android/app/build.gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

android {
    namespace "com.example.detox"
    compileSdk 34

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId "com.example.detox"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}
EOF

cat << 'EOF' > android/app/src/main/AndroidManifest.xml
<manifest xmlns:android="http://schemas.android.com/apk/and/android">
    <application
        android:label="Detox"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
EOF

# 5. إنشاء ملف الـ GitHub Actions Workflow المحدث لبناء الـ APK
echo "🤖 إنشاء ملف الـ Workflow لـ GitHub Actions..."
cat << 'EOF' > .github/workflows/build_apk.yml
name: Build Flutter APK

on:
  push:
    branches:
      - main
      - master

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release --no-tree-shake-icons

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: Detox-App
          path: build/app/outputs/flutter-apk/app-release.apk
EOF

# 6. الربط بـ GitHub والرفع التلقائي
echo "🚀 جاري التهيئة والرفع إلى مستودع Detox..."
git init
git add .
git commit -m "Build: Initial Detox Minimalist Tracker"
git branch -M main
git remote remove origin 2>/dev/null
git remote add origin https://github.com/bee-medd/Detox.git

echo "⏳ سيُطلب منك الآن إدخال اسم مستخدم GitHub والـ Token (أو كلمة المرور) لإتمام الرفع الزمني..."
git push -u origin main --force

echo "✅ تم إرسال الملفات بنجاح إلى المستودع!"
echo "🎯 افتح الرابط: https://github.com/bee-medd/Detox/actions لتتابع سير بناء تطبيقك الجديد."
