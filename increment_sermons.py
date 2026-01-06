import json

# Read the JSON data
with open('all_explanations.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Create new dictionary with renamed keys
new_data = {}

for key, value in data.items():
    # Extract the sermon number
    sermon_num = int(key.replace('الخطبة', ''))
    
    # If sermon number is 130 or higher, increment by 1
    if sermon_num >= 130:
        new_sermon_num = sermon_num + 1
        new_key = f"الخطبة{new_sermon_num}"
        new_data[new_key] = value
        print(f"✏️  Renamed: {key} → {new_key}")
    else:
        # Keep sermons 1-129 as is
        new_data[key] = value

# Save the updated data
with open('all_explanations.json', 'w', encoding='utf-8') as f:
    json.dump(new_data, f, ensure_ascii=False, indent=2)

print(f"\n✅ Done! Total sermons: {len(new_data)}")
print(f"📊 Original count: {len(data)}")
print(f"📊 New count: {len(new_data)}")
print(f"\n📋 Summary:")
print(f"   - Sermons 1-129: Unchanged")
print(f"   - Sermons 130-149: Incremented by 1 (now 131-150)")
