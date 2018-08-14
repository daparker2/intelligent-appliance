// Mechanical model of Telesto Max10 FPGA module
// https://numato.com/docs/telesto-max-10-fpga-module/
// Recommended not to interfere with the board top dimensions below the height of P1 in your design

// Rounding function for round objects, reduce to increase performance
FN_ROUND=10;

// Error in mm which permits a differencing operation to produce a convex shape
FUZZ=0.001;

// Pin ports
PORT_PIN_PITCH=2.54;
PORT_PIN_R=1.1/2;
PORT_PIN_CX=4;
PORT_PIN_CY=24;
PORT_PIN_Z=10;
PORT_X=PORT_PIN_CX*PORT_PIN_PITCH;
PORT_Y=PORT_PIN_CY*PORT_PIN_PITCH;

// PCB chamfer areas
PCB_CHAMFER_X=0.44;
PCB_CHAMFER_Y=0.96;

// PCB dimensions
PCB_X=57.54;
PCB_Y=83.8;
PCB_Z=1;

// PCB hole dimensions
PCB_HOLE_R=3.25/2;
PCB_HOLE_Z=2*PCB_Z;
PCB_HOLE_X=28.96;
PCB_HOLE_Y=54.86;
PCB_HOLE_OX=14.29;
PCB_HOLE_OY=4.04;

// JTAG port dimensions
// (http://katalog.we-online.de/em/datasheet/6120xx21621.pdf)
JTAG_PORT_X=20.32;
JTAG_PORT_Y=9.10;
JTAG_PORT_Z=PCB_Z+9.10;
JTAG_PORT_OX=PCB_CHAMFER_X;
JTAG_PORT_OY=PCB_Y-JTAG_PORT_Y;
JTAG_PORT_OZ=-9.10;

// Header P1 dimensions
// (http://katalog.we-online.de/em/datasheet/6130xx11121.pdf)
P1_PIN_PITCH=2.54;
P1_PIN_R=1.1/2;
P1_PIN_H=PCB_Z + 6;
P1_PIN_CY=3;
P1_PIN_OX=PCB_HOLE_OX-1.5;
P1_PIN_OY=PCB_HOLE_OY+1.5;

// USB port J1
// (https://cdn.amphenol-icc.com/media/wysiwyg/files/drawing/10118192.pdf)
J1_PORT_X=7.5;
J1_PORT_Y=5.2;
J1_PORT_Z=PCB_Z + 1.9;
J1_PORT_OX=31.25;
J1_PORT_OY=-3;
J1_PORT_OZ=-1.9;

// Power port J2
// (https://www.cui.com/product/resource/pj-032bh.pdf)
J2_PORT_X=9;
J2_PORT_Y=12;
J2_PORT_Z=PCB_Z+11;
J2_PORT_OX=18.13;
J2_PORT_OY=-6;
J2_PORT_OZ=-11;

// FPGA estimate
FPGA_X=30;
FPGA_Y=30;
FPGA_Z=PCB_Z + 1.5;
FPGA_OX=14;
FPGA_OY=20;
FPGA_OZ=-1.5;

module port_bank() {
    translate([-PORT_PIN_PITCH/2, -PORT_PIN_PITCH/2, 0])
        for (x = [1:PORT_PIN_CX], y = [1:PORT_PIN_CY]) {
            translate([x * PORT_PIN_PITCH, y * PORT_PIN_PITCH, 0])
                cylinder(r=PORT_PIN_R, h=PORT_PIN_Z, $fn=FN_ROUND, center=true);
        }
}

module pcb_chamfer_area_x() {
    translate([-FUZZ,0,-PCB_Z/2])
        cube([PCB_CHAMFER_X + FUZZ, PCB_Y + FUZZ, PCB_Z * 2]);
}

module pcb_chamfer_area_y() {
    translate([0,-FUZZ,-PCB_Z/2])
        cube([PCB_X, PCB_CHAMFER_Y + FUZZ, PCB_Z * 2]);
}

module pcb_holes() {
    // Origin is relative to BL on the mechanical layout
    translate([PCB_HOLE_OX, PCB_HOLE_OY, FUZZ]) {
        cylinder(r=PCB_HOLE_R, h=PCB_HOLE_Z, center=true, $fn=FN_ROUND);
        translate([PCB_HOLE_X, 0, 0])
            cylinder(r=PCB_HOLE_R, h=PCB_HOLE_Z, center=true, $fn=FN_ROUND);    
        translate([0, PCB_HOLE_Y, 0])
            cylinder(r=PCB_HOLE_R, h=PCB_HOLE_Z, center=true, $fn=FN_ROUND);
        translate([PCB_HOLE_X, PCB_HOLE_Y, 0])
            cylinder(r=PCB_HOLE_R, h=PCB_HOLE_Z, center=true, $fn=FN_ROUND);
    }
}

module pcb() {
    color("DarkGreen", 1.0) {
        // Using minkowski difference here for chamfer kills the OpenSCAD
        //minkowski() {
            difference() {
                cube([PCB_X, PCB_Y, PCB_Z]);
                pcb_holes();
                //pcb_chamfer_area_x();
                //pcb_chamfer_area_y();
                //translate([PCB_X-PCB_CHAMFER_X+FUZZ,0,0])
                    //pcb_chamfer_area_x();
                //translate([0,PCB_Y-PCB_CHAMFER_Y+FUZZ,0])
                    //pcb_chamfer_area_y();
                
                // Left and right port banks
                translate([PCB_CHAMFER_X, PCB_CHAMFER_Y, 0])
                    port_bank();
                translate([PCB_X-PCB_CHAMFER_X-PORT_X, PCB_CHAMFER_Y, 0])
                    port_bank();
            }
            cylinder(r=(PCB_CHAMFER_X+PCB_CHAMFER_Y)/2, h=PCB_Z, $fn=FN_ROUND);
        //}
    }
}

module jtag_port() {
    color("DarkGray", 1.0) {
        translate([JTAG_PORT_OX, JTAG_PORT_OY, JTAG_PORT_OZ])
            cube([JTAG_PORT_X, JTAG_PORT_Y, JTAG_PORT_Z]);
    }
}

module p1_port() {
    color("Gold", 1.0) {
        translate([P1_PIN_OX - P1_PIN_PITCH/2, P1_PIN_OY - P1_PIN_PITCH/2, -PORT_PIN_Z/2 + PCB_Z])
            for (y = [1:P1_PIN_CY]) {
                translate([0, y * P1_PIN_PITCH, 0])
                    cylinder(r=PORT_PIN_R, h=PORT_PIN_Z, $fn=FN_ROUND, center=true);
            }
    }
}

module j1_port() {
    color("DarkGrey", 1.0) {
        translate([J1_PORT_OX, J1_PORT_OY, J1_PORT_OZ])
            cube([J1_PORT_X, J1_PORT_Y, J1_PORT_Z]);
    }
}

module j2_port() {
    color("DarkGrey", 1.0) {
        translate([J2_PORT_OX, J2_PORT_OY, J2_PORT_OZ])
            cube([J2_PORT_X, J2_PORT_Y, J2_PORT_Z]);
    }
}

module fpga() {
    // Just throw something roughly in the middle of the board to make it look pretty
    color("Black", 1.0) {
        translate([FPGA_OX, FPGA_OY, FPGA_OZ])
            cube([FPGA_X, FPGA_Y, FPGA_Z]);
    }
}

module pcba() {
    union() {
        pcb();
        jtag_port();
        p1_port();
        j1_port();
        j2_port();
        fpga();
    }
}

//p1_port();
pcba();
