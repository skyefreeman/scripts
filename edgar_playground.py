#!/usr/bin/env python

import os
import sys
from pathlib import Path
from edgar import *

def main():
    if len(sys.argv) != 2:
        print("Usage: python edgar_playground.py <ticker>")
        sys.exit(1)
    
    ticker = sys.argv[1].upper()
    print(f"Fetching filings for {ticker}")
    
    set_identity("skyefreeman@icloud.com")
    company = Company(ticker)
    filings = company.get_filings()

    # retrieve documents
    latest_quarterlies = filings.filter(form="10-Q").latest(2)
    latest_annual = filings.filter(form="10-K")[0]
    prospectus = filings.filter(form="S-1")[0]

    # combine all document objects into a single list
    docs = []
    for quarterly in latest_quarterlies:
        docs.append(quarterly)
    docs.append(latest_annual)
    docs.append(prospectus)

    # create a new list, converting each document into html, markdown, and text
    html_files = []
    markdown_files = []
    text_files = []
    for doc in docs:
        try:
            html_content = doc.html()
            html_files.append({
                'content': html_content,
                'filing_date': doc.filing_date,
                'form': doc.form,
                'filename': f"{doc.filing_date}_{doc.form}.html"
            })
            
            markdown_content = doc.markdown()
            markdown_files.append({
                'content': markdown_content,
                'filing_date': doc.filing_date,
                'form': doc.form,
                'filename': f"{doc.filing_date}_{doc.form}.md"
            })
            
            text_content = doc.text()
            text_files.append({
                'content': text_content,
                'filing_date': doc.filing_date,
                'form': doc.form,
                'filename': f"{doc.filing_date}_{doc.form}.txt"
            })
        except Exception as e:
            print(f"Error converting {doc.form} from {doc.filing_date}: {e}")
            continue

    # write each html, markdown, and text file to disk in a new directory by the ticker
    # each filename is in the format "{ticker}_{form_type}_{date}.{ext}"
    company_dir = Path(ticker)
    company_dir.mkdir(exist_ok=True)
    
    saved_files = []
    for html_file in html_files:
        html_filename = f"{ticker}_{html_file['form']}_{html_file['filing_date']}.html"
        file_path = company_dir / html_filename
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(html_file['content'])
            saved_files.append(str(file_path))
            print(f"Saved: {file_path}")
        except Exception as e:
            print(f"Error saving {html_filename}: {e}")
            continue
    
    for markdown_file in markdown_files:
        markdown_filename = f"{ticker}_{markdown_file['form']}_{markdown_file['filing_date']}.md"
        file_path = company_dir / markdown_filename
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(markdown_file['content'])
            saved_files.append(str(file_path))
            print(f"Saved: {file_path}")
        except Exception as e:
            print(f"Error saving {markdown_filename}: {e}")
            continue
    
    for text_file in text_files:
        text_filename = f"{ticker}_{text_file['form']}_{text_file['filing_date']}.txt"
        file_path = company_dir / text_filename
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(text_file['content'])
            saved_files.append(str(file_path))
            print(f"Saved: {file_path}")
        except Exception as e:
            print(f"Error saving {text_filename}: {e}")
            continue

    # convert each html document to pdf
    for html_file in html_files:
        try:
            from weasyprint import HTML
            
            html_content = html_file['content']
            if html_content and html_content.strip():
                pdf_filename = f"{ticker}_{html_file['form']}_{html_file['filing_date']}.pdf"
                pdf_path = company_dir / pdf_filename
                
                # Convert HTML to PDF using weasyprint
                html_doc = HTML(string=html_content)
                html_doc.write_pdf(str(pdf_path))
                print(f"Created PDF: {pdf_path}")
        except Exception as e:
            print(f"Error creating PDF for {html_file['form']} - {html_file['filing_date']}: {e}")
            continue

if __name__ == '__main__':
    main()
