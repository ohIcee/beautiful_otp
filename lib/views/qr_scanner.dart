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
  String? _qrInfo = null;
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
    });
  }

  _scanCode() {
    setState(() {
      _camState = true;
    });
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
        children: [
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: Icon(CupertinoIcons.back),
            ),
          ),
          SizedBox(width: 20.0),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.pop(
                    context,
                    AuthEntry(
                        name: 'testname',
                        algorithm: OTPAlgorithm.SHA1,
                        customName: '',
                        digits: 6,
                        issuer: 'Amazon',
                        period: 30,
                        secret: 'testsecret'),
                  ),
                  child: const Icon(CupertinoIcons.ant_fill),
                ),
                const Text('Debug QR Code'),
                const SizedBox(width: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedQrCode() {
    if (_qrInfo == null) {
      return const Text('Nothing... This shouldn\'t ever be seen :o');
    }

    print(_qrInfo!);
    AuthEntry entry = AuthEntry.fromGauthString(_qrInfo!, false);
    _nameController.text = entry.name!;
    _secretController.text = entry.secret!;
    _issuerController.text = entry.issuer!;
    _digitsController.text = entry.digits?.toString() ?? "6";
    _algorithmController.text = entry.algorithm?.name ?? "SHA1";
    _periodController.text = entry.period?.toString() ?? "30";

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
          const SizedBox(height: 30.0),
          CupertinoButton(
            child: Row(
              children: [
                Icon(showAdvancedOptions
                    ? CupertinoIcons.chevron_down
                    : CupertinoIcons.chevron_up),
                SizedBox(width: 30.0),
                Text('Advanced Options'),
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
          SizedBox(height: 50.0),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom + 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton.filled(
                  child: const Text('Confirm'),
                  onPressed: () => Navigator.pop(context, entry),
                ),
                CupertinoButton(
                  onPressed: () {
                    setState(() {
                      _qrInfo = null;
                      _camState = true;
                    });
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

  Widget _buildTextField(String labelName, TextEditingController controller,
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
                  controller: controller,
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
