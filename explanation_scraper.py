#!/usr/bin/env python3
"""
Scraper for Nahj al-Balagha explanations from gadir.free.fr
Extracts sermon numbers and their explanations (sharh/tafsir)
"""

import requests
from bs4 import BeautifulSoup
import json
import re
from typing import Dict, List
import time


def fetch_page_content(url: str) -> BeautifulSoup:
    """
    Fetch and parse a single page.
    
    Args:
        url: URL of the page to fetch
        
    Returns:
        BeautifulSoup object of the page, or None if error
    """
    try:
        response = requests.get(url, timeout=30)
        response.encoding = response.apparent_encoding or 'windows-1256'
        response.raise_for_status()
        return BeautifulSoup(response.text, 'html.parser')
    except Exception as e:
        print(f"❌ Error fetching {url}: {e}")
        return None


def extract_sermons_from_combined_content(all_soups: List[BeautifulSoup]) -> Dict[str, str]:
    """
    Extract all sermons from combined content of multiple pages.
    This allows sermons that span multiple pages to be extracted completely.
    
    Args:
        all_soups: List of BeautifulSoup objects from all pages in a book
        
    Returns:
        Dictionary with sermon number as key and explanation text as value
    """
    result = {}
    
    # Combine all elements from all pages, skipping the book title h1 from each page
    all_elements = []
    for soup in all_soups:
        if soup:
            body = soup.find('body')
            if body:
                elements = body.find_all(['h1', 'h3', 'p'], recursive=False)
                # Skip the first h1 ONLY if it's the book title (not a sermon)
                first_h1_in_page = True
                for element in elements:
                    # Check if this is the first h1 in the page
                    if element.name == 'h1' and first_h1_in_page:
                        first_h1_in_page = False  # Mark that we've seen the first h1
                        h1_text = element.get_text(strip=True)
                        # Skip ONLY if this is the book title (not a sermon)
                        if 'نفحات' in h1_text or 'الولاية' in h1_text or 'الخطبة' not in h1_text:
                            continue  # Skip this book title
                        # Otherwise, it's a sermon header, so add it
                    all_elements.append(element)
    
    # Now process the combined elements
    i = 0
    while i < len(all_elements):
        element = all_elements[i]
        
        # Check if this is a sermon header
        if element.name == 'h1':
            h1_text = element.get_text(strip=True)
            # Match patterns like: الخطبة 1, الخطبة(1) 21, الخطبة 65, etc.
            # First try to match the last number (the actual sermon number after any footnote)
            numbers = re.findall(r'\d+', h1_text)
            
            # Only process if this h1 is actually a sermon header (contains 'الخطبة')
            if numbers and 'الخطبة' in h1_text:
                # Take the last number as the sermon number (e.g., from "الخطبة(1) 21", take 21)
                sermon_number = numbers[-1]
                key = f"الخطبة{sermon_number}"
                print(f"  ✅ Found: {key}")
                
                # Find the explanation section
                explanation_parts = []
                found_sharh_section = False
                i += 1  # Move to next element
                
                # Collect all content until the next h1 (next sermon)
                while i < len(all_elements):
                    current = all_elements[i]
                    
                    # Stop if we hit another h1 (could be next sermon or another heading)
                    if current.name == 'h1':
                        break
                    
                    # Check if this is the "الشرح والتفسير" marker (in <p class="mohem">)
                    if current.name == 'p' and 'mohem' in current.get('class', []):
                        text = current.get_text(strip=True)
                        if 'الشرح والتفسير' in text or 'الشرح' in text or 'التفسير' in text:
                            found_sharh_section = True
                            i += 1
                            continue
                    
                    # Also check for <h3> markers like <h3>شرح الخطبة</h3> or <h3>الشرح والتفسير</h3>
                    if current.name == 'h3':
                        text = current.get_text(strip=True)
                        if 'شرح الخطبة' in text or 'شرح' in text or 'الشرح والتفسير' in text or 'التفسير' in text:
                            found_sharh_section = True
                            i += 1
                            continue
                    
                    # Collect paragraph text after sharh section starts
                    # If multiple explanation sections are found, keep collecting all paragraphs
                    if found_sharh_section and current.name == 'p':
                        # Skip footnotes
                        if 'foot1' not in current.get('class', []):
                            text = current.get_text(strip=True)
                            if text:
                                explanation_parts.append(text)
                    
                    i += 1
                
                # Save the complete explanation
                if explanation_parts:
                    result[key] = '\n\n'.join(explanation_parts)
                    print(f"    📝 Extracted {len(explanation_parts)} paragraphs (complete across all pages)")
                else:
                    print(f"    ⚠️  No explanation found for {key}")
                
                # Don't increment i here, let the outer loop handle the next h1
                continue
            else:
                # This h1 is not a sermon header (e.g., chapter title, section heading)
                # Just skip it and continue to the next element
                i += 1
                continue
        
        i += 1
    
    return result


