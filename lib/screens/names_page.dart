import 'package:flutter/material.dart';
import 'package:proyecto_aa/screens/cara_page.dart';
import 'package:proyecto_aa/screens/reto_page.dart';
import 'package:proyecto_aa/screens/verdad_page.dart';
import 'package:textfield_tags/textfield_tags.dart';

class NamesPage extends StatefulWidget {
  final String titulo;
  const NamesPage({super.key, required this.titulo});

  @override
  State<NamesPage> createState() => _NamesPageState();
}

class _NamesPageState extends State<NamesPage> {
  late double _distanceToField;
  late StringTagController _tagsController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    super.initState();
    _tagsController = StringTagController();
    _tagsController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

  void _onStartGame() {
    final jugadores = _tagsController.getTags ?? [];
    if (jugadores.isNotEmpty && widget.titulo == "Cubata o Reto") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RetoPage(jugadores: jugadores)),
      );
    } else if (jugadores.isNotEmpty && widget.titulo == "Cubata o Verdad") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VerdadPage(jugadores: jugadores)),
      );
    } else if (jugadores.isNotEmpty &&
        widget.titulo == "Que cara pondrías si") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CaraPage(jugadores: jugadores)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añade jugadores'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFieldTags<String>(
              textfieldTagsController: _tagsController,
              initialTags: const [],
              textSeparators: const [' ', ','],
              letterCase: LetterCase.normal,
              validator: (tag) {
                if (tag.trim().isEmpty) return 'No puede estar vacío';
                if ((_tagsController.getTags ?? []).contains(tag))
                  return 'Ya existe';
                return null;
              },
              inputFieldBuilder: (context, values) {
                return TextField(
                  controller: values.textEditingController,
                  focusNode: values.focusNode,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: values.tags.isEmpty
                        ? 'Escribe un jugador y pulsa Enter'
                        : '',
                    errorText: values.error,
                    prefixIcon: values.tags.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: values.tagScrollController,
                            child: Row(
                              children: values.tags.map((tag) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(tag,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () => values.onTagRemoved(tag),
                                        child: const Icon(
                                          Icons.cancel,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : null,
                  ),
                  onChanged: values.onTagChanged,
                  onSubmitted: (text) => values.onTagSubmitted(text),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_tagsController.getTags?.isNotEmpty ?? false)
                  ? _onStartGame
                  : null,
              child: const Text('Comenzar juego'),
            ),
          ],
        ),
      ),
    );
  }
}
