#!/usr/bin/env python3
"""
Web scraper for Nahj al-Balagha from imamali.net
Extracts sermon titles and content to generate a JSON file
"""

import requests
from bs4 import BeautifulSoup
import json
import time
from urllib.parse import urljoin

# Base URL for the website
BASE_URL = "https://www.imamali.net/"
START_URL = "https://www.imamali.net/?id=13446"

def get_page_content(url):
    """
    Fetch page content with proper headers
    """
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }
    
    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.encoding = 'utf-8'  # Ensure proper encoding for Arabic text
        response.raise_for_status()
        return response.text
    except requests.RequestException as e:
        print(f"Error fetching {url}: {e}")
        return None

def extract_sermon_list(html_content):
    """
    Extract list of sermons with their titles and links
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    sermons = []
    
    # Find all list items with class "AKD-Categ_List"
    sermon_items = soup.find_all('li', class_='AKD-Categ_List')
    
    for item in sermon_items:
        # Find the link element
        link_element = item.find('a', class_='AKD-HrefList')
        if not link_element:
            continue
        
        # Extract the title from the span with class "AKD-Li_Tx_"
        title_element = item.find('span', class_='AKD-Li_Tx_')
        if not title_element:
            continue
        
        title = title_element.get_text(strip=True)
        
        # Extract the href attribute
        href = link_element.get('href', '')
        if href:
            # Construct full URL
            full_url = urljoin(BASE_URL, href)
            sermons.append({
                'title': title,
                'url': full_url
            })
    
    return sermons

def extract_sermon_content(html_content):
    """
    Extract the main content/text from a sermon page
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    
    # Find the main content area with the correct class
    content_area = soup.find('div', class_='AKD-SiraBodyTx_')
    
    if content_area:
        # Remove all footnote divs (divs with id starting with 'ftn')
        for footnote in content_area.find_all('div', id=lambda x: x and x.startswith('ftn')):
            footnote.decompose()
        
        # Extract text and clean it up
        text = content_area.get_text(separator='\n\n', strip=True)
        return text
    
    # Fallback: try alternative selectors
    content_area = soup.find('div', class_='AKD-TextContent')
    if content_area:
        # Remove footnotes from fallback content too
        for footnote in content_area.find_all('div', id=lambda x: x and x.startswith('ftn')):
            footnote.decompose()
        
        text = content_area.get_text(separator='\n\n', strip=True)
        return text
    
    # If no specific content area found, return empty string
    # This prevents getting unwanted content from the page
    return ""

def scrape_sermons(start_url):
    """
    Main scraping function
    """
    print(f"Starting scraper for: {start_url}")
    
    # Get the main page with sermon list
    html_content = get_page_content(start_url)
    if not html_content:
        print("Failed to fetch the main page")
        return {}
    
    # Extract sermon list
    sermons = extract_sermon_list(html_content)
    print(f"Found {len(sermons)} sermons")
    
    # Dictionary to store results
    results = {}
    
    # Scrape each sermon
    for i, sermon in enumerate(sermons, 1):
        print(f"Scraping sermon {i}/{len(sermons)}: {sermon['title']}")
        
        # Fetch sermon page
        sermon_html = get_page_content(sermon['url'])
        if not sermon_html:
            print(f"  Failed to fetch sermon page")
            continue
        
        # Extract content
        content = extract_sermon_content(sermon_html)
        
        # Store in results
        results[sermon['title']] = {
            'text': content,
            'notes': []
        }
        
        # Be polite to the server - add a small delay
        time.sleep(1)
    
    return results

def save_to_json(data, filename='output.json'):
    """
    Save scraped data to JSON file with proper UTF-8 encoding
    """
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"\nData saved to {filename}")
    print(f"Total sermons scraped: {len(data)}")

if __name__ == "__main__":
    # Scrape the sermons
    sermon_data = scrape_sermons(START_URL)
    
    # Save to JSON file
    if sermon_data:
        save_to_json(sermon_data, 'assets/scraped_output.json')
    else:
        print("No data was scraped")
