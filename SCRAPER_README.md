# Nahj al-Balagha Web Scraper

This Python script scrapes sermon data from imamali.net and generates a JSON file.

## Installation

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

## Usage

Run the scraper:
```bash
python scraper.py
```

The script will:
1. Fetch the main page with the sermon list
2. Extract all sermon titles and their URLs
3. Visit each sermon page and extract the content
4. Save all data to `assets/scraped_output.json`

## Output Format

The generated JSON file has the following structure:
```json
{
  "Sermon Title": {
    "text": "Full sermon content...",
    "notes": []
  }
}
```

## Notes

- The scraper includes a 1-second delay between requests to be polite to the server
- Arabic text is properly handled with UTF-8 encoding
- If scraping fails for a specific sermon, it will be skipped and the script will continue

## Customization

You can modify the following in `scraper.py`:
- `START_URL`: Change the starting page URL
- `extract_sermon_content()`: Adjust CSS selectors if the page structure changes
- Delay between requests (currently 1 second)
