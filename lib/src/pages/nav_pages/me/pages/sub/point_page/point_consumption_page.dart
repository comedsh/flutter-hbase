import 'package:flutter/material.dart';

class PaginatedDataTableDemo extends StatefulWidget {
  const PaginatedDataTableDemo({super.key});

  @override
  State<PaginatedDataTableDemo> createState() => _PaginatedDataTableDemoState();
}

class _PaginatedDataTableDemoState extends State<PaginatedDataTableDemo> {
  late MyDataSource _dataSource;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  bool _sortAscending = true;
  int? _sortColumnIndex;

  @override
  void initState() {
    super.initState();
    _dataSource = MyDataSource();
  }

  void _sort<T>(
      Comparable<T> Function(MyData d) getField, int columnIndex, bool ascending) {
    _dataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PaginatedDataTable Demo'),
      ),
      body: SingleChildScrollView(
        child: PaginatedDataTable(
          header: const Text('User Data'),
          rowsPerPage: _rowsPerPage,
          onRowsPerPageChanged: (int? value) {
            setState(() {
              _rowsPerPage = value!;
            });
          },
          sortAscending: _sortAscending,
          sortColumnIndex: _sortColumnIndex,
          columns: [
            DataColumn(
              label: const Text('ID'),
              onSort: (columnIndex, ascending) =>
                  _sort<num>((d) => d.id, columnIndex, ascending),
            ),
            DataColumn(
              label: const Text('Name'),
              onSort: (columnIndex, ascending) =>
                  _sort<String>((d) => d.name, columnIndex, ascending),
            ),
            DataColumn(
              label: const Text('Age'),
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort<num>((d) => d.age, columnIndex, ascending),
            ),
          ],
          source: _dataSource,
        ),
      ),
    );
  }
}

class MyData {
  final int id;
  final String name;
  final int age;

  MyData({required this.id, required this.name, required this.age});
}

class MyDataSource extends DataTableSource {
  final List<MyData> _data = List.generate(
    20,
    (index) => MyData(
      id: index,
      name: 'User ${index + 1}',
      age: 20 + index % 10,
    ),
  );

  void sort<T>(Comparable<T> Function(MyData d) getField, bool ascending) {
    _data.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final row = _data[index];
    return DataRow(
      cells: [
        DataCell(Text(row.id.toString())),
        DataCell(Text(row.name)),
        DataCell(Text(row.age.toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}