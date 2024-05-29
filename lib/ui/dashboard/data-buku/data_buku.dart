import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:perpustakaan_mobile/services/FirebaseServices.dart';
import 'package:perpustakaan_mobile/services/SharedPreferencesServices.dart';
import 'package:perpustakaan_mobile/ui/dashboard/data-buku/section/view-pdf/view_pdf.dart';

import 'package:flutter/foundation.dart';
import 'package:perpustakaan_mobile/utils/Time.dart';
import 'package:perpustakaan_mobile/utils/Utils.dart';
import 'package:perpustakaan_mobile/utils/log_utils.dart';
import 'package:perpustakaan_mobile/utils/position.dart';
import 'package:perpustakaan_mobile/utils/show_utils.dart';
import 'package:perpustakaan_mobile/widget/text/text_widget.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;

import '../../../model/ModelQuery.dart';
import '../../../utils/navigate_utils.dart';

class DataBuku extends StatefulWidget {
  final DocumentSnapshot? data;

  const DataBuku({Key? key, this.data}) : super(key: key);

  @override
  State<DataBuku> createState() => _DataBukuState();
}

class _DataBukuState extends State<DataBuku> {
  final firebaseServices = FirebaseServices();
  final time = Time();
  int? sisaPeminjaman;

  final preferences = SharedPreferencesServices();

  String email = "";
  String noAnggota = "";

  @override
  initState() {
    super.initState();
    getEmail();
    getSisaPeminjaman();
  }

  Future<void> getEmail() async {
    await preferences.init();
    final noAnggota = preferences.getString("no_anggota");
    final qUsers = await firebaseServices.queryFuture(
        "users", [ModelQuery(key: "no_anggota", value: noAnggota)]);
    final dataUser = qUsers.docs[0].data();
    setState(() {
      email = dataUser["email"];
      this.noAnggota = noAnggota;
    });
  }

  Future<void> getSisaPeminjaman() async {
    final time = Time();
    final dataPeminjaman = await firebaseServices
        .queryFuture("peminjaman", [ModelQuery(key: "email", value: email)]);

    for (final dataP in dataPeminjaman.docs) {
      final dt = dataP.data();
      if (dt["barcode"] == widget.data!["barcode"]) {
        if (dt['konfirmasi']) {
          final tanggalPeminjaman =
              dt['tanggal_pengembalian'].toString().split("-");
          final datePeminjaman = int.parse(tanggalPeminjaman[2]);
          final monthPeminjaman = int.parse(tanggalPeminjaman[1]);
          final yearPeminjaman = int.parse(tanggalPeminjaman[0]);

          int sisaHariNow = time.getJumlahHariDate(
              yearPeminjaman, monthPeminjaman, datePeminjaman);

          if (sisaHariNow == 0) {
            sisaHariNow = 1;
          } else if (sisaHariNow < 0) {
            sisaHariNow = sisaHariNow.abs();
          }
          log("sisaHariNow", v: sisaHariNow);
          setState(() {
            sisaPeminjaman = sisaHariNow;
          });
        }
        break;
      }
    }
  }

  void onPinjamBuku() async {
    final qUsers = await firebaseServices.queryFuture(
        "users", [ModelQuery(key: "no_anggota", value: noAnggota)]);
    final dataUser = qUsers.docs[0].data();

    final dataPeminjaman = await firebaseServices.queryFuture(
        "peminjaman", [ModelQuery(key: "email", value: dataUser["email"])]);

    bool isDuplicated = false;

    for (final dataP in dataPeminjaman.docs) {
      final dt = dataP.data();
      if (dt["barcode"] == widget.data!["barcode"]) {
        isDuplicated = true;
        break;
      }
    }

    if (!isDuplicated) {
      final sizeDataPeminjaman = dataPeminjaman.size;

      if (sizeDataPeminjaman < 3) {
        var getDate = time.getDateByRange(14);

        final tanggalPengembalian =
            "${time.getYear()}-${getDate[1]}-${getDate[0]}";
        final data = <String, dynamic>{
          "nama_peminjam": dataUser["nama"],
          "email": dataUser["email"],
          "judul_buku": widget.data!["judul_buku"],
          "pengarang": widget.data!["pengarang"],
          "image": widget.data!["image"],
          "rak": widget.data!["rak"],
          "konfirmasi": true,
          "type_peminjaman": "online",
          "barcode": widget.data!["barcode"],
          "tanggal_peminjaman": time.getTimeNow(),
          "tanggal_pengembalian": tanggalPengembalian,
          "buku": widget.data!["buku"]
        };

        firebaseServices.add("peminjaman", data);

        Utils.showSnackBar("Berhasil", Colors.green);

        navigatePop();
      } else {
        Utils.showSnackBar(
            "Batas peminjaman buku tidak boleh lebih dari 3", Colors.red);
      }
    } else {
      Utils.showSnackBar("Buku sudah di pinjam", Colors.red);
    }
  }

