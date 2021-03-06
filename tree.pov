//Set the center of image
#declare scene_center_x=;
#declare scene_center_y=2500;

//Include locations and heights for trees.
#include "tree.inc"

#version 3.6;

// Pov Includes
#include "colors.inc"  
#include "transforms.inc"

// Custom Include
#include "tree.inc" //degenerate 3D tree stamp

#declare Camera_Size = 5000; //5000 ft x 5000 ft grid for OSIP
background {color <0, 0, 0>}

#declare Camera_Location = <scene_center_x,175,scene_center_y> ;
#declare Camera_Lookat   = <scene_center_x,0,scene_center_y> ; 
 
// Use orthographic camera for true plan view 
camera {
        orthographic
        location Camera_Location
        look_at Camera_Lookat
        right Camera_Size*x
        up Camera_Size*y
}   

// Union all the trees together into one object


union {

	#declare Rnd_1 = seed (1153);

	#declare LastIndex = dimension_size(tree_coords_tree, 1)-2;
	#declare Index = 0;
	#while(Index <= LastIndex)
                        object  {
	                      TREE
        		         scale tree_height_tree[Index]
		                rotate <0,rand(Rnd_1)*360,0>
		                translate tree_coords_tree[Index] 
        	        }
		#declare Index = Index + 1;
	#end

// Pigment trees according to distance from camera
	 pigment {
 		gradient x color_map {
 			[0 color rgb 1]
 			[1 color rgb 0]
 		}
	 	scale <vlength(Camera_Location-Camera_Lookat),1,1>
 	 	Reorient_Trans(x, Camera_Lookat-Camera_Location)
 	 	translate Camera_Location
	 }
 	finish {ambient 1}
}
