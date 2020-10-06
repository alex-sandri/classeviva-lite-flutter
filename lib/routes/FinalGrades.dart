import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaFinalGrade.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableView.dart';
import 'package:classeviva_lite/widgets/classeviva_webview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinalGrades extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClasseVivaRefreshableView<List<ClasseVivaFinalGrade>>(
      title: "Scrutini",
      stream: () => ClasseViva.current.getFinalGrades(),
      builder: (finalGrades) {
        return ListView.builder(
          itemCount: finalGrades.length,
          itemBuilder: (context, index) {
            final ClasseVivaFinalGrade item = finalGrades[index];

            return ListTile(
              title: Text(item.type),
              onTap: () => Get.to(ClasseVivaWebview(
                title: item.type,
                url: Uri.parse(item.url),
              )),
            );
          },
        );
      },
      isResultEmpty: (result) => result.isEmpty,
      emptyResultMessage: "Non sono presenti documenti",
    );
  }
}