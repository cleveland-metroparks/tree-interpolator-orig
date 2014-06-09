#!/bin/bash -x

START=$(date +%s)

filenum=0

echo "Please enter desired pixel size in feet:"
#read pixel_size
pixel_size=10
width_height=`echo "5000 / $pixel_size" | bc`
half_pixel=`echo "$pixel_size / 2" | bc`

debug=false
#debug=true

#for f in $(ls 22[6-7]0_*.inc); do
#for f in $(ls 2240_690.inc); do
#for f in $(ls 227*.inc); do
for f in $(ls *.inc); do

# Calculate center of image, upper left corner of image, etc.

	filenum=`expr $filenum + 1`

	name=`echo $f | awk -F'.' '{print $1}'`  			# Split off non-extension portion of name
	xcoord=`echo $name | awk -F'_' '{print $1 "000"}'`	# Convert name sections to coordinates
	ycoord=`echo $name | awk -F'_' '{print $2 "000"}'`
	xcenter=`expr $xcoord + 2500`						# Find center of tile
	ycenter=`expr $ycoord + 2500`
	xcorner=`echo "$xcoord + $half_pixel" | bc`			# Fine UL corner of tile and pixel center
	ycorner=`echo "$ycoord + 5000 - $half_pixel" | bc`
	xc=`echo $name | awk -F'_' '{print $1}'`			# Split off portions of name for finding
	yc=`echo $name | awk -F'_' '{print $2}'`			#	adjacent tiles

#	if [ ! -f $name.png ]
#		then

#Generate file names for adjacent tiles
	inc1x=`expr $xc - 5`
	inc1y=`expr $yc + 5`
	inc1_file=`echo $inc1x"_"$inc1y`
	inc1_file_nm=`echo $inc1_file".inc"`

	inc2x=`expr $xc + 0`
	inc2y=`expr $yc + 5`
	inc2_file=`echo $inc2x"_"$inc2y`
	inc2_file_nm=`echo $inc2_file".inc"`

	inc3x=`expr $xc + 5`
	inc3y=`expr $yc + 5`
	inc3_file=`echo $inc3x"_"$inc3y`
	inc3_file_nm=`echo $inc3_file".inc"`

	inc4x=`expr $xc - 5`
	inc4y=`expr $yc + 0`
	inc4_file=`echo $inc4x"_"$inc4y`
	inc4_file_nm=`echo $inc4_file".inc"`

	inc5x=`expr $xc + 5`
	inc5y=`expr $yc + 0`
	inc5_file=`echo $inc5x"_"$inc5y`
	inc5_file_nm=`echo $inc5_file".inc"`

	inc6x=`expr $xc - 5`
	inc6y=`expr $yc - 5`
	inc6_file=`echo $inc6x"_"$inc6y`
	inc6_file_nm=`echo $inc6_file".inc"`

	inc7x=`expr $xc + 0`
	inc7y=`expr $yc - 5`
	inc7_file=`echo $inc7x"_"$inc7y`
	inc7_file_nm=`echo $inc7_file".inc"`

	inc8x=`expr $xc + 5`
	inc8y=`expr $yc - 5`
	inc8_file=`echo $inc8x"_"$inc8y`
	inc8_file_nm=`echo $inc8_file".inc"`

# Create Pov file for generating image
	echo "//Set the center of image" > $name.pov
	echo "#declare scene_center_x="$xcenter";" >> $name.pov
	echo "#declare scene_center_y="$ycenter";" >> $name.pov
	echo >> $name.pov
	echo "//Include locations and heights for trees." >> $name.pov
	echo '#include "'$f'"' >> $name.pov
	more tree_height_template.pov >> $name.pov
	./tree_height_adj_control.sh $name >> $name.pov

# Check for existence of adjacent tiles and include if they exist
	if [ -f $inc1_file.inc ]
		then
			echo "//Include locations and heights for trees." >> $name.pov
			echo '#include "'$inc1_file'.inc"' >> $name.pov
			./tree_height_adj_control.sh $inc1_file >> $name.pov
	fi

	if [ -f $inc2_file_nm ]
		then
			echo "//Include locations and heights for trees." >> $name.pov
			echo '#include "'$inc2_file'.inc"' >> $name.pov
			./tree_height_adj_control.sh $inc2_file >> $name.pov
	fi

	if [ -f $inc3_file_nm ]
		then
			echo "//Include locations and heights for trees." >> $name.pov
			echo '#include "'$inc3_file'.inc"' >> $name.pov
			./tree_height_adj_control.sh $inc3_file >> $name.pov
	fi

	if [ -f $inc4_file_nm ]
		then
			echo "//Include locations and heights for trees." >> $name.pov
			echo '#include "'$inc4_file'.inc"' >> $name.pov
			./tree_height_adj_control.sh $inc4_file >> $name.pov
	fi

	if [ -f $inc5_file.inc ]
		then
			echo "//Include locations and heights for trees." >> $name.pov
			echo '#include "'$inc5_file'.inc"' >> $name.pov
			./tree_height_adj_control.sh $inc5_file >> $name.pov
	fi

	if [ -f $inc6_file_nm ]
		then
			echo "//Include locations and heights for trees." >> $name.pov
			echo '#include "'$inc6_file'.inc"' >> $name.pov
			./tree_height_adj_control.sh $inc6_file >> $name.pov
	fi

	if [ -f $inc7_file_nm ]
		then
			echo "//Include locations and heights for trees." >> $name.pov
			echo '#include "'$inc7_file'.inc"' >> $name.pov
			./tree_height_adj_control.sh $inc7_file >> $name.pov
	fi

	if [ -f $inc8_file_nm ]
		then
			echo "//Include locations and heights for trees." >> $name.pov
			echo '#include "'$inc8_file'.inc"' >> $name.pov
			./tree_height_adj_control.sh $inc8_file >> $name.pov
	fi

# Create *.pgw (world) file
	echo $pixel_size > $name.pgw
	echo 0.0 >> $name.pgw
	echo 0.0 >> $name.pgw
	echo -$pixel_size >> $name.pgw
	echo $xcorner >> $name.pgw
	echo $ycorner >> $name.pgw

# Run povray with input pov file, ouput PNG @ 16-bit resolution

	povray +I$name.pov +O$name.png +FN16 +W$width_height +H$width_height -D
#	povray +I$name.pov +O$name.png +FN16 +W$width_height +H$width_height -D +A

#	fi

done

# Mosaic pngs to a single tiff with overviews

pwd1=`pwd`
basename1=`basename $pwd1`
echo
echo "Building virtual mosaic:"
gdalbuildvrt $basename1.vrt *.png
echo
echo "Converting mosaic to tif:"
gdal_translate -b 1 $basename1.vrt $basename1.tif
echo
echo "Adding overviews:"
gdaladdo -r average $basename1.tif 2 4 8 16 32 64 128 256 512 1024

# Perform a little cleanup:
if [ $debug = true ]
	then
		echo ""
		echo "Leaving files in place for debug purposes."
	else
		echo ""
		echo "Deleting pov, png, vrt, and pgw files..."
		echo " ... if you need to retain these for debug purposes,"
		echo "     edit $0 shell file and change 'debug' to true."
		rm 2*.pov *.pgw *.png *.vrt
fi

# Report back on performance

END=$(date +%s)
DIFF=$(( $END - $START ))
echo
echo "Processing took $DIFF seconds"

if [ $filenum = 1 ]
	then
		echo "for $filenum file,"
	else
		echo "for $filenum files,"
fi

echo "i.e. `echo "$DIFF / $filenum" | bc` seconds per tile."
