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
"""A user friendly command line interface to access MadGraph features.
   Uses the cmd package for command interpretation and tab completion.
"""

import atexit
import cmd
import logging
import optparse
import os
import pydoc
import re
import signal
import subprocess
import sys
import traceback
import time

# Optional Library (not present on all platform)
try:
    import readline
except:
    readline = None
    
from madgraph import MG4DIR, MG5DIR, MadGraph5Error

import madgraph.core.base_objects as base_objects
import madgraph.core.diagram_generation as diagram_generation
import madgraph.core.drawing as draw_lib
import madgraph.core.helas_objects as helas_objects

import madgraph.iolibs.drawing_eps as draw
import madgraph.iolibs.export_cpp as export_cpp
import madgraph.iolibs.export_v4 as export_v4
import madgraph.iolibs.helas_call_writers as helas_call_writers
import madgraph.iolibs.file_writers as writers
import madgraph.iolibs.files as files
import madgraph.iolibs.group_subprocs as group_subprocs
import madgraph.iolibs.import_v4 as import_v4
import madgraph.iolibs.misc as misc
import madgraph.iolibs.save_load_object as save_load_object

import madgraph.interface.tutorial_text as tutorial_text

import madgraph.various.process_checks as process_checks

import models as ufomodels
import models.import_ufo as import_ufo

# Special logger for the Cmd Interface
logger = logging.getLogger('cmdprint') # -> stdout
logger_stderr = logging.getLogger('fatalerror') # ->stderr
logger_tuto = logging.getLogger('tutorial') # -> stdout include instruction in  
                                            #order to learn MG5

#===============================================================================
# CmdExtended
#===============================================================================
class CmdExtended(cmd.Cmd):
    """Extension of the cmd.Cmd command line.
    This extensions supports line breaking, history, comments,
    internal call to cmdline,..."""

    #suggested list of command
    next_possibility = {
        'mg5_start': ['import model ModelName', 'import command PATH',
                      'import proc_v4 PATH', 'tutorial'],
        'import model' : ['generate PROCESS','define MULTIPART PART1 PART2 ...', 
                                   'display particles', 'display interactions'],
        'define': ['define MULTIPART PART1 PART2 ...', 'generate PROCESS', 
                                                    'display multiparticles'],
        'generate': ['add process PROCESS','output [OUTPUT_TYPE] [PATH]','draw .'],
        'add process':['output [OUTPUT_TYPE] [PATH]', 'display processes'],
        'output':['history PATH', 'exit'],
        'display': ['generate PROCESS', 'add process PROCESS', 'output [OUTPUT_TYPE] [PATH]'],
        'draw': ['shell CMD'],
        'export':['history PATH', 'exit'],
        'import proc_v4' : ['exit'],
        'tutorial': ['generate PROCESS', 'import model MODEL', 'help TOPIC']
    }
        
    def __init__(self, *arg, **opt):
        """Init history and line continuation"""
        
        # If possible, build an info line with current version number 
        # and date, from the VERSION text file

        info = misc.get_pkg_info()
        info_line = ""

        if info.has_key('version') and  info.has_key('date'):
            len_version = len(info['version'])
            len_date = len(info['date'])
            if len_version + len_date < 30:
                info_line = "#*         VERSION %s %s %s         *\n" % \
                            (info['version'],
                            (30 - len_version - len_date) * ' ',
                            info['date'])

        # Create a header for the history file.
        # Remember to fill in time at writeout time!
        self.history_header = \
        '#************************************************************\n' + \
        '#*                        MadGraph 5                        *\n' + \
        '#*                                                          *\n' + \
        "#*                *                       *                 *\n" + \
        "#*                  *        * *        *                   *\n" + \
        "#*                    * * * * 5 * * * *                     *\n" + \
        "#*                  *        * *        *                   *\n" + \
        "#*                *                       *                 *\n" + \
        "#*                                                          *\n" + \
        "#*                                                          *\n" + \
        info_line + \
        "#*                                                          *\n" + \
        "#*    The MadGraph Development Team - Please visit us at    *\n" + \
        "#*    https://server06.fynu.ucl.ac.be/projects/madgraph     *\n" + \
        '#*                                                          *\n' + \
        '#************************************************************\n' + \
        '#*                                                          *\n' + \
        '#*               Command File for MadGraph 5                *\n' + \
        '#*                                                          *\n' + \
        '#*     run as ./bin/mg5  filename                           *\n' + \
        '#*                                                          *\n' + \
        '#*     automaticaly generated the %(time)s%(fill)s*\n' + \
        '#*                                                          *\n' + \
        '#************************************************************\n'
        
        if info_line:
            info_line = info_line[1:]

        logger.info(\
        "************************************************************\n" + \
        "*                                                          *\n" + \
        "*           W E L C O M E  to  M A D G R A P H  5          *\n" + \
        "*                                                          *\n" + \
        "*                                                          *\n" + \
        "*                 *                       *                *\n" + \
        "*                   *        * *        *                  *\n" + \
        "*                     * * * * 5 * * * *                    *\n" + \
        "*                   *        * *        *                  *\n" + \
        "*                 *                       *                *\n" + \
        "*                                                          *\n" + \
        info_line + \
        "*                                                          *\n" + \
        "*    The MadGraph Development Team - Please visit us at    *\n" + \
        "*    https://server06.fynu.ucl.ac.be/projects/madgraph     *\n" + \
        "*                                                          *\n" + \
        "*               Type 'help' for in-line help.              *\n" + \
        "*           Type 'tutorial' to learn how MG5 works         *\n" + \
        "*                                                          *\n" + \
        "************************************************************")

        self.log = True
        self.history = []
        self.save_line = ''
        cmd.Cmd.__init__(self, *arg, **opt)
        self.__initpos = os.path.abspath(os.getcwd())
        
    def precmd(self, line):
        """ A suite of additional function needed for in the cmd
        this implement history, line breaking, comment treatment,...
        """
        
        if not line:
            return line

        # Update the history of this suite of command,
        # except for useless commands (empty history and help calls)
        if line != "history" and \
            not line.startswith('help') and \
            not line.startswith('#*'):
            self.history.append(line)

        # Check if we are continuing a line:
        if self.save_line:
            line = self.save_line + line 
            self.save_line = ''
        
        # Check if the line is complete
        if line.endswith('\\'):
            self.save_line = line[:-1]
            return '' # do nothing   
        
        # Remove comment
        if '#' in line:
            line = line.split('#')[0]

        # Deal with line splitting
        if ';' in line:
            for subline in line.split(';'):
                stop = self.onecmd(subline)
                stop = self.postcmd(stop, subline)
            return ''
        
        # execute the line command
        return line

    def nice_error_handling(self, error, line):
        """ """ 
        # Make sure that we are at the initial position
        os.chdir(self.__initpos)
        # Create the debug files
        self.log = False
        cmd.Cmd.onecmd(self, 'history MG5_debug')
        debug_file = open('MG5_debug', 'a')
        traceback.print_exc(file=debug_file)
        # Create a nice error output
        if self.history and line == self.history[-1]:
            error_text = 'Command \"%s\" interrupted with error:\n' % line
        elif self.history:
            error_text = 'Command \"%s\" interrupted in sub-command:\n' %line
            error_text += '\"%s\" with error:\n' % self.history[-1]
        else:
            error_text = ''
        error_text += '%s : %s\n' % (error.__class__.__name__, str(error).replace('\n','\n\t'))
        error_text += 'Please report this bug on https://bugs.launchpad.net/madgraph5\n'
        error_text += 'More information is found in \'%s\'.\n' % \
                        os.path.realpath("MG5_debug")
        error_text += 'Please attach this file to your report.'
        logger_stderr.critical(error_text)
        #stop the execution if on a non interactive mode
        if self.use_rawinput == False:
            sys.exit('Exit on error')
        return False

    def nice_user_error(self, error, line):
        # Make sure that we are at the initial position
        os.chdir(self.__initpos)
        if line == self.history[-1]:
            error_text = 'Command \"%s\" interrupted with error:\n' % line
        else:
            error_text = 'Command \"%s\" interrupted in sub-command:\n' %line
            error_text += '\"%s\" with error:\n' % self.history[-1] 
        error_text += '%s : %s' % (error.__class__.__name__, str(error).replace('\n','\n\t'))
        logger_stderr.error(error_text)
        #stop the execution if on a non interactive mode
        if self.use_rawinput == False:
            sys.exit()
        # Remove failed command from history
        self.history.pop()
        return False

    
    def onecmd(self, line):
        """catch all error and stop properly command accordingly"""
        
        try:
            cmd.Cmd.onecmd(self, line)
        except MadGraph5Error as error:
            if __debug__:
                self.nice_error_handling(error, line)
            else:
                self.nice_user_error(error, line)
        except Exception as error:
            self.nice_error_handling(error, line)
            
    def exec_cmd(self, line):
        """for third party call, call the line with pre and postfix treatment"""
        
        logger.info(line)
        line = self.precmd(line)
        stop = cmd.Cmd.onecmd(self, line)
        stop = self.postcmd(stop, line)
        return stop      

    def run_cmd(self, line):
        """for third party call, call the line with pre and postfix treatment"""
        
        logger.info(line)
        line = self.precmd(line)
        stop = self.onecmd(line)
        stop = self.postcmd(stop, line)
        return stop 
    
    def postcmd(self,stop, line):
        """ finishing a command
        This looks if we have to write an additional text for the tutorial."""
        
        # Print additional information in case of routines fails
        if stop == False:
            return False
        
        args=line.split()
        # Return for empty line
        if len(args)==0:
            return stop
        
        # try to print linked to the first word in command 
        #as import_model,... if you don't find then try print with only
        #the first word.
        if len(args)==1:
            command=args[0]
        else:
            command = args[0]+'_'+args[1]
        
        try:
            logger_tuto.info(getattr(tutorial_text, command).replace('\n','\n\t'))
        except:
            try:
                logger_tuto.info(getattr(tutorial_text, args[0]).replace('\n','\n\t'))
            except:
                pass
            


    def emptyline(self):
        """If empty line, do nothing. Default is repeat previous command."""
        pass
    
    def default(self, line):
        """Default action if line is not recognized"""

        # Faulty command
        logger.warning("Command \"%s\" not recognized, please try again" % \
                                                                line.split()[0])
    # Quit
    def do_quit(self, line):
        sys.exit(1)
        
    do_exit = do_quit

    # Aliases
    do_EOF = do_quit
    do_exit = do_quit

    def do_help(self, line):
        """ propose some usefull possible action """
        
        cmd.Cmd.do_help(self,line)
        
        # if not basic help -> simple call is enough    
        if line:
            return

        if len(self.history) == 0:
            last_action_2 = last_action = 'mg5_start'
        else:
            last_action_2 = last_action = 'none'
        
        pos = 0
        authorize = self.next_possibility.keys() 
        while last_action_2  not in authorize and last_action not in authorize:
            pos += 1
            if pos > len(self.history):
                last_action_2 = last_action = 'mg5_start'
                break
            
            args = self.history[-1 * pos].split()
            last_action = args[0]
            if len(args)>1: 
                last_action_2 = '%s %s' % (last_action, args[1])
            else: 
                last_action_2 = 'none'
        
        print 'Contextual Help'
        print '==============='
        if last_action_2 in authorize:
            options = self.next_possibility[last_action_2]
        elif last_action in authorize:
            options = self.next_possibility[last_action]
        
        text = 'The following command(s) may be useful in order to continue.\n'
        for option in options:
            text+='\t %s \n' % option      
        print text


    def timed_input(self, question, default, timeout=None):
        """ a question with a maximal time to answer take default otherwise"""
        class TimeOutError(Exception):
            """Class for run-time error"""
            pass
        def handle_alarm(signum, frame): 
            raise TimeOutError
        if timeout is None:
            timeout = self.timeout
        signal.signal(signal.SIGALRM, handle_alarm)
        signal.alarm(timeout)
        if timeout:
            question += '[%ss to answer] ' % timeout
        try:
            result = raw_input(question)
        except TimeOutError:
            print default
            return default
        finally:
            signal.alarm(0)
        return result





