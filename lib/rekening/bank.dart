import 'package:etuntas/profile/profile.dart';
import 'package:etuntas/rekening/addBank.dart';
import 'package:flutter/material.dart';

class Bank extends StatefulWidget {
  const Bank({super.key});

  @override
  State<Bank> createState() => _BankState();
}

class _BankState extends State<Bank> {
  List<Map<String, String>> bankAccounts = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 80, left: 20, right: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Profile()),
                      );
                    },
                    child: Image.asset(
                      'assets/simbol back.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const Text(
                    "Akun Bank",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0XFF000000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 50, right: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Rekening Saya",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                      const Text(
                        " (Maksimal 3)",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(width: 69),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => addBank()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: bankAccounts.length,
                      itemBuilder: (context, index) {
                        final bank = bankAccounts[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.account_balance,
                                color: Colors.blue),
                            title: Text(bank['bankName'] ?? ''),
                            subtitle: Text(bank['accountOwner'] ?? ''),
                          ),
                        );
                      },
                    ),
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
