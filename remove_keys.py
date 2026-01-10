import json

# Keys to remove (set their value to empty object)
keys_to_remove = [19, 35, 46, 49, 89, 95, 98, 104, 118, 126, 137, 153, 167, 171, 
                  212, 213, 219, 258, 262, 289, 290, 291, 292, 294, 295, 296, 
                  298, 300, 301, 302, 303, 305, 307, 308, 309, 310, 312, 314, 
                  315, 317, 318, 319, 330, 335, 373, 379, 385, 388, 455, 478, 
                  516, 526, 539, 544, 553, 561, 563, 566, 571]

# Convert to strings as JSON keys are strings
keys_to_remove = [str(k) for k in keys_to_remove]

# Read the JSON file
with open('assets/imamali_with_notes.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Remove the specified keys by setting them to empty objects
for key in keys_to_remove:
    if key in data:
        data[key] = {}
        print(f"Removed content from key: {key}")

# Write back to the file with proper formatting
with open('assets/imamali_with_notes.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"\nTotal keys processed: {len(keys_to_remove)}")
print("File updated successfully!")