#===============================================================================
# Helper function
#=============================================================================
def split_arg(line):
    """Split a line of arguments"""
    
    split = line.split()
    out=[]
    tmp=''
    for data in split:
        if data[-1] == '\\':
            tmp += data[:-1]+' '
        elif tmp:
            out.append(tmp+data)
        else:
            out.append(data)
    return out

 

#===============================================================================
# HelpToCmd
#===============================================================================
class HelpToCmd(object):
    """ The Series of help routine for the MadGraphCmd"""    
    
    def help_save(self):
        logger.info("syntax: save %s FILENAME" % "|".join(self._save_opts))
        logger.info("-- save information as file FILENAME")


    def help_load(self):
        logger.info("syntax: load %s FILENAME" % "|".join(self._save_opts))
        logger.info("-- load information from file FILENAME")

    def help_import(self):
        
        logger.info("syntax: import " + "|".join(self._import_formats) + \
              " FILENAME")
        logger.info("-- imports file(s) in various formats")
        logger.info("")
        logger.info("   import model MODEL [-modelname]:")
        logger.info("      Import a UFO or MG4 model.")
        logger.info("      MODEL should be a valid UFO model name")
        logger.info("      -modelname keeps the original")
        logger.info("             particle names for the model")
        logger.info("")
        logger.info("   import model_v4 MODEL [-modelname] :")
        logger.info("      Import an MG4 model.")
        logger.info("      Model should be the name of the model")
        logger.info("      or the path to theMG4 model directory")
        logger.info("      -modelname keeps the original")
        logger.info("             particle names for the model")
        logger.info("")
        logger.info("   import proc_v4 [PATH] :"  )
        logger.info("      Execute MG5 based on a proc_card.dat in MG4 format.")
        logger.info("      Path to the proc_card is optional if you are in a")
        logger.info("      madevent directory")
        logger.info("")
        logger.info("   import command PATH :")
        logger.info("      Execute the list of command in the file at PATH")
        
    def help_display(self):
        logger.info("syntax: display " + "|".join(self._display_opts))
        logger.info("-- display a the status of various internal state variables")
        logger.info("   for particles/interactions you can specify the name or id of the")
        logger.info("   particles/interactions to receive more details information.")
        logger.info("   example display particles e+.")
        logger.info("   For \"checks\", can specify only to see failed checks.")

    def help_tutorial(self):
        logger.info("syntax: tutorial [" + "|".join(self._tutorial_opts) + "]")
        logger.info("-- start/stop the tutorial mode")

    def help_output(self):
        logger.info("syntax [" + "|".join(self._export_formats) + \
                    "] [name|.|auto] [options]")
        logger.info("-- Output any generated process(es) to file.")
        logger.info("   mode: Default mode is madevent. Default path is \'.\'.")
        logger.info("   If mode is madevent or standalone, create a copy of")
        logger.info("     the V4 Template in the MG_ME directory, with the model and")
        logger.info("     Helas set up appropriately.")
        logger.info("   - If mode is standalone, the directory will be in")
        logger.info("     Standalone format, otherwise in MadEvent format.")
        logger.info("   - If mode is matrix, output the matrix.f files for all")
        logger.info("     generated processes in directory \"name\".")
        logger.info("   If mode is standalone_cpp, output the .h and .cc files")
        logger.info("     for the processes and model files in standalone C++")
        logger.info("     format in directory \"name\".")
        logger.info("   If mode is pythia8, output the .h and .cc files for")
        logger.info("     the processes in Pythia 8 format in directory \"name\".")
        logger.info("   If mode is pythia8_model, output the .h and .cc files for")
        logger.info("     for the model parameters and Aloha functions for the model.")
        logger.info("   name: The name of the copy of Template.")
        logger.info("   If you put '.' instead of a name, your pwd will be used.")
        logger.info("   If you put 'auto', an automatic name PROC_XX_n will be created.")
        logger.info("   options:")
        logger.info("      -f: force cleaning of the directory if it already exists")
        logger.info("      -noclean: no cleaning performed in \"name\"")
        logger.info("      -nojpeg: no jpeg diagrams will be generated")
        logger.info("   Example:")
        logger.info("       output")
        logger.info("       output standalone MYRUN -d ../MG_ME -f")
        
    def help_check(self):

        logger.info("syntax: check " + "|".join(self._check_opts) + " [param_card] process_definition")
        logger.info("-- check a process or set of processes. Options:")
        logger.info("full: Perform all three checks described below:")
        logger.info("   permutation, gauge and lorentz_invariance.")
        logger.info("permutation: Check that the model and MG5 are working")
        logger.info("   properly by generating permutations of the process and")
        logger.info("   checking that the resulting matrix elements give the")
        logger.info("   same value.")
        logger.info("gauge: Check that processes with massless gauge bosons")
        logger.info("   are gauge invariant")
        logger.info("lorentz_invariance: Check that the amplitude is lorentz")
        logger.info("   invariant by comparing the amplitiude in different frames")        
        logger.info("If param_card is given, that param_card is used instead")
        logger.info("   of the default values for the model.")
        logger.info("For process syntax, please see help generate")

    def help_generate(self):

        logger.info("syntax: generate INITIAL STATE > REQ S-CHANNEL > FINAL STATE $ EXCL S-CHANNEL / FORBIDDEN PARTICLES COUP1=ORDER1 COUP2=ORDER2 @N")
        logger.info("-- generate diagrams for a given process")
        logger.info("   Syntax example: l+ vl > w+ > l+ vl a $ z / a h QED=3 QCD=0 @1")
        logger.info("   Alternative required s-channels can be separated by \"|\":")
        logger.info("   b b~ > W+ W- | H+ H- > ta+ vt ta- vt~")
        logger.info("   If no coupling orders are given, MG5 will try to determine")
        logger.info("   orders to ensure maximum number of QCD vertices.")
        logger.info("   Note that if there are more than one non-QCD coupling type,")
        logger.info("   coupling orders need to be specified by hand.")
        logger.info("Decay chain syntax:")
        logger.info("   core process, decay1, (decay2, (decay2', ...)), ...  etc")
        logger.info("   Example: p p > t~ t QED=0, (t~ > W- b~, W- > l- vl~), t > j j b @2")
        logger.info("   Note that identical particles will all be decayed.")
        logger.info("To generate a second process use the \"add process\" command")

    def help_add(self):

        logger.info("syntax: add process INITIAL STATE > REQ S-CHANNEL > FINAL STATE $ EXCL S-CHANNEL / FORBIDDEN PARTICLES COUP1=ORDER1 COUP2=ORDER2")
        logger.info("-- generate diagrams for a process and add to existing processes")
        logger.info("   Syntax example: l+ vl > w+ > l+ vl a $ z / a h QED=3 QCD=0 @1")
        logger.info("   Alternative required s-channels can be separated by \"|\":")
        logger.info("   b b~ > W+ W- | H+ H- > ta+ vt ta- vt~")
        logger.info("   If no coupling orders are given, MG5 will try to determine")
        logger.info("   orders to ensure maximum number of QCD vertices.")
        logger.info("Decay chain syntax:")
        logger.info("   core process, decay1, (decay2, (decay2', ...)), ...  etc")
        logger.info("   Example: p p > t~ t QED=0, (t~ > W- b~, W- > l- vl~), t > j j b @2")
        logger.info("   Note that identical particles will all be decayed.")

    def help_define(self):
        logger.info("syntax: define multipart_name [=] part_name_list")
        logger.info("-- define a multiparticle")
        logger.info("   Example: define p = g u u~ c c~ d d~ s s~ b b~")

    def help_history(self):
        logger.info("syntax: history [FILEPATH|clean|.] ")
        logger.info("   If FILEPATH is \'.\' and \'output\' is done,")
        logger.info("   Cards/proc_card_mg5.dat will be used.")
        logger.info("   If FILEPATH is omitted, the history will be output to stdout.")
        logger.info("   \"clean\" will remove all entries from the history.")

    def help_draw(self):
        _draw_parser.print_help()

    def help_set(self):
        logger.info("syntax: set %s argument" % "|".join(self._set_options))
        logger.info("-- set options for generation or output")
        logger.info("   group_subprocesses_output True/False: ")
        logger.info("     Smart grouping of subprocesses into directories,")
        logger.info("     mirroring of initial states, and combination of")
        logger.info("     integration channels.")
        logger.info("     Example: p p > j j j w+ gives 5 directories and 184 channels")
        logger.info("     (cf. 65 directories and 1048 channels for regular output)")
        logger.info("   ignore_six_quark_processes multi_part_label")
        logger.info("     (default none) ignore processes with at least 6 of any")
        logger.info("     of the quarks given in multi_part_label.")
        logger.info("     These processes give negligible contribution to the")
        logger.info("     cross section but have subprocesses/channels.")
    def help_shell(self):
        logger.info("syntax: shell CMD (or ! CMD)")
        logger.info("-- run the shell command CMD and catch output")

    def help_quit(self):
        logger.info("syntax: quit")
        logger.info("-- terminates the application")
    
    help_EOF = help_quit
    
    def help_help(self):
        logger.info("syntax: help")
        logger.info("-- access to the in-line help" )

