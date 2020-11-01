#To be inserted at 8006adf4
.include "../../Globals.s"
.include "../Header.s"

# Original Line
	stfs	f1, 0x0624 (r31)

# Update array of previous inputs
	lbz	r3, MEX_UCFPrevX(r31)
	stb	r3, MEX_UCF2fX(r31)
	lbz	r3, MEX_UCFCurrX(r31)
	stb	r3, MEX_UCFPrevX(r31)

# Store current
	lbz	r3, 0x1A8C (r31)
	stb	r3, MEX_UCFCurrX(r31)