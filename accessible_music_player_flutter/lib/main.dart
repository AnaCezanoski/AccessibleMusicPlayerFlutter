import 'package:flutter/material.dart';

void main() {
  runApp(const AccessibleMusicPlayerApp());
}

class AccessibleMusicPlayerApp extends StatelessWidget {
  const AccessibleMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DB954), // verde Spotify
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const PlayerScreen(),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool isPlaying = false;
  bool isLiked = false;
  double progress = 0.25; // 25%

  final FocusNode prevFocus = FocusNode(debugLabel: 'Anterior');
  final FocusNode playPauseFocus = FocusNode(debugLabel: 'Reproduzir/Pausar');
  final FocusNode nextFocus = FocusNode(debugLabel: 'Próximo');
  final FocusNode likeFocus = FocusNode(debugLabel: 'Gostar');

  @override
  void dispose() {
    prevFocus.dispose();
    playPauseFocus.dispose();
    nextFocus.dispose();
    likeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Music Player'),
      ),
      body: SafeArea(
        child: Semantics(
          label: 'Tela de player de música com capa do álbum, título, artista, barra de progresso e controles.',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final horizontalPadding = width < 380 ? 12.0 : 20.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Capa do álbum Scorpion
                    Semantics(
                      label: 'Capa do álbum Scorpion do Drake',
                      image: true,
                      child: ExcludeSemantics(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              'https://upload.wikimedia.org/wikipedia/en/9/90/Scorpion_by_Drake.jpg',
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade900,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade900,
                                  alignment: Alignment.center,
                                  child: const Text('Imagem não disponível'),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Título e artista
                    Semantics(
                      container: true,
                      label: 'Informações da música',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nonstop',
                            style: theme.textTheme.titleLarge,
                            softWrap: true,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Drake',
                            style: theme.textTheme.titleMedium,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Barra de progresso
                    Semantics(
                      label: 'Progresso da música',
                      increasedValue: '${((progress + 0.01).clamp(0.0, 1.0) * 100).round()} por cento',
                      decreasedValue: '${((progress - 0.01).clamp(0.0, 1.0) * 100).round()} por cento',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Slider(
                            value: progress,
                            min: 0,
                            max: 1,
                            divisions: 100,
                            label: '${(progress * 100).round()}%'.toString(),
                            semanticFormatterCallback: (value) =>
                                'Progresso da música, ${(value * 100).round()} por cento',
                            onChanged: (v) => setState(() => progress = v),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatTime(progress * _durationSeconds), semanticsLabel: 'Tempo decorrido ${_formatTime(progress * _durationSeconds)}'),
                              Text(_formatTime(_durationSeconds), semanticsLabel: 'Duração total ${_formatTime(_durationSeconds)}'),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Controles de reprodução
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _A11yIconButton(
                          focusNode: prevFocus,
                          tooltip: 'Faixa anterior',
                          semanticsLabel: 'Faixa anterior',
                          icon: Icons.skip_previous_rounded,
                          onPressed: () {},
                        ),
                        _A11yIconButton(
                          focusNode: playPauseFocus,
                          tooltip: isPlaying ? 'Pausar' : 'Reproduzir',
                          semanticsLabel: isPlaying ? 'Pausar' : 'Reproduzir',
                          isToggle: true,
                          isToggled: isPlaying,
                          icon: isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                          onPressed: () {
                            setState(() => isPlaying = !isPlaying);
                          },
                        ),
                        _A11yIconButton(
                          focusNode: nextFocus,
                          tooltip: 'Próxima faixa',
                          semanticsLabel: 'Próxima faixa',
                          icon: Icons.skip_next_rounded,
                          onPressed: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Botão de Gostar
                    Center(
                      child: _A11yIconButton(
                        focusNode: likeFocus,
                        tooltip: isLiked ? 'Gostei' : 'Gostar',
                        semanticsLabel: isLiked ? 'Gostei' : 'Gostar',
                        isToggle: true,
                        isToggled: isLiked,
                        icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        onPressed: () => setState(() => isLiked = !isLiked),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const _HelperTips(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static const double _durationSeconds = 330; // duração fictícia ~5:30
  String _formatTime(double seconds) {
    final s = seconds.round();
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }
}

class _A11yIconButton extends StatelessWidget {
  const _A11yIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.semanticsLabel,
    this.isToggle = false,
    this.isToggled = false,
    this.focusNode,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final String semanticsLabel;
  final bool isToggle;
  final bool isToggled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final Widget button = IconButton(
      focusNode: focusNode,
      onPressed: onPressed,
      icon: Icon(icon, size: 40),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      tooltip: tooltip,
    );

    return Semantics(
      label: semanticsLabel,
      button: true,
      toggled: isToggle ? isToggled : null,
      enabled: true,
      child: ExcludeSemantics(child: button),
    );
  }
}

class _HelperTips extends StatelessWidget {
  const _HelperTips();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: DefaultTextStyle(
        style: theme.textTheme.bodyMedium!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Como validar a acessibilidade deste player',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('• Ative o TalkBack (Android) ou VoiceOver (iOS) e navegue por todos os controles.'),
            Text('• Aumente o tamanho de fonte do sistema e verifique se título/artista continuam legíveis.'),
            Text('• Use um verificador de contraste e confira texto ícone/fundo; este tema escuro atinge AA.'),
            Text('• Tente operar o slider pelo leitor de tela e perceba o anúncio do valor em porcentagem.'),
            Text('• Garanta que todos os botões tenham área de toque confortável (mínimo 44x44 lógicos).'),
          ],
        ),
      ),
    );
  }
}
