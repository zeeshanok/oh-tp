import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> msgs = [];

  Future<List<String>> getSMS() async {
    if (await Permission.sms.request().isGranted) {
      final query = SmsQuery();
      final msgs = await query
          .querySms(kinds: [SmsQueryKind.inbox], count: 8, sort: true);
      return msgs.map((e) => "${e.date} ${e.address}").toList();
    } else {
      throw Exception("permission to read sms wasnt granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Get sms"),
              onPressed: () async {
                final result = await getSMS();
                setState(() {
                  msgs = result;
                });
              },
            ),
            for (final msg in msgs)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(msg),
              )
          ],
        ),
      ),
    );
  }
}