  Future<void> readBookWithAudio() async {
    final client = http.Client();
    final uri = Uri.parse(widget.data!["buku"]);

    try {
      final http.StreamedResponse response =
          await client.send(http.Request('GET', uri));
      final totalBytes = response.contentLength;
      var bytesReceived = 0;

      final List<int> buffer = <int>[];
      await for (final List<int> chunk in response.stream) {
        buffer.addAll(chunk);
        bytesReceived += chunk.length;

        if (totalBytes != null) {
          log("progress", v: bytesReceived / totalBytes);
          // setState(() {
          //   _progress = bytesReceived / totalBytes;
          // });
        }
      }

      // Once download is complete, you can proceed with processing the PDF
      // For example:
      final documentBytes = Uint8List.fromList(buffer);
      // Now you have the bytes of the downloaded PDF in documentBytes

      //   log("first", v: widget.data!["buku"]);

      // final documentBytes = await http.readBytes(Uri.parse(widget.data!["buku"]));

      // log("documentBytes");
      PdfDocument document = PdfDocument(inputBytes: documentBytes);

      PdfTextExtractor extractor = PdfTextExtractor(document);

      String text = extractor.extractText();
      log("text", v: text);
    } catch (e) {
      log("error", v: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          title: const Center(
            child: Text(
              'Data Buku',
              style: TextStyle(color: Colors.white),
            ),
          ),
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(Icons.search),
          //     onPressed: () {},
          //   ),
          // ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xff0096ff), Color(0xff6610f2)],
                  begin: FractionalOffset.bottomLeft,
                  end: FractionalOffset.bottomRight),
            ),
          ),
        ),
        body: Container(
            margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Wrap(
                spacing: 5.0,
                runSpacing: 4.0,
                direction: Axis.horizontal,
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.only(top: 5, right: 10),
                      // height: 140,
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            widget.data!["image"],
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                          H(8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.book),
                                  H(8),
                                  SizedBox(
                                      width: 150,
                                      child: TextWidget(
                                        widget.data!["judul_buku"],
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ),
                              V(8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.person),
                                  H(8),
                                  SizedBox(
                                      width: 150,
                                      child: TextWidget(
                                        widget.data!["pengarang"],
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ),
                              V(8),
                              Row(
                                children: [
                                  const Icon(Icons.barcode_reader),
                                  H(8),
                                  SizedBox(
                                      width: 150,
                                      child: TextWidget(
                                        widget.data!["barcode"],
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ),
                            ],
                          )
                        ],
                      )),
                  V(16),
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        child: Wrap(
                          children: [
                            Column(
                              children: [
                                Wrap(
                                  spacing: 15,
                                  children: [
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      padding: const EdgeInsets.all(8),
                                      height: 130,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.blue, width: 2),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                      ),
                                      child: SingleChildScrollView(
                                        child: Text(
                                          widget.data!["sinopsis"],
                                          style: const TextStyle(height: 1.5),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      child: Wrap(
                                        spacing: 15,
                                        direction: Axis.vertical,
                                        children: [
                                          Text(
                                            'Tanggal Terbit: ${DateFormat("dd MMMM yyyy").format(widget.data!["tanggal"].toDate())}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Jumlah Halaman: ${widget.data!["halaman"]}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Rak Buku: ${widget.data!["rak"]}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(3),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              sisaPeminjaman == null
                                                  ? Colors.blue
                                                  : const Color.fromARGB(
                                                      255, 137, 136, 136),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                        ),
                                        child: TextWidget(
                                          sisaPeminjaman == null
                                              ? "Ringkasan Buku"
                                              : "Sisa peminjaman: $sisaPeminjaman Hari",
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          navigatePush(ViewPdf(
                                              path: widget.data!["buku"],
                                              judul: widget.data!["judul_buku"],
                                              isPinjam:
                                                  sisaPeminjaman != null));
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(3),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                        ),
                                        onPressed: readBookWithAudio,
                                        child: const TextWidget(
                                          "Baca buku dengan audio",
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    sisaPeminjaman == null
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 15),
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(3),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20),
                                              ),
                                              child: const TextWidget(
                                                "Pinjam Buku",
                                                color: Colors.black,
                                              ),
                                              onPressed: () async {
                                                AlertDialog alert = AlertDialog(
                                                  title: const Text("Meminjam"),
                                                  content: const Text(
                                                      "Apakah anda yakin ingin meminjam buku?"),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: () async {
                                                          onPinjamBuku();
                                                        },
                                                        child:
                                                            const Text("Ok")),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          navigatePop();
                                                        },
                                                        child: const Text(
                                                            "Batal")),
                                                  ],
                                                );
                                                dialogShow(
                                                    context: context,
                                                    widget: alert);
                                              },
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ])));
  }
}
