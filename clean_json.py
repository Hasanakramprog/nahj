#!/usr/bin/env python3
"""
Clean JSON file by removing footnote references
Removes patterns like [1], ([1]), [2], ([2]), etc. from both keys and values
"""

import json
import re

def clean_text(text):
    """
    Remove footnote references from text
    Patterns: [1], ([1]), [2], ([2]), etc.
    """
    if not isinstance(text, str):
        return text
    
    # Remove patterns like ([1]), ([2]), ([123]), etc.
    text = re.sub(r'\(\[\d+\]\)', '', text)
    
    # Remove patterns like [1], [2], [123], etc.
    text = re.sub(r'\[\d+\]', '', text)
    
    # Clean up extra spaces that might be left
    text = re.sub(r'\s+', ' ', text)
    
    # Remove leading/trailing whitespace
    text = text.strip()
    
    return text

def clean_json_data(data):
    """
    Recursively clean all keys and values in the JSON data
    """
    if isinstance(data, dict):
        cleaned = {}
        for key, value in data.items():
            # Clean the key
            cleaned_key = clean_text(key)
            
            # Clean the value (recursively if it's a dict or list)
            if isinstance(value, dict):
                cleaned_value = clean_json_data(value)
            elif isinstance(value, list):
                cleaned_value = [clean_text(item) if isinstance(item, str) else clean_json_data(item) for item in value]
            elif isinstance(value, str):
                cleaned_value = clean_text(value)
            else:
                cleaned_value = value
            
            cleaned[cleaned_key] = cleaned_value
        
        return cleaned
    
    elif isinstance(data, list):
        return [clean_text(item) if isinstance(item, str) else clean_json_data(item) for item in data]
    
    elif isinstance(data, str):
        return clean_text(data)
    
    else:
        return data

def clean_json_file(input_file, output_file):
    """
    Read JSON file, clean it, and save to output file
    """
    print(f"Reading from: {input_file}")
    
    # Read the JSON file
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print(f"Original entries: {len(data)}")
    
    # Clean the data
    print("Cleaning footnote references...")
    cleaned_data = clean_json_data(data)
    
    print(f"Cleaned entries: {len(cleaned_data)}")
    
    # Save to output file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(cleaned_data, f, ensure_ascii=False, indent=2)
    
    print(f"Saved cleaned data to: {output_file}")
    print("Done!")

if __name__ == "__main__":
    import sys
    
    # Check for command line arguments
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
        # Use provided output file or generate one
        if len(sys.argv) > 2:
            output_file = sys.argv[2]
        else:
            output_file = input_file.replace('.json', '_cleaned.json')
    else:
        # Default behavior (hardcoded)
        input_file = 'assets/scraped_output.json'
        output_file = 'assets/scraped_output_cleaned.json'
    
    # Clean the JSON file
    clean_json_file(input_file, output_file)
    
    # Show some examples of what was cleaned
    print("\n" + "="*50)
    print("Example patterns that were removed:")
    print("  [1], [2], [123]")
    print("  ([1]), ([2]), ([123])")
    print("="*50)