#===============================================================================
# CheckValidForCmd
#===============================================================================
class CheckValidForCmd(object):
    """ The Series of help routine for the MadGraphCmd"""
    
    class InvalidCmd(MadGraph5Error):
        """a class for the invalid syntax call"""
    
    class RWError(MadGraph5Error):
        """a class for read/write errors"""
    
    def check_add(self, args):
        """check the validity of line
        syntax: add process PROCESS 
        """
    
        if len(args) < 2:
            self.help_add()
            raise self.InvalidCmd('\"add\" requires two arguments')
        
        if args[0] != 'process':
            raise self.InvalidCmd('\"add\" requires the argument \"process\"')

        if not self._curr_model:
            raise MadGraph5Error, \
                  'No model currently active, please load or import a model.'
    
        self.check_process_format(' '.join(args[1:]))

    def check_define(self, args):
        """check the validity of line
        syntax: define multipart_name [ part_name_list ]
        """  

        
        if len(args) < 2:
            self.help_define()
            raise self.InvalidCmd('\"define\" command requires at least two arguments')

        if args[1] == '=':
            del args[1]
            if len(args) < 2:
                self.help_define()
                raise self.InvalidCmd('\"define\" command requires at least one particles name after \"=\"')
        
        if '=' in args:
            self.help_define()
            raise self.InvalidCmd('\"define\" command requires symbols \"=\" at the second position')
        
        if not self._curr_model:
            raise self.InvalidCmd("No particle list currently active, please import a model first")

        if self._curr_model['particles'].find_name(args[0]):
            raise MadGraph5Error("label %s is a particle name in this model\n\
            Please retry with another name." % args[0])

    def check_display(self, args):
        """check the validity of line
        syntax: display XXXXX
        """
            
        if len(args) < 1 or args[0] not in self._display_opts:
            self.help_display()
            raise self.InvalidCmd

        if not self._curr_model:
            raise self.InvalidCmd("No model currently active, please import a model!")

        if args[0] in ['processes', 'diagrams'] and not self._curr_amps:
            raise self.InvalidCmd("No process generated, please generate a process!")
        if args[0] == 'checks' and not self._comparisons:
            raise self.InvalidCmd("No check results to display.")


    def check_draw(self, args):
        """check the validity of line
        syntax: draw DIRPATH [option=value]
        """
        
        if len(args) < 1:
            self.help_draw()
            raise self.InvalidCmd('\"draw\" command requires a directory path')
        
        if not self._curr_amps:
            raise self.InvalidCmd("No process generated, please generate a process!")
            
        if not os.path.isdir(args[0]):
            raise self.InvalidCmd( "%s is not a valid directory for export file" % args[0])
            
    def check_check(self, args):
        """check the validity of args"""
        
        if  not self._curr_model:
            raise self.InvalidCmd("No model currently active, please import a model!")

        if self._model_v4_path:
            raise self.InvalidCmd(\
                "\"check\" not possible for v4 models")

        if len(args) < 2:
            self.help_check()
            raise self.InvalidCmd("\"check\" requires an argument and a process.")

        param_card = None
        if os.path.isfile(args[1]):
            param_card = args.pop(1)

        if args[0] not in self._check_opts:
            self.help_check()
            raise self.InvalidCmd("\"check\" called with wrong argument")
        
        if any([',' in elem for elem in args]):
            raise MadGraph5Error('Decay chains not allowed in check')
        
        self.check_process_format(" ".join(args[1:]))

        return param_card
    
    def check_generate(self, args):
        """check the validity of args"""
        
        if  not self._curr_model:
            raise self.InvalidCmd("No model currently active, please import a model!")

        if len(args) < 1:
            self.help_generate()
            raise self.InvalidCmd("\"generate\" requires a process.")

        self.check_process_format(" ".join(args))
 
        return True
    
    def check_process_format(self, process):
        """ check the validity of the string given to describe a format """
        
        #check balance of paranthesis
        if process.count('(') != process.count(')'):
            raise self.InvalidCmd('Invalid Format, no balance between open and close parenthesis')
        #remove parenthesis for fututre introspection
        process = process.replace('(',' ').replace(')',' ')
        
        # split following , (for decay chains)
        subprocesses = process.split(',')
        if len(subprocesses) > 1:
            for subprocess in subprocesses:
                self.check_process_format(subprocess)
            return
        
        # request that we have one or two > in the process
        if process.count('>') not in [1,2]:
            raise self.InvalidCmd(
               'wrong format for \"%s\" this part requires one or two symbols \'>\', %s found' 
               % (process, process.count('>')))
        
        # we need at least one particles in each pieces
        particles_parts = process.split('>')
        for particles in particles_parts:
            if re.match(r'^\s*$', particles):
                raise self.InvalidCmd(
                '\"%s\" is a wrong process format. Please try again' % process)  
        
        # '/' and '$' sould be used only after the process definition
        for particles in particles_parts[:-1]:
            if re.search('\D/', particles):
                raise self.InvalidCmd(
                'wrong process format: restriction should be place after the final states')
            if re.search('\D\$', particles):
                raise self.InvalidCmd(
                'wrong process format: restriction should be place after the final states')
        
    
        
    def check_history(self, args):
        """check the validity of line"""
        
        if len(args) > 1:
            self.help_history()
            raise self.InvalidCmd('\"history\" command takes at most one argument')
        
        if not len(args):
            return
        
        if args[0] =='.':
            if not self._export_dir:
                raise self.InvalidCmd("No default directory is defined for \'.\' option")
        elif args[0] != 'clean':
                dirpath = os.path.dirname(args[0])
                if dirpath and not os.path.exists(dirpath) or \
                       os.path.isdir(args[0]):
                    raise self.InvalidCmd("invalid path %s " % dirpath)
    
    def check_import(self, args):
        """check the validity of line"""
        
        if not args or args[0] not in self._import_formats:
            self.help_import()
            raise self.InvalidCmd('wrong \"import\" format')
        
        if args[0].startswith('model') and len(args) != 2:
            if not (len(args) == 3 and args[-1] == '-modelname'):
                self.help_import()
                raise self.InvalidCmd('incorrect number of arguments')
        
        if args[0] == 'proc_v4' and len(args) != 2 and not self._export_dir:
            self.help_import()
            raise self.InvalidCmd('PATH is mandatory in the current context\n' + \
                                  'Did you forget to run the \"output\" command')
                        
        if '-modelname' in args:
            if args[-1] != '-modelname':
                args.remove('-modelname')
                args.append('-modelname')
        
    def check_load(self, args):
        """ check the validity of the line"""
        
        if len(args) != 2 or args[0] not in self._save_opts:
            self.help_load()
            raise self.InvalidCmd('wrong \"load\" format')
            
        
    def check_save(self, args):
        """ check the validity of the line"""
        if len(args) != 2 or args[0] not in self._save_opts:
            self.help_save()
            raise self.InvalidCmd('wrong \"save\" format')
    
    def check_set(self, args):
        """ check the validity of the line"""
        
        if len(args) < 2:
            self.help_set()
            raise self.InvalidCmd('set needs an option and an argument')

        if args[0] not in self._set_options:
            self.help_set()
            raise self.InvalidCmd('Possible options for set are %s' % \
                                  self._set_options)

        if args[0] in ['group_subprocesses_output']:
            if args[1] not in ['False', 'True']:
                raise self.InvalidCmd('%s needs argument False or True' % \
                                      args[0])
        if args[0] in ['ignore_six_quark_processes']:
            if args[1] not in self._multiparticles.keys():
                raise self.InvalidCmd('ignore_six_quark_processes needs ' + \
                                      'a multiparticle name as argument')
            
    def check_output(self, args):
        """ check the validity of the line"""
        
        if args and args[0] in self._export_formats:
            self._export_format = args.pop(0)

        if not self._curr_amps and self._export_format != "pythia8_model":
            text = 'No processes generated. Please generate a process first.'
            raise self.InvalidCmd(text)

        if not self._curr_model:
            text = 'No model found. Please import a model first and then retry.'
            raise self.InvalidCmd(text)

        if self._model_v4_path and \
               (self._export_format not in self._v4_export_formats or \
                self._options['group_subprocesses_output']):
            text = " The Model imported (MG4 format) does not contain enough\n "
            text += " information for this type of output. In order to create\n"
            text += " output for " + args[0] + ", you have to use a UFO model.\n"
            text += " Those model can be imported with mg5> import model NAME."
            logger.warning(text)
            raise self.InvalidCmd('')

        if args and args[0][0] != '-':
            # This is a path
            path = args.pop(0)
            # Check for special directory treatment
            if path == 'auto' and self._export_format in \
                     ['madevent', 'standalone', 'standalone_cpp']:
                self.get_default_path()
            else:
                self._export_dir = path

        if not self._export_dir:
            # No valid path
            self.get_default_path()

        if self._export_format in ['madevent', 'standalone'] \
               and not self._mgme_dir and \
               os.path.realpath(self._export_dir) != os.path.realpath('.'):
            raise MadGraph5Error, \
                  "To generate a new MG4 directory, you need a valid MG_ME path"

        self._export_dir = os.path.realpath(self._export_dir)

    def get_default_path(self):
        """Set self._export_dir to the default (\'auto\') path"""
        
        if self._export_format.startswith('madevent'):
            name_dir = lambda i: 'PROC_%s_%s' % \
                                    (self._curr_model['name'], i)
            auto_path = lambda i: os.path.join(self.writing_dir,
                                               name_dir(i))
        elif self._export_format == 'standalone':
            name_dir = lambda i: 'PROC_SA_%s_%s' % \
                                    (self._curr_model['name'], i)
            auto_path = lambda i: os.path.join(self.writing_dir,
                                               name_dir(i))                
        elif self._export_format == 'standalone_cpp':
            name_dir = lambda i: 'PROC_SA_CPP_%s_%s' % \
                                    (self._curr_model['name'], i)
            auto_path = lambda i: os.path.join(self.writing_dir,
                                               name_dir(i))                
        else:
            self._export_dir = '.'
            return
        for i in range(500):
            if os.path.isdir(auto_path(i)):
                continue
            else:
                self._export_dir = auto_path(i) 
                break
        if not self._export_dir:
            raise self.InvalidCmd('Can\'t use auto path,' + \
                                  'more than 500 dirs already')    
            
        
#===============================================================================
# CheckValidForCmdWeb
#===============================================================================
class CheckValidForCmdWeb(CheckValidForCmd):
    """ Check the validity of input line for web entry
    (no explicit path authorized)"""
    
    class WebRestriction(MadGraph5Error):
        """class for WebRestriction"""
    
    def check_draw(self, args):
        """check the validity of line
        syntax: draw FILEPATH [option=value]
        """
        raise self.WebRestriction('direct call to draw is forbidden on the web')
      
    def check_history(self, args):
        """check the validity of line
        No Path authorize for the Web"""
        
        CheckValidForCmd.check_history(self, args)

        if len(args) == 2 and args[1] not in ['.', 'clean']:
            raise self.WebRestriction('Path can\'t be specify on the web.')

        
    def check_import(self, args):
        """check the validity of line
        No Path authorize for the Web"""
        
        CheckValidForCmd.check_import(self, args)
        
        if len(args) >= 2 and args[0] == 'proc_v4' and args[1] != '.':
            raise self.WebRestriction('Path can\'t be specify on the web.')

        if len(args) >= 2 and args[0] == 'command':
            if args[1] != './Cards/proc_card_mg5.dat': 
                raise self.WebRestriction('Path can\'t be specify on the web.')
        else:
            for arg in args:
                if '/' in arg:
                    raise self.WebRestriction('Path can\'t be specify on the web.')
        
    def check_load(self, args):
        """ check the validity of the line
        No Path authorize for the Web"""

        CheckValidForCmd.check_load(self, args)        

        if len(args) == 2:
            if args[0] != 'model':
                raise self.WebRestriction('only model can be loaded online')
            if 'model.pkl' not in args[1]:
                raise self.WebRestriction('not valid pkl file: wrong name')
            if not os.path.realpath(args[1]).startswith(os.path.join(MG4DIR, \
                                                                    'Models')):
                raise self.WebRestriction('Wrong path to load model')
        
    def check_save(self, args):
        """ not authorize on web"""
        raise self.WebRestriction('\"save\" command not authorize online')
    
    def check_output(self, args):
        """ check the validity of the line"""
        
        # In web mode, can only do forced, automatic madevent output

        args[:] = ['madevent', 'auto', '-f']

