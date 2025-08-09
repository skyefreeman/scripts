#!/usr/bin/env python

import os
from pathlib import Path
from edgar import *

def main():
    set_identity("skyefreeman@icloud.com")
    company = Company("PCT")
    filings = company.get_filings()

    # retrieve documents
    latest_quarterlies = filings.filter(form="10-Q").latest(4)
    latest_annual = filings.filter(form="10-K")[0]
    prospectus = filings.filter(form="S-1")[0]

    # combine all document objects into a single list
    docs = []
    for quarterly in latest_quarterlies:
        docs.append(quarterly)
    docs.append(latest_annual)
    docs.append(prospectus)

    # create a new list, converting each document into an html file
    html_files = []
    for doc in docs:
        try:
            html_content = doc.html()
            html_files.append({
                'content': html_content,
                'filing_date': doc.filing_date,
                'form': doc.form,
                'filename': f"{doc.filing_date}_{doc.form}.html"
            })
        except Exception as e:
            print(f"Error converting {doc.form} from {doc.filing_date} to HTML: {e}")
            continue

    # write each html file to disk in a new directory by the company name,
    # each filename is in the format "{date}_{form_type}.html"
    company_dir = Path(company.tickers[0])
    company_dir.mkdir(exist_ok=True)
    
    saved_files = []
    for html_file in html_files:
        file_path = company_dir / html_file['filename']
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(html_file['content'])
            saved_files.append(str(file_path))
            print(f"Saved: {file_path}")
        except Exception as e:
            print(f"Error saving {html_file['filename']}: {e}")
            continue

    # combine all the html files into a single epub file
    try:
        import ebooklib
        from ebooklib import epub
        
        book = epub.EpubBook()
        book.set_identifier(f"{company.tickers[0]}_{company.cik}")
        book.set_title(f"{company.name} SEC Filings")
        book.set_language('en')
        book.add_author('SEC EDGAR')
        
        # Add chapters
        chapters = []
        for i, html_file in enumerate(html_files):
            chapter = epub.EpubHtml(
                title=f"{html_file['form']} - {html_file['filing_date']}",
                file_name=f"chapter_{i+1}.xhtml",
                lang='en'
            )
            
            html_content = html_file['content']
            if html_content and html_content.strip():
                chapter.content = html_content
                book.add_item(chapter)
                chapters.append(chapter)
        
        # Only create EPUB if we have chapters
        if chapters:
            # Add navigation
            book.toc = chapters
            book.add_item(epub.EpubNcx())
            book.add_item(epub.EpubNav())
            
            # Add spine
            book.spine = ['nav'] + chapters
            
            # Write EPUB
            epub_path = company_dir / f"{company.tickers[0]}_filings.epub"
            epub.write_epub(str(epub_path), book, {})
            print(f"Created EPUB: {epub_path}")
        else:
            print("No valid chapters found - EPUB creation skipped")
        
    except ImportError:
        print("ebooklib not installed. Install with: pip install ebooklib")
        print("EPUB creation skipped.")
    except Exception as e:
        print(f"Error creating EPUB: {e}")

if __name__ == '__main__':
    main()
