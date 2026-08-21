import os
import re

peso_svg = '<path d="M20 11H4"/><path d="M20 7H4"/><path d="M7 21V3h8a4 4 0 0 1 0 8H7"/>'

# Read all html files in app/templates
for root, _, files in os.walk('app/templates'):
    for file in files:
        if file.endswith('.html'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            orig = content
            
            # Replace <line ... /> \n <path d="M17... />
            content = re.sub(
                r'<line\s+x1="12"\s+y1="1"\s+x2="12"\s+y2="23"\s*/?>\s*<path\s+d="M17 5H9\.5a3\.5 3\.5 0 [0 ]+7h5a3\.5 3\.5 0 [01 ]+7H6"\s*/?>',
                peso_svg,
                content,
                flags=re.IGNORECASE
            )
            
            # Replace single <path> that combines both: d="M12 2v20M17 5H9.5...
            content = re.sub(
                r'<path\s+d="M12 2v20M17 5H9\.5a3\.5 3\.5 0 [0 ]+7h5a3\.5 3\.5 0 [01 ]+7H6"\s*/?>',
                peso_svg,
                content,
                flags=re.IGNORECASE
            )
            
            # Replace <path d="M12 2v20" /> \n <path d="M17..." />
            content = re.sub(
                r'<path\s+d="M12 2v20"\s*/?>\s*<path\s+d="M17 5H9\.5a3\.5 3\.5 0 [0 ]+7h5a3\.5 3\.5 0 [01 ]+7H6"\s*/?>',
                peso_svg,
                content,
                flags=re.IGNORECASE
            )
            
            # Catch standalone M17... path
            content = re.sub(
                r'<path\s+d="M17 5H9\.5a3\.5 3\.5 0 [0 ]+7h5a3\.5 3\.5 0 [01 ]+7H6"\s*/?>',
                peso_svg,
                content,
                flags=re.IGNORECASE
            )
            
            if orig != content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated {filepath}")
