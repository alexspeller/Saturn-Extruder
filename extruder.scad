include <MCAD/bearing.scad>;
include <MCAD/motors.scad>;
include <nutsnbolts/cyl_head_bolt.scad>;
include <utils.scad>;
use <MCAD/hardware.scad>;
use <saturn.ttf>;
// Planetary gear bearing (customizable)
//https://woodgears.ca/gear/planetary.html
//
//If you want the planetary gears to be evenly spaced, and all be
//engaging the next tooth at the same time, then both your sun
//and your ring gear needs to be evenly divisible by the number of planets.
//http://www.torcbrain.de/uebersetzungsrechner-planetengetriebe/?lang=en
//
//
//translate([0, 0, 25])
//rotate([180, 0, 0])
//stepper_motor_mount(17,slide_distance=0, mochup=true, tolerance=0);
//
// outer diameter of ring
full_outer_diameter = 65;
D=full_outer_diameter - 8;
// thickness
T=12;
// clearance
tol=0.15;
number_of_planets=3;
number_of_teeth_on_planets=15;
approximate_number_of_teeth_on_sun=9;
//number_of_planets=4;
//number_of_teeth_on_planets=14;
//approximate_number_of_teeth_on_sun=8;

pushfitsize = 10.5;
pushfitpitch = 0.907;

spring_compressed_length = 13;
spring_outer_diameter = 7.5;
spring_inner_diameter = 5.5;
spring_stud_radius = (spring_inner_diameter-0.8) / 2;

// pressure angle
P=45;//[30:60]
// number of teeth to twist across
nTwist=1;
// width of hexagonal hole
w=4;
$fn=20;
DR=0.5*1;// maximum depth ratio of teeth


assembly();

module assembly() {
	//planet_carrier();
	//translate([0, 0, 15]) idler();
	translate([0, 0, 5]) rotate([180, 0, 0]) planetary_gears();
	top_case();
	filament();
}


module screws_for_top() {
	for(r=[45:90:360]) {
		rotate([0, 0, r])
		translate([29.3, 0, 0]) {
			rotate([180, 0, 0]) {
				%screw("M3x12");
				translate([0, 0, 16])
				hole_through("M3", l=12, h=16);
				translate([0, 0, -9])
				nutcatch_sidecut(name="M3", l=4.5, clh=0.2);
			}
		}
	}

}


module filament() {
	%translate([-50, 6.9, 22.5])
	rotate([0, 90, 0])
	cylinder(r=1.5, h=100);
}


module top_case() {
	h = 32;

	%translate([0, 0, 31]) bearing(model=608);

