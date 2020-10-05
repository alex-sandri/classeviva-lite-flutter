import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaBook.dart';
import 'package:classeviva_lite/routes/Book.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Books extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClasseVivaRefreshableView<List<ClasseVivaBook>>(
      title: "Libri",
      stream: () => ClasseViva.current.getBooks(),
      builder: (books) {
        return ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final ClasseVivaBook book = books[index];

            return ListTile(
              title: Text(book.title),
              onTap: () => Get.to(Book(book)),
            );
          },
        );
      },
      isResultEmpty: (result) => result.isEmpty,
      emptyResultMessage: "Non sono presenti libri",
    );
  }
}