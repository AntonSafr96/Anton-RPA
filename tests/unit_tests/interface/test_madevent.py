##############################################################################
#
# Copyright (c) 2010 The MadGraph Development team and Contributors
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
from cmd import Cmd
""" Basic test of the command interface """

import unittest
import madgraph
import madgraph.interface.cmd_interface as mgcmd
import madgraph.interface.extended_cmd as ext_cmd
import madgraph.interface.madevent_interface as mecmd
import os


root_path = os.path.split(os.path.dirname(os.path.realpath( __file__ )))[0]
root_path = os.path.dirname(root_path)
# root_path is ./tests
pjoin = os.path.join

class TestMadEventCmd(unittest.TestCase):
    """ check if the ValidCmd works correctly """
    
    def test_card_type_recognition(self):
        """Check that the different card are recognize correctly"""

        card_dir= pjoin(root_path,'..','Template', 'Cards')

        detect = mecmd.MadEventCmd.detect_card_type

        # Delphes
        self.assertEqual(detect(pjoin(card_dir, 'delphes_card_ATLAS.dat')),
                         'delphes_card.dat')
        self.assertEqual(detect(pjoin(card_dir, 'delphes_card_CMS.dat')),
                         'delphes_card.dat')
        self.assertEqual(detect(pjoin(card_dir, 'delphes_card_default.dat')),
                         'delphes_card.dat')
        self.assertEqual(detect(pjoin(card_dir, 'delphes_trigger_ATLAS.dat')),
                         'delphes_trigger.dat')
        self.assertEqual(detect(pjoin(card_dir, 'delphes_trigger_CMS.dat')),
                         'delphes_trigger.dat')
        self.assertEqual(detect(pjoin(card_dir, 'delphes_trigger.dat')),
                         'delphes_trigger.dat')
        # run_card
        self.assertEqual(detect(pjoin(card_dir, 'run_card.dat')),
                         'run_card.dat')
        self.assertEqual(detect(pjoin(card_dir, 'run_card.dat.bak')),
                         'run_card.dat')
        self.assertEqual(detect(pjoin(root_path, 'input_files','run_card_matching.dat')),
                         'run_card.dat')

        # PGS
        self.assertEqual(detect(pjoin(card_dir, 'pgs_card_ATLAS.dat')),
                         'pgs_card.dat')
        self.assertEqual(detect(pjoin(card_dir, 'pgs_card_CMS.dat')),
                         'pgs_card.dat')
        self.assertEqual(detect(pjoin(card_dir, 'pgs_card_LHC.dat')),
                         'pgs_card.dat')
        self.assertEqual(detect(pjoin(card_dir, 'pgs_card_TEV.dat')),
                         'pgs_card.dat')
        self.assertEqual(detect(pjoin(card_dir, 'pgs_card_default.dat')),
                         'pgs_card.dat')
        
        # PLOT_CARD
        self.assertEqual(detect(pjoin(card_dir, 'plot_card.dat')),
                         'plot_card.dat')

        # PYTHIA_CARD
        self.assertEqual(detect(pjoin(card_dir, 'pythia_card_default.dat')),
                         'pythia_card.dat')

        # PARAM_CARD
        self.assertEqual(detect(pjoin(card_dir, 'param_card.dat')),
                         'param_card.dat')
        self.assertEqual(detect(pjoin(root_path, 'input_files','sps1a_param_card.dat')),
                         'param_card.dat')
        self.assertEqual(detect(pjoin(root_path, 'input_files','restrict_sm.dat')),
                         'param_card.dat')
