import 'package:arna/arna.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/providers.dart';
import '/strings.dart';
import '/utils/languages.dart';

class Languages extends ConsumerStatefulWidget {
  const Languages({
    super.key,
    required this.source,
  });

  final bool source;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LanguagesState();
}

class _LanguagesState extends ConsumerState<Languages> {
  late SharedPreferences preferences;
  TextEditingController controller = TextEditingController();
  final List<ArnaRadioListTile<String>> list = <ArnaRadioListTile<String>>[];
  final List<ArnaRadioListTile<String>> filteredList = <ArnaRadioListTile<String>>[];
  bool queryIsEmpty = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async => preferences = await SharedPreferences.getInstance();

  Future<void> search(String query, String groupValue) async {
    if (query.isEmpty) {
      queryIsEmpty = true;
      filteredList.clear();
      setState(() {});
      return;
    }
    if (query.isNotEmpty) {
      queryIsEmpty = false;
      filteredList.clear();
      languages.forEach((String key, String value) {
        if (languages[key]!.toLowerCase().contains(query.toLowerCase())) {
          filteredList.add(
            ArnaRadioListTile<String>(
              value: key,
              groupValue: groupValue,
              title: languages[key]!,
              onChanged: (String? value) async {
                if (widget.source) {
                  preferences.setString('source', value!);
                  ref.read(sourceProvider.notifier).state = value;
                } else {
                  preferences.setString('target', value!);
                  ref.read(targetProvider.notifier).state = value;
                }
                Navigator.pop(context);
              },
            ),
          );
        }
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final String groupValue = widget.source ? ref.watch(sourceProvider) : ref.watch(targetProvider);
    if (queryIsEmpty) {
      languages.forEach((String key, String value) {
        final ArnaRadioListTile<String> item = ArnaRadioListTile<String>(
          value: key,
          groupValue: groupValue,
          title: languages[key]!,
          onChanged: (String? value) async {
            if (widget.source) {
              preferences.setString('source', value!);
              ref.read(sourceProvider.notifier).state = value;
            } else {
              preferences.setString('target', value!);
              ref.read(targetProvider.notifier).state = value;
            }
            Navigator.pop(context);
          },
        );
        list.add(item);
        filteredList.add(item);
      });
    }

    return Column(
      children: <Widget>[
        ArnaSearchField(
          showSearch: true,
          controller: controller,
          onChanged: (String text) => search(text, groupValue),
          hintText: Strings.search,
        ),
        const ArnaDivider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ArnaList(
                  title: Strings.language,
                  showDividers: true,
                  showBackground: true,
                  children: filteredList,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
