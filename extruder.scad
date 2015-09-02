include <MCAD/bearing.scad>
include <MCAD/motors.scad>
include <nutsnbolts/cyl_head_bolt.scad>
include <utils.scad>


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
//stepper_motor_mount(17,slide_distance=0, mochup=false, tolerance=0);
//
// outer diameter of ring
full_outer_diameter = 55;
D=full_outer_diameter - 8;
// thickness
T=12;
// clearance
tol=0.15;
number_of_planets=4;
number_of_teeth_on_planets=24;
approximate_number_of_teeth_on_sun=16;


// pressure angle
P=45;//[30:60]
// number of teeth to twist across
nTwist=1;
// width of hexagonal hole
w=4;

DR=0.5*1;// maximum depth ratio of teeth
planetary_gears();

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

	translate([0,0,T/2]){
		difference(){
			cylinder(r=full_outer_diameter/2,h=T,center=true,$fn=100);
			herringbone(nr,pitch,P,DR,-tol,helix_angle,T+0.2);
			for (i = [45:90:359]) {
				rotate([0, 180, i])
				translate([22, 0, -17]) { //-11
					translate([5, 0, 10])
					rotate([0, 15, 0])
					cylinder(r=1.5, h=10, $fn=20);
				}
			}

		}

		// stepper mount
		translate([0, 0, T/2])
		difference() {
			union() {
				cylinder(r1=full_outer_diameter/2, r2=49/2 - 4, h=13, $fn=100);
				for (i = [45:90:359]) {
					rotate([0, 0, i])
						translate([20, 0, 9])
						cylinder(r=8, h=4);
				}
			}
			translate([0, 0, -1])
			cylinder(r1=full_outer_diameter/2 - 6, r2=49/2 - 11, h=15, $fn=100);
			translate([0, 0, -1])
			for (i = [15:90:359]) {
				rotate([0, 0, i])
				arc(height=15, depth=20, radius=full_outer_diameter / 2 + 1, degrees=30);
			}

			for (i = [45:90:359]) {
				rotate([0, 180, i])
				translate([22, 0, -11]) { //-11
					translate([0, 0, 11]) hole_through(name="M3", l=8, h=11);
					translate([4, 0, 11]) hole_through(name="M3", l=0, h=9);
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
				cylinder(h=cone_height, r1=4.6, r2=9, $fn=40);
			}

			// shaft hole
			translate([0, 0, -T/2])
				cylinder(r=2.55, h=24, $fn=40);
			// nut holes
			for (i = [0:120:360]) {
				rotate([0, 0, i])
				translate([0, 0, cone_height + T/2 - 3.5])
				rotate([0, 90]) {
					translate([0, 0, -5.5])
					rotate([0, 180, 0])
					nutcatch_sidecut(name="M3", l=4.5);
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
						])
					bearing(model=623, outline=true,
						material=Steel, sideMaterial=Brass);

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
