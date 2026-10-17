import 'dart:io';

void main() {
  final files = [
    'lib/pages/chat_pages.dart',
    'lib/pages/dinding_doa_pages.dart',
    'lib/pages/journal_pages.dart',
    'lib/pages/mood_tracker.dart',
    'lib/pages/peer_chat_lobby_page.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var content = file.readAsStringSync();
    
    // Some files might have multiple `return Scaffold(`. 
    // We only want to wrap the top-level one inside `Widget build(BuildContext context)` or similar.
    // A simple regex might be tricky if there are nested scaffolds.
    // Instead, let's just wrap `return Scaffold(` with the wrapper ONLY IF it's followed by `backgroundColor`.
    
    content = content.replaceAll(
      'return Scaffold(', 
      '''return Container(
          color: const Color(0xFFFAF4F0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ClipRRect(
                child: Scaffold('''
    );

    // We also need to add closing brackets `))))` where the Scaffold ends.
    // This is hard to do with regex because we don't know where the Scaffold ends.
    
    // Instead of regex, let's use the replace_file_content tool manually for the root Scaffolds.
  }
}
