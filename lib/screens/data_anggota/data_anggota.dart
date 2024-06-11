import 'dart:convert';

import 'package:admin_perpustakaan/services/FirebaseServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as webFile;

class DataAnggota extends StatefulWidget {
  const DataAnggota({Key? key}) : super(key: key);

  @override
  State<DataAnggota> createState() => _DataAnggotaState();
}

class _DataAnggotaState extends State<DataAnggota> {
  FirebaseServices fs = FirebaseServices();

  List<QueryDocumentSnapshot>? allData;

  void onExport() {
    var l = [];
    allData!.forEach((e) {
      var noAnggota = e['no_anggota'].toString();
      var nama = e['nama'].toString();
      var email = e['email'].toString();
      var pekerjaan = e['pekerjaan'].toString();
      var alamat = e['alamat'].toString();
      var hp = e['hp'];
      var ibuKandung = e['ibu_kandung'];
      var nohpIbuKandung = e['no_hp_ibu_kandung'];

      l.add({
        "no_anggota": noAnggota,
        "nama": nama,
        "email": email,
        "pekerjaan": pekerjaan,
        "alamat": alamat,
        "hp": hp,
        "ibu_kandung": ibuKandung,
        "no_hp_ibu_kandung": nohpIbuKandung,
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
        stream: fs.getAllStream("users"),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            allData = snapshot.data!.docs;
            return Expanded(
              child: SingleChildScrollView(
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
                            "Data Anggota",
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
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                                headingRowColor:
                                    MaterialStateProperty.resolveWith(
                                        (states) => Colors.blue.shade200),
                                columns: const [
                                  DataColumn(label: Text("No Anggota")),
                                  DataColumn(label: Text("Nama")),
                                  DataColumn(label: Text("Email")),
                                  DataColumn(label: Text("Pekerjaan")),
                                  DataColumn(label: Text("Alamat")),
                                  DataColumn(label: Text("No Hp")),
                                  DataColumn(label: Text("Nama Ibu")),
                                  DataColumn(label: Text("No Hp Ibu")),
                                ],
                                rows: List<DataRow>.generate(
                                    snapshot.data!.docs.length, (index) {
                                  DocumentSnapshot data =
                                      snapshot.data!.docs[index];

                                  return DataRow(cells: [
                                    DataCell(Text(data['no_anggota'])),
                                    DataCell(Text(data['nama'])),
                                    DataCell(Text(data['email'])),
                                    DataCell(Text(data['pekerjaan'])),
                                    DataCell(Text(data['alamat'])),
                                    DataCell(Text(data['hp'])),
                                    DataCell(Text(data['ibu_kandung'])),
                                    DataCell(Text(data['no_hp_ibu_kandung'])),
                                  ]);
                                })),
                          ),
                          //Now let's set the pagination
                          const SizedBox(
                            height: 40.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
