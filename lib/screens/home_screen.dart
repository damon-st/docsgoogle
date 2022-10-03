import 'package:docsgoogle/common/widgets/loader.dart';
import 'package:docsgoogle/constants/colors.dart';
import 'package:docsgoogle/models/document_model.dart';
import 'package:docsgoogle/models/error_model.dart';
import 'package:docsgoogle/repository/auth_repository.dart';
import 'package:docsgoogle/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void sigOut(
    WidgetRef ref,
  ) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(WidgetRef ref, BuildContext context) async {
    String token = ref.read(userProvider)?.token ?? "";
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);
    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);
    if (errorModel.data != null) {
      navigator.push("/document/${errorModel.data.id}");
    } else {
      snackbar.showSnackBar(
        SnackBar(
          content: Text("Error ${errorModel.error}"),
        ),
      );
    }
  }

  void navigateToDocument(BuildContext context, String documentId) {
    final navigator = Routemaster.of(context);
    navigator.push("/document/$documentId");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kColorsWhite,
          actions: [
            IconButton(
                onPressed: () {
                  createDocument(ref, context);
                },
                icon: const Icon(
                  Icons.add,
                  color: kColorsBlack,
                )),
            IconButton(
                onPressed: () {
                  sigOut(ref);
                },
                icon: const Icon(
                  Icons.logout,
                  color: kColorsRed,
                )),
          ],
        ),
        body: FutureBuilder<ErrorModel>(
            future:
                ref.watch(documentRepositoryProvider).getDocuments(user!.token),
            builder: (c, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              if (s.hasData && s.data?.data == null) {
                return const SizedBox();
              }
              return Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: size.width * .6,
                  child: ListView.builder(
                      itemCount: (s.data!.data as List).length,
                      itemBuilder: (c, index) {
                        DocumentModel doc = s.data!.data[index];
                        return InkWell(
                          onTap: () {
                            navigateToDocument(context, doc.id);
                          },
                          child: SizedBox(
                            height: 50,
                            child: Card(
                              child: Center(
                                child: Text(
                                  doc.title,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              );
            }));
  }
}
