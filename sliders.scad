//////////////////////////////////////////////////////////////////////
// LibFile: sliders.scad
//   Simple V-groove based sliders and rails.
//   To use, add these lines to the beginning of your file:
//   ```
//   include <BOSL2/std.scad>
//   include <BOSL2/sliders.scad>
//   ```
//////////////////////////////////////////////////////////////////////


// Section: Modules


// Module: slider()
// Description:
//   Creates a slider to match a V-groove rail.
// Usage:
//   slider(l, w, h, [base], [wall], [ang], [slop], [orient], [anchor])
// Arguments:
//   l = Length (long axis) of slider.
//   w = Width of slider.
//   h = Height of slider.
//   base = Height of slider base.
//   wall = Width of wall behind each side of the slider.
//   ang = Overhang angle for slider, to facilitate supportless printig.
//   slop = Printer-specific slop value to make parts fit exactly.
//   anchor = Alignment of the slider.  Use the constants from `constants.scad`.  Default: `UP`.
//   orient = Orientation of the slider.  Use the directional constants from `constants.scad`.  Default: `BACK`.
//   spin = Number of degrees to rotate around the Z axis, before orienting.
// Example:
//   slider(l=30, base=10, wall=4, slop=0.2, spin=90);
module slider(l=30, w=10, h=10, base=10, wall=5, ang=30, slop=PRINTER_SLOP, anchor=BOTTOM, spin=0, orient=UP)
{
	full_width = w + 2*wall;
	full_height = h + base;

	orient_and_anchor([full_width, l, h+2*base], orient, anchor, spin=spin, chain=true) {
		zrot(90)
		down(base+h/2) {
			// Base
			cuboid([full_width, l, base-slop], chamfer=2, edges=edges([FRONT,BACK], except=BOT), anchor=BOTTOM);

			// Wall
			xflip_copy(offset=w/2+slop) {
				cuboid([wall, l, full_height], chamfer=2, edges=edges(RIGHT, except=BOT), anchor=BOTTOM+LEFT);
			}

			// Sliders
			up(base+h/2) {
				xflip_copy(offset=w/2+slop+0.02) {
					bev_h = h/2*tan(ang);
					prismoid([h, l], [0, l-w], h=bev_h+0.01, orient=LEFT, anchor=BOT);
				}
			}
		}
		children();
	}
}



// Module: rail()
// Description:
//   Creates a V-groove rail.
// Usage:
//   rail(l, w, h, [chamfer], [ang], [orient], [anchor])
// Arguments:
//   l = Length (long axis) of slider.
//   w = Width of slider.
//   h = Height of slider.
//   chamfer = Size of chamfer at end of rail.
//   ang = Overhang angle for slider, to facilitate supportless printig.
//   anchor = Translate so anchor point is at origin (0,0,0).  See [anchor](attachments.scad#anchor).  Default: `BOTTOM`
//   spin = Rotate this many degrees around the Z axis after anchor.  See [spin](attachments.scad#spin).  Default: `0`
//   orient = Vector to rotate top towards, after spin.  See [orient](attachments.scad#orient).  Default: `UP`
// Example:
//   rail(l=100, w=10, h=10);
module rail(l=30, w=10, h=10, chamfer=1.0, ang=30, anchor=BOTTOM, spin=0, orient=UP)
{
	attack_ang = 30;
	attack_len = 2;

	fudge = 1.177;
	chamf = sqrt(2) * chamfer;
	cosa = cos(ang*fudge);
	sina = sin(ang*fudge);

	z1 = h/2;
	z2 = z1 - chamf * cosa;
	z3 = z1 - attack_len * sin(attack_ang);
	z4 = 0;

	x1 = w/2;
	x2 = x1 - chamf * sina;
	x3 = x1 - chamf;
	x4 = x1 - attack_len * sin(attack_ang);
	x5 = x2 - attack_len * sin(attack_ang);
	x6 = x1 - z1 * sina;
	x7 = x4 - z1 * sina;

	y1 = l/2;
	y2 = y1 - attack_len * cos(attack_ang);

	orient_and_anchor([w, l, h], orient, anchor, spin=spin, chain=true) {
		polyhedron(
			convexity=4,
			points=[
				[-x5, -y1,  z3],
				[ x5, -y1,  z3],
				[ x7, -y1,  z4],
				[ x4, -y1, -z1-0.05],
				[-x4, -y1, -z1-0.05],
				[-x7, -y1,  z4],

				[-x3, -y2,  z1],
				[ x3, -y2,  z1],
				[ x2, -y2,  z2],
				[ x6, -y2,  z4],
				[ x1, -y2, -z1-0.05],
				[-x1, -y2, -z1-0.05],
				[-x6, -y2,  z4],
				[-x2, -y2,  z2],

				[ x5,  y1,  z3],
				[-x5,  y1,  z3],
				[-x7,  y1,  z4],
				[-x4,  y1, -z1-0.05],
				[ x4,  y1, -z1-0.05],
				[ x7,  y1,  z4],

				[ x3,  y2,  z1],
				[-x3,  y2,  z1],
				[-x2,  y2,  z2],
				[-x6,  y2,  z4],
				[-x1,  y2, -z1-0.05],
				[ x1,  y2, -z1-0.05],
				[ x6,  y2,  z4],
				[ x2,  y2,  z2],
			],
			faces=[
				[0, 1, 2],
				[0, 2, 5],
				[2, 3, 4],
				[2, 4, 5],

				[0, 13, 6],
				[0, 6, 7],
				[0, 7, 1],
				[1, 7, 8],
				[1, 8, 9],
				[1, 9, 2],
				[2, 9, 10],
				[2, 10, 3],
				[3, 10, 11],
				[3, 11, 4],
				[4, 11, 12],
				[4, 12, 5],
				[5, 12, 13],
				[5, 13, 0],

				[14, 15, 16],
				[14, 16, 19],
				[16, 17, 18],
				[16, 18, 19],

				[14, 27, 20],
				[14, 20, 21],
				[14, 21, 15],
				[15, 21, 22],
				[15, 22, 23],
				[15, 23, 16],
				[16, 23, 24],
				[16, 24, 17],
				[17, 24, 25],
				[17, 25, 18],
				[18, 25, 26],
				[18, 26, 19],
				[19, 26, 27],
				[19, 27, 14],

				[6, 21, 20],
				[6, 20, 7],
				[7, 20, 27],
				[7, 27, 8],
				[8, 27, 26],
				[8, 26, 9],
				[9, 26, 25],
				[9, 25, 10],
				[10, 25, 24],
				[10, 24, 11],
				[11, 24, 23],
				[11, 23, 12],
				[12, 23, 22],
				[12, 22, 13],
				[13, 22, 21],
				[13, 21, 6],
			]
		);
		children();
	}
}



// vim: noexpandtab tabstop=4 shiftwidth=4 softtabstop=4 nowrap
