#!/bin/bash

# Bret Berger
# October 2013
# when presented with a directory with files having misnamed extensions,
# check all files in a directory for file type using file command
#   if filetype is jpg, copy to new directory for type jpg (with correct extension)
#   if filetype is tiff, and filename begins with PO or P0, convert to jpg and put in jpg directory.
#   if filetype is tiff, convert to pdf and put in a new directory for type pdf.

# requires imagemagic, tiff2pdf

INFILESDIR="/home/bret/Desktop/TIFFCharts/"
PDFDIR="/home/bret/Desktop/PDFCharts/"
JPGDIR="/home/bret/Desktop/JPGImages/"

let image_tiffs=0
let chart_tiffs=0
let jpegs=0

echo "TIFF file directory (location of files to process) = $INFILESDIR"
echo "PDF file directory (processed pdf files go here) = $PDFDIR"
echo "JPG file directory (processed jpg files go here) = $JPGDIR" 

printf "\n"
for f in "$INFILESDIR"*
do
	fname=$(basename "$f")
	ext="${fname##*.}"
	inbasefname="${fname%.*}"
	pdfoutfname="$PDFDIR$inbasefname.pdf"
	jpgoutfname="$JPGDIR$inbasefname.jpg"
	echo "Input file = $f"
	echo "Input base file name = $inbasefname"

	FT=`file $f`
	echo "The file command returns: "$FT


	if [[ "$FT" == *"TIFF image data"* && ( "$inbasefname" == *"PO"* || "$inbasefname" == *"P0"* ) ]]
	then
		# The file is an image in TIFF format, convert to JPEG
		let image_tiffs=$image_tiffs+1
		echo "This is a TIFF image file"
		echo "JPG output file name = $jpgoutfname"
		cmd="convert $f $jpgoutfname"
		echo "command = $cmd"
		eval $cmd
	elif [[ "$FT" == *"TIFF image data"* ]]
	then
		# The file is a chart in TIFF format, convert to PDF
		let chart_tiffs=$chart_tiffs+1
		echo "This is a TIFF chart file"
		echo "PDF output file name = $pdfoutfname"
		cmd="tiff2pdf -o $pdfoutfname -p letter $f"
		echo "command = $cmd"
		eval $cmd
	elif [[ "$FT" == *"JPEG image data"* ]]
	then
		# The file is a JPEG with incorrect extension, rename with .jpg extension
		let jpegs=$jpegs+1
		echo "This is a JPEG file"
		echo "JPG output file name = $jpgoutfname"
		cmd="cp $f $jpgoutfname"
		echo "command = $cmd"
		eval $cmd
	else
		# Not a file we need to process
		echo "This is neither a TIFF nor JPEG file"
	fi

	printf "\n\n"
done

echo "Image TIFF count = $image_tiffs"
echo "Chart TIFF count = $chart_tiffs"
echo "JPEG count = $jpegs"
