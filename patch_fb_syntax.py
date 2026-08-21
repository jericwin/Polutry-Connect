py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/templates/marketplace/farmer_feedback.html'
with open(py_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# The original inner loop remnants start at the unexpected {% else %} around line 240.
# We will find where my new loop ends (    </div> around line 239) and the final     {% else %} around line 267.
start_idx = -1
end_idx = -1

for i, line in enumerate(lines):
    if line.strip() == '{% else %}' and lines[i-1].strip() == '</div>' and lines[i-2].strip() == '{% endfor %}':
        # This could be line 240 or 267. Let's find the FIRST unexpected else
        if start_idx == -1:
            start_idx = i

if start_idx != -1:
    # Now find the ACTUAL outer else which is followed by <div class="mp-empty">
    for i in range(start_idx + 1, len(lines)):
        if line.strip() == '{% else %}' and '<div class="mp-empty">' in lines[i+1]:
            end_idx = i
            break
        # Or if the current line is the actual outer else
        if lines[i].strip() == '{% else %}' and i + 1 < len(lines) and 'mp-empty' in lines[i+1]:
            end_idx = i
            break

if start_idx != -1 and end_idx != -1:
    new_lines = lines[:start_idx] + lines[end_idx:]
    with open(py_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print("Deleted lines from", start_idx, "to", end_idx)
else:
    print("Could not find bounds", start_idx, end_idx)