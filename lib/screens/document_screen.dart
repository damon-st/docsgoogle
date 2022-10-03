import 'dart:async';

import 'package:docsgoogle/common/widgets/loader.dart';
import 'package:docsgoogle/constants/colors.dart';
import 'package:docsgoogle/models/document_model.dart';
import 'package:docsgoogle/models/error_model.dart';
import 'package:docsgoogle/repository/auth_repository.dart';
import 'package:docsgoogle/repository/document_repository.dart';
import 'package:docsgoogle/repository/socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({Key? key, required this.id}) : super(key: key);

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final TextEditingController titleController =
      TextEditingController(text: "Untitled Document");

  quill.QuillController? _controller;
  ErrorModel? errorModel;

  SocketRepository socketRepository = SocketRepository();
  StreamSubscription<dynamic>? subQuill;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();

    socketRepository.changeListener((data) {
      _controller?.compose(
          quill.Delta.fromJson(data["delta"]),
          _controller?.selection ?? const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.REMOTE);
    });

    if (timer?.isActive ?? false) timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave({
        "delta": _controller?.document.toDelta(),
        "room": widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

    if (errorModel?.data != null) {
      DocumentModel document = errorModel!.data as DocumentModel;
      titleController.text = document.title;
      _controller = quill.QuillController(
          selection: const TextSelection.collapsed(offset: 0),
          document: document.content.isEmpty
              ? quill.Document()
              : quill.Document.fromDelta(
                  quill.Delta.fromJson(document.content)));
      if (!mounted) return;
      setState(() {});
    }

    subQuill = _controller!.document.changes.listen((event) {
      //1 DELTA entire conent of document
      //2 DELTA changes that are made from the previous part
      //3 local ? we have typed
      if (event.item3 == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {
          "delta": event.item2,
          "room": widget.id,
        };
        socketRepository.typing(map);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller?.dispose();
    titleController.dispose();
    subQuill?.cancel();
    super.dispose();
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateTitle(
        token: ref.read(userProvider)!.token, id: widget.id, title: title);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_controller == null) {
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kColorsWhite,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                        text: "http://localhost:3000/#/document/${widget.id}"))
                    .then((value) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Copy Link")));
                });
              },
              icon: const Icon(
                Icons.lock,
                size: 16,
              ),
              label: const Text(
                "Share",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kColorsBlue,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                color: kColorsGrey,
                width: 0.1,
              )),
            )),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 9.0,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Routemaster.of(context).replace("/");
                },
                child: Image.asset(
                  "assets/docs-logo.png",
                  height: 40,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: size.width * .2,
                child: TextField(
                  onSubmitted: (c) {
                    updateTitle(ref, c);
                  },
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: kColorsBlue,
                    )),
                    contentPadding: EdgeInsets.only(
                      left: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            quill.QuillToolbar.basic(controller: _controller!),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: SizedBox(
                width: size.width * .75,
                child: Card(
                  color: kColorsWhite,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor.basic(
                      controller: _controller!,
                      readOnly: false, // true for view only mode
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