#===============================================================================
# CompleteForCmd
#===============================================================================
class CompleteForCmd(CheckValidForCmd):
    """ The Series of help routine for the MadGraphCmd"""
    
    def list_completion(self, text, list):
        """Propose completions of text in list"""
        if not text:
            completions = list
        else:
            completions = [ f
                            for f in list
                            if f.startswith(text)
                            ]
        return completions

    def path_completion(self, text, base_dir = None, only_dirs = False):
        """Propose completions of text to compose a valid path"""

        if base_dir is None:
            base_dir = os.getcwd()

        if only_dirs:
            completion = [f
                          for f in os.listdir(base_dir)
                          if f.startswith(text) and \
                          os.path.isdir(os.path.join(base_dir, f)) and \
                          (not f.startswith('.') or text.startswith('.'))
                          ]
        else:
            completion = [f
                          for f in os.listdir(base_dir)
                          if f.startswith(text) and \
                          os.path.isfile(os.path.join(base_dir, f)) and \
                          (not f.startswith('.') or text.startswith('.'))
                          ]

            completion = completion + \
                         [f + os.path.sep
                          for f in os.listdir(base_dir)
                          if f.startswith(text) and \
                          os.path.isdir(os.path.join(base_dir, f)) and \
                          (not f.startswith('.') or text.startswith('.'))
                          ]

        completion += [f for f in ['.'+os.path.sep, '..'+os.path.sep] if \
                       f.startswith(text)]

        return completion

    def model_completion(self, text, process):
        """ complete the line with model information """
        while ',' in process:
            process = process[process.index(',')+1:]
        args = split_arg(process)
        couplings = []

        # Force '>' if two initial particles.
        if len(args) == 2 and args[-1] != '>':
                return self.list_completion(text, '>')
            
        # Add non-particle names
        if len(args) > 0 and args[-1] != '>':
            couplings = ['>']
        if '>' in args and args.index('>') < len(args) - 1:
            couplings = [c + "=" for c in self._couplings] + \
                        ['@','$','/','>',',']
        return self.list_completion(text, self._particle_names + \
                                    self._multiparticles.keys() + couplings)
        
            
    def complete_history(self, text, line, begidx, endidx):
        "Complete the add command"

        args = split_arg(line[0:begidx])

        # Directory continuation
        if args[-1].endswith(os.path.sep):
            return self.path_completion(text,
                                        os.path.join('.',*[a for a in args \
                                                    if a.endswith(os.path.sep)]))

        if len(args) == 1:
            return self.path_completion(text)
        
    def complete_generate(self, text, line, begidx, endidx):
        "Complete the add command"

        # Return list of particle names and multiparticle names, as well as
        # coupling orders and allowed symbols
        args = split_arg(line[0:begidx])
        if len(args) > 2 and args[-1] == '@' or args[-1].endswith('='):
            return

        try:
            return self.model_completion(text, ' '.join(args[1:]))
        except Exception as error:
            print error
            
        #if len(args) > 1 and args[-1] != '>':
        #    couplings = ['>']
        #if '>' in args and args.index('>') < len(args) - 1:
        #    couplings = [c + "=" for c in self._couplings] + ['@','$','/','>']
        #return self.list_completion(text, self._particle_names + \
        #                            self._multiparticles.keys() + couplings)
        
    def complete_add(self, text, line, begidx, endidx):
        "Complete the add command"

        args = split_arg(line[0:begidx])

        # Format
        if len(args) == 1:
            return self.list_completion(text, self._add_opts)

        return self.complete_generate(text, " ".join(args[1:]), begidx, endidx)

        # Return list of particle names and multiparticle names, as well as
        # coupling orders and allowed symbols
        couplings = []
        if len(args) > 2 and args[-1] != '>':
            couplings = ['>']
        if '>' in args and args.index('>') < len(args) - 1:
            couplings = [c + "=" for c in self._couplings] + ['@','$','/','>']
        return self.list_completion(text, self._particle_names + \
                                    self._multiparticles.keys() + couplings)
        
    def complete_check(self, text, line, begidx, endidx):
        "Complete the add command"

        args = split_arg(line[0:begidx])

        # Format
        if len(args) == 1:
            return self.list_completion(text, self._check_opts)

        


        # Directory continuation
        if args[-1].endswith(os.path.sep):
            return self.path_completion(text,
                                        os.path.join('.',*[a for a in args \
                                                    if a.endswith(os.path.sep)]))
        # autocompletion for particles/couplings
        model_comp = self.model_completion(text, ' '.join(args[2:]))

        if len(args) == 2:
            return model_comp + self.path_completion(text)

        if len(args) > 2:
            return model_comp
            
        
    def complete_tutorial(self, text, line, begidx, endidx):
        "Complete the tutorial command"

        # Format
        if len(split_arg(line[0:begidx])) == 1:
            return self.list_completion(text, self._tutorial_opts)
        
    def complete_define(self, text, line, begidx, endidx):
        """Complete particle information"""
        return self.model_completion(text, line[6:])

    def complete_display(self, text, line, begidx, endidx):
        "Complete the display command"

        args = split_arg(line[0:begidx])
        # Format
        if len(args) == 1:
            return self.list_completion(text, self._display_opts)

        if len(args) == 2 and args[1] == 'checks':
            return self.list_completion(text, 'failed')

        if len(args) == 2 and args[1] == 'particles':
            return self.model_completion(text, line[begidx:])

    def complete_draw(self, text, line, begidx, endidx):
        "Complete the draw command"

        args = split_arg(line[0:begidx])

        # Directory continuation
        if args[-1].endswith(os.path.sep):
            return self.path_completion(text,
                                        os.path.join('.',*[a for a in args if a.endswith(os.path.sep)]),
                                        only_dirs = True)
        # Format
        if len(args) == 1:
            return self.path_completion(text, '.', only_dirs = True)


        #option
        if len(args) >= 2:
            opt = ['horizontal', 'external=', 'max_size=', 'add_gap=',
                                'non_propagating', '--']
            return self.list_completion(text, opt)

    def complete_load(self, text, line, begidx, endidx):
        "Complete the load command"

        args = split_arg(line[0:begidx])        

        # Format
        if len(args) == 1:
            return self.list_completion(text, self._save_opts)

        # Directory continuation
        if args[-1].endswith(os.path.sep):
            return self.path_completion(text,
                                        os.path.join('.',*[a for a in args if \
                                                      a.endswith(os.path.sep)]))

        # Filename if directory is not given
        if len(args) == 2:
            return self.path_completion(text)

    def complete_save(self, text, line, begidx, endidx):
        "Complete the save command"

        args = split_arg(line[0:begidx])

        # Format
        if len(args) == 1:
            return self.list_completion(text, self._save_opts)

        # Directory continuation
        if args[-1].endswith(os.path.sep):
            return self.path_completion(text,
                                        os.path.join('.',*[a for a in args if a.endswith(os.path.sep)]),
                                        only_dirs = True)

        # Filename if directory is not given
        if len(args) == 2:
            return self.path_completion(text)

    def complete_output(self, text, line, begidx, endidx,
                        possible_options = ['f', 'noclean', 'nojpeg'],
                        possible_options_full = ['-f', '-noclean', '-nojpeg']):
        "Complete the output command"

        possible_format = self._export_formats
        #don't propose directory use by MG_ME
        forbidden_names = ['MadGraphII', 'Template', 'pythia-pgs', 'CVS',
                            'Calculators', 'MadAnalysis', 'SimpleAnalysis',
                            'mg5', 'DECAY', 'EventConverter', 'Models',
                            'ExRootAnalysis', 'HELAS', 'Transfer_Fct']
        #name of the run =>proposes old run name
        args = split_arg(line[0:begidx])
        if len(args) >= 1: 
            # Directory continuation
            if args[-1].endswith(os.path.sep):
                return [name for name in self.path_completion(text,
                        os.path.join('.',*[a for a in args if a.endswith(os.path.sep)]),
                        only_dirs = True) if name not in forbidden_names]
            # options
            if args[-1][0] == '-' or len(args) > 1 and args[-2] == '-':
                return self.list_completion(text, possible_options)
            if len(args) > 2:
                return self.list_completion(text, possible_options_full)
            # Formats
            if len(args) == 1:
                if any([p.startswith(text) for p in possible_format]):
                    return [name for name in \
                            self.list_completion(text, possible_format) + \
                            ['.' + os.path.sep, '..' + os.path.sep, 'auto'] \
                            if name.startswith(text)]

            # directory names
            content = [name for name in self.path_completion(text, '.', only_dirs = True) \
                       if name not in forbidden_names]
            content += ['auto']
            return self.list_completion(text, content)


    def complete_set(self, text, line, begidx, endidx):
        "Complete the set command"

        args = split_arg(line[0:begidx])

        # Format
        if len(args) == 1:
            return self.list_completion(text, self._set_options)

        if len(args) == 2:
            if args[1] in ['group_subprocesses_output']:
                return self.list_completion(text, ['False', 'True'])
            
            if args[1] in ['ignore_six_quark_processes']:
                return self.list_completion(text, self._multiparticles.keys())
        
    def complete_shell(self, text, line, begidx, endidx):
        """ add path for shell """

        # Filename if directory is given
        #
        if len(split_arg(line[0:begidx])) > 1 and line[begidx - 1] == os.path.sep:
            if not text:
                text = ''
            output = self.path_completion(text,
                                        base_dir=\
                                          split_arg(line[0:begidx])[-1])
        else:
            output = self.path_completion(text)
        return output

    def complete_import(self, text, line, begidx, endidx):
        "Complete the import command"

        args=split_arg(line[0:begidx])

        # Format
        if len(args) == 1:
            return self.list_completion(text, self._import_formats)

        # Directory continuation
        if args[-1].endswith(os.path.sep):
            if args[1].startswith('model'):
                return self.path_completion(text,
                                    os.path.join('.',*[a for a in args if \
                                                      a.endswith(os.path.sep)]),
                                    only_dirs = True)
            else:
                return self.path_completion(text,
                                    os.path.join('.',*[a for a in args if \
                                                      a.endswith(os.path.sep)]))
        # Model directory name if directory is not given
        if len(split_arg(line[0:begidx])) == 2:
            if args[1] == 'model':
                file_cond = lambda p : os.path.exists(os.path.join(MG5DIR,'models',p,'particles.py'))
                mod_name = lambda name: name
            elif args[1] == 'model_v4':
                file_cond = lambda p :  (os.path.exists(os.path.join(MG5DIR,'models',p,'particles.dat')) 
                                      or os.path.exists(os.path.join(self._mgme_dir,'Models',p,'particles.dat')))
                mod_name = lambda name :(name[-3:] != '_v4' and name or name[:-3]) 
            else:
                return []
                
            return [mod_name(name) for name in \
                    self.path_completion(text,
                                            os.path.join(MG5DIR,'models'),
                                            only_dirs = True) \
                       if file_cond(name)]
                                

        # Options
        if len(args) > 2 and args[1].startswith('model') and args[-1][0] != '-':
                return ['-modelname']
        if len(args) > 3 and args[1].startswith('model') and args[-1][0] == '-':
                return ['modelname']

  


    