	difference() {
		union() {

			// spring
			%translate([0, 0, 40])
			rotate([0, 90, -10])
			translate([17.5, -26.5, 10 - spring_compressed_length])
			cylinder(r=spring_outer_diameter / 2, h=spring_compressed_length);

			// spring stud
			translate([-6, -10, 22.5])
			rotate([0, 90, -10])
			translate([0, -15, 14 - spring_compressed_length])
			cylinder(h=2, r=spring_stud_radius);

			difference() {
				translate([-15, -30, 17])
				rotate([0, 0, -10])
				translate([6 - spring_compressed_length, 0, 0])
					cube([14,15,20]);

				translate([-32, -28, 16])
				rotate([0, 0, -30])
				cube([20,10,30]);
			}


			//lid
			difference() {
				union() {
					translate([0, 0, 37])
						cylinder(r=full_outer_diameter/2, h=3, $fn=100);
					translate([0, 0, 32])
					cylinder(r=15, h=5);
				}
				translate([0, 0, 31]) scale(1.02) bearing(model=608, outline=true);
				cylinder(r=4.1, h=50);
			}

			// top idler brace
			difference() {
				union() {
					translate([0, 0, 31])
						cylinder(r=full_outer_diameter / 2, h=8, $fn=100);
					translate([14, 26, 30])
						cylinder(r=3, h=1);

				}

				translate([0, 0, 4])
					cylinder(r=full_outer_diameter / 2 - 6.5, h=36, $fn=100);

			}

			// bottom idler brace
			difference() {
				union() {
					translate([0, 0, 5])
						cylinder(r=full_outer_diameter / 2, h=9, $fn=100);
					translate([14, 26, 14])
						cylinder(r=3, h=1);
				}

				translate([0, 0, 4])
					cylinder(r=full_outer_diameter / 2 - 6.5, h=36, $fn=100);

				translate([-40, -60, 4])
					cube([50,80,36]);
				translate([-40, -60, 4])
				rotate([0, 0, 20])
					cube([50,80,36]);

				translate([0, -72.5, 4])
				rotate([0, 0, -10])
					cube([50,79,36]);

				rotate([0, 0, -10])
				translate([-70, 17, 4])
					cube([50,17,36]);

				translate([14, 26, 34]) {
					%screw("M3x25");
					translate([0, 0, 30])
					hole_through("M3", l=25, h=30);
					translate([0, 0, -22.5])
					rotate([0, 0, 45])
					nutcatch_sidecut(name="M3", l=4.5, clh=0.2);
				}

			}

			// outer walls
			difference() {
				translate([0, 0, 5])
					cylinder(r=full_outer_diameter / 2, h=h, $fn=100);

				translate([0, 0, 4])
					cylinder(r=full_outer_diameter / 2 - 6.5, h=36, $fn=100);

				rotate([0, 0, -10])
				translate([10.4 - spring_compressed_length, -45, 14]) //-5.6
					cube([15.5 + spring_compressed_length,44,36]);


				translate([-64.5, -2.2, 4])
				rotate([0, 0, -45])
					cube([31.5,44,36]);

				rotate([0, 0, -10])
				translate([10, 8, 4])
					cube([30,15,36]);

				rotate([0, 0, -10])
				translate([-19, 17, 4])
					cube([50,17,36]);
			}
			//arms

			difference() {
				union() {
					translate([-30, -12, 15])
					rotate([0, 0, -45])
					  cube([6, 25, 23]);
				translate([-15.1, 10.5, 15])
					rotate([0, 0, 45])
					  cube([6, 14, 23]);
				}
				translate([-18, 1, 14])
				  cube([20, 11.5, 20]);
				 cylinder(r=11.2, h=50, $fn=40);
				 translate([0, 19.5, 14])
				 cylinder(r=12, h=50, $fn=40);



			}


			// push fit mount
			difference() {
				translate([-17.5, -1, 15])
					cube([13, 16, 23]);
				translate([0, 0, 14])
				cylinder(r=11.3, h=25, $fn=40);
				translate([0, 19.5, 14])
				cylinder(r=12, h=25, $fn=40);

				//filament hole
				translate([-50, 6.9, 22.5])
				rotate([0, 90, 0])
				cylinder(r=1.65, h=100);
				// flange
				translate([-10, 6.9, 22.5])
				rotate([0, 90, 0])
				cylinder(r1=1.65, r2=2.3, h=3);


				translate([-15, 6.9, 22.5])
				rotate([0, 90, 0])
				rod( 5, true, renderrodthreads=true, rodsize=pushfitsize, rodpitch=pushfitpitch );
			}

		}

		translate([14, 26, 34]) {
			%screw("M3x25");
			translate([0, 0, 30])
			hole_through("M3", l=20, h=30);
		}

		//logo
		difference() {
			translate([0, 18, 30])
				cylinder(r=9,h=20);
		
			translate([0, 18, 0])
			rotate([0, 0, -20])
			scale([2, 0.4, 1])
			difference() {
			translate([0, 0, 30])
				cylinder(r=9,h=20);
			translate([0, 0, 30])
				cylinder(r=7,h=20);
			}
		}
		difference() {
			translate([0, 18, 0])
			rotate([0, 0, -20])
			scale([2, 0.4, 1])
			difference() {
			translate([0, 0, 39.5])
				cylinder(r=9,h=20);
			translate([0, 0, 39.5])
				cylinder(r=7,h=20);
			}
			translate([0, 20, 30])
				cylinder(r=8,h=20);

		}

		translate([0, -16, 39.5])
		linear_extrude(height = 0.5) {
			text("Saturn", font="Saturn\\-Regular:style=Regular", halign="center", size=8.5);
		}

		screws_for_top();
	}

}


module idler() {
	%translate([0, 19.4, 4]) bearing(model=608);
	%translate([14, 26, 19]) {
		screw("M3x25");
		translate([0, 0, 30])
		hole_through("M3", l=40, h=30);
	}

		//filament
	difference() {

		cylinder(r=full_outer_diameter / 2, h=15, $fn=100);
			rotate([0, 0, -10])
			translate([24, -25, -0.5])
			cube([10,50,16]);

		rotate([0, 0, -10])
			translate([-35, -35, -0.5])
			cube([45,53.4,16]);

		rotate([0, 0, -10])
		translate([-37, -35, -0.5])
			cube([20,80,16]);

		translate([0, 19.4, 3.8]) scale(1.06) bearing(model=608, outline=true);
		//#translate([0, 19, 10]) scale(1.05) bearing(model=608, outline=true);

		// filament hole
		translate([-20, 6.9, 7.5])
		rotate([0, 90, 0])
		cylinder(r=1.8, h=60);

		translate([23.1, 6.9, 7.5])
		rotate([0, 90, 0])
		cylinder(r1=1.8, r2=3, h=3);

		// pivot
		translate([14, 26, 0])
			cylinder(r=1.55, h=15);

		// axle
		translate([0, 19, 1])
		cylinder(r=4, h=13);
		translate([0, 19, 1])
		%cylinder(r=4, h=13);
	}

