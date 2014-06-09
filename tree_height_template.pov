
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
