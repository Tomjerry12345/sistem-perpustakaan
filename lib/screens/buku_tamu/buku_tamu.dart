import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as webFile;

class BukuTamu extends StatefulWidget {
  const BukuTamu({Key? key}) : super(key: key);

  @override
  State<BukuTamu> createState() => _BukuTamuState();
}

class _BukuTamuState extends State<BukuTamu> {
  final scrollController = ScrollController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final double sizeColumn = 200;

  List<QueryDocumentSnapshot>? allData;

  void onExport() {
    var l = [];
    allData!.forEach((e) {
      var noAnggota = e['no_anggota'].toString();
      var nama = e['nama'].toString();
      var alamat = e['alamat'].toString();

      final tanggal = e["tanggal"];
      final hari = tanggal["hari"];
      final bulan = tanggal["bulan"];
      final tahun = tanggal["tahun"];
      var date = "$hari/$bulan/$tahun";

      var pekerjaan = e['pekerjaan'].toString();
      var noHp = e['noHp'];

      l.add({
        "no_anggota": noAnggota,
        "nama": nama,
        "alamat": alamat,
        "date": date,
        "pekerjaan": pekerjaan,
        "noHp": noHp,
      });
    });
    var jsonString = jsonEncode(l);
    var blob = webFile.Blob([
      [jsonString]
    ], 'application/json', 'native');

    webFile.AnchorElement(
      href: webFile.Url.createObjectUrlFromBlob(blob).toString(),
    )
      ..setAttribute("download", "buku-tamu.json")
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore.collection("tamu").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            allData = snapshot.data!.docs;
            return Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 30, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Buku Tamu",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  textStyle: const TextStyle(fontSize: 16)),
                              onPressed: () {
                                onExport();
                              },
                              child: const Text(
                                'Export',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, bottom: 40, top: 15),
                    child: InteractiveViewer(
                      scaleEnabled: false,
                      // constrained: false,
                      child: Scrollbar(
                        controller: scrollController,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                              headingRowColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => Colors.blue.shade200),
                              columns: const [
                                DataColumn(label: Text("No anggota")),
                                DataColumn(label: Text("Nama")),
                                DataColumn(label: Text("Alamat")),
                                DataColumn(label: Text("Tanggal berkunjung")),
                                DataColumn(label: Text("Pekerjaan")),
                                DataColumn(label: Text("No Hp")),
                              ],
                              rows: List<DataRow>.generate(
                                  snapshot.data!.docs.length, (index) {
                                DocumentSnapshot data =
                                    snapshot.data!.docs[index];

                                final tanggal = data["tanggal"];
                                final hari = tanggal["hari"];
                                final bulan = tanggal["bulan"];
                                final tahun = tanggal["tahun"];

                                return DataRow(cells: [
                                  DataCell(SizedBox(
                                      width: sizeColumn,
                                      child: Text(data['no_anggota']))),
                                  DataCell(SizedBox(
                                      width: sizeColumn,
                                      child: Text(data['nama']))),
                                  DataCell(SizedBox(
                                      width: sizeColumn,
                                      child: Text(data['alamat']))),
                                  DataCell(SizedBox(
                                      width: sizeColumn,
                                      child: Text("$hari/$bulan/$tahun"))),
                                  DataCell(SizedBox(
                                      width: sizeColumn,
                                      child: Text(data['pekerjaan']))),
                                  DataCell(SizedBox(
                                      width: sizeColumn,
                                      child: Text(data['noHp']))),
                                ]);
                              })),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Expanded(
              child: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}
