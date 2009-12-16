################################################################################
#
# Copyright (c) 2009 The MadGraph Development team and Contributors
#
# This file is a part of the MadGraph 5 project, an application which 
# automatically generates Feynman diagrams and matrix elements for arbitrary
# high-energy processes in the Standard Model and beyond.
#
# It is subject to the MadGraph license which should accompany this 
# distribution.
#
# For more information, please visit: http://madgraph.phys.ucl.ac.be
#
################################################################################

"""Classes, methods and functions required to square a QCD color string for
squared diagrams and interference terms."""

import itertools

import madgraph.core.color_algebra as color_algebra

def build_color_matrix(col_basis1, col_basis2, equal=False):
    """Create a color matrix NxM starting from color_basis dictionaries of size
    N and M. Also returns (in a pair) a dictionary summarizing the color matrix
    entries by only storing elements which are actually different."""

    color_matrix = []
    color_dict = {}

    for i1, (k1, v1) in enumerate(col_basis1.items()):
        color_line = []
        for i2, (k2, v2) in enumerate(col_basis2.items()):
            # First we create color factor for each string
            col_str1 = color_algebra.ColorString(list(k1))
            col_str2 = color_algebra.ColorString(list(k2))
            col_fact1 = color_algebra.ColorFactor([col_str1])
            col_fact2 = \
                color_algebra.ColorFactor([col_str2.complex_conjugate()])
            # We simplify them, INCLUDING T product simplification
            col_fact1.simplify()
            col_fact2.simplify()

            col_fact = color_algebra.ColorFactor()
            for col_str1 in col_fact1:
                for col_str2 in col_fact2:
                    col_fact.append(color_algebra.ColorString(col_str1 + col_str2))
            col_fact.simplify()
            color_line.append(col_fact)
            col_fact.sort()
            tuple_col_fact = tuple([tuple(x) for x in col_fact])

            if tuple_col_fact and tuple_col_fact not in color_dict.keys():
                color_dict[tuple_col_fact] = [(i1, i2)]
            elif col_fact:
                color_dict[tuple_col_fact].append((i1, i2))
        color_matrix.append(color_line)

    return (color_matrix, color_dict)