	// spring stud
	translate([-10, -10, 7.5])
	rotate([0, 90, -10])
	translate([0, -15, 16.2])
	cylinder(h=2, r=spring_stud_radius);
	// handle
	difference() {
		union() {
			rotate([0, 0, -10])
			translate([10, -40, 0])
				cube([14, 20, 15]);
			rotate([0, 0, -10])
			translate([12.3, -40, 0])
				cylinder(h=15, r=2.3);
		}

		translate([36, -50.9, -0.5])
			cylinder(h=16, r=30, $fn=100);
	}
}

module bolt() {
	gear2_bolt_hex_d       = 12.8;
	gear2_bolt_hex_r        = gear2_bolt_hex_d/2;

	translate([0, 0, 5.3])
		cylinder(h=25, r=4);
		cylinder(r=gear2_bolt_hex_r  / cos(180 / 6), h=5.3, $fn=6);

}

module pulley() {
	translate([0, 0, 6.8])
	cylinder(r=11.35/2, h=3.5);
	difference() {
		cylinder(h=12.6, r=13.2 / 2);
		translate([0, 0, 6.8])
			cylinder(r=13.3/2, h=3.5);
	}
}

module planet_carrier() {
	m=round(number_of_planets);
	np=round(number_of_teeth_on_planets);
	ns1=approximate_number_of_teeth_on_sun;
	k1=round(2/m*(ns1+np));

	k= k1*m%2!=0 ? k1+1 : k1;
	ns=k*m/2-np;
	nr=ns+2*np;
	pitchD=0.9*D/(1+min(PI/(2*nr*tan(P)),PI*DR/nr));
	pitch=pitchD*PI/nr;
	helix_angle=atan(2*nTwist*pitch/T);
	phi=$t*360/m;

	difference() {
		union() {
			// carrier body
			translate([0, 0, 6])
			cylinder(r=pitchD/2 - 1 - 2, h=3, $fn=100);

			translate([0, 0, 9]) {
				%bolt();
				//pully
				% translate([0, 0, 22]) rotate([180,0,0]) pulley();
				// bolt restraint
				//%translate([0, 0, 21]) bearing(model=608);
				// bolt fitting
				difference() {
					cylinder(r=11, h=5.3);
					bolt();
				}
			}

			for(i=[1:m])rotate([0,0,i*360/m+phi])translate([pitchD/2*(ns+np)/nr,0,0])
				rotate([0,0,i*ns/m*360/np-phi*(ns+np)/np-phi])
					union() {
						translate([0, 0, 1])
						%bearing(model=623, outline=false, sideMaterial=Brass);
						// grubscrew holder
						translate([0, 0, 9])
						cylinder(h=4, r=6);
					}
		}



		for(i=[1:m]) {
			rotate([0,0,i*360/m+phi])translate([pitchD/2*(ns+np)/nr,0,0])
			rotate([0,0,i*ns/m*360/np-phi*(ns+np)/np-phi]) {
				union() {
					//%bearing(model=624, outline=false, sideMaterial=Brass);
					// grubscrew
					translate([0, 0, 7.4])
						nut("M3");
					%translate([0, 0, 7.4])
						nut("M3");
					translate([0, 0, 10])
					%screw("M3x8");
					translate([0, 0, 20-7])
						hole_through("M3", l=8, h=10-7);
				}

			}
		}

	}


}

module planetary_gears() {
	m=round(number_of_planets);
	np=round(number_of_teeth_on_planets);
	ns1=approximate_number_of_teeth_on_sun;
	k1=round(2/m*(ns1+np));

	k= k1*m%2!=0 ? k1+1 : k1;
	ns=k*m/2-np;
	nr=ns+2*np;
	pitchD=0.9*D/(1+min(PI/(2*nr*tan(P)),PI*DR/nr));
	pitch=pitchD*PI/nr;
	helix_angle=atan(2*nTwist*pitch/T);

	if(ns1 != ns) {
		log_error(str("Sun gear teeth number was adjusted from ", ns1, " to ", ns));
	}

