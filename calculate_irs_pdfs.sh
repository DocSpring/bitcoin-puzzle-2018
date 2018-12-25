#!/bin/bash

for f in ../form_api/pdfs/irs/forms/*.pdf; do
  BASENAME=$(basename $f)
  printf "$BASENAME => \t"
  ./process_file.rb $f
done

# https://www.irs.gov/pub/irs-prior/f1099r--2016.pdf

# => 4922a0ff06ef81ed6156770d00127104180032eb164dbe804922a0fff18206c8