#===============================================================================
# MadGraphCmd
#===============================================================================
class MadGraphCmd(CmdExtended, HelpToCmd):
    """The command line processor of MadGraph"""    

    # Options and formats available
    _display_opts = ['particles', 'interactions', 'processes', 'diagrams', 
                     'multiparticles', 'couplings', 'lorentz', 'checks']
    _add_opts = ['process']
    _save_opts = ['model', 'processes']
    _tutorial_opts = ['start', 'stop']
    _check_opts = ['full', 'permutation', 'gauge', 'lorentz_invariance']
    _import_formats = ['model_v4', 'model', 'proc_v4', 'command']
    _v4_export_formats = ['madevent', 'standalone', 'matrix'] 
    _export_formats = _v4_export_formats + ['standalone_cpp', 'pythia8',
                                            'pythia8_model']
    _set_options = ['group_subprocesses_output',
                    'ignore_six_quark_processes']
    # Variables to store object information
    _curr_model = None  #base_objects.Model()
    _curr_amps = diagram_generation.AmplitudeList()
    _curr_matrix_elements = helas_objects.HelasMultiProcess()
    _curr_fortran_model = None
    _curr_cpp_model = None
    _done_export = False

    # Variables to store state information
    _multiparticles = {}
    _options = {}
    _generate_info = "" # store the first generated process
    _model_format = None
    _model_v4_path = None
    _use_lower_part_names = False
    _export_dir = None
    _export_format = 'madevent'
    _mgme_dir = MG4DIR
    _comparisons = None
    
    def __init__(self, mgme_dir = '', *completekey, **stdin):
        """ add a tracker of the history """

        CmdExtended.__init__(self, *completekey, **stdin)
        
        # Set MG/ME directory path
        if mgme_dir:
            if os.path.isdir(os.path.join(mgme_dir, 'Template')):
                self._mgme_dir = mgme_dir
                logger.info('Setting MG/ME directory to %s' % mgme_dir)
            else:
                logger.warning('Warning: Directory %s not valid MG/ME directory' % \
                             mgme_dir)
                self._mgme_dir = MG4DIR

        # Detect if this script is launched from a valid copy of the Template,
        # if so store this position as standard output directory
        if 'TemplateVersion.txt' in os.listdir('.'):
            #Check for ./
            self._export_dir = os.path.realpath('.')
        elif 'TemplateVersion.txt' in os.listdir('..'):
            #Check for ../
            self._export_dir = os.path.realpath('..')
        elif self.stdin != sys.stdin:
            #Check for position defined by the input files
            input_path = os.path.realpath(self.stdin.name).split(os.path.sep)
            print "Not standard stdin, use input path"
            if input_path[-2] == 'Cards':
                self._export_dir = os.path.sep.join(input_path[:-2])
        
    # Add a process to the existing multiprocess definition
    # Generate a new amplitude
    def do_add(self, line):
        """Generate an amplitude for a given process and add to
        existing amplitudes
        syntax:
        """

        args = split_arg(line)
        
        # Check the validity of the arguments
        self.check_add(args)

        if args[0] == 'process':            
            # Rejoin line
            line = ' '.join(args[1:])
            
            # store the first process (for the perl script)
            if not self._generate_info:
                self._generate_info = line
                
            # Reset Helas matrix elements
            self._curr_matrix_elements = helas_objects.HelasMultiProcess()

            try:
                if line.find(',') == -1:
                    myprocdef = self.extract_process(line)
                else:
                    myprocdef, line = self.extract_decay_chain_process(line)
            except MadGraph5Error, error:
                logger_stderr.warning("Empty or wrong format process :\n" + \
                                     str(error))
                return
                
            if myprocdef:

                cpu_time1 = time.time()
                
                # Generate processes
                collect_mirror_procs = \
                                     self._options['group_subprocesses_output']
                ignore_six_quark_processes = \
                               self._options['ignore_six_quark_processes'] if \
                               "ignore_six_quark_processes" in self._options \
                               else []

                myproc = diagram_generation.MultiProcess(myprocdef,
                                              collect_mirror_procs =\
                                              collect_mirror_procs,
                                              ignore_six_quark_processes = \
                                              ignore_six_quark_processes)
                    
                for amp in myproc.get('amplitudes'):
                    if amp not in self._curr_amps:
                        self._curr_amps.append(amp)
                    else:
                        warning = "Warning: Already in processes:\n%s" % \
                                                    amp.nice_string_processes()
                        logger.warning(warning)

                # Reset _done_export, since we have new process
                self._done_export = False

                cpu_time2 = time.time()

                nprocs = len(myproc.get('amplitudes'))
                ndiags = sum([amp.get_number_of_diagrams() for \
                                  amp in myproc.get('amplitudes')])
                logger.info("%i processes with %i diagrams generated in %0.3f s" % \
                      (nprocs, ndiags, (cpu_time2 - cpu_time1)))
                ndiags = sum([amp.get_number_of_diagrams() for \
                                  amp in self._curr_amps])
                logger.info("Total: %i processes with %i diagrams" % \
                      (len(self._curr_amps), ndiags))                
  
    # Define a multiparticle label
    def do_define(self, line, log=True):
        """Define a multiparticle"""

        if self._use_lower_part_names:
            # Particle names lowercase
            line = line.lower()
        # Make sure there are spaces around = and |
        line = line.replace("=", " = ")
        line = line.replace("|", " | ")
        args = split_arg(line)
        # check the validity of the arguments
        self.check_define(args)

        label = args[0]
        
        pdg_list = self.extract_particle_ids(args[1:])
        self._multiparticles[label] = pdg_list
        if log:
            logger.info("Defined multiparticle %s" % \
                                             self.multiparticle_string(label))
    
    # Display
    def do_display(self, line):
        """Display current internal status"""

        args = split_arg(line)
        #check the validity of the arguments
        self.check_display(args)

        if args[0] == 'particles' and len(args) == 1:
            print "Current model contains %i particles:" % \
                    len(self._curr_model['particles'])
            part_antipart = [part for part in self._curr_model['particles'] \
                             if not part['self_antipart']]
            part_self = [part for part in self._curr_model['particles'] \
                             if part['self_antipart']]
            for part in part_antipart:
                print part['name'] + '/' + part['antiname'],
            print ''
            for part in part_self:
                print part['name'],
            print ''

        elif args[0] == 'particles':
            for arg in args[1:]:
                if arg.isdigit() or (arg[0] == '-' and arg[1:].isdigit()):
                    particle = self._curr_model.get_particle(abs(int(arg)))
                else:
                    particle = self._curr_model['particles'].find_name(arg)
                if not particle:
                    raise self.InvalidCmd, 'no particle %s in current model' % arg

                print "Particle %s has the following properties:" % particle.get_name()
                print str(particle)
            
        elif args[0] == 'interactions' and len(args) == 1:
            text = "Current model contains %i interactions\n" % \
                    len(self._curr_model['interactions'])
            for inter in self._curr_model['interactions']:
                text += str(inter['id']) + ':'
                for part in inter['particles']:
                    if part['is_part']:
                        text += part['name']
                    else:
                        text += part['antiname']
                    text += " "
                text += " ".join(order + '=' + str(inter['orders'][order]) \
                                 for order in inter['orders'])
                text += '\n'
            pydoc.pager(text)

        elif args[0] == 'interactions':
            for arg in args[1:]:
                if int(arg) > len(self._curr_model['interactions']):
                    raise self.InvalidCmd, 'no interaction %s in current model' % arg
                if int(arg) == 0:
                    print 'Special interactions which identify two particles'
                else:
                    print "Interactions %s has the following property:" % arg
                    print self._curr_model['interactions'][int(arg)-1]


        elif args[0] == 'processes':
            for amp in self._curr_amps:
                print amp.nice_string_processes()

        elif args[0] == 'diagrams':
            text = "\n".join([amp.nice_string() for amp in self._curr_amps])
            pydoc.pager(text)

        elif args[0] == 'multiparticles':
            print 'Multiparticle labels:'
            for key in self._multiparticles:
                print self.multiparticle_string(key)
        
        elif args[0] == 'couplings' and len(args) == 1:
            couplings = set()
            for interaction in self._curr_model['interactions']:
                for order in interaction['orders'].keys():
                    couplings.add(order)
            print ' / '.join(couplings)
            
        elif args[0] == 'couplings':
            if self._model_v4_path:
                print 'No couplings information available in V4 model'
                return
            try:
                ufomodel = ufomodels.load_model(self._curr_model.get('name'))
                print eval('ufomodel.couplings.%s.nice_string()'%args[1])
            except:
                raise self.InvalidCmd, 'no couplings %s in current model' % args[1]
        
        elif args[0] == 'lorentz':
            if self._model_v4_path:
                print 'No lorentz information available in V4 model'
                return
            elif len(args) == 1: 
                raise self.InvalidCmd,\
                     'display lorentz require an argument: the name of the lorentz structure.'
                return
            try:
                ufomodel = ufomodels.load_model(self._curr_model.get('name'))
                print eval('ufomodel.lorentz.%s.nice_string()'%args[1])
            except:
                raise self.InvalidCmd, 'no lorentz %s in current model' % args[1]
            
        elif args[0] == 'checks':
            comparisons = self._comparisons[0]
            if len(args) > 1 and args[1] == 'failed':
                comparisons = [c for c in comparisons if not c['passed']]
            outstr = "Process check results:"
            for comp in comparisons:
                outstr += "\n%s:" % comp['process'].nice_string()
                outstr += "\n   Phase space point: (px py pz E)"
                for i, p in enumerate(comp['momenta']):
                    outstr += "\n%2s    %+.9e  %+.9e  %+.9e  %+.9e" % tuple([i] + p)
                outstr += "\n   Permutation values:"
                outstr += "\n   " + str(comp['values'])
                if comp['passed']:
                    outstr += "\n   Process passed (rel. difference %.9e)" % \
                          comp['difference']
                else:
                    outstr += "\n   Process failed (rel. difference %.9e)" % \
                          comp['difference']

            used_aloha = sorted(self._comparisons[1])
            outstr += "\nChecked ALOHA routines:"
            for aloha in used_aloha:
                aloha_str = aloha[0]
                if aloha[1]:
                    aloha_str += 'C' + 'C'.join([str(ia) for ia in aloha[1]])
                aloha_str += "_%d" % aloha[2]
                outstr += "\n" + aloha_str

            pydoc.pager(outstr)            
        
    def multiparticle_string(self, key):
        """Returns a nicely formatted string for the multiparticle"""

        if self._multiparticles[key] and \
               isinstance(self._multiparticles[key][0], list):
            return "%s = %s" % (key, "|".join([" ".join([self._curr_model.\
                                     get('particle_dict')[part_id].get_name() \
                                                     for part_id in id_list]) \
                                  for id_list in self._multiparticles[key]]))
        else:
            return "%s = %s" % (key, " ".join([self._curr_model.\
                                    get('particle_dict')[part_id].get_name() \
                                    for part_id in self._multiparticles[key]]))
            
  

    def do_tutorial(self, line):
        """Activate/deactivate the tutorial mode."""

        args = split_arg(line)
        if len(args) > 0 and args[0] == "stop":
            logger_tuto.info("\n\tThanks for using the tutorial!")
            logger_tuto.setLevel(logging.ERROR)
        else:
            logger_tuto.setLevel(logging.INFO)

        if not self._mgme_dir:
            logger_tuto.info(\
                       "\n\tWarning: To use all features in this tutorial, " + \
                       "please run from a" + \
                       "\n\t         valid MG_ME directory.")

    def do_draw(self, line):
        """ draw the Feynman diagram for the given process """

        args = split_arg(line)
        # Check the validity of the arguments
        self.check_draw(args)
        
        # Check if we plot a decay chain 
        if any([isinstance(a, diagram_generation.DecayChainAmplitude) for \
               a in self._curr_amps]) and not self._done_export:
            warn = 'WARNING: You try to draw decay chain diagrams without first running output.\n'
            warn += '\t  The decay processes will be drawn separately'
            logger.warning(warn)

        (options, args) = _draw_parser.parse_args(args)
        options = draw_lib.DrawOption(options)
        start = time.time()
        
        # Collect amplitudes
        amplitudes = diagram_generation.AmplitudeList()

        for amp in self._curr_amps:
            amplitudes.extend(amp.get_amplitudes())            

        for amp in amplitudes:
            filename = os.path.join(args[0], 'diagrams_' + \
                                    amp.get('process').shell_string() + ".eps")
            plot = draw.MultiEpsDiagramDrawer(amp['diagrams'],
                                          filename,
                                          model=self._curr_model,
                                          amplitude='',
                                          legend=amp.get('process').input_string())

            logger.info("Drawing " + \
                         amp.get('process').nice_string())
            plot.draw(opt=options)
            logger.info("Wrote file " + filename)

        stop = time.time()
        logger.info('time to draw %s' % (stop - start)) 
    
    # Generate a new amplitude
    def do_check(self, line):
        """Check a given process or set of processes"""

        args = split_arg(line)

        # Check args validity
        param_card = self.check_check(args)

        line = " ".join(args[1:])
        myprocdef = self.extract_process(line)

        # Check that we have something    
        if not myprocdef:
            raise MadGraph5Error("Empty or wrong format process, please try again.")

        # Disable diagram generation logger
        diag_logger = logging.getLogger('madgraph.diagram_generation')
        old_level = diag_logger.getEffectiveLevel()
        diag_logger.setLevel(logging.WARNING)

        # run the check
        cpu_time1 = time.time()
        # Run matrix element generation check on processes

        comparisons = []
        gauge_result = []
        lorentz_result =[]
        nb_processes = 0
        
        if args[0] in  ['permutation', 'full']:
            comparisons = process_checks.check_processes(myprocdef,
                                                        param_card = param_card,
                                                        quick = True)
            nb_processes += len(comparisons[0])
            
        if args[0] in  ['gauge', 'full']:
            gauge_result = process_checks.check_gauge(myprocdef,
                                                      param_card = param_card)
            nb_processes += len(gauge_result)
            
        if args[0] in ['lorentz_invariance', 'full']:
            lorentz_result = process_checks.check_lorentz(myprocdef,
                                                      param_card = param_card)
            nb_processes += len(lorentz_result)
            
        cpu_time2 = time.time()

        logger.info("%i processes checked in %0.3f s" \
                    % (nb_processes,
                      (cpu_time2 - cpu_time1)))

        text = ""

        if gauge_result:
            text += 'Gauge results:\n'
            text += process_checks.output_gauge(gauge_result) + '\n'

        if lorentz_result:
            text += 'Lorentz invariance results:\n'
            text += process_checks.output_lorentz_inv(lorentz_result) + '\n'

        if comparisons:
            text += 'Process permutation results:\n'
            text += process_checks.output_comparisons(comparisons[0]) + '\n'
            self._comparisons = comparisons

        logger.info(text)
        pydoc.pager(text)
        # Restore diagram logger
        diag_logger.setLevel(old_level)

        return
    
    # Generate a new amplitude
    def do_generate(self, line):
        """Generate an amplitude for a given process"""

        args = split_arg(line)

        # Check args validity
        self.check_generate(args)

        # Reset Helas matrix elements
        self._curr_matrix_elements = helas_objects.HelasMultiProcess()
        self._generate_info = line
        # Reset _done_export, since we have new process
        self._done_export = False

        # Extract process from process definition
        if ',' in line:
            myprocdef, line = self.extract_decay_chain_process(line)
        else:
            myprocdef = self.extract_process(line)
            
        # Check that we have something    
        if not myprocdef:
            raise MadGraph5Error("Empty or wrong format process, please try again.")

        cpu_time1 = time.time()
        # Generate processes
        collect_mirror_procs = self._options['group_subprocesses_output']
        ignore_six_quark_processes = \
                            self._options['ignore_six_quark_processes'] if \
                            "ignore_six_quark_processes" in self._options \
                            else []

        myproc = diagram_generation.MultiProcess(myprocdef,
                                              collect_mirror_procs = \
                                              collect_mirror_procs,
                                              ignore_six_quark_processes = \
                                              ignore_six_quark_processes)
        self._curr_amps = myproc.get('amplitudes')
        cpu_time2 = time.time()

        nprocs = len(self._curr_amps)
        ndiags = sum([amp.get_number_of_diagrams() for \
                              amp in self._curr_amps])
        logger.info("%i processes with %i diagrams generated in %0.3f s" % \
                  (nprocs, ndiags, (cpu_time2 - cpu_time1)))
    
    def extract_process(self, line, proc_number = 0, overall_orders = {}):
        """Extract a process definition from a string. Returns
        a ProcessDefinition."""

        # Check basic validity of the line
        if not line.count('>') in [1,2]:
            self.do_help('generate')
            print
            raise self.InvalidCmd('Wrong use of \">\" special character.')
        

        # Perform sanity modifications on the lines:
        # Add a space before and after any > , $ / |
        space_before = re.compile(r"(?P<carac>\S)(?P<tag>[/\,\\$\\>|])(?P<carac2>\S)")
        line = space_before.sub(r'\g<carac> \g<tag> \g<carac2>', line)       
        
        # Use regular expressions to extract s-channel propagators,
        # forbidden s-channel propagators/particles, coupling orders
        # and process number, starting from the back

        # Start with process number (identified by "@")
        proc_number_pattern = re.compile("^(.+)@\s*(\d+)\s*(.*)$")
        proc_number_re = proc_number_pattern.match(line)
        if proc_number_re:
            proc_number = int(proc_number_re.group(2))
            line = proc_number_re.group(1) + \
                   proc_number_re.group(3)

        # Then take coupling orders (identified by "=")
        order_pattern = re.compile("^(.+)\s+(\w+)\s*=\s*(\d+)\s*$")
        order_re = order_pattern.match(line)
        orders = {}
        while order_re:
            orders[order_re.group(2)] = int(order_re.group(3))
            line = order_re.group(1)
            order_re = order_pattern.match(line)

        if self._use_lower_part_names:
            # Particle names lowercase
            line = line.lower()

        # Now check for forbidden particles, specified using "/"
        slash = line.find("/")
        dollar = line.find("$")
        forbidden_particles = ""
        if slash > 0:
            if dollar > slash:
                forbidden_particles_re = re.match("^(.+)\s*/\s*(.+\s*)(\$.*)$", line)
            else:
                forbidden_particles_re = re.match("^(.+)\s*/\s*(.+\s*)$", line)
            if forbidden_particles_re:
                forbidden_particles = forbidden_particles_re.group(2)
                line = forbidden_particles_re.group(1)
                if len(forbidden_particles_re.groups()) > 2:
                    line = line + forbidden_particles_re.group(3)

        # Now check for forbidden schannels, specified using "$"
        forbidden_schannels_re = re.match("^(.+)\s*\$\s*(.+)\s*$", line)
        forbidden_schannels = ""
        if forbidden_schannels_re:
            forbidden_schannels = forbidden_schannels_re.group(2)
            line = forbidden_schannels_re.group(1)

        # Now check for required schannels, specified using "> >"
        required_schannels_re = re.match("^(.+?)>(.+?)>(.+)$", line)
        required_schannels = ""
        if required_schannels_re:
            required_schannels = required_schannels_re.group(2)
            line = required_schannels_re.group(1) + ">" + \
                   required_schannels_re.group(3)

        args = split_arg(line)

        myleglist = base_objects.MultiLegList()
        state = False

        # Extract process
        for part_name in args:
            if part_name == '>':
                if not myleglist:
                    raise MadGraph5Error, "No final state particles"
                state = True
                continue

            mylegids = []
            if part_name in self._multiparticles:
                if isinstance(self._multiparticles[part_name][0], list):
                    raise MadGraph5Error,\
                          "Multiparticle %s is or-multiparticle" % part_name + \
                          " which can be used only for required s-channels"
                mylegids.extend(self._multiparticles[part_name])
            else:
                mypart = self._curr_model['particles'].find_name(part_name)
                if mypart:
                    mylegids.append(mypart.get_pdg_code())

            if mylegids:
                myleglist.append(base_objects.MultiLeg({'ids':mylegids,
                                                        'state':state}))
            else:
                raise MadGraph5Error, \
                      "No particle %s in model" % part_name

        if filter(lambda leg: leg.get('state') == True, myleglist):
            # We have a valid process

            # Now extract restrictions
            forbidden_particle_ids = \
                              self.extract_particle_ids(forbidden_particles)
            if forbidden_particle_ids and \
               isinstance(forbidden_particle_ids[0], list):
                raise MadGraph5Error,\
                      "Multiparticle %s is or-multiparticle" % part_name + \
                      " which can be used only for required s-channels"
            forbidden_schannel_ids = \
                              self.extract_particle_ids(forbidden_schannels)
            if forbidden_schannel_ids and \
               isinstance(forbidden_schannel_ids[0], list):
                raise MadGraph5Error,\
                      "Multiparticle %s is or-multiparticle" % part_name + \
                      " which can be used only for required s-channels"
            required_schannel_ids = \
                               self.extract_particle_ids(required_schannels)
            if required_schannel_ids and not \
                   isinstance(required_schannel_ids[0], list):
                required_schannel_ids = [required_schannel_ids]
            

            #decay_process = len(filter(lambda leg: \
            #                           leg.get('state') == False,
            #                           myleglist)) == 1


            return \
                base_objects.ProcessDefinition({'legs': myleglist,
                              'model': self._curr_model,
                              'id': proc_number,
                              'orders': orders,
                              'forbidden_particles': forbidden_particle_ids,
                              'forbidden_s_channels': forbidden_schannel_ids,
                              'required_s_channels': required_schannel_ids,
                              'overall_orders': overall_orders
                              })
      #                       'is_decay_chain': decay_process\

    def extract_particle_ids(self, args):
        """Extract particle ids from a list of particle names. If
        there are | in the list, this corresponds to an or-list, which
        is represented as a list of id lists. An or-list is used to
        allow multiple required s-channel propagators to be specified
        (e.g. Z/gamma)."""

        if isinstance(args, basestring):
            args.replace("|", " | ")
            args = split_arg(args)
        all_ids = []
        ids=[]
        for part_name in args:
            mypart = self._curr_model['particles'].find_name(part_name)
            if mypart:
                ids.append([mypart.get_pdg_code()])
            elif part_name in self._multiparticles:
                ids.append(self._multiparticles[part_name])
            elif part_name == "|":
                # This is an "or-multiparticle"
                if ids:
                    all_ids.append(ids)
                ids = []
            else:
                raise MadGraph5Error("No particle %s in model" % part_name)
        all_ids.append(ids)
        # Flatten id list, to take care of multiparticles and
        # or-multiparticles
        res_lists = []
        for i, id_list in enumerate(all_ids):
            res_lists.extend(diagram_generation.expand_list_list(id_list))
        # Trick to avoid duplication while keeping ordering
        for ilist, idlist in enumerate(res_lists):
            set_dict = {}
            res_lists[ilist] = [set_dict.setdefault(i,i) for i in idlist \
                         if i not in set_dict]

        if len(res_lists) == 1:
            res_lists = res_lists[0]

        return res_lists

    def extract_decay_chain_process(self, line, level_down=False):
        """Recursively extract a decay chain process definition from a
        string. Returns a ProcessDefinition."""

        # Start with process number (identified by "@") and overall orders
        proc_number_pattern = re.compile("^(.+)@\s*(\d+)\s*((\w+\s*=\s*\d+\s*)*)$")
        proc_number_re = proc_number_pattern.match(line)
        proc_number = 0
        overall_orders = {}
        if proc_number_re:
            proc_number = int(proc_number_re.group(2))
            line = proc_number_re.group(1)
            if proc_number_re.group(3):
                order_pattern = re.compile("^(.*?)\s*(\w+)\s*=\s*(\d+)\s*$")
                order_line = proc_number_re.group(3)
                order_re = order_pattern.match(order_line)
                while order_re:
                    overall_orders[order_re.group(2)] = int(order_re.group(3))
                    order_line = order_re.group(1)
                    order_re = order_pattern.match(order_line)
            logger.info(line)            
            
        index_comma = line.find(",")
        index_par = line.find(")")
        min_index = index_comma
        if index_par > -1 and (index_par < min_index or min_index == -1):
            min_index = index_par
        
        if min_index > -1:
            core_process = self.extract_process(line[:min_index], proc_number,
                                                overall_orders)
        else:
            core_process = self.extract_process(line, proc_number,
                                                overall_orders)

        #level_down = False

        while index_comma > -1:
            line = line[index_comma + 1:]
            if not line.strip():
                break
            index_par = line.find(')')
            if line.lstrip()[0] == '(':
                # Go down one level in process hierarchy
                #level_down = True
                line = line.lstrip()[1:]
                # This is where recursion happens
                decay_process, line = \
                            self.extract_decay_chain_process(line,
                                                             level_down=True)
                index_comma = line.find(",")
                index_par = line.find(')')
            else:
                index_comma = line.find(",")
                min_index = index_comma
                if index_par > -1 and \
                       (index_par < min_index or min_index == -1):
                    min_index = index_par
                if min_index > -1:
                    decay_process = self.extract_process(line[:min_index])
                else:
                    decay_process = self.extract_process(line)

            core_process.get('decay_chains').append(decay_process)

            if level_down:
                if index_par == -1:
                    raise MadGraph5Error, \
                      "Missing ending parenthesis for decay process"

                if index_par < index_comma:
                    line = line[index_par + 1:]
                    level_down = False
                    break

        if level_down:
            index_par = line.find(')')
            if index_par == -1:
                raise MadGraph5Error, \
                      "Missing ending parenthesis for decay process"
            line = line[index_par + 1:]
            
        # Return the core process (ends recursion when there are no
        # more decays)
        return core_process, line
    
    # Write the list of command line use in this session
    def do_history(self, line):
        """write in a file the suite of command that was used"""
        
        args = split_arg(line)
        # Check arguments validity
        self.check_history(args)

        if len(args) == 0:
            print '\n'.join(self.history)
            return
        elif args[0] == 'clean':
            self.history = []
            logger.info('History is cleaned')
            return
        elif args[0] == '.':
            output_file = os.path.join(self._export_dir, 'Cards', \
                                       'proc_card_mg5.dat')
            output_file = open(output_file, 'w')
        else:
            output_file = open(args[0], 'w')
            
        # Create the command file
        text = self.history_header % misc.get_time_info()
        text += ('\n'.join(self.history) + '\n') 
        
        #write this information in a file
        output_file.write(text)
        output_file.close()

        if self.log:
            logger.info("History written to " + output_file.name)
    
    # Import files
    def do_import(self, line):
        """Import files with external formats"""

        args = split_arg(line)
        # Check argument's validity
        self.check_import(args)
        
        if args[0].startswith('model'):
            self._model_v4_path = None
            # Clear history, amplitudes and matrix elements when a model is imported
            self.history = self.history[-1:]
            self._curr_amps = diagram_generation.AmplitudeList()
            self._curr_matrix_elements = helas_objects.HelasMultiProcess()
            # Import model
            if args[0].endswith('_v4'):
                self._curr_model, self._model_v4_path = \
                                 import_v4.import_model(args[1], self._mgme_dir)
                self._curr_fortran_model = \
                      helas_call_writers.FortranHelasCallWriter(\
                                                             self._curr_model)
                # Automatically turn off subprocess grouping
                self.do_set('group_subprocesses_output False')
            else:
                self._curr_model = import_ufo.import_model(args[1])
                self._curr_fortran_model = \
                      helas_call_writers.FortranUFOHelasCallWriter(\
                                                             self._curr_model)
                # Automatically turn on subprocess grouping
                self.do_set('group_subprocesses_output True')
                self._curr_cpp_model = \
                      helas_call_writers.CPPUFOHelasCallWriter(\
                                                             self._curr_model)
            if '-modelname' not in args:
                self._curr_model.pass_particles_name_in_mg_default()

            # Do post-processing of model
            self.process_model()

            # Reset amplitudes and matrix elements and global checks
            self._curr_amps = diagram_generation.AmplitudeList()
            self._curr_matrix_elements = helas_objects.HelasMultiProcess()
            process_checks.store_aloha = []
            
        elif args[0] == 'command':
            if not os.path.isfile(args[1]):
                raise MadGraph5Error("Path %s is not a valid pathname" % args[1])
            else:
                # Check the status of export and try to use file position is no
                #self._export dir are define
                self.check_for_export_dir(args[1])
                # Execute the card
                self.import_mg5_proc_card(args[1])    
        
        elif args[0] == 'proc_v4':
            
            if len(args) == 1 and self._export_dir:
                proc_card = os.path.join(self._export_dir, 'Cards', \
                                                                'proc_card.dat')
            elif len(args) == 2:
                proc_card = args[1]
                # Check the status of export and try to use file position is no
                #self._export dir are define
                if os.path.isdir(args[1]):
                    proc_card = os.path.join(proc_card, 'Cards', \
                                                                'proc_card.dat')    
                self.check_for_export_dir(os.path.realpath(proc_card))
            else:
                raise MadGraph5Error('No default directory in output')

 
            #convert and excecute the card
            self.import_mg4_proc_card(proc_card)
                                     
    def process_model(self):
        """Set variables _particle_names and _couplings for tab
        completion, define multiparticles"""

         # Set variables for autocomplete
        self._particle_names = [p.get('name') for p in self._curr_model.get('particles')] + \
             [p.get('antiname') for p in self._curr_model.get('particles')]
        self._couplings = list(set(sum([i.get('orders').keys() for i in \
                                        self._curr_model.get('interactions')], [])))
        # Check if we can use case-independent particle names
        self._use_lower_part_names = \
            (self._particle_names == \
             [p.get('name').lower() for p in self._curr_model.get('particles')] + \
             [p.get('antiname').lower() for p in self._curr_model.get('particles')])

        self.add_default_multiparticles()
        
    
    def import_mg4_proc_card(self, filepath):
        """ read a V4 proc card, convert it and run it in mg5"""
        
        # change the status of this line in the history -> pass in comment
        self.history[-1] = '#%s' % self.history[-1]
         
        # read the proc_card.dat
        reader = files.read_from_file(filepath, import_v4.read_proc_card_v4)
        if not reader:
            raise MadGraph5Error('\"%s\" is not a valid path' % filepath)
        
        if self._mgme_dir:
            # Add comment to history
            self.exec_cmd("# Import the model %s" % reader.model)
            line = self.exec_cmd('import model_v4 %s -modelname' % \
                                 (reader.model))
        else:
            logging.error('No MG_ME installation detected')
            return    


        # Now that we have the model we can split the information
        lines = reader.extract_command_lines(self._curr_model)

        for line in lines:
            self.exec_cmd(line)
    
        return 
           
    def import_mg5_proc_card(self, filepath):
        # remove this call from history
        self.history.pop()
        self.timeout, old_time_out = 20, self.timeout
        
        # Read the lines of the file and execute them
        for line in CmdFile(filepath):
            #remove pointless spaces and \n
            line = line.replace('\n', '').strip()
            # execute the line
            if line:
                self.exec_cmd(line)
        self.timeout = old_time_out
        return
    
    def add_default_multiparticles(self):
        """ add default particle from file interface.multiparticles_default.txt
        """
        
        defined_multiparticles = self._multiparticles.keys()
        removed_multiparticles = []
        # First check if the defined multiparticles are allowed in the
        # new model
        for key in self._multiparticles.keys():
            try:
                for part in self._multiparticles[key]:
                    self._curr_model.get('particle_dict')[part]
            except:
                del self._multiparticles[key]
                defined_multiparticles.remove(key)
                removed_multiparticles.append(key)
        
        # Now add default multiparticles
        for line in open(os.path.join(MG5DIR, 'input', \
                                      'multiparticles_default.txt')):
            if line.startswith('#'):
                continue
            try:
                if self._use_lower_part_names:
                    multipart_name = line.lower().split()[0]
                else:
                    multipart_name = line.split()[0]
                if multipart_name not in self._multiparticles:
                    self.do_define(line)
                    
            except MadGraph5Error, why:
                logger_stderr.warning('impossible to set default multiparticles %s because %s' %
                                        (line.split()[0],why))
        if defined_multiparticles:
            logger.info("Kept definitions of multiparticles %s unchanged" % \
                                         " / ".join(defined_multiparticles))

        for removed_part in removed_multiparticles:
            if removed_part in self._multiparticles:
                removed_multiparticles.remove(removed_part)

        if removed_multiparticles:
            logger.info("Removed obsolete multiparticles %s" % \
                                         " / ".join(removed_multiparticles))
            
    def check_for_export_dir(self, filepath):
        """Check if the files is in a valid export directory and assign it to
        export path if if is"""
        
        # keep previous if a previous one is defined
        if self._export_dir:
            return
        
        path_split = filepath.split(os.path.sep)
        if len(path_split) > 2 and path_split[-2] == 'Cards':
            self._export_dir = os.path.sep.join(path_split[:-2])
                
    
    def do_load(self, line):
        """Load information from file"""

        args = split_arg(line)
        # check argument validity
        self.check_load(args)

        cpu_time1 = time.time()
        if args[0] == 'model':
            self._curr_model = save_load_object.load_from_file(args[1])
            if self._curr_model.get('parameters'):
                # This is a UFO model
                self._model_v4_path = None
                self._curr_fortran_model = \
                  helas_call_writers.FortranUFOHelasCallWriter(self._curr_model)
            else:
                # This is a v4 model
                self._model_v4_path = import_v4.find_model_path(\
                    self._curr_model.get('name').replace("_v4", ""),
                    self._mgme_dir)
                self._curr_fortran_model = \
                  helas_call_writers.FortranHelasCallWriter(self._curr_model)

            # Do post-processing of model
            self.process_model()
                
            #save_model.save_model(args[1], self._curr_model)
            if isinstance(self._curr_model, base_objects.Model):
                cpu_time2 = time.time()
                logger.info("Loaded model from file in %0.3f s" % \
                      (cpu_time2 - cpu_time1))
            else:
                raise self.RWError('Could not load model from file %s' \
                                      % args[1])
        elif args[0] == 'processes':
            amps = save_load_object.load_from_file(args[1])
            if isinstance(amps, diagram_generation.AmplitudeList):
                cpu_time2 = time.time()
                logger.info("Loaded processes from file in %0.3f s" % \
                      (cpu_time2 - cpu_time1))
                if amps:
                    model = amps[0].get('process').get('model')
                    if not model.get('parameters'):
                        # This is a v4 model.  Look for path.
                        self._model_v4_path = import_v4.find_model_path(\
                                   model.get('name').replace("_v4", ""),
                                   self._mgme_dir)
                        self._curr_fortran_model = \
                                helas_call_writers.FortranHelasCallWriter(\
                                                              model)
                    else:
                        self._model_v4_path = None
                        self._curr_fortran_model = \
                                helas_call_writers.FortranUFOHelasCallWriter(\
                                                              model)
                    # If not exceptions from previous steps, set
                    # _curr_amps and _curr_model
                    self._curr_amps = amps                    
                    self._curr_model = model
                    logger.info("Model set from process.")
                    # Do post-processing of model
                    self.process_model()
                self._done_export = None
            else:
                raise self.RWError('Could not load processes from file %s' % args[1])
        if self._model_v4_path:
            # Automatically turn off subprocess grouping
            self.do_set('group_subprocesses_output False')
        else:
            # Automatically turn on subprocess grouping
            self.do_set('group_subprocesses_output True')
        
    
    def do_save(self, line):
        """Save information to file"""

        args = split_arg(line)
        # Check argument validity
        self.check_save(args)

        if args[0] == 'model':
            if self._curr_model:
                #save_model.save_model(args[1], self._curr_model)
                if save_load_object.save_to_file(args[1], self._curr_model):
                    logger.info('Saved model to file %s' % args[1])
            else:
                raise self.InvalidCmd('No model to save!')
        elif args[0] == 'processes':
            if self._curr_amps:
                if save_load_object.save_to_file(args[1], self._curr_amps):
                    logger.info('Saved processes to file %s' % args[1])
            else:
                raise self.InvalidCmd('No processes to save!')
    
    # Set an option
    def do_set(self, line):
        """Set an option, which will be default for coming generations/outputs
        """

        args = split_arg(line)
        
        # Check the validity of the arguments
        self.check_set(args)

        if args[0] == 'ignore_six_quark_processes':
            self._options[args[0]] = list(set([abs(p) for p in \
                                      self._multiparticles[args[1]]\
                                      if self._curr_model.get_particle(p).\
                                      is_fermion() and \
                                      self._curr_model.get_particle(abs(p)).\
                                      get('color') == 3]))
            logger.info('Ignore processes with >= 6 quarks (%s)' % \
                        ",".join([\
                            self._curr_model.get_particle(q).get('name') \
                            for q in self._options[args[0]]]))
        if args[0] == 'group_subprocesses_output':
            self._options[args[0]] = eval(args[1])
            logger.info('Set group_subprocesses_output to %s' % \
                        str(self._options[args[0]]))

    def do_output(self, line):
        """Initialize a new Template or reinitialize one"""
        
        args = split_arg(line)
        # Check Argument validity
        self.check_output(args)
        
        noclean = '-noclean' in args
        force = '-f' in args 
        nojpeg = '-nojpeg' in args
    
        if self._done_export == (self._export_dir, self._export_format):
            logger.info('Matrix elements already exported to directory %s' % \
                        self._export_dir)
            return

        if not force and not noclean and os.path.isdir(self._export_dir)\
               and self._export_format in ['madevent', 'standalone']:
            # Don't ask if user already specified force or noclean
            logger.info('INFO: directory %s already exists.' % self._export_dir)
            logger.info('If you continue this directory will be cleaned')
            answer = self.timed_input('Do you want to continue? [y/n]', 'y')
            if answer != 'y':
                raise MadGraph5Error('Stopped by user request')

        group_subprocesses = self._export_format == 'madevent' and \
                             self._options['group_subprocesses_output']
        # Make a Template Copy
        if self._export_format.startswith('madevent'):
            export_v4.copy_v4template(self._mgme_dir, self._export_dir,
                                      not noclean, self._model_v4_path,
                                      group_subprocesses)
        elif self._export_format == 'standalone':
            export_v4.copy_v4standalone(self._mgme_dir, self._export_dir,
                                        not noclean)
        elif self._export_format == 'standalone_cpp':
            export_cpp.setup_cpp_standalone_dir(self._export_dir, self._curr_model)
        elif not os.path.isdir(self._export_dir):
            os.makedirs(self._export_dir)

        # Reset _done_export, since we have new directory
        self._done_export = False

        # Perform export and finalize right away
        options = ''
        if nojpeg:
            options = '-nojpeg'

        self.export(options)

    # Export a matrix element
    def export(self, line):
        """Export a generated amplitude to file"""

        def generate_matrix_elements(self):
            """Helper function to generate the matrix elements before
            exporting"""

            cpu_time1 = time.time()
            if not self._curr_matrix_elements.get('matrix_elements'):
                self._curr_matrix_elements = \
                             helas_objects.HelasMultiProcess(\
                                           self._curr_amps)
            cpu_time2 = time.time()

            ndiags = sum([len(me.get('diagrams')) for \
                          me in self._curr_matrix_elements.\
                          get('matrix_elements')])

            return ndiags, cpu_time2 - cpu_time1

        # Start of the actual routine

        args = split_arg(line)
        # Check the validity of the arguments and return the output path
        if __debug__:
            self.check_output(args)

        if self._export_format == 'pythia8_model':
            cpu_time1 = time.time()
            export_cpp.convert_model_to_pythia8(\
                            self._curr_model, self._export_dir)
            cpu_time2 = time.time()
            logger.info(("Exported UFO model to Pythia 8 format in %0.3f s") \
                        % (cpu_time2 - cpu_time1))

            return

        if self._done_export == (self._export_dir, self._export_format):
            # We have already done export in this path
            logger.info("Matrix elements already exported to directory %s" % \
                                    self._export_dir)
            return        

        # Determine if we want to group subprocesses
        group_subprocesses = self._export_format == 'madevent' and \
                             self._options['group_subprocesses_output']
        
        if not group_subprocesses:
            # Do not generate matrix elements, since this is done by the
            # SubProcessGroup objects
            ndiags, cpu_time = generate_matrix_elements(self)

        calls = 0

        nojpeg = '-nojpeg' in args

        path = self._export_dir
        if self._export_format in ['madevent', 'standalone', 'standalone_cpp']:
            path = os.path.join(path, 'SubProcesses')
            
        if self._export_format == 'madevent':

            if group_subprocesses:
                ndiags = 0
                cpu_time1 = time.time()
                dc_amps = [amp for amp in self._curr_amps if isinstance(amp, \
                                    diagram_generation.DecayChainAmplitude)]
                non_dc_amps = diagram_generation.AmplitudeList(\
                         [amp for amp in self._curr_amps if not \
                          isinstance(amp, \
                                     diagram_generation.DecayChainAmplitude)])
                subproc_groups = group_subprocs.SubProcessGroupList()
                if non_dc_amps:
                    subproc_groups.extend(\
                               group_subprocs.SubProcessGroup.group_amplitudes(\
                                                                   non_dc_amps))
                for dc_amp in dc_amps:
                    dc_subproc_group = \
                             group_subprocs.DecayChainSubProcessGroup.\
                                                       group_amplitudes(dc_amp)
                    subproc_groups.extend(\
                              dc_subproc_group.\
                                    generate_helas_decay_chain_subproc_groups())

                cpu_time1 = time.time()
                for sp_group in subproc_groups:
                    ndiags = ndiags + sum([len(m.get('diagrams')) for m in \
                          sp_group.get('matrix_elements')])
                cpu_time = time.time() - cpu_time1
                cpu_time1 = time.time()
                for (group_number, me_group) in enumerate(subproc_groups):
                    calls = calls + \
                         export_v4.generate_subprocess_group_directory_v4_madevent(\
                                me_group, self._curr_fortran_model,
                                group_number, path)
                    matrix_elements = \
                                 me_group.get('matrix_elements')
                    self._curr_matrix_elements.get('matrix_elements').\
                                                             extend(matrix_elements)
                cpu_time2 = time.time() - cpu_time1
            else:
                cpu_time1 = time.time()
                for me_number, me in \
                   enumerate(self._curr_matrix_elements.get('matrix_elements')):
                    calls = calls + \
                            export_v4.generate_subprocess_directory_v4_madevent(\
                                me, self._curr_fortran_model, me_number, path)

                cpu_time2 = time.time() - cpu_time1

            # Write the procdef_mg5.dat file with process info
            card_path = os.path.join(path, os.path.pardir, 'SubProcesses', \
                                     'procdef_mg5.dat')
            if self._generate_info:
                export_v4.write_procdef_mg5(card_path,
                                self._curr_model['name'],
                                self._generate_info)
                try:
                    cmd.Cmd.onecmd(self, 'history .')
                except:
                    pass
                
        if self._export_format == 'standalone':
            for me in self._curr_matrix_elements.get('matrix_elements'):
                calls = calls + \
                        export_v4.generate_subprocess_directory_v4_standalone(\
                            me, self._curr_fortran_model, path)
            
        if self._export_format == 'matrix':
            cpu_time1 = time.time()
            for me in self._curr_matrix_elements.get('matrix_elements'):
                filename = os.path.join(path, 'matrix_' + \
                           me.get('processes')[0].shell_string() + ".f")
                if os.path.isfile(filename):
                    logger.warning("Overwriting existing file %s" % filename)
                else:
                    logger.info("Creating new file %s" % filename)
                calls = calls + export_v4.write_matrix_element_v4_standalone(\
                    writers.FortranWriter(filename),\
                    me, self._curr_fortran_model)
            cpu_time2 = time.time() - cpu_time1

        if self._export_format == 'pythia8':
            export_cpp.generate_process_files_pythia8(\
                            self._curr_matrix_elements, self._curr_cpp_model,
                            process_string = self._generate_info, path = path)
                
        if self._export_format == 'standalone_cpp':
            for me in self._curr_matrix_elements.get('matrix_elements'):
                export_cpp.generate_subprocess_directory_standalone_cpp(\
                              me, self._curr_cpp_model,
                              path = path)
                
        logger.info(("Generated helas calls for %d subprocesses " + \
              "(%d diagrams) in %0.3f s") % \
              (len(self._curr_matrix_elements.get('matrix_elements')),
               ndiags, cpu_time))

        if calls:
            if "cpu_time2" in locals():
                logger.info("Wrote files for %d helas calls in %0.3f s" % \
                            (calls, cpu_time2))
            else:
                logger.info("Wrote files for %d helas calls" % \
                            (calls))
        # Replace the amplitudes with the actual amplitudes from the
        # matrix elements, which allows proper diagram drawing also of
        # decay chain processes
        self._curr_amps = diagram_generation.AmplitudeList(\
               [me.get('base_amplitude') for me in \
                self._curr_matrix_elements.get('matrix_elements')])

        # Remember that we have done export
        self._done_export = (self._export_dir, self._export_format)

        if self._export_format in ['madevent', 'standalone', 'standalone_cpp']:
            # Automatically run finalize
            options = []
            if nojpeg:
                options = ['-nojpeg']
                
            self.finalize(options)
            
        #reinitialize to empty the default output dir
        self._export_dir = None
    
    def finalize(self, options):
        """Make the html output, write proc_card_mg5.dat and create
        madevent.tar.gz for a MadEvent directory"""
        
        #look if the user ask to bypass the jpeg creation
        if '-nojpeg' in options:
            makejpg = False
        else:
            makejpg = True

        # For v4 models, copy the model/HELAS information.
        if self._model_v4_path:
            logger.info('Copy %s model files to directory %s' % \
                        (os.path.basename(self._model_v4_path), self._export_dir))
            export_v4.export_model_files(self._model_v4_path, self._export_dir)
            export_v4.export_helas(os.path.join(self._mgme_dir,'HELAS'),
                                   self._export_dir)
        elif self._export_format in ['madevent', 'standalone']:
            logger.info('Export UFO model to MG4 format')
            # wanted_lorentz are the lorentz structures which are
            # actually used in the wavefunctions and amplitudes in
            # these processes
            wanted_lorentz = self._curr_matrix_elements.get_used_lorentz()
            wanted_couplings = self._curr_matrix_elements.get_used_couplings()
            export_v4.convert_model_to_mg4(self._curr_model,
                                           os.path.join(self._export_dir),
                                           wanted_lorentz,
                                           wanted_couplings)
        if self._export_format == 'standalone_cpp':
            logger.info('Export UFO model to C++ format')
            # wanted_lorentz are the lorentz structures which are
            # actually used in the wavefunctions and amplitudes in
            # these processes
            wanted_lorentz = self._curr_matrix_elements.get_used_lorentz()
            wanted_couplings = self._curr_matrix_elements.get_used_couplings()
            export_cpp.convert_model_to_cpp(self._curr_model,
                                            os.path.join(self._export_dir),
                                            wanted_lorentz,
                                            wanted_couplings)
            export_cpp.make_model_cpp(self._export_dir)

        if self._export_format.startswith('madevent'):
            os.system('touch %s/done' % os.path.join(self._export_dir,
                                                     'SubProcesses'))        
            export_v4.finalize_madevent_v4_directory(self._export_dir, makejpg,
                                                     [self.history_header] + \
                                                     self.history)
        elif self._export_format == 'standalone':
            export_v4.finalize_standalone_v4_directory(self._export_dir,
                                                     [self.history_header] + \
                                                     self.history)

        logger.info('Output to directory ' + self._export_dir + ' done.')
        if self._export_format.startswith('madevent'):
            logger.info('Please see ' + self._export_dir + '/README')
            logger.info('for information about how to generate events from this process.')

    def do_help(self, line):
        """ propose some usefull possible action """
        
        super(MadGraphCmd,self).do_help(line)
        
        if line:
            return
        
        if len(self.history) == 0:
            last_action_2 = 'mg5_start'
            last_action = 'mg5_start'
        else:
            args = self.history[-1].split()
            last_action = args[0]
            if len(args)>1: 
                last_action_2 = '%s %s' % (last_action, args[1])
            else: 
                last_action_2 = 'none'
        