	echo(ring_gear_teeth=nr);
	if(nr / m != round(nr / m)) {
		log_error("Ring gear teeth is not evenly divisible by the number of planets");
	}
	if(ns / m != round(ns / m)) {
		log_error(str("Sun gear teeth (", ns, ") is not evenly divisible by the number of planets"));
	}

	gear_ratio = 1 + nr / ns;
	log_blue(str("Gear ratio is ", gear_ratio));
	phi=$t*360/m;
	difference() {
	translate([0,0,T/2]){
		// 1515 mount
		difference() {
			translate([-full_outer_diameter / 2, -35, -T/2])
			cube([4, 70, 15]);
			translate([-full_outer_diameter / 2 + 4, -28.5, 1])
			rotate([0, 90, 0])
			hole_through("M3", l=4);
			translate([-full_outer_diameter / 2 + 4, 28.5, 1])
			rotate([0, 90, 0])
			hole_through("M3", l=4);
		}

		difference(){
			cylinder(r=full_outer_diameter/2,h=T,center=true,$fn=100);
			herringbone(nr,pitch,P,DR,-tol,helix_angle,T+0.2);

		}

		// stepper mount
		translate([0, 0, T/2])
		difference() {
			union() {
				cylinder(r1=full_outer_diameter/2, r2=49/2 - 4, h=13, $fn=100);
				for (i = [45:90:359]) {
					rotate([0, 0, i])
						translate([20, 0, 9])
						cylinder(r=6, h=4);
				}
			}
			translate([0, 0, -1])
			cylinder(r1=full_outer_diameter/2 - 6, r2=49/2 - 6, h=15, $fn=100);
			translate([0, 0, -1])
			for (i = [15:180:359]) {
				//rotate([0, 0, i])
				//arc(height=15, depth=20, radius=full_outer_diameter / 2 + 1, degrees=30);
			}

			for (i = [45:90:359]) {
				rotate([0, 180, i])
				translate([22, 0, -11]) { //-11
					translate([0, 0, 11]) hole_through(name="M3", l=8, h=11,cld=0.15);
					translate([4, 0, 6.5]) cube([13,6.5,9], center = true);
					%screw("M3x8");
				}
			}

		}

		cone_height = 9;
		// Sun gear
		rotate([0,0,(np+1)*180/ns+phi*(ns+np)*2/ns])
		difference(){
			union() {
				mirror([0,1,0])
					herringbone(ns,pitch,P,DR,tol,helix_angle,T);
					translate([0, 0, T/2])
				cylinder(h=cone_height, r1=5.2, r2=10, $fn=40);
			}

			// shaft hole
			translate([0, 0, -T/2])
				cylinder(r=5.4/2, h=24, $fn=40);
			// nut holes
			for (i = [0:120:360]) {
				rotate([0, 0, i])
				translate([0, 0, cone_height + T/2 - 3.5])
				rotate([0, 90]) {
					translate([0, 0, -5.5])
					rotate([0, 180, 0])
					nutcatch_sidecut(name="M3", l=4.5, clh=0.1);
					hole_through(name="M3", l=8);
				}
			}
		}

		// planet gears
		for(i=[1:m])rotate([0,0,i*360/m+phi])translate([pitchD/2*(ns+np)/nr,0,0])
			rotate([0,0,i*ns/m*360/np-phi*(ns+np)/np-phi])
				difference() {
					herringbone(np,pitch,P,DR,tol,helix_angle,T);
					translate([0, 0, -T/2
						]) {
						scale(1.04)
						bearing(model=623, outline=true,
							material=Steel, sideMaterial=Brass);
					}

				}
	}
	translate([0, 0, 5])rotate([-180, 0, 0]) {
			screws_for_top();

		}

	}

}
module rack(
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	helix_angle=0,
	clearance=0,
	gear_thickness=5,
	flat=false){
addendum=circular_pitch/(4*tan(pressure_angle));

flat_extrude(h=gear_thickness,flat=flat)translate([0,-clearance*cos(pressure_angle)/2])
	union(){
		translate([0,-0.5-addendum])square([number_of_teeth*circular_pitch,1],center=true);
		for(i=[1:number_of_teeth])
			translate([circular_pitch*(i-number_of_teeth/2-0.5),0])
			polygon(points=[[-circular_pitch/2,-addendum],[circular_pitch/2,-addendum],[0,addendum]]);
	}
}

module herringbone(
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	depth_ratio=1,
	clearance=0,
	helix_angle=0,
	gear_thickness=5){
	union(){
	gear(number_of_teeth,
		circular_pitch,
		pressure_angle,
		depth_ratio,
		clearance,
		helix_angle,
		gear_thickness/2);
	mirror([0,0,1])
		gear(number_of_teeth,
			circular_pitch,
			pressure_angle,
			depth_ratio,
			clearance,
			helix_angle,
			gear_thickness/2);
}}

