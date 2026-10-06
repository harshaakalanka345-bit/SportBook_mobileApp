import re

with open('lib/features/auth/auth_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()
text = re.sub(r'content:\s*Text\(\'Auth error: \\\n\(Entering Demo Mode automatically\)\'\),', r"content: Text('Auth error: \$msg\n(Entering Demo Mode automatically)'),", text)
with open('lib/features/auth/auth_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

with open('lib/features/auth/registration_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()
text = re.sub(r'content:\s*Text\(\'Registration error: \\\n\(Entering Demo Mode automatically\)\'\),', r"content: Text('Registration error: \$message\n(Entering Demo Mode automatically)'),", text)
with open('lib/features/auth/registration_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