#===============================================================================
# MadGraphCmd
#===============================================================================
class MadGraphCmdWeb(MadGraphCmd, CheckValidForCmdWeb):
    """The command line processor of MadGraph"""
 
    timeout = 1 # time authorize to answer question [0 is no time limit]
    def __init__(self, *arg, **opt):
    
        if os.environ.has_key('_CONDOR_SCRATCH_DIR'):
            self.writing_dir = os.path.join(os.environ['_CONDOR_SCRATCH_DIR'], \
                                                                 os.path.pardir)
        else:
            self.writing_dir = os.path.join(os.environ['MADGRAPH_DATA'],
                               os.environ['REMOTE_USER'])
        
        #standard initialization
        MadGraphCmd.__init__(self, mgme_dir = '', *arg, **opt)

#===============================================================================
# MadGraphCmd
#===============================================================================
class MadGraphCmdShell(MadGraphCmd, CompleteForCmd, CheckValidForCmd):
    """The command line processor of MadGraph""" 
    
    writing_dir = '.'
    timeout = 0 # time authorize to answer question [0 is no time limit]
    
    def preloop(self):
        """Initializing before starting the main loop"""

        self.prompt = 'mg5>'
        
        if readline:
            readline.parse_and_bind("tab: complete")

        # initialize command history if HOME exists
        if os.environ.has_key('HOME') and readline:
            history_file = os.path.join(os.environ['HOME'], '.mg5history')
            try:
                readline.read_history_file(history_file)
            except IOError:
                pass
            atexit.register(readline.write_history_file, history_file)

        # By default, load the UFO Standard Model
        logger.info("Loading default model: sm")
        self.do_import('model sm')
        self.history.append('import model sm')


    # Access to shell
    def do_shell(self, line):
        "Run a shell command"

        if line.strip() is '':
            self.help_shell()
        else:
            logging.info("running shell command: " + line)
            subprocess.call(line, shell=True)

