import json

transcript_path = r'C:\Users\Windows 10 Pro\.gemini\antigravity-ide\brain\998cd42b-b9ea-4e56-b8c7-ab149f0f271b\.system_generated\logs\transcript_full.jsonl'
patches = []

with open(transcript_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            entry = json.loads(line)
        except:
            continue
            
        if 'tool_calls' in entry:
            for tc in entry['tool_calls']:
                if tc.get('function') == 'default_api:replace_file_content' and 'production.py' in tc.get('arguments', {}).get('TargetFile', ''):
                    patches.append(tc['arguments'].get('ReplacementContent', ''))
                elif tc.get('function') == 'default_api:multi_replace_file_content' and 'production.py' in tc.get('arguments', {}).get('TargetFile', ''):
                    for chunk in tc['arguments'].get('ReplacementChunks', []):
                        patches.append(chunk.get('ReplacementContent', ''))

with open('recover_logs.txt', 'w', encoding='utf-8') as out:
    for p in patches:
        out.write("--- PATCH ---\n")
        out.write(p + "\n")
