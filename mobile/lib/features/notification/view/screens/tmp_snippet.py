from pathlib import Path
text = Path('notification_screen.dart').read_text()
start = text.index('void _handleExtraCostResponse')
end = text.index( void _handleGoHome, start)
print(text[start:end])
