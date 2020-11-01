#To be inserted at 8006ae8c
.include "../../Globals.s"
.include "../Header.s"

# Original Line
	stfs	f0, 0x0624 (r31)

# Update array of previous inputs
	lbz	r4, MEX_UCFPrevX(r31)
	stb	r4, MEX_UCF2fX(r31)
	lbz	r4, MEX_UCFCurrX(r31)
	stb	r4, MEX_UCFPrevX(r31)

# Store current
	lbz	r4,0x18(r3)
	stb	r4, MEX_UCFCurrX(r31)