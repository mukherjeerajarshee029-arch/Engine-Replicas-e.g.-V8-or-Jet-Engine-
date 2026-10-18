// V8 Engine Educational CAD Assembly
// Units: millimetres
// Parametric OpenSCAD concept model — non-combustion display prototype.
// IMPORTANT: This is a visual/educational starting model, NOT a validated mechanism.
// Verify fit, collisions, print orientation, and tolerances before fabrication.

$fn = 48;

// ---------- Main parameters ----------
engine_length = 150;
engine_width  = 118;
engine_height = 112;
bank_angle = 45;                 // Each bank tilted from vertical
bore_d = 20;
piston_h = 18;
stroke = 18;
rod_cc = 42;
crank_radius = stroke/2;
crankshaft_d = 5;
bearing_clearance = 0.30;        // initial diametral allowance for prototype
wall = 4;
show_pistons = true;
show_rods = true;
show_crankshaft = true;
show_heads = true;
show_intake = true;
show_exhaust = true;
show_stand = true;

// Colors are for visual grouping in OpenSCAD.
block_color = [0.42,0.46,0.50];
head_color  = [0.22,0.25,0.29];
piston_color = [0.78,0.80,0.82];
rod_color = [0.85,0.48,0.12];
crank_color = [0.18,0.22,0.26];
intake_color = [0.10,0.28,0.45];

// ---------- Helper geometry ----------
module rounded_box(size=[10,10,10], r=2) {
    // Rounded external block made by hull; dimensions remain approximate.
    hull() for (x=[r,size[0]-r], y=[r,size[1]-r], z=[r,size[2]-r])
        translate([x,y,z]) sphere(r=r);
}

module cylinder_bank(side=1) {
    // Bank with four cylinder bores arranged along engine length.
    // The bore axes follow the bank angle.
    color(block_color)
    difference() {
        rotate([0, side*bank_angle, 0])
            translate([-26, -engine_length/2, 0])
                cube([52, engine_length, 58], center=false);
        for (i=[0:3]) {
            y = -engine_length/2 + 22 + i*35;
            rotate([0, side*bank_angle, 0])
                translate([0, y, 31])
                    rotate([90,0,0])
                        cylinder(d=bore_d+0.5, h=30, center=true);
        }
    }
}

module crankcase() {
    color(block_color)
    difference() {
        translate([-40,-engine_length/2-8,-18])
            cube([80,engine_length+16,38]);
        translate([0,0,-1])
            rotate([90,0,0])
                cylinder(d=26,h=engine_length+20,center=true);
    }
}

module piston(x,y,z) {
    color(piston_color)
    translate([x,y,z])
    difference() {
        cylinder(d=bore_d-0.35,h=piston_h,center=true);
        translate([0,0,-piston_h/2-0.1])
            cylinder(d=8,h=piston_h+0.2);
    }
}

module connecting_rod(p1,p2) {
    // p1 and p2 are 3D points. Hull of end bosses makes a simple rod.
    color(rod_color)
    hull() {
        translate(p1) sphere(d=8);
        translate(p2) sphere(d=7);
    }
}

module crankshaft() {
    // Simplified visual crankshaft: longitudinal shaft, four paired throws.
    color(crank_color) {
        rotate([90,0,0])
            cylinder(d=crankshaft_d,h=engine_length+30,center=true);
        for (i=[0:3]) {
            yy = -engine_length/2 + 25 + i*35;
            // crank webs on either side of each throw
            translate([0,yy,-crank_radius])
                cube([24,5,5],center=true);
            translate([0,yy+10,crank_radius])
                cube([24,5,5],center=true);
            translate([0,yy+5,0])
                rotate([90,0,0])
                    cylinder(d=crankshaft_d,h=12,center=true);
        }
    }
}

module cylinder_heads() {
    for (side=[-1,1]) {
        color(head_color)
        rotate([0,side*bank_angle,0])
            translate([-28,-engine_length/2,54])
                cube([56,engine_length,12]);
    }
}

module intake_manifold() {
    color(intake_color) {
        translate([-22,-engine_length/2+12,52])
            cube([44,engine_length-24,15]);
        for (i=[0:3]) {
            y=-engine_length/2+25+i*35;
            translate([0,y,58])
                cylinder(d=12,h=18);
        }
    }
}

module exhaust_headers() {
    for (side=[-1,1]) {
        color([0.72,0.30,0.12])
        for (i=[0:3]) {
            y=-engine_length/2+20+i*35;
            translate([side*36,y,18])
                rotate([0,side*18,side*12])
                    cylinder(d=7,h=42);
        }
    }
}

module flywheel() {
    color([0.15,0.17,0.19])
    translate([0,engine_length/2+12,-1])
        rotate([90,0,0])
            difference() {
                cylinder(d=52,h=8,center=true);
                cylinder(d=crankshaft_d+1,h=10,center=true);
            }
}

module display_stand() {
    color([0.12,0.14,0.17]) {
        translate([-48,-engine_length/2-18,-40])
            cube([96,engine_length+36,8]);
        for (y=[-engine_length/2+10,engine_length/2-10])
            translate([-32,y,-32]) cube([8,8,20]);
        for (y=[-engine_length/2+10,engine_length/2-10])
            translate([24,y,-32]) cube([8,8,20]);
    }
}

// ---------- Assembly ----------
module v8_engine() {
    // Crankcase and cylinder banks
    crankcase();
    cylinder_bank(-1);
    cylinder_bank(1);

    if (show_heads) cylinder_heads();
    if (show_intake) intake_manifold();
    if (show_exhaust) exhaust_headers();
    if (show_crankshaft) crankshaft();
    flywheel();

    // Eight approximate pistons and connecting rods.
    // Positions are arranged for visualization only; this is not a kinematically constrained assembly.
    for (side=[-1,1]) {
        for (i=[0:3]) {
            y=-engine_length/2+22+i*35;
            x=side*17;
            z=24 + ((i%2==0) ? 4 : -4);
            if (show_pistons) piston(x,y,z);
            if (show_rods)
                connecting_rod([x,y,z-piston_h/2],[0,y+5,-crank_radius]);
        }
    }
    if (show_stand) display_stand();
}

v8_engine();

// ---------- Export notes ----------
// To export: Open this file in OpenSCAD, press F6 (Render), then File > Export > Export as STL.
// Export one part at a time by temporarily commenting out v8_engine(); and calling the desired module.
// The assembly is a concept model; check all clearances and rebuild moving joints before printing.