#===============================================================================
# 
#===============================================================================
class CmdFile(file):
    """ a class for command input file -in order to debug cmd \n problem"""
    
    def __init__(self, name, opt='rU'):
        
        file.__init__(self, name, opt)
        self.text = file.read(self)
        self.close()
        self.lines = self.text.split('\n')
    
    def readline(self, *arg, **opt):
        """readline method treating correctly a line whithout \n at the end
           (add it)
        """
        if self.lines:
            line = self.lines.pop(0)
        else:
            return ''
        
        if line.endswith('\n'):
            return line
        else:
            return line + '\n'
    
    def __next__(self):
        return self.lines.__next__()    
    def __iter__(self):
        return self.lines.__iter__()
  
#===============================================================================
# Command Parser
#=============================================================================== 
# DRAW
_draw_usage = "draw FILEPATH [options]\n" + \
         "-- draw the diagrams in eps format\n" + \
         "   Files will be FILEPATH/diagrams_\"process_string\".eps \n" + \
         "   Example: draw plot_dir . \n"
_draw_parser = optparse.OptionParser(usage=_draw_usage)
_draw_parser.add_option("", "--horizontal", default=False,
                   action='store_true', help="force S-channel to be horizontal")
_draw_parser.add_option("", "--external", default=0, type='float',
                    help="authorizes external particles to end at top or " + \
                    "bottom of diagram. If bigger than zero this tune the " + \
                    "length of those line.")
_draw_parser.add_option("", "--max_size", default=1.5, type='float',
                         help="this forbids external line bigger than max_size")
_draw_parser.add_option("", "--non_propagating", default=True, \
                          dest="contract_non_propagating", action='store_false',
                          help="avoid contractions of non propagating lines") 
_draw_parser.add_option("", "--add_gap", default=0, type='float', \
                          help="set the x-distance between external particles")  

    
    
    
#===============================================================================
# __main__
#===============================================================================

if __name__ == '__main__':
    
    run_option = sys.argv
    if len(run_option) > 1:
        # The first argument of sys.argv is the name of the program
        input_file = open(run_option[1], 'rU')
        cmd_line = MadGraphCmd(stdin=input_file)
        cmd_line.use_rawinput = False #put it in non interactive mode
        cmd_line.cmdloop()
    else:
        # Interactive mode
        MadGraphCmd().cmdloop()    
