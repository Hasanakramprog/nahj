#!/usr/bin/env python3
"""
Web scraper for Nahj al-Balagha (Letters/Sayings) from imamali.net
Extracts titles and content to generate a JSON file.
Target URL: https://www.imamali.net/?id=13452
"""

import requests
from bs4 import BeautifulSoup
import json
import time
from urllib.parse import urljoin

# Base URL for the website
BASE_URL = "https://www.imamali.net/"
START_URL = "https://www.imamali.net/?id=13452"

def get_page_content(url):
    """
    Fetch page content with proper headers
    """
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    
    try:
        response = requests.get(url, headers=headers, timeout=15)
        response.encoding = 'utf-8'  # Ensure proper encoding for Arabic text
        response.raise_for_status()
        return response.text
    except requests.RequestException as e:
        print(f"Error fetching {url}: {e}")
        return None

def extract_list(html_content):
    """
    Extract list of items with their titles and links
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    items = []
    
    # Try finding list items with the class used in the other page
    list_items = soup.find_all('li', class_='AKD-Categ_List')
    
    # If standard list items founds
    if list_items:
        for item in list_items:
            link_element = item.find('a', class_='AKD-HrefList')
            if not link_element: continue
            
            title_element = item.find('span', class_='AKD-Li_Tx_')
            title = title_element.get_text(strip=True) if title_element else "Unknown Title"
            
            href = link_element.get('href', '')
            if href:
                full_url = urljoin(BASE_URL, href)
                items.append({'title': title, 'url': full_url})
    else:
        # Fallback: Find direct links as identified by browser inspection
        # "a.AKD-HrefList"
        # Since browser agent said items are "a.AKD-HrefList", we check this structure too
        links = soup.find_all('a', class_='AKD-HrefList')
        for link in links:
             # Title might be inside
             title_span = link.find('span', class_='AKD-Li_Tx_') or link.find('span')
             title = title_span.get_text(strip=True) if title_span else link.get_text(strip=True)
             
             href = link.get('href', '')
             if href:
                full_url = urljoin(BASE_URL, href)
                items.append({'title': title, 'url': full_url})

    return items

def extract_content(html_content):
    """
    Extract the main content/text from a detail page
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    
    # Find the main content area
    content_area = soup.find('div', class_='AKD-SiraBodyTx_')
    
    if content_area:
        # Remove all footnote divs
        for footnote in content_area.find_all('div', id=lambda x: x and x.startswith('ftn')):
            footnote.decompose()
        
        # Extract text and clean it up
        text = content_area.get_text(separator='\n\n', strip=True)
        return text
    
    # Fallback
    content_area = soup.find('div', class_='AKD-TextContent')
    if content_area:
        for footnote in content_area.find_all('div', id=lambda x: x and x.startswith('ftn')):
            footnote.decompose()
        text = content_area.get_text(separator='\n\n', strip=True)
        return text
        
    return ""

def scrape_items(start_url):
    print(f"Starting scraper for: {start_url}")
    
    html_content = get_page_content(start_url)
    if not html_content:
        print("Failed to fetch the main page")
        return {}
    
    items = extract_list(html_content)
    print(f"Found {len(items)} items")
    
    results = {}
    
    for i, item in enumerate(items, 1):
        print(f"Scraping item {i}/{len(items)}: {item['title']}")
        
        item_html = get_page_content(item['url'])
        if not item_html:
            print(f"  Failed to fetch item page")
            continue
        
        content = extract_content(item_html)
        
        # Structure matches the previous scraper output format
        results[item['title']] = {
            'text': content,
            'notes': []
        }
        
        time.sleep(1) # Be polite
    
    return results

def save_to_json(data, filename='letters_output.json'):
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"\nData saved to {filename}")
    print(f"Total items scraped: {len(data)}")

if __name__ == "__main__":
    data = scrape_items(START_URL)
    if data:
        save_to_json(data, 'assets/letters_output.json')
    else:
        print("No data was scraped")
