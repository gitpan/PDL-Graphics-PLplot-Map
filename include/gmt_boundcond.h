/*--------------------------------------------------------------------
 *    The GMT-system:	@(#)gmt_boundcond.h	3.5  06/20/99
 *
 *	Copyright (c) 1991-1999 by P. Wessel and W. H. F. Smith
 *	See COPYING file for copying and redistribution conditions.
 *
 *	This program is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; version 2 of the License.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	Contact info: www.soest.hawaii.edu/gmt
 *--------------------------------------------------------------------*/
/*
 * gmt_boundcond.h defines structures and functions used for setting
 * boundary conditions in processing grd file data.  
 *
 * Author:	W H F Smith
 * Date:	17 April 1998
 *
 */

struct GMT_EDGEINFO {
	/* Description below is the final outcome after parse and verify */
	int	nxp;	/* if X periodic, nxp > 0 is the period in pixels  */
	int	nyp;	/* if Y periodic, nxp > 0 is the period in pixels  */
	BOOLEAN	gn;	/* TRUE if top    edge will be set as N pole  */
	BOOLEAN	gs;	/* TRUE if bottom edge will be set as N pole  */
};


/*   GMT_boundcond_init initializes elements of struct to 0 and FALSE  */
EXTERN_MSC void GMT_boundcond_init (struct GMT_EDGEINFO *edgeinfo);

/*  GMT_boundcond_parse reads the argv[i][2] string and flags user's wishes  */
EXTERN_MSC int GMT_boundcond_parse (struct GMT_EDGEINFO *edgeinfo, char *edgestring);

/*  GMT_boundcond_param_prep sets edgeinfo according to wishes and grd h  */
EXTERN_MSC int GMT_boundcond_param_prep (struct GRD_HEADER *h, struct GMT_EDGEINFO *edgeinfo);

/*  GMT_boundcond_set sets padding values around grd to implement bond conds.  */
EXTERN_MSC int GMT_boundcond_set (struct GRD_HEADER *h, struct GMT_EDGEINFO *edgeinfo, int *pad, float *data);