def save_to_json(data: Dict[str, str], output_file: str):
    """Save data to JSON file."""
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ Saved {len(data)} sermons to {output_file}")


def scrape_all_books_and_pages(books: List[int], pages: List[int]) -> Dict[str, str]:
    """
    Scrape multiple books and pages.
    This function fetches all pages of a book first, then extracts complete sermons
    that may span across multiple pages.
    
    Args:
        books: List of book numbers (1-5)
        pages: List of page numbers (1-28)
        
    Returns:
        Combined dictionary of all sermons and explanations
    """
    all_results = {}
    total_books = len(books)
    total_pages = len(pages)
    
    for book_idx, book_num in enumerate(books, 1):
        book_str = f"{book_num:02d}"  # Format as 01, 02, 03, etc.
        
        print(f"\n{'='*70}")
        print(f"📚 Processing Book {book_num} ({book_idx}/{total_books})")
        print(f"{'='*70}")
        
        # Fetch all pages for this book first
        print(f"\n📥 Fetching all {len(pages)} pages for Book {book_num}...")
        all_soups = []
        
        for page_idx, page_num in enumerate(pages, 1):
            page_str = f"{page_num:02d}"  # Format as 01, 02, 03, etc.
            url = f"http://gadir.free.fr/Ar/imamali/Nhj/Nefhatul_Velaye/7/book_39/NAFAHATVELG{book_str}/{page_str}.html"
            
            print(f"  📄 Fetching page {page_num}/{total_pages}... ", end='', flush=True)
            soup = fetch_page_content(url)
            if soup:
                all_soups.append(soup)
                print("✅")
            else:
                print("❌")
            
            # Be nice to the server
            time.sleep(1)
        
        # Now extract all sermons from the combined content
        print(f"\n🔍 Extracting sermons from Book {book_num} (all {len(all_soups)} pages combined)...")
        book_results = extract_sermons_from_combined_content(all_soups)
        all_results.update(book_results)
        
        print(f"\n✅ Book {book_num} complete: {len(book_results)} sermons extracted")
    
    return all_results


def main():
    """Main execution function."""
    
    print("=" * 70)
    print("🕌 Nahj al-Balagha Explanation Scraper")
    print("=" * 70)
    print()
    
    # Scrape all books (1-5) and pages (1-28)
    print("📖 Scraping books 1-5, pages 1-28...")
    print("⏱️  This may take a while (140 pages total)...")
    print()
    
    books = list(range(1, 6))  # Books 1-5
    pages = list(range(1, 29))  # Pages 1-28
    
    all_data = scrape_all_books_and_pages(books, pages)
    
    if all_data:
        # Save all results
        save_to_json(all_data, 'all_explanations.json')
        
        # Print summary
        print("\n" + "=" * 70)
        print("� Scraping Summary:")
        print("=" * 70)
        print(f"Total sermons extracted: {len(all_data)}")
        print(f"Books processed: {len(books)} (Books 1-5)")
        print(f"Pages per book: {len(pages)} (Pages 1-28)")
        print(f"Total pages scraped: {len(books) * len(pages)}")
        
        # Print preview of first few sermons
        print("\n" + "=" * 70)
        print("📄 Preview of extracted data (first 3 sermons):")
        print("=" * 70)
        for key, value in list(all_data.items())[:3]:
            print(f"\n� Key: {key}")
            print(f"📝 Value preview (first 100 chars):")
            print(value[:100] + "..." if len(value) > 100 else value)
    else:
        print("\n⚠️  No data was extracted!")
    
    print("\n" + "=" * 70)
    print("✅ Scraping complete!")
    print("=" * 70)


if __name__ == "__main__":
    main()
