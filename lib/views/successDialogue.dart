import 'package:flutter/material.dart';

class SuccessDialogExample extends StatefulWidget {
  const SuccessDialogExample({super.key});

  @override
  _SuccessDialogExampleState createState() => _SuccessDialogExampleState();
}

class _SuccessDialogExampleState extends State<SuccessDialogExample> {
  bool _isLoading = false;

  void _showSuccessDialog() {
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.red.shade100,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Completed Successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Success! Your account has been created. Please wait a moment as we prepare everything for you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ],
          ),
        );
      },
    );

    // Simulate a delay and close the dialog
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success Dialog Example'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _showSuccessDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Submit',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
