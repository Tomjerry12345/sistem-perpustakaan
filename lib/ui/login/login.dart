import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:local_auth/local_auth.dart';
import 'package:perpustakaan_mobile/model/ModelQuery.dart';
import 'package:perpustakaan_mobile/services/FirebaseServices.dart';
import 'package:perpustakaan_mobile/services/SharedPreferencesServices.dart';
import 'package:perpustakaan_mobile/ui/registrasi/registrasi.dart';
import 'package:perpustakaan_mobile/utils/Utils.dart';
// import 'package:perpustakaan_mobile/utils/log_utils.dart';
// import 'package:perpustakaan_mobile/utils/log_utils.dart';
import 'package:perpustakaan_mobile/utils/navigate_utils.dart';
import 'package:perpustakaan_mobile/utils/position.dart';
import 'package:perpustakaan_mobile/widget/text/text_widget.dart';
import 'package:perpustakaan_mobile/widget/textfield/textfield_component.dart';
import 'package:perpustakaan_mobile/widget/textfield/textfield_password_component.dart';
import 'package:perpustakaan_mobile/ui/dashboard/bottom_nav.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final noAnggotaController = TextEditingController();
  final passwordController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();
  final fs = FirebaseServices();

  final preference = SharedPreferencesServices();

  @override
  void dispose() {
    noAnggotaController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            V(68),
            SizedBox(
              width: double.infinity,
              height: 100,
              child: Image.asset("assets/images/logo.png"),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "LOGIN",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 24,
                  color: HexColor("#017DC3"),
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextfieldComponent(
                    label: 'No. Anggota',
                    controller: noAnggotaController,
                    inputType: TextInputType.number,
                    colorText: Colors.blue,
                  ),
                  V(32),
                  TextfieldPasswordComponent(
                      label: "Password",
                      controller: passwordController,
                      colorText: Colors.blue)
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2BB1EB),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const TextWidget(
                  "Masuk",
                  color: Colors.white,
                ),
                onPressed: () {
                  signIn();
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Tidak Punya Kartu Anggota ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Registrasi()),
                      );
                    },
                    child: const Text(
                      "Daftar",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      final noAnggota = noAnggotaController.text.trim();
      final password = passwordController.text.trim();

      preference.init();

      var res = await fs.queryFuture("users", [
        ModelQuery(key: "no_anggota", value: noAnggota),
        ModelQuery(key: "password", value: password),
      ]);

      if (res.size > 0) {
        preference.setString('no_anggota', noAnggota);
        navigatePush(const BottomNav(), isRemove: true);
      } else {
        throw Exception("No anggota / kata sandi salah");
      }

      // log("res", v: res.size);

      // await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: noAnggota,
      //   password: password,
      // );
      // navigatorKey.currentState!.popUntil((route) => route.isFirst);
      // navigatePush(const FaceAutentikasi(), isRemove: true);
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Utils.showSnackBar(e.message, Colors.red);
    } on Exception catch (e) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Utils.showSnackBar(e.toString(), Colors.red);
    }
  }
}
