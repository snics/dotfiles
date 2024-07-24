pdf_to_txt() {
  output_file="export.txt"

  # Loop through all PDF files in the current directory and extract the content
  for pdf_file in *.pdf; do
    pdftotext -enc UTF-8 "$pdf_file" - >> "$output_file"
  done

  echo "The content of all PDF files has been saved to the text file: $output_file"
}

alias pdf2txt=pdf_to_txt
