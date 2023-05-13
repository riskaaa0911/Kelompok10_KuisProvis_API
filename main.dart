import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

class JenisPinjaman {
  String nama;
  String id;

  JenisPinjaman({required this.nama, required this.id});
}

class PinjamanData {
  List<JenisPinjaman> pinjaman = <JenisPinjaman>[];

  PinjamanData(Map<String, dynamic> json) {
    var data = json["data"];
    for (var item in data) {
      var nama = item["nama"];
      var id = item["id"];
      pinjaman.add(JenisPinjaman(nama: nama, id: id));
    }
  }

  factory PinjamanData.fromJson(Map<String, dynamic> json) {
    return PinjamanData(json);
  }
}

class PinjamanCubit extends Cubit<List<JenisPinjaman>> {
  PinjamanCubit() : super([]);

  fetchData(String country) async {
    String url = '';
    if (country == 'Jenis Pinjaman 1') {
      url = 'http://178.128.17.76:8000/jenis_pinjaman/1';
    } else if (country == 'Jenis Pinjaman 2') {
      url = 'http://178.128.17.76:8000/jenis_pinjaman/2';
    } else if (country == 'Jenis Pinjaman 3') {
      url = 'http://178.128.17.76:8000/jenis_pinjaman/3';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var pinjaman = PinjamanData.fromJson(jsonData).pinjaman;
      emit(pinjaman);
    } else {
      throw Exception('Failed to load data');
    }
  }
}

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<PinjamanCubit>(
          create: (context) => PinjamanCubit()..fetchData('Jenis Pinjaman 1'),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String selectedCountry = 'Jenis Pinjaman 1';

  @override
  Widget build(BuildContext context) {
    final universityCubit = context.read<PinjamanCubit>();

    return MaterialApp(
      title: 'University Data',
      home: Scaffold(
        appBar: AppBar(
          title: Text('My App P2P'),
        ),
        body: Column(
          children: [
            Text(
                '1901377,Afina Rahmani; 2109103,Riska Nurohmah; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedCountry,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue!;
                    universityCubit.fetchData(
                        selectedCountry); // Fetch data for the selected country
                  });
                },
                items: <String>[
                  'Jenis Pinjaman 1',
                  'Jenis Pinjaman 2',
                  'Jenis Pinjaman 3'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            BlocBuilder<PinjamanCubit, List<JenisPinjaman>>(
              builder: (context, pinjaman) {
                if (pinjaman.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: pinjaman.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            onTap: () {},
                            leading: Image.network(
                                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                            trailing: const Icon(Icons.more_vert),
                            title: Text(pinjaman[index].nama),
                            subtitle: Text("id:${pinjaman[index].id}"),
                            tileColor: Colors.white70);
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
