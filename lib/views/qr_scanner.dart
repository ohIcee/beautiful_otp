import 'package:app_settings/app_settings.dart';
import 'package:beautiful_otp/models/auth_entry.dart';
import 'package:dart_otp/dart_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({Key? key}) : super(key: key);

  @override
  _QrScannerState createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  String? _qrInfo;
  bool _camState = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  final TextEditingController _issuerController = TextEditingController();
  final TextEditingController _algorithmController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  final TextEditingController _digitsController = TextEditingController();

  bool secretTextObscured = true;
  bool showAdvancedOptions = false;

  _qrCallback(String? code) {
    setState(() {
      _camState = false;
      _qrInfo = code;

      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ));

      if (_qrInfo != 'manual') {
        AuthEntry entry = AuthEntry.fromGauthString(_qrInfo!, false);
        _nameController.text = entry.name!;
        _secretController.text = entry.secret!;
        _issuerController.text = entry.issuer!;
        _digitsController.text = entry.digits?.toString() ?? "6";
        _algorithmController.text = entry.algorithm?.name ?? "SHA1";
        _periodController.text = entry.period?.toString() ?? "30";
      } else {
        _digitsController.text = "6";
        _algorithmController.text = "SHA1";
        _periodController.text = "30";
      }
    });
  }

  _scanCode() {
    setState(() {
      _camState = true;
      _qrInfo = null;
    });

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  void initState() {
    super.initState();
    _scanCode();
  }

  @override
  void dispose() {
    super.dispose();

    _nameController.dispose();
    _secretController.dispose();
    _issuerController.dispose();
    _algorithmController.dispose();
    _periodController.dispose();
    _digitsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Container(
            child: _camState
                ? Center(
                    child: SizedBox(
                      height: 1000,
                      width: 500,
                      child: Center(
                        child: QRBarScannerCamera(
                          onError: (context, error) =>
                              _buildErrorWidget(error as PlatformException),
                          qrCodeCallback: (code) {
                            _qrCallback(code);
                          },
                        ),
                      ),
                    ),
                  )
                : _buildScannedQrCode(),
          ),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top + 10, left: 40.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back),
            ),
          ),
          const SizedBox(width: 20.0),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: _qrInfo == null
                ? CupertinoButton(
                    onPressed: () {
                      _qrCallback('manual');
                    },
                    child: Row(
                      children: const [
                        Icon(CupertinoIcons.keyboard),
                        SizedBox(width: 15.0),
                        Text('Enter manually'),
                      ],
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedQrCode() {
    if (_qrInfo == null) {
      return const Text('Nothing... This shouldn\'t ever be seen :o');
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 40.0,
        right: 40.0,
        top: MediaQuery.of(context).viewPadding.top + 80.0,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          _buildTextField('Name', _nameController),
          _buildTextField('Issuer', _issuerController),
          _buildTextField('Secret', _secretController, obscureText: true),
          CupertinoButton(
            child: Row(
              children: [
                Icon(
                  showAdvancedOptions
                      ? CupertinoIcons.chevron_down
                      : CupertinoIcons.chevron_up,
                  size: 20.0,
                ),
                const SizedBox(width: 20.0),
                const Text('Advanced Options'),
              ],
            ),
            onPressed: () {
              setState(() {
                showAdvancedOptions = !showAdvancedOptions;
              });
            },
          ),
          const SizedBox(height: 10.0),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 100),
            child: showAdvancedOptions
                ? Column(
                    children: [
                      _buildTextField('Algorithm', _algorithmController),
                      _buildTextField('Period', _periodController,
                          keyboardType: TextInputType.number),
                      _buildTextField('Digits', _digitsController,
                          keyboardType: TextInputType.number),
                    ],
                  )
                : Container(),
          ),
          const SizedBox(height: 50.0),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom + 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton.filled(
                  child: const Text('Confirm'),
                  onPressed: () {
                    if (_nameController.text.isEmpty ||
                        _secretController.text.isEmpty ||
                        _issuerController.text.isEmpty) return;

                    AuthEntry entry = AuthEntry(
                      name: _nameController.text,
                      customName: '',
                      secret: _secretController.text,
                      issuer: _issuerController.text,
                      digits: _digitsController.text.isEmpty
                          ? 6
                          : int.parse(_digitsController.text),
                      algorithm: _algorithmController.text.isEmpty
                          ? OTPAlgorithm.SHA1
                          : AuthEntry.nameToAlgorithm(
                              _algorithmController.text),
                      period: _periodController.text.isEmpty
                          ? 30
                          : int.parse(_periodController.text),
                    );

                    Navigator.pop(context, entry);
                  },
                  // onPressed: () => Navigator.pop(context, entry),
                ),
                CupertinoButton(
                  onPressed: () {
                    _scanCode();
                  },
                  child: const Text('Scan Again'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String labelName, TextEditingController textController,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6.0),
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: textController,
                  obscureText: obscureText ? secretTextObscured : false,
                  keyboardType: keyboardType,
                  enabled: !(obscureText && secretTextObscured),
                ),
              ),
              obscureText
                  ? CupertinoButton(
                      child: Icon(
                        secretTextObscured
                            ? CupertinoIcons.eye_slash_fill
                            : CupertinoIcons.eye,
                      ),
                      onPressed: () {
                        setState(() {
                          secretTextObscured = !secretTextObscured;
                        });
                      },
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(PlatformException error) {
    if (error.code == "PERMISSION_DENIED") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Camera Permission Denied',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('Camera permission is needed to scan QR Codes.'),
          SizedBox(height: 10.0),
          CupertinoButton.filled(
            child: Text('Go to App Settings'),
            onPressed: AppSettings.openLocationSettings,
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(error.code, style: const TextStyle(fontWeight: FontWeight.bold)),
        error.message == null ? Container() : Text(error.message!),
      ],
    );
  }
}
