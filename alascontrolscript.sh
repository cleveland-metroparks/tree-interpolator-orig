#!/bin/bash

START=$(date +%s)

filenum=0
debug=false
#debug=true

#run las2las to correct any bounding box errors and rename all the .las files to nXXXX_XXX.las
#for name in *.las; do las2las -i $name -o n${name:1:4}_${name:5:7} ; rm $name ; done

for f in $( ls *.las); do
#for f in $( ls n2240_6*.las); do
#for f in $( ls n2240_690.las); do
 filenum=`expr $filenum + 1`
 name=`echo $f | awk -F'.' '{print $1}'` 
 namen=`echo $name | sed 's/n//'`

 #echo $namen
 echo "Processing LiDAR file number "$filenum", "$f"..."
 las2txt --parse xyzcM -sep komma $f $f.csv

 echo "BEGIN;" > $name.sql

 echo "DROP TABLE IF EXISTS $name;" >> $name.sql
 echo "CREATE TABLE $name ( x numeric, y numeric, z numeric, class integer, gid integer) \
 WITH (OIDS=FALSE); ALTER TABLE $name OWNER TO postgres;" >> $name.sql
 echo "\\copy $name from $f.csv with csv" >> $name.sql

 echo "\\echo Done loading LiDAR data.  Let's create something spatial." >> $name.sql

 echo "\\echo Adding geometry column..." >> $name.sql
 echo "SELECT AddGeometryColumn('public','$name','the_geom',3734,'POINT', 2);" >> $name.sql

 echo "\\echo Creating points from x and y columns..." >> $name.sql
 echo "UPDATE $name SET the_geom = ST_SetSRID(ST_MakePoint(x,y),3734);" >> $name.sql

 echo "\\echo Creating spatial index on LiDAR points..." >> $name.sql
 echo "CREATE INDEX $name"_the_geom_idx" ON $name USING gist(the_geom);" >> $name.sql

 echo "\\echo Adding primary key..." >> $name.sql
 echo "ALTER TABLE $name ADD PRIMARY KEY (gid);" >> $name.sql
 
 echo "\\echo Clustering for efficiency..." >> $name.sql
 echo "ALTER TABLE "$name" CLUSTER ON "$name"_the_geom_idx;" >> $name.sql
 
 echo "\\echo Performing nearest neighbor query..." >> $name.sql
 echo "DROP TABLE IF EXISTS "$name"_height;" >> $name.sql
 echo "CREATE TABLE "$name"_height AS " >> $name.sql
 echo "SELECT x, y, height FROM " >> $name.sql
 echo "(SELECT DISTINCT ON(veg.gid) veg.gid as gid, ground.gid as gid_ground, veg.x as x, veg.y as y, ground.z as z, veg.z - ground.z as height, veg.the_geom as geometry, veg.class as class" >> $name.sql
 echo "FROM (SELECT * FROM "$name" WHERE class = 5) As veg, (SELECT * FROM "$name" WHERE class = 2) As ground" >> $name.sql
 echo "WHERE veg.class = 5 AND veg.gid <> ground.gid AND ST_DWithin(veg.the_geom, ground.the_geom, 10)" >> $name.sql
 echo "ORDER BY veg.gid, ST_Distance(veg.the_geom,ground.the_geom)) AS vegpoints WHERE height > 0;" >> $name.sql


 echo "\\echo Writing query back out to text file..." >> $name.sql
 echo "\copy "$name"_height TO '"$namen".txt'" >> $name.sql

  # Perform a little cleanup:
 if [ $debug = true ]
	then
		echo ""
		echo "Leaving tables in place for debug purposes."
	else
 		echo "\\echo Performing cleanup..." >> $name.sql
 		echo "TRUNCATE TABLE "$name"_height; TRUNCATE TABLE "$name";" >> $name.sql
 		echo "DROP TABLE IF EXISTS "$name"_height; DROP TABLE IF EXISTS "$name";" >> $name.sql
 fi
 
  
 echo "COMMIT;" >> $name.sql
  
 psql -d lidar -f $name.sql
 
 lidarcount=`wc -l $namen.txt | awk '{ print $1 };'`
 echo "#declare tree_coords_"$namen" = array["$lidarcount"]{" > $namen.inc
 more $namen.txt | awk '{ print "<" $1 ", 0, " $2 ">" };' >> $namen.inc
 echo "}" >> $namen.inc
 
 echo "#declare tree_height_"$namen" = array["$lidarcount"]{" >> $namen.inc
 more $namen.txt | awk '{ print $3 "," };' >> $namen.inc
 echo "}" >> $namen.inc 

  # Perform a little cleanup:
 if [ $debug = true ]
	then
		echo ""
		echo "Leaving files and tables in place for debug purposes."
	else
		echo ""
		echo "Deleting excess sql and csv files..."
		echo " ... if you need to retain these for debug purposes,"
		echo "     edit $0 shell file and change 'debug' to true."
		rm $name.sql $f.csv $namen.txt
		echo ""
 fi

done

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