module gear (
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	depth_ratio=1,
	clearance=0,
	helix_angle=0,
	gear_thickness=5,
	flat=false){
pitch_radius = number_of_teeth*circular_pitch/(2*PI);
twist=tan(helix_angle)*gear_thickness/pitch_radius*180/PI;

flat_extrude(h=gear_thickness,twist=twist,flat=flat)
	gear2D (
		number_of_teeth,
		circular_pitch,
		pressure_angle,
		depth_ratio,
		clearance);
}

module flat_extrude(h,twist,flat){
	if(flat==false)
		linear_extrude(height=h,twist=twist,slices=twist/6)children(0);
	else
		children(0);
}

module gear2D (
	number_of_teeth,
	circular_pitch,
	pressure_angle,
	depth_ratio,
	clearance){
pitch_radius = number_of_teeth*circular_pitch/(2*PI);
base_radius = pitch_radius*cos(pressure_angle);
depth=circular_pitch/(2*tan(pressure_angle));
outer_radius = clearance<0 ? pitch_radius+depth/2-clearance : pitch_radius+depth/2;
root_radius1 = pitch_radius-depth/2-clearance/2;
root_radius = (clearance<0 && root_radius1<base_radius) ? base_radius : root_radius1;
backlash_angle = clearance/(pitch_radius*cos(pressure_angle)) * 180 / PI;
half_thick_angle = 90/number_of_teeth - backlash_angle/2;
pitch_point = involute (base_radius, involute_intersect_angle (base_radius, pitch_radius));
pitch_angle = atan2 (pitch_point[1], pitch_point[0]);
min_radius = max (base_radius,root_radius);

intersection(){
	rotate(90/number_of_teeth)
		circle($fn=number_of_teeth*3,r=pitch_radius+depth_ratio*circular_pitch/2-clearance/2);
	union(){
		rotate(90/number_of_teeth)
			circle($fn=number_of_teeth*2,r=max(root_radius,pitch_radius-depth_ratio*circular_pitch/2-clearance/2));
		for (i = [1:number_of_teeth])rotate(i*360/number_of_teeth){
			halftooth (
				pitch_angle,
				base_radius,
				min_radius,
				outer_radius,
				half_thick_angle);
			mirror([0,1])halftooth (
				pitch_angle,
				base_radius,
				min_radius,
				outer_radius,
				half_thick_angle);
		}
	}
}}

module halftooth (
	pitch_angle,
	base_radius,
	min_radius,
	outer_radius,
	half_thick_angle){
index=[0,1,2,3,4,5];
start_angle = max(involute_intersect_angle (base_radius, min_radius)-5,0);
stop_angle = involute_intersect_angle (base_radius, outer_radius);
angle=index*(stop_angle-start_angle)/index[len(index)-1];
p=[[0,0],
	involute(base_radius,angle[0]+start_angle),
	involute(base_radius,angle[1]+start_angle),
	involute(base_radius,angle[2]+start_angle),
	involute(base_radius,angle[3]+start_angle),
	involute(base_radius,angle[4]+start_angle),
	involute(base_radius,angle[5]+start_angle)];

difference(){
	rotate(-pitch_angle-half_thick_angle)polygon(points=p);
	square(2*outer_radius);
}}

// Mathematical Functions
//===============

// Finds the angle of the involute about the base radius at the given distance (radius) from it's center.
//source: http://www.mathhelpforum.com/math-help/geometry/136011-circle-involute-solving-y-any-given-x.html

function involute_intersect_angle (base_radius, radius) = sqrt (pow (radius/base_radius, 2) - 1) * 180 / PI;

// Calculate the involute position for a given base radius and involute angle.

function involute (base_radius, involute_angle) =
[
	base_radius*(cos (involute_angle) + involute_angle*PI/180*sin (involute_angle)),
	base_radius*(sin (involute_angle) - involute_angle*PI/180*cos (involute_angle))
];


module arc( height, depth, radius, degrees ) {
    // This dies a horible death if it's not rendered here
    // -- sucks up all memory and spins out of control
    render() {
        difference() {
            // Outer ring
            rotate_extrude($fn = 100)
                translate([radius - height, 0, 0])
                    square([height,depth]);

            // Cut half off
            translate([0,-(radius+1),-.5])
                cube ([radius+1,(radius+1)*2,depth+1]);

            // Cover the other half as necessary
            rotate([0,0,180-degrees])
            translate([0,-(radius+1),-.5])
                cube ([radius+1,(radius+1)*2,depth+1]);

        }
    }
}
