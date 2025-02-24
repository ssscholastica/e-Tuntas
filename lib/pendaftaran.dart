import 'package:flutter/material.dart';

class Pendaftaran extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: SignUpForm1(),
      ),
    );
  }
}

class SignUpForm1 extends StatefulWidget {
  @override
  State<SignUpForm1> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm1> {
  String? errorMessage;

  TextEditingController firstnamecontroller = TextEditingController();
  TextEditingController lastnamecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController confirmcontroller = TextEditingController();
  TextEditingController findcontroller = TextEditingController();
  TextEditingController campuscontroller = TextEditingController();
  TextEditingController majorcontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 414,
      height: 932,
      color: Colors.white,
      child: Stack(children: [
        Positioned(
          left: 32,
          top: 5,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  width: 370,
                  height: 40,
                  child: Text(
                    'Pendaftaran',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                    width: 370,
                    height: 50,
                    child: Text(
                        'Lengkapi form pendaftaran berikut untuk masuk kedalam sistem',
                        style: TextStyle(color: Colors.black, fontSize: 15)))
              ],
            ),
          ),
        ),
        Positioned(
            top: 130,
            left: 32,
            child: SizedBox(
                width: 290,
                child: Text(
                  'Data Penerima',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ))),
        Positioned(
          left: 32,
          top: 102,
          child: SizedBox(
            width: 290,
            child: Text(
              'Nama Pendaftar',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 133,
          child: Container(
            width: 343,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(width: 0.50, color: Color(0xFF828282)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextFormField(),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 214,
          child: SizedBox(
            width: 290,
            child: Text(
              'Email',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 245,
          child: Container(
            width: 343,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(width: 0.50, color: Color(0xFF828282)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextFormField(
                onSaved: (value) {
                  firstnamecontroller.text = value!;
                },
                controller: firstnamecontroller,
                showCursor: true,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 326,
          child: SizedBox(
            width: 290,
            child: Text(
              'Alamat',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 357,
          child: Container(
            width: 343,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(width: 0.50, color: Color(0xFF828282)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextFormField(
                onSaved: (value) {
                  lastnamecontroller.text = value!;
                },
                controller: lastnamecontroller,
                showCursor: true,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 438,
          child: SizedBox(
            width: 290,
            child: Text(
              'Tanggal lahir',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 469,
          child: Container(
            width: 343,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(width: 0.50, color: Color(0xFF828282)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextFormField(
                onSaved: (value) {
                  passwordcontroller.text = value!;
                },
                controller: passwordcontroller,
                showCursor: true,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                decoration: InputDecoration(border: InputBorder.none),
                obscureText: true,
              ),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 550,
          child: SizedBox(
            width: 290,
            child: Text(
              'Nomor HP',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 581,
          child: Container(
            width: 343,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(width: 0.50, color: Color(0xFF828282)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextFormField(
                onSaved: (value) {
                  confirmcontroller.text = value!;
                },
                controller: confirmcontroller,
                showCursor: true,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                decoration: InputDecoration(border: InputBorder.none),
                obscureText: true,
              ),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 662,
          child: SizedBox(
            width: 290,
            child: Text(
              'PG/Unit Terakhir Dinas',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Positioned(
          left: 32,
          top: 717,
          child: Container(
            width: 343,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(width: 0.50, color: Color(0xFF828282)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextFormField(
                validator: (value) {
                  if (_formKey.currentState!.validate()) {
                    return ("This cannot be Empty");
                  }
                  return null;
                },
                onSaved: (value) {
                  findcontroller.text = value!;
                },
                controller: findcontroller,
                showCursor: true,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ),
        Positioned(
          left: 332,
          top: 845,
          child: SizedBox(
            width: 112,
            child: Text(
              'Step 1 of 2',
              style: TextStyle(
                color: Color(0xFF828282),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
          ),
        ),
        Positioned(
          left: 207,
          top: 868,
          child: Container(
            width: 196,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Color(0xFF828282),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          top: 868,
          child: Container(
            width: 197,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Color(0xFFF6AF1F),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 287,
          top: 877,
          child: GestureDetector(
            // onTap: () {
            //   uploadData();
            // },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 94.95,
                  height: 37,
                  decoration: ShapeDecoration(
                    color: Color(0xFF0B1F56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
