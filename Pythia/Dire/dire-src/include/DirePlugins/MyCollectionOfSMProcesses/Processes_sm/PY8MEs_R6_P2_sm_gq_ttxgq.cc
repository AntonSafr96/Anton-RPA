//==========================================================================
// This file has been automatically generated for Pythia 8 by
// MadGraph5_aMC@NLO v. 2.5.3, 2017-03-09
// By the MadGraph5_aMC@NLO Development Team
// Visit launchpad.net/madgraph5 and amcatnlo.web.cern.ch
//==========================================================================

#include "PY8MEs_R6_P2_sm_gq_ttxgq.h"
#include "HelAmps_sm.h"

using namespace Pythia8_sm; 

namespace PY8MEs_namespace 
{
//==========================================================================
// Class member functions for calculating the matrix elements for
// Process: g u > t t~ g u WEIGHTED<=4 @6
// Process: g c > t t~ g c WEIGHTED<=4 @6
// Process: g d > t t~ g d WEIGHTED<=4 @6
// Process: g s > t t~ g s WEIGHTED<=4 @6
// Process: g u~ > t t~ g u~ WEIGHTED<=4 @6
// Process: g c~ > t t~ g c~ WEIGHTED<=4 @6
// Process: g d~ > t t~ g d~ WEIGHTED<=4 @6
// Process: g s~ > t t~ g s~ WEIGHTED<=4 @6

// Exception class
class PY8MEs_R6_P2_sm_gq_ttxgqException : public exception
{
  virtual const char * what() const throw()
  {
    return "Exception in class 'PY8MEs_R6_P2_sm_gq_ttxgq'."; 
  }
}
PY8MEs_R6_P2_sm_gq_ttxgq_exception; 

// Required s-channel initialization
//int PY8MEs_R6_P2_sm_gq_ttxgq::req_s_channels[nreq_s_channels] = {}; 

int PY8MEs_R6_P2_sm_gq_ttxgq::helicities[ncomb][nexternal] = {{-1, -1, -1, -1,
    -1, -1}, {-1, -1, -1, -1, -1, 1}, {-1, -1, -1, -1, 1, -1}, {-1, -1, -1, -1,
    1, 1}, {-1, -1, -1, 1, -1, -1}, {-1, -1, -1, 1, -1, 1}, {-1, -1, -1, 1, 1,
    -1}, {-1, -1, -1, 1, 1, 1}, {-1, -1, 1, -1, -1, -1}, {-1, -1, 1, -1, -1,
    1}, {-1, -1, 1, -1, 1, -1}, {-1, -1, 1, -1, 1, 1}, {-1, -1, 1, 1, -1, -1},
    {-1, -1, 1, 1, -1, 1}, {-1, -1, 1, 1, 1, -1}, {-1, -1, 1, 1, 1, 1}, {-1, 1,
    -1, -1, -1, -1}, {-1, 1, -1, -1, -1, 1}, {-1, 1, -1, -1, 1, -1}, {-1, 1,
    -1, -1, 1, 1}, {-1, 1, -1, 1, -1, -1}, {-1, 1, -1, 1, -1, 1}, {-1, 1, -1,
    1, 1, -1}, {-1, 1, -1, 1, 1, 1}, {-1, 1, 1, -1, -1, -1}, {-1, 1, 1, -1, -1,
    1}, {-1, 1, 1, -1, 1, -1}, {-1, 1, 1, -1, 1, 1}, {-1, 1, 1, 1, -1, -1},
    {-1, 1, 1, 1, -1, 1}, {-1, 1, 1, 1, 1, -1}, {-1, 1, 1, 1, 1, 1}, {1, -1,
    -1, -1, -1, -1}, {1, -1, -1, -1, -1, 1}, {1, -1, -1, -1, 1, -1}, {1, -1,
    -1, -1, 1, 1}, {1, -1, -1, 1, -1, -1}, {1, -1, -1, 1, -1, 1}, {1, -1, -1,
    1, 1, -1}, {1, -1, -1, 1, 1, 1}, {1, -1, 1, -1, -1, -1}, {1, -1, 1, -1, -1,
    1}, {1, -1, 1, -1, 1, -1}, {1, -1, 1, -1, 1, 1}, {1, -1, 1, 1, -1, -1}, {1,
    -1, 1, 1, -1, 1}, {1, -1, 1, 1, 1, -1}, {1, -1, 1, 1, 1, 1}, {1, 1, -1, -1,
    -1, -1}, {1, 1, -1, -1, -1, 1}, {1, 1, -1, -1, 1, -1}, {1, 1, -1, -1, 1,
    1}, {1, 1, -1, 1, -1, -1}, {1, 1, -1, 1, -1, 1}, {1, 1, -1, 1, 1, -1}, {1,
    1, -1, 1, 1, 1}, {1, 1, 1, -1, -1, -1}, {1, 1, 1, -1, -1, 1}, {1, 1, 1, -1,
    1, -1}, {1, 1, 1, -1, 1, 1}, {1, 1, 1, 1, -1, -1}, {1, 1, 1, 1, -1, 1}, {1,
    1, 1, 1, 1, -1}, {1, 1, 1, 1, 1, 1}};

//--------------------------------------------------------------------------
// Color config initialization
void PY8MEs_R6_P2_sm_gq_ttxgq::initColorConfigs() 
{
  color_configs = vector < vec_vec_int > (); 

  // Color flows of process Process: g u > t t~ g u WEIGHTED<=4 @6
  color_configs.push_back(vec_vec_int()); 
  // JAMP #0
  int jamp00[2 * nexternal] = {1, 3, 3, 0, 1, 0, 0, 4, 4, 2, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp00, jamp00 + (2 * nexternal))); 
  // JAMP #1
  int jamp01[2 * nexternal] = {1, 3, 4, 0, 1, 0, 0, 3, 4, 2, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp01, jamp01 + (2 * nexternal))); 
  // JAMP #2
  int jamp02[2 * nexternal] = {1, 3, 4, 0, 1, 0, 0, 2, 4, 3, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp02, jamp02 + (2 * nexternal))); 
  // JAMP #3
  int jamp03[2 * nexternal] = {1, 3, 2, 0, 1, 0, 0, 4, 4, 3, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp03, jamp03 + (2 * nexternal))); 
  // JAMP #4
  int jamp04[2 * nexternal] = {2, 3, 4, 0, 1, 0, 0, 1, 4, 3, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp04, jamp04 + (2 * nexternal))); 
  // JAMP #5
  int jamp05[2 * nexternal] = {2, 3, 1, 0, 1, 0, 0, 4, 4, 3, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp05, jamp05 + (2 * nexternal))); 
  // JAMP #6
  int jamp06[2 * nexternal] = {2, 3, 3, 0, 1, 0, 0, 4, 4, 1, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp06, jamp06 + (2 * nexternal))); 
  // JAMP #7
  int jamp07[2 * nexternal] = {2, 3, 4, 0, 1, 0, 0, 3, 4, 1, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp07, jamp07 + (2 * nexternal))); 
  // JAMP #8
  int jamp08[2 * nexternal] = {4, 3, 1, 0, 1, 0, 0, 3, 4, 2, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp08, jamp08 + (2 * nexternal))); 
  // JAMP #9
  int jamp09[2 * nexternal] = {4, 3, 3, 0, 1, 0, 0, 1, 4, 2, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp09, jamp09 + (2 * nexternal))); 
  // JAMP #10
  int jamp010[2 * nexternal] = {4, 3, 3, 0, 1, 0, 0, 2, 4, 1, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp010, jamp010 + (2 * nexternal))); 
  // JAMP #11
  int jamp011[2 * nexternal] = {4, 3, 2, 0, 1, 0, 0, 3, 4, 1, 2, 0}; 
  color_configs[0].push_back(vec_int(jamp011, jamp011 + (2 * nexternal))); 

  // Color flows of process Process: g u~ > t t~ g u~ WEIGHTED<=4 @6
  color_configs.push_back(vec_vec_int()); 
  // JAMP #0
  int jamp10[2 * nexternal] = {1, 3, 0, 1, 2, 0, 0, 3, 4, 2, 0, 4}; 
  color_configs[1].push_back(vec_int(jamp10, jamp10 + (2 * nexternal))); 
  // JAMP #1
  int jamp11[2 * nexternal] = {1, 3, 0, 1, 2, 0, 0, 4, 4, 2, 0, 3}; 
  color_configs[1].push_back(vec_int(jamp11, jamp11 + (2 * nexternal))); 
  // JAMP #2
  int jamp12[2 * nexternal] = {2, 3, 0, 1, 2, 0, 0, 3, 4, 1, 0, 4}; 
  color_configs[1].push_back(vec_int(jamp12, jamp12 + (2 * nexternal))); 
  // JAMP #3
  int jamp13[2 * nexternal] = {2, 3, 0, 1, 2, 0, 0, 4, 4, 1, 0, 3}; 
  color_configs[1].push_back(vec_int(jamp13, jamp13 + (2 * nexternal))); 
  // JAMP #4
  int jamp14[2 * nexternal] = {1, 3, 0, 1, 2, 0, 0, 4, 4, 3, 0, 2}; 
  color_configs[1].push_back(vec_int(jamp14, jamp14 + (2 * nexternal))); 
  // JAMP #5
  int jamp15[2 * nexternal] = {1, 3, 0, 1, 2, 0, 0, 2, 4, 3, 0, 4}; 
  color_configs[1].push_back(vec_int(jamp15, jamp15 + (2 * nexternal))); 
  // JAMP #6
  int jamp16[2 * nexternal] = {2, 3, 0, 1, 2, 0, 0, 4, 4, 3, 0, 1}; 
  color_configs[1].push_back(vec_int(jamp16, jamp16 + (2 * nexternal))); 
  // JAMP #7
  int jamp17[2 * nexternal] = {2, 3, 0, 1, 2, 0, 0, 1, 4, 3, 0, 4}; 
  color_configs[1].push_back(vec_int(jamp17, jamp17 + (2 * nexternal))); 
  // JAMP #8
  int jamp18[2 * nexternal] = {4, 3, 0, 1, 2, 0, 0, 1, 4, 2, 0, 3}; 
  color_configs[1].push_back(vec_int(jamp18, jamp18 + (2 * nexternal))); 
  // JAMP #9
  int jamp19[2 * nexternal] = {4, 3, 0, 1, 2, 0, 0, 3, 4, 2, 0, 1}; 
  color_configs[1].push_back(vec_int(jamp19, jamp19 + (2 * nexternal))); 
  // JAMP #10
  int jamp110[2 * nexternal] = {4, 3, 0, 1, 2, 0, 0, 2, 4, 1, 0, 3}; 
  color_configs[1].push_back(vec_int(jamp110, jamp110 + (2 * nexternal))); 
  // JAMP #11
  int jamp111[2 * nexternal] = {4, 3, 0, 1, 2, 0, 0, 3, 4, 1, 0, 2}; 
  color_configs[1].push_back(vec_int(jamp111, jamp111 + (2 * nexternal))); 
}

//--------------------------------------------------------------------------
// Destructor.
PY8MEs_R6_P2_sm_gq_ttxgq::~PY8MEs_R6_P2_sm_gq_ttxgq() 
{
  for(int i = 0; i < nexternal; i++ )
  {
    delete[] p[i]; 
    p[i] = NULL; 
  }
}

//--------------------------------------------------------------------------
// Return the list of possible helicity configurations
vector < vec_int > PY8MEs_R6_P2_sm_gq_ttxgq::getHelicityConfigs(vector<int>
    permutation)
{
  vector<int> chosenPerm; 
  if (permutation.size() == 0)
  {
    chosenPerm = perm; 
  }
  else
  {
    chosenPerm = permutation; 
  }
  vector < vec_int > res(ncomb, vector<int> (nexternal, 0)); 
  for (int ihel = 0; ihel < ncomb; ihel++ )
  {
    for(int j = 0; j < nexternal; j++ )
    {
      res[ihel][chosenPerm[j]] = helicities[ihel][j]; 
    }
  }
  return res; 
}

//--------------------------------------------------------------------------
// Return the list of possible color configurations
vector < vec_int > PY8MEs_R6_P2_sm_gq_ttxgq::getColorConfigs(int
    specify_proc_ID, vector<int> permutation)
{
  int chosenProcID = -1; 
  if (specify_proc_ID == -1)
  {
    chosenProcID = proc_ID; 
  }
  else
  {
    chosenProcID = specify_proc_ID; 
  }
  vector<int> chosenPerm; 
  if (permutation.size() == 0)
  {
    chosenPerm = perm; 
  }
  else
  {
    chosenPerm = permutation; 
  }
  vector < vec_int > res(color_configs[chosenProcID].size(), vector<int>
      (nexternal * 2, 0));
  for (int icol = 0; icol < color_configs[chosenProcID].size(); icol++ )
  {
    for(int j = 0; j < (2 * nexternal); j++ )
    {
      res[icol][chosenPerm[j/2] * 2 + j%2] =
          color_configs[chosenProcID][icol][j];
    }
  }
  return res; 
}


//--------------------------------------------------------------------------
// Implements the map Helicity ID -> Helicity Config
vector<int> PY8MEs_R6_P2_sm_gq_ttxgq::getHelicityConfigForID(int hel_ID,
    vector<int> permutation)
{
  if (hel_ID < 0 || hel_ID >= ncomb)
  {
    cout <<  "Error in function 'getHelicityConfigForID' of class" << 
    " 'PY8MEs_R6_P2_sm_gq_ttxgq': Specified helicity ID '" << 
    hel_ID <<  "' cannot be found." << endl; 
    throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
  }
  vector<int> chosenPerm; 
  if (permutation.size() == 0)
  {
    chosenPerm = perm; 
  }
  else
  {
    chosenPerm = permutation; 
  }
  vector<int> res(nexternal, 0); 
  for (int j = 0; j < nexternal; j++ )
  {
    res[chosenPerm[j]] = helicities[hel_ID][j]; 
  }
  return res; 
}

//--------------------------------------------------------------------------
// Implements the map Helicity Config -> Helicity ID
int PY8MEs_R6_P2_sm_gq_ttxgq::getHelicityIDForConfig(vector<int> hel_config,
    vector<int> permutation)
{
  vector<int> chosenPerm; 
  if (permutation.size() == 0)
  {
    chosenPerm = perm; 
  }
  else
  {
    chosenPerm = permutation; 
  }
  if (permutation.size() == 0) {
    chosenPerm = invert_mapping(perm); 
  } else {
    chosenPerm = invert_mapping(permutation);
  }
  int user_ihel = -1; 
  if (hel_config.size() > 0)
  {
    bool found = false; 
    for(int i = 0; i < ncomb; i++ )
    {
      found = true; 
      for (int j = 0; j < nexternal; j++ )
      {
        if (helicities[i][chosenPerm[j]] != hel_config[j])
        {
          found = false; 
          break; 
        }
      }
      if ( !found)
        continue; 
      else
      {
        user_ihel = i; 
        break; 
      }
    }
    if (user_ihel == -1)
    {
      cout <<  "Error in function 'getHelicityIDForConfig' of class" << 
      " 'PY8MEs_R6_P2_sm_gq_ttxgq': Specified helicity" << 
      " configuration cannot be found." << endl; 
      throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
    }
  }
  return user_ihel; 
}


//--------------------------------------------------------------------------
// Implements the map Color ID -> Color Config
vector<int> PY8MEs_R6_P2_sm_gq_ttxgq::getColorConfigForID(int color_ID, int
    specify_proc_ID, vector<int> permutation)
{
  int chosenProcID = -1; 
  if (specify_proc_ID == -1)
  {
    chosenProcID = proc_ID; 
  }
  else
  {
    chosenProcID = specify_proc_ID; 
  }
  if (color_ID < 0 || color_ID >= int(color_configs[chosenProcID].size()))
  {
    cout <<  "Error in function 'getColorConfigForID' of class" << 
    " 'PY8MEs_R6_P2_sm_gq_ttxgq': Specified color ID '" << 
    color_ID <<  "' cannot be found." << endl; 
    throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
  }
  vector<int> chosenPerm; 
  if (permutation.size() == 0)
  {
    chosenPerm = perm; 
  }
  else
  {
    chosenPerm = permutation; 
  }
  vector<int> res(color_configs[chosenProcID][color_ID].size(), 0); 
  for (int j = 0; j < (2 * nexternal); j++ )
  {
    res[chosenPerm[j/2] * 2 + j%2] = color_configs[chosenProcID][color_ID][j]; 
  }
  return res; 
}

//--------------------------------------------------------------------------
// Implements the map Color Config -> Color ID
int PY8MEs_R6_P2_sm_gq_ttxgq::getColorIDForConfig(vector<int> color_config, int
    specify_proc_ID, vector<int> permutation)
{
  int chosenProcID = -1; 
  if (specify_proc_ID == -1)
  {
    chosenProcID = proc_ID; 
  }
  else
  {
    chosenProcID = specify_proc_ID; 
  }
  vector<int> chosenPerm; 
  if (permutation.size() == 0)
  {
    chosenPerm = perm; 
  }
  else
  {
    chosenPerm = permutation; 
  }
  if (permutation.size() == 0) {
    chosenPerm = invert_mapping(perm); 
  } else {
    chosenPerm = invert_mapping(permutation);
  }

//cout << "id  =" << specify_proc_ID << " " << chosenProcID << endl;
//cout << "perm=" << permutation.size() << " " << chosenPerm.size() << endl;


  // Find which color configuration is asked for
  // -1 indicates one wants to sum over all color configurations
  int user_icol = -1; 
  if (color_config.size() > 0)
  {
    bool found = false; 
    for(int i = 0; i < color_configs[chosenProcID].size(); i++ )
    {

//cout << "try" << endl;
//cout << "  ";
//  for(int n = 0; n < color_configs[chosenProcID].size(); n++ )
//    cout << color_configs[chosenProcID][i][n] << "\t";
//cout << endl;
//cout << "  ";
//  for(int n = 0; n < color_config.size(); n++ )
//    cout << color_config[n] << "\t";
//cout << endl;




      found = true; 
      for (int j = 0; j < (nexternal * 2); j++ )
      {

        // If colorless then make sure it matches
        // The little arithmetics in the color index is just
        // the permutation applies on the particle list which is
        // twice smaller since each particle can have two color indices.
        if (color_config[j] == 0)
        {
          if (color_configs[chosenProcID][i][chosenPerm[j/2] * 2 + j%2] != 0)
          {
            found = false; 
            break; 
          }
          // Otherwise check that the color linked position matches
        }
        else
        {
          int color_linked_pos = -1; 
          // Find the other end of the line in the user color config
          for (int k = 0; k < (nexternal * 2); k++ )
          {
            if (k == j)
              continue; 
            if (color_config[j] == color_config[k])
            {
              color_linked_pos = k; 
              break; 
            }
          }
          if (color_linked_pos == -1)
          {
            cout <<  "Error in function 'getColorIDForConfig' of class" << 
            " 'PY8MEs_R6_P2_sm_gq_ttxgq': A color line could " << 
            " not be closed." << endl;
            return -2; 
            //throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
          }
          // Now check whether the color line matches
          if (color_configs[chosenProcID][i][chosenPerm[j/2] * 2 + j%2] !=
              color_configs[chosenProcID][i][chosenPerm[color_linked_pos/2] * 2
              + color_linked_pos%2])
          {
            found = false; 
            break; 
          }
        }
      }
      if ( !found)
        continue; 
      else
      {
        user_icol = i; 
        break; 
      }
    }

    if (user_icol == -1)
    {
      cout <<  "Error in function 'getColorIDForConfig' of class" << 
      " 'PY8MEs_R6_P2_sm_gq_ttxgq': Specified color" << 
      " configuration cannot be found." << endl; 
      return -2;
      //throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
    }
  }
  return user_icol; 
}

//--------------------------------------------------------------------------
// Returns all result previously computed in SigmaKin
vector < vec_double > PY8MEs_R6_P2_sm_gq_ttxgq::getAllResults(int
    specify_proc_ID)
{
  int chosenProcID = -1; 
  if (specify_proc_ID == -1)
  {
    chosenProcID = proc_ID; 
  }
  else
  {
    chosenProcID = specify_proc_ID; 
  }
  return all_results[chosenProcID]; 
}

//--------------------------------------------------------------------------
// Returns a result previously computed in SigmaKin for a specific helicity
// and color ID. -1 means avg and summed over that characteristic.
double PY8MEs_R6_P2_sm_gq_ttxgq::getResult(int helicity_ID, int color_ID, int
    specify_proc_ID)
{
  if (helicity_ID < - 1 || helicity_ID >= ncomb)
  {
    cout <<  "Error in function 'getResult' of class" << 
    " 'PY8MEs_R6_P2_sm_gq_ttxgq': Specified helicity ID '" << 
    helicity_ID <<  "' configuration cannot be found." << endl; 
    throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
  }
  int chosenProcID = -1; 
  if (specify_proc_ID == -1)
  {
    chosenProcID = proc_ID; 
  }
  else
  {
    chosenProcID = specify_proc_ID; 
  }
  if (color_ID < - 1 || color_ID >= int(color_configs[chosenProcID].size()))
  {
    cout <<  "Error in function 'getResult' of class" << 
    " 'PY8MEs_R6_P2_sm_gq_ttxgq': Specified color ID '" << 
    color_ID <<  "' configuration cannot be found." << endl; 
    throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
  }
  return all_results[chosenProcID][helicity_ID + 1][color_ID + 1]; 
}

//--------------------------------------------------------------------------
// Check for the availability of the requested process and if available,
// If available, this returns the corresponding permutation and Proc_ID to use.
// If not available, this returns a negative Proc_ID.
pair < vector<int> , int > PY8MEs_R6_P2_sm_gq_ttxgq::static_getPY8ME(vector<int> initial_pdgs, vector<int> final_pdgs, set<int> schannels) 
{

  // Not available return value
  pair < vector<int> , int > NA(vector<int> (), -1); 

  // Check if s-channel requirements match
  if (nreq_s_channels > 0)
  {
    std::set<int> s_channel_proc;
    if (schannels != s_channel_proc)
      return NA; 
  }
  else
  {
    if (schannels.size() != 0)
      return NA; 
  }

  // Check number of final state particles
  if (final_pdgs.size() != (nexternal - ninitial))
    return NA; 

  // Check number of initial state particles
  if (initial_pdgs.size() != ninitial)
    return NA; 

  // List of processes available in this class
  const int nprocs = 16; 
  const int proc_IDS[nprocs] = {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1,
      1};
  const int in_pdgs[nprocs][ninitial] = {{21, 2}, {21, 4}, {21, 1}, {21, 3},
      {21, -2}, {21, -4}, {21, -1}, {21, -3}, {2, 21}, {4, 21}, {1, 21}, {3,
      21}, {-2, 21}, {-4, 21}, {-1, 21}, {-3, 21}};
  const int out_pdgs[nprocs][nexternal - ninitial] = {{6, -6, 21, 2}, {6, -6,
      21, 4}, {6, -6, 21, 1}, {6, -6, 21, 3}, {6, -6, 21, -2}, {6, -6, 21, -4},
      {6, -6, 21, -1}, {6, -6, 21, -3}, {6, -6, 21, 2}, {6, -6, 21, 4}, {6, -6,
      21, 1}, {6, -6, 21, 3}, {6, -6, 21, -2}, {6, -6, 21, -4}, {6, -6, 21,
      -1}, {6, -6, 21, -3}};

  bool in_pdgs_used[ninitial]; 
  bool out_pdgs_used[nexternal - ninitial]; 
  for(int i = 0; i < nprocs; i++ )
  {
    int permutations[nexternal]; 

    // Reinitialize initial state look-up variables
    for(int j = 0; j < ninitial; j++ )
    {
      in_pdgs_used[j] = false; 
      permutations[j] = -1; 
    }
    // Look for initial state matches
    for(int j = 0; j < ninitial; j++ )
    {
      for(int k = 0; k < ninitial; k++ )
      {
        // Make sure it has not been used already
        if (in_pdgs_used[k])
          continue; 
        if (initial_pdgs[k] == in_pdgs[i][j])
        {
          permutations[j] = k; 
          in_pdgs_used[k] = true; 
          break; 
        }
      }
      // If no match found for this particular initial state,
      // proceed with the next process
      if (permutations[j] == -1)
        break; 
    }
    // Proceed with next process if not match found
    if (permutations[ninitial - 1] == -1)
      continue; 

    // Reinitialize final state look-up variables
    for(int j = 0; j < (nexternal - ninitial); j++ )
    {
      out_pdgs_used[j] = false; 
      permutations[ninitial + j] = -1; 
    }
    // Look for final state matches
    for(int j = 0; j < (nexternal - ninitial); j++ )
    {
      for(int k = 0; k < (nexternal - ninitial); k++ )
      {
        // Make sure it has not been used already
        if (out_pdgs_used[k])
          continue; 
        if (final_pdgs[k] == out_pdgs[i][j])
        {
          permutations[ninitial + j] = ninitial + k; 
          out_pdgs_used[k] = true; 
          break; 
        }
      }
      // If no match found for this particular initial state,
      // proceed with the next process
      if (permutations[ninitial + j] == -1)
        break; 
    }
    // Proceed with next process if not match found
    if (permutations[nexternal - 1] == -1)
      continue; 

    // Return process found
    return pair < vector<int> , int > (vector<int> (permutations, permutations
        + nexternal), proc_IDS[i]);
  }

  // No process found
  return NA; 
}

//--------------------------------------------------------------------------
// Set momenta
void PY8MEs_R6_P2_sm_gq_ttxgq::setMomenta(vector < vec_double > momenta_picked)
{
  if (momenta_picked.size() != nexternal)
  {
    cout <<  "Error in function 'setMomenta' of class" << 
    " 'PY8MEs_R6_P2_sm_gq_ttxgq': Incorrect number of" << 
    " momenta specified." << endl; 
    throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
  }
  for(int i = 0; i < nexternal; i++ )
  {
    if (momenta_picked[i].size() != 4)
    {
      cout <<  "Error in function 'setMomenta' of class" << 
      " 'PY8MEs_R6_P2_sm_gq_ttxgq': Incorrect number of" << 
      " momenta components specified." << endl; 
      throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
    }
    if (momenta_picked[i][0] < 0.0)
    {
      cout <<  "Error in function 'setMomenta' of class" << 
      " 'PY8MEs_R6_P2_sm_gq_ttxgq': A momentum was specified" << 
      " with negative energy. Check conventions." << endl; 
      throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
    }
    for (int j = 0; j < 4; j++ )
    {
      p[i][j] = momenta_picked[i][j]; 
    }
  }
}

//--------------------------------------------------------------------------
// Set color configuration to use. An empty vector means sum over all.
void PY8MEs_R6_P2_sm_gq_ttxgq::setColors(vector<int> colors_picked)
{
  if (colors_picked.size() == 0)
  {
    user_colors = vector<int> (); 
    return; 
  }
  if (colors_picked.size() != (2 * nexternal))
  {
    cout <<  "Error in function 'setColors' of class" << 
    " 'PY8MEs_R6_P2_sm_gq_ttxgq': Incorrect number" << 
    " of colors specified." << endl; 
    throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
  }
  user_colors = vector<int> ((2 * nexternal), 0); 
  for(int i = 0; i < (2 * nexternal); i++ )
  {
    user_colors[i] = colors_picked[i]; 
  }

//  for(int i = 0; i < (2 * nexternal); i++ )
//    cout << user_colors[i] << "\t";
//  cout << endl;

}

//--------------------------------------------------------------------------
// Set the helicity configuration to use. Am empty vector means sum over all.
void PY8MEs_R6_P2_sm_gq_ttxgq::setHelicities(vector<int> helicities_picked) 
{
  if (helicities_picked.size() != nexternal)
  {
    if (helicities_picked.size() == 0)
    {
      user_helicities = vector<int> (); 
      return; 
    }
    cout <<  "Error in function 'setHelicities' of class" << 
    " 'PY8MEs_R6_P2_sm_gq_ttxgq': Incorrect number" << 
    " of helicities specified." << endl; 
    throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
  }
  user_helicities = vector<int> (nexternal, 0); 
  for(int i = 0; i < nexternal; i++ )
  {
    user_helicities[i] = helicities_picked[i]; 
  }
}

//--------------------------------------------------------------------------
// Set the permutation to use (will apply to momenta, colors and helicities)
void PY8MEs_R6_P2_sm_gq_ttxgq::setPermutation(vector<int> perm_picked) 
{
  if (perm_picked.size() != nexternal)
  {
    cout <<  "Error in function 'setPermutations' of class" << 
    " 'PY8MEs_R6_P2_sm_gq_ttxgq': Incorrect number" << 
    " of permutations specified." << endl; 
    throw PY8MEs_R6_P2_sm_gq_ttxgq_exception; 
  }
  for(int i = 0; i < nexternal; i++ )
  {
    perm[i] = perm_picked[i]; 
  }
}

// Set the proc_ID to use
void PY8MEs_R6_P2_sm_gq_ttxgq::setProcID(int procID_picked) 
{
  proc_ID = procID_picked; 
}

//--------------------------------------------------------------------------
// Initialize process.

void PY8MEs_R6_P2_sm_gq_ttxgq::initProc() 
{
  // Initialize vectors.
  perm = vector<int> (nexternal, 0); 
  user_colors = vector<int> (2 * nexternal, 0); 
  user_helicities = vector<int> (nexternal, 0); 
  p = vector < double * > (); 
  for (int i = 0; i < nexternal; i++ )
  {
    p.push_back(new double[4]); 
  }
  initColorConfigs(); 
  // Instantiate the model class and set parameters that stay fixed during run
  mME.push_back(pars->ZERO); 
  mME.push_back(pars->ZERO); 
  mME.push_back(pars->mdl_MT); 
  mME.push_back(pars->mdl_MT); 
  mME.push_back(pars->ZERO); 
  mME.push_back(pars->ZERO); 
  jamp2 = vector < vec_double > (2); 
  jamp2[0] = vector<double> (12, 0.); 
  jamp2[1] = vector<double> (12, 0.); 
  all_results = vector < vec_vec_double > (2); 
  // The first entry is always the color or helicity avg/summed matrix element.
  all_results[0] = vector < vec_double > (ncomb + 1, vector<double> (12 + 1,
      0.));
  all_results[1] = vector < vec_double > (ncomb + 1, vector<double> (12 + 1,
      0.));
}

//--------------------------------------------------------------------------
// Evaluate the squared matrix element.

double PY8MEs_R6_P2_sm_gq_ttxgq::sigmaKin() 
{
  // Set the parameters which change event by event
  pars->setDependentParameters(); 
  pars->setDependentCouplings(); 
  // Reset color flows
  for(int i = 0; i < 12; i++ )
    jamp2[0][i] = 0.; 
  for(int i = 0; i < 12; i++ )
    jamp2[1][i] = 0.; 

  // Local variables and constants
  const int max_tries = 10; 
  vector < vec_bool > goodhel(nprocesses, vec_bool(ncomb, false)); 
  vec_int ntry(nprocesses, 0); 
  double t = 0.; 
  double result = 0.; 

  // Denominators: spins, colors and identical particles
  const int denom_colors[nprocesses] = {24, 24}; 
  const int denom_hels[nprocesses] = {4, 4}; 
  const int denom_iden[nprocesses] = {1, 1}; 

  if (ntry[proc_ID] <= max_tries)
    ntry[proc_ID] = ntry[proc_ID] + 1; 

  // Find which helicity configuration is asked for
  // -1 indicates one wants to sum over helicities
  int user_ihel = getHelicityIDForConfig(user_helicities); 

  // Find which color configuration is asked for
  // -1 indicates one wants to sum over all color configurations
  int user_icol = getColorIDForConfig(user_colors); 

//if (user_icol == -2) abort();
if (user_icol == -2) return -1.;

  // Reset the list of results that will be recomputed here
  // Starts with -1 which are the summed results
  for (int ihel = -1; ihel + 1 < all_results[proc_ID].size(); ihel++ )
  {
    // Only if it is the helicity picked
    if (user_ihel != -1 && ihel != user_ihel)
      continue; 
    for (int icolor = -1; icolor + 1 < all_results[proc_ID][ihel + 1].size();
        icolor++ )
    {
      // Only if color picked
      if (user_icol != -1 && icolor != user_icol)
        continue; 
      all_results[proc_ID][ihel + 1][icolor + 1] = 0.; 
    }
  }

  // Calculate the matrix element for all helicities
  // unless already detected as vanishing
  for(int ihel = 0; ihel < ncomb; ihel++ )
  {
    // Skip helicity if already detected as vanishing
    if ((ntry[proc_ID] >= max_tries) && !goodhel[proc_ID][ihel])
      continue; 

    // Also skip helicity if user asks for a specific one
    if ((ntry[proc_ID] >= max_tries) && user_ihel != -1 && user_ihel != ihel)
      continue; 

    calculate_wavefunctions(helicities[ihel]); 

    // Reset locally computed color flows
    for(int i = 0; i < 12; i++ )
      jamp2[0][i] = 0.; 
    for(int i = 0; i < 12; i++ )
      jamp2[1][i] = 0.; 

    if (proc_ID == 0)
      t = matrix_6_gu_ttxgu(); 
    if (proc_ID == 1)
      t = matrix_6_gux_ttxgux(); 

    // Store which helicities give non-zero result
    if ((ntry[proc_ID] < max_tries) && t != 0. && !goodhel[proc_ID][ihel])
      goodhel[proc_ID][ihel] = true; 

    // Aggregate results
    if (user_ihel == -1 || user_ihel == ihel)
    {
      if (user_icol == -1)
      {
        result = result + t; 
        if (user_ihel == -1)
        {
          all_results[proc_ID][0][0] += t; 
          for (int i = 0; i < jamp2[proc_ID].size(); i++ )
          {
            all_results[proc_ID][0][i + 1] += jamp2[proc_ID][i]; 
          }
        }
        all_results[proc_ID][ihel + 1][0] += t; 
        for (int i = 0; i < jamp2[proc_ID].size(); i++ )
        {
          all_results[proc_ID][ihel + 1][i + 1] += jamp2[proc_ID][i]; 
        }
      }
      else
      {
        result = result + jamp2[proc_ID][user_icol]; 
        if (user_ihel == -1)
        {
          all_results[proc_ID][0][user_icol + 1] += jamp2[proc_ID][user_icol]; 
        }
        all_results[proc_ID][ihel + 1][user_icol + 1] +=
            jamp2[proc_ID][user_icol];
      }
    }

  }

  // Normalize results with the identical particle factor
  result = result/denom_iden[proc_ID]; 
  // Starts with -1 which are the summed results
  for (int ihel = -1; ihel + 1 < all_results[proc_ID].size(); ihel++ )
  {
    // Only if it is the helicity picked
    if (user_ihel != -1 && ihel != user_ihel)
      continue; 
    for (int icolor = -1; icolor + 1 < all_results[proc_ID][ihel + 1].size();
        icolor++ )
    {
      // Only if color picked
      if (user_icol != -1 && icolor != user_icol)
        continue; 
      all_results[proc_ID][ihel + 1][icolor + 1] /= denom_iden[proc_ID]; 
    }
  }


  // Normalize when when summing+averaging over helicity configurations
  if (user_ihel == -1)
  {
    result /= denom_hels[proc_ID]; 
    if (user_icol == -1)
    {
      all_results[proc_ID][0][0] /= denom_hels[proc_ID]; 
      for (int i = 0; i < jamp2[proc_ID].size(); i++ )
      {
        all_results[proc_ID][0][i + 1] /= denom_hels[proc_ID]; 
      }
    }
    else
    {
      all_results[proc_ID][0][user_icol + 1] /= denom_hels[proc_ID]; 
    }
  }

  // Normalize when summing+averaging over color configurations
  if (user_icol == -1)
  {
    result /= denom_colors[proc_ID]; 
    if (user_ihel == -1)
    {
      all_results[proc_ID][0][0] /= denom_colors[proc_ID]; 
      for (int i = 0; i < ncomb; i++ )
      {
        all_results[proc_ID][i + 1][0] /= denom_colors[proc_ID]; 
      }
    }
    else
    {
      all_results[proc_ID][user_ihel + 1][0] /= denom_colors[proc_ID]; 
    }
  }

  // Finally return it
  return result; 

}

//==========================================================================
// Private class member functions

//--------------------------------------------------------------------------
// Evaluate |M|^2 for each subprocess

void PY8MEs_R6_P2_sm_gq_ttxgq::calculate_wavefunctions(const int hel[])
{
  // Calculate wavefunctions for all processes
  // Calculate all wavefunctions
  vxxxxx(p[perm[0]], mME[0], hel[0], -1, w[0]); 
  ixxxxx(p[perm[1]], mME[1], hel[1], +1, w[1]); 
  oxxxxx(p[perm[2]], mME[2], hel[2], +1, w[2]); 
  ixxxxx(p[perm[3]], mME[3], hel[3], -1, w[3]); 
  vxxxxx(p[perm[4]], mME[4], hel[4], +1, w[4]); 
  oxxxxx(p[perm[5]], mME[5], hel[5], +1, w[5]); 
  VVV1P0_1(w[0], w[4], pars->GC_10, pars->ZERO, pars->ZERO, w[6]); 
  FFV1P0_3(w[3], w[2], pars->GC_11, pars->ZERO, pars->ZERO, w[7]); 
  FFV1_1(w[5], w[6], pars->GC_11, pars->ZERO, pars->ZERO, w[8]); 
  FFV1_2(w[1], w[6], pars->GC_11, pars->ZERO, pars->ZERO, w[9]); 
  FFV1P0_3(w[1], w[5], pars->GC_11, pars->ZERO, pars->ZERO, w[10]); 
  FFV1_1(w[2], w[6], pars->GC_11, pars->mdl_MT, pars->mdl_WT, w[11]); 
  FFV1_2(w[3], w[6], pars->GC_11, pars->mdl_MT, pars->mdl_WT, w[12]); 
  FFV1_1(w[2], w[0], pars->GC_11, pars->mdl_MT, pars->mdl_WT, w[13]); 
  FFV1_2(w[3], w[4], pars->GC_11, pars->mdl_MT, pars->mdl_WT, w[14]); 
  FFV1_1(w[5], w[4], pars->GC_11, pars->ZERO, pars->ZERO, w[15]); 
  FFV1P0_3(w[3], w[13], pars->GC_11, pars->ZERO, pars->ZERO, w[16]); 
  FFV1_2(w[1], w[4], pars->GC_11, pars->ZERO, pars->ZERO, w[17]); 
  FFV1_1(w[13], w[4], pars->GC_11, pars->mdl_MT, pars->mdl_WT, w[18]); 
  FFV1_2(w[3], w[0], pars->GC_11, pars->mdl_MT, pars->mdl_WT, w[19]); 
  FFV1_1(w[2], w[4], pars->GC_11, pars->mdl_MT, pars->mdl_WT, w[20]); 
  FFV1P0_3(w[19], w[2], pars->GC_11, pars->ZERO, pars->ZERO, w[21]); 
  FFV1_2(w[19], w[4], pars->GC_11, pars->mdl_MT, pars->mdl_WT, w[22]); 
  FFV1_1(w[5], w[0], pars->GC_11, pars->ZERO, pars->ZERO, w[23]); 
  FFV1P0_3(w[1], w[23], pars->GC_11, pars->ZERO, pars->ZERO, w[24]); 
  FFV1_1(w[23], w[4], pars->GC_11, pars->ZERO, pars->ZERO, w[25]); 
  FFV1_2(w[1], w[0], pars->GC_11, pars->ZERO, pars->ZERO, w[26]); 
  FFV1P0_3(w[26], w[5], pars->GC_11, pars->ZERO, pars->ZERO, w[27]); 
  FFV1_2(w[26], w[4], pars->GC_11, pars->ZERO, pars->ZERO, w[28]); 
  FFV1_1(w[20], w[0], pars->GC_11, pars->mdl_MT, pars->mdl_WT, w[29]); 
  VVV1P0_1(w[0], w[10], pars->GC_10, pars->ZERO, pars->ZERO, w[30]); 
  FFV1_2(w[14], w[0], pars->GC_11, pars->mdl_MT, pars->mdl_WT, w[31]); 
  FFV1_1(w[15], w[0], pars->GC_11, pars->ZERO, pars->ZERO, w[32]); 
  VVV1P0_1(w[0], w[7], pars->GC_10, pars->ZERO, pars->ZERO, w[33]); 
  FFV1_2(w[17], w[0], pars->GC_11, pars->ZERO, pars->ZERO, w[34]); 
  oxxxxx(p[perm[1]], mME[1], hel[1], -1, w[35]); 
  ixxxxx(p[perm[5]], mME[5], hel[5], -1, w[36]); 
  FFV1_1(w[35], w[6], pars->GC_11, pars->ZERO, pars->ZERO, w[37]); 
  FFV1_2(w[36], w[6], pars->GC_11, pars->ZERO, pars->ZERO, w[38]); 
  FFV1P0_3(w[36], w[35], pars->GC_11, pars->ZERO, pars->ZERO, w[39]); 
  FFV1_1(w[35], w[4], pars->GC_11, pars->ZERO, pars->ZERO, w[40]); 
  FFV1_2(w[36], w[4], pars->GC_11, pars->ZERO, pars->ZERO, w[41]); 
  FFV1_1(w[35], w[0], pars->GC_11, pars->ZERO, pars->ZERO, w[42]); 
  FFV1P0_3(w[36], w[42], pars->GC_11, pars->ZERO, pars->ZERO, w[43]); 
  FFV1_1(w[42], w[4], pars->GC_11, pars->ZERO, pars->ZERO, w[44]); 
  FFV1_2(w[36], w[0], pars->GC_11, pars->ZERO, pars->ZERO, w[45]); 
  FFV1P0_3(w[45], w[35], pars->GC_11, pars->ZERO, pars->ZERO, w[46]); 
  FFV1_2(w[45], w[4], pars->GC_11, pars->ZERO, pars->ZERO, w[47]); 
  VVV1P0_1(w[0], w[39], pars->GC_10, pars->ZERO, pars->ZERO, w[48]); 
  FFV1_1(w[40], w[0], pars->GC_11, pars->ZERO, pars->ZERO, w[49]); 
  FFV1_2(w[41], w[0], pars->GC_11, pars->ZERO, pars->ZERO, w[50]); 

  // Calculate all amplitudes
  // Amplitude(s) for diagram number 0
  FFV1_0(w[1], w[8], w[7], pars->GC_11, amp[0]); 
  FFV1_0(w[9], w[5], w[7], pars->GC_11, amp[1]); 
  VVV1_0(w[6], w[7], w[10], pars->GC_10, amp[2]); 
  FFV1_0(w[3], w[11], w[10], pars->GC_11, amp[3]); 
  FFV1_0(w[12], w[2], w[10], pars->GC_11, amp[4]); 
  FFV1_0(w[14], w[13], w[10], pars->GC_11, amp[5]); 
  FFV1_0(w[1], w[15], w[16], pars->GC_11, amp[6]); 
  FFV1_0(w[17], w[5], w[16], pars->GC_11, amp[7]); 
  FFV1_0(w[3], w[18], w[10], pars->GC_11, amp[8]); 
  VVV1_0(w[4], w[10], w[16], pars->GC_10, amp[9]); 
  FFV1_0(w[19], w[20], w[10], pars->GC_11, amp[10]); 
  FFV1_0(w[1], w[15], w[21], pars->GC_11, amp[11]); 
  FFV1_0(w[17], w[5], w[21], pars->GC_11, amp[12]); 
  FFV1_0(w[22], w[2], w[10], pars->GC_11, amp[13]); 
  VVV1_0(w[4], w[10], w[21], pars->GC_10, amp[14]); 
  FFV1_0(w[3], w[20], w[24], pars->GC_11, amp[15]); 
  FFV1_0(w[14], w[2], w[24], pars->GC_11, amp[16]); 
  FFV1_0(w[17], w[23], w[7], pars->GC_11, amp[17]); 
  FFV1_0(w[1], w[25], w[7], pars->GC_11, amp[18]); 
  VVV1_0(w[4], w[7], w[24], pars->GC_10, amp[19]); 
  FFV1_0(w[3], w[20], w[27], pars->GC_11, amp[20]); 
  FFV1_0(w[14], w[2], w[27], pars->GC_11, amp[21]); 
  FFV1_0(w[26], w[15], w[7], pars->GC_11, amp[22]); 
  FFV1_0(w[28], w[5], w[7], pars->GC_11, amp[23]); 
  VVV1_0(w[4], w[7], w[27], pars->GC_10, amp[24]); 
  FFV1_0(w[3], w[29], w[10], pars->GC_11, amp[25]); 
  FFV1_0(w[3], w[20], w[30], pars->GC_11, amp[26]); 
  FFV1_0(w[31], w[2], w[10], pars->GC_11, amp[27]); 
  FFV1_0(w[14], w[2], w[30], pars->GC_11, amp[28]); 
  FFV1_0(w[1], w[32], w[7], pars->GC_11, amp[29]); 
  FFV1_0(w[1], w[15], w[33], pars->GC_11, amp[30]); 
  FFV1_0(w[34], w[5], w[7], pars->GC_11, amp[31]); 
  FFV1_0(w[17], w[5], w[33], pars->GC_11, amp[32]); 
  VVVV1_0(w[0], w[4], w[7], w[10], pars->GC_12, amp[33]); 
  VVVV3_0(w[0], w[4], w[7], w[10], pars->GC_12, amp[34]); 
  VVVV4_0(w[0], w[4], w[7], w[10], pars->GC_12, amp[35]); 
  VVV1_0(w[4], w[10], w[33], pars->GC_10, amp[36]); 
  VVV1_0(w[4], w[7], w[30], pars->GC_10, amp[37]); 
  FFV1_0(w[36], w[37], w[7], pars->GC_11, amp[38]); 
  FFV1_0(w[38], w[35], w[7], pars->GC_11, amp[39]); 
  VVV1_0(w[6], w[7], w[39], pars->GC_10, amp[40]); 
  FFV1_0(w[3], w[11], w[39], pars->GC_11, amp[41]); 
  FFV1_0(w[12], w[2], w[39], pars->GC_11, amp[42]); 
  FFV1_0(w[14], w[13], w[39], pars->GC_11, amp[43]); 
  FFV1_0(w[36], w[40], w[16], pars->GC_11, amp[44]); 
  FFV1_0(w[41], w[35], w[16], pars->GC_11, amp[45]); 
  FFV1_0(w[3], w[18], w[39], pars->GC_11, amp[46]); 
  VVV1_0(w[4], w[39], w[16], pars->GC_10, amp[47]); 
  FFV1_0(w[19], w[20], w[39], pars->GC_11, amp[48]); 
  FFV1_0(w[36], w[40], w[21], pars->GC_11, amp[49]); 
  FFV1_0(w[41], w[35], w[21], pars->GC_11, amp[50]); 
  FFV1_0(w[22], w[2], w[39], pars->GC_11, amp[51]); 
  VVV1_0(w[4], w[39], w[21], pars->GC_10, amp[52]); 
  FFV1_0(w[3], w[20], w[43], pars->GC_11, amp[53]); 
  FFV1_0(w[14], w[2], w[43], pars->GC_11, amp[54]); 
  FFV1_0(w[41], w[42], w[7], pars->GC_11, amp[55]); 
  FFV1_0(w[36], w[44], w[7], pars->GC_11, amp[56]); 
  VVV1_0(w[4], w[7], w[43], pars->GC_10, amp[57]); 
  FFV1_0(w[3], w[20], w[46], pars->GC_11, amp[58]); 
  FFV1_0(w[14], w[2], w[46], pars->GC_11, amp[59]); 
  FFV1_0(w[45], w[40], w[7], pars->GC_11, amp[60]); 
  FFV1_0(w[47], w[35], w[7], pars->GC_11, amp[61]); 
  VVV1_0(w[4], w[7], w[46], pars->GC_10, amp[62]); 
  FFV1_0(w[3], w[29], w[39], pars->GC_11, amp[63]); 
  FFV1_0(w[3], w[20], w[48], pars->GC_11, amp[64]); 
  FFV1_0(w[31], w[2], w[39], pars->GC_11, amp[65]); 
  FFV1_0(w[14], w[2], w[48], pars->GC_11, amp[66]); 
  FFV1_0(w[36], w[49], w[7], pars->GC_11, amp[67]); 
  FFV1_0(w[36], w[40], w[33], pars->GC_11, amp[68]); 
  FFV1_0(w[50], w[35], w[7], pars->GC_11, amp[69]); 
  FFV1_0(w[41], w[35], w[33], pars->GC_11, amp[70]); 
  VVVV1_0(w[0], w[4], w[7], w[39], pars->GC_12, amp[71]); 
  VVVV3_0(w[0], w[4], w[7], w[39], pars->GC_12, amp[72]); 
  VVVV4_0(w[0], w[4], w[7], w[39], pars->GC_12, amp[73]); 
  VVV1_0(w[4], w[39], w[33], pars->GC_10, amp[74]); 
  VVV1_0(w[4], w[7], w[48], pars->GC_10, amp[75]); 


}
double PY8MEs_R6_P2_sm_gq_ttxgq::matrix_6_gu_ttxgu() 
{
  int i, j; 
  // Local variables
  const int ngraphs = 38; 
  const int ncolor = 12; 
  std::complex<double> ztemp; 
  std::complex<double> jamp[ncolor]; 
  // The color matrix;
  double denom[ncolor] = {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3}; 
  double cf[ncolor][ncolor] = {{48, 16, 0, 16, -2, 0, 16, 6, 0, 16, 0, -2},
      {16, 48, 16, 0, 0, -2, 6, 16, 16, 0, -2, 0}, {0, 16, 48, 16, 16, 6, -2,
      0, 6, -2, -6, -2}, {16, 0, 16, 48, 6, 16, 0, -2, -2, 6, -2, -6}, {-2, 0,
      16, 6, 48, 16, 0, 16, -2, -6, -2, 6}, {0, -2, 6, 16, 16, 48, 16, 0, -6,
      -2, 6, -2}, {16, 6, -2, 0, 0, 16, 48, 16, -2, 0, 16, 0}, {6, 16, 0, -2,
      16, 0, 16, 48, 0, -2, 0, 16}, {0, 16, 6, -2, -2, -6, -2, 0, 48, 16, 6,
      16}, {16, 0, -2, 6, -6, -2, 0, -2, 16, 48, 16, 6}, {0, -2, -6, -2, -2, 6,
      16, 0, 6, 16, 48, 16}, {-2, 0, -2, -6, 6, -2, 0, 16, 16, 6, 16, 48}};

  // Calculate color flows
  jamp[0] = +1./2. * (-amp[5] - amp[6] - std::complex<double> (0, 1) * amp[9] -
      amp[21] - amp[22] + std::complex<double> (0, 1) * amp[24] +
      std::complex<double> (0, 1) * amp[28] - std::complex<double> (0, 1) *
      amp[30] + amp[34] + amp[35] + amp[36] + amp[37]);
  jamp[1] = +1./2. * (+1./3. * amp[6] + 1./3. * amp[7] + 1./3. * amp[11] +
      1./3. * amp[12]);
  jamp[2] = +1./2. * (+std::complex<double> (0, 1) * amp[1] - amp[2] +
      std::complex<double> (0, 1) * amp[3] - amp[7] - amp[8] +
      std::complex<double> (0, 1) * amp[9] - amp[31] - std::complex<double> (0,
      1) * amp[32] - amp[33] - amp[34] - amp[36]);
  jamp[3] = +1./2. * (-1./3. * std::complex<double> (0, 1) * amp[3] - 1./3. *
      std::complex<double> (0, 1) * amp[4] + 1./3. * amp[5] + 1./3. * amp[8] +
      1./3. * amp[27]);
  jamp[4] = +1./2. * (-1./3. * std::complex<double> (0, 1) * amp[0] - 1./3. *
      std::complex<double> (0, 1) * amp[1] + 1./3. * amp[17] + 1./3. * amp[18]
      + 1./3. * amp[31]);
  jamp[5] = +1./2. * (+std::complex<double> (0, 1) * amp[0] + amp[2] +
      std::complex<double> (0, 1) * amp[4] - amp[16] - amp[18] +
      std::complex<double> (0, 1) * amp[19] - amp[27] - std::complex<double>
      (0, 1) * amp[28] + amp[33] - amp[35] - amp[37]);
  jamp[6] = +1./2. * (+1./3. * amp[15] + 1./3. * amp[16] + 1./3. * amp[20] +
      1./3. * amp[21]);
  jamp[7] = +1./2. * (-amp[10] - amp[12] + std::complex<double> (0, 1) *
      amp[14] - amp[15] - amp[17] - std::complex<double> (0, 1) * amp[19] -
      std::complex<double> (0, 1) * amp[26] + std::complex<double> (0, 1) *
      amp[32] + amp[34] + amp[35] + amp[36] + amp[37]);
  jamp[8] = +1./2. * (-std::complex<double> (0, 1) * amp[0] - amp[2] -
      std::complex<double> (0, 1) * amp[4] - amp[11] - amp[13] -
      std::complex<double> (0, 1) * amp[14] - amp[29] + std::complex<double>
      (0, 1) * amp[30] - amp[33] - amp[34] - amp[36]);
  jamp[9] = +1./2. * (+1./3. * std::complex<double> (0, 1) * amp[0] + 1./3. *
      std::complex<double> (0, 1) * amp[1] + 1./3. * amp[22] + 1./3. * amp[23]
      + 1./3. * amp[29]);
  jamp[10] = +1./2. * (-std::complex<double> (0, 1) * amp[1] + amp[2] -
      std::complex<double> (0, 1) * amp[3] - amp[20] - amp[23] -
      std::complex<double> (0, 1) * amp[24] - amp[25] + std::complex<double>
      (0, 1) * amp[26] + amp[33] - amp[35] - amp[37]);
  jamp[11] = +1./2. * (+1./3. * std::complex<double> (0, 1) * amp[3] + 1./3. *
      std::complex<double> (0, 1) * amp[4] + 1./3. * amp[10] + 1./3. * amp[13]
      + 1./3. * amp[25]);

  // Sum and square the color flows to get the matrix element
  double matrix = 0; 
  for(i = 0; i < ncolor; i++ )
  {
    ztemp = 0.; 
    for(j = 0; j < ncolor; j++ )
      ztemp = ztemp + cf[i][j] * jamp[j]; 
    matrix = matrix + real(ztemp * conj(jamp[i]))/denom[i]; 
  }

  // Store the leading color flows for choice of color
  for(i = 0; i < ncolor; i++ )
    jamp2[0][i] += real(jamp[i] * conj(jamp[i])); 

  return matrix; 
}

double PY8MEs_R6_P2_sm_gq_ttxgq::matrix_6_gux_ttxgux() 
{
  int i, j; 
  // Local variables
  const int ngraphs = 38; 
  const int ncolor = 12; 
  std::complex<double> ztemp; 
  std::complex<double> jamp[ncolor]; 
  // The color matrix;
  double denom[ncolor] = {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3}; 
  double cf[ncolor][ncolor] = {{48, 16, 16, 6, 0, 16, -2, 0, 0, 16, -2, 0},
      {16, 48, 6, 16, 16, 0, 0, -2, 16, 0, 0, -2}, {16, 6, 48, 16, -2, 0, 0,
      16, -2, 0, 0, 16}, {6, 16, 16, 48, 0, -2, 16, 0, 0, -2, 16, 0}, {0, 16,
      -2, 0, 48, 16, 16, 6, 6, -2, -2, -6}, {16, 0, 0, -2, 16, 48, 6, 16, -2,
      6, -6, -2}, {-2, 0, 0, 16, 16, 6, 48, 16, -2, -6, 6, -2}, {0, -2, 16, 0,
      6, 16, 16, 48, -6, -2, -2, 6}, {0, 16, -2, 0, 6, -2, -2, -6, 48, 16, 16,
      6}, {16, 0, 0, -2, -2, 6, -6, -2, 16, 48, 6, 16}, {-2, 0, 0, 16, -2, -6,
      6, -2, 16, 6, 48, 16}, {0, -2, 16, 0, -6, -2, -2, 6, 6, 16, 16, 48}};

  // Calculate color flows
  jamp[0] = +1./2. * (+amp[48] + amp[50] - std::complex<double> (0, 1) *
      amp[52] + amp[53] + amp[55] + std::complex<double> (0, 1) * amp[57] +
      std::complex<double> (0, 1) * amp[64] - std::complex<double> (0, 1) *
      amp[70] - amp[72] - amp[73] - amp[74] - amp[75]);
  jamp[1] = +1./2. * (-1./3. * amp[53] - 1./3. * amp[54] - 1./3. * amp[58] -
      1./3. * amp[59]);
  jamp[2] = +1./2. * (-1./3. * amp[44] - 1./3. * amp[45] - 1./3. * amp[49] -
      1./3. * amp[50]);
  jamp[3] = +1./2. * (+amp[43] + amp[44] + std::complex<double> (0, 1) *
      amp[47] + amp[59] + amp[60] - std::complex<double> (0, 1) * amp[62] -
      std::complex<double> (0, 1) * amp[66] + std::complex<double> (0, 1) *
      amp[68] - amp[72] - amp[73] - amp[74] - amp[75]);
  jamp[4] = +1./2. * (-std::complex<double> (0, 1) * amp[38] - amp[40] -
      std::complex<double> (0, 1) * amp[42] + amp[54] + amp[56] -
      std::complex<double> (0, 1) * amp[57] + amp[65] + std::complex<double>
      (0, 1) * amp[66] - amp[71] + amp[73] + amp[75]);
  jamp[5] = +1./2. * (+1./3. * std::complex<double> (0, 1) * amp[38] + 1./3. *
      std::complex<double> (0, 1) * amp[39] - 1./3. * amp[55] - 1./3. * amp[56]
      - 1./3. * amp[69]);
  jamp[6] = +1./2. * (+1./3. * std::complex<double> (0, 1) * amp[41] + 1./3. *
      std::complex<double> (0, 1) * amp[42] - 1./3. * amp[43] - 1./3. * amp[46]
      - 1./3. * amp[65]);
  jamp[7] = +1./2. * (-std::complex<double> (0, 1) * amp[39] + amp[40] -
      std::complex<double> (0, 1) * amp[41] + amp[45] + amp[46] -
      std::complex<double> (0, 1) * amp[47] + amp[69] + std::complex<double>
      (0, 1) * amp[70] + amp[71] + amp[72] + amp[74]);
  jamp[8] = +1./2. * (+std::complex<double> (0, 1) * amp[39] - amp[40] +
      std::complex<double> (0, 1) * amp[41] + amp[58] + amp[61] +
      std::complex<double> (0, 1) * amp[62] + amp[63] - std::complex<double>
      (0, 1) * amp[64] - amp[71] + amp[73] + amp[75]);
  jamp[9] = +1./2. * (-1./3. * std::complex<double> (0, 1) * amp[41] - 1./3. *
      std::complex<double> (0, 1) * amp[42] - 1./3. * amp[48] - 1./3. * amp[51]
      - 1./3. * amp[63]);
  jamp[10] = +1./2. * (-1./3. * std::complex<double> (0, 1) * amp[38] - 1./3. *
      std::complex<double> (0, 1) * amp[39] - 1./3. * amp[60] - 1./3. * amp[61]
      - 1./3. * amp[67]);
  jamp[11] = +1./2. * (+std::complex<double> (0, 1) * amp[38] + amp[40] +
      std::complex<double> (0, 1) * amp[42] + amp[49] + amp[51] +
      std::complex<double> (0, 1) * amp[52] + amp[67] - std::complex<double>
      (0, 1) * amp[68] + amp[71] + amp[72] + amp[74]);

  // Sum and square the color flows to get the matrix element
  double matrix = 0; 
  for(i = 0; i < ncolor; i++ )
  {
    ztemp = 0.; 
    for(j = 0; j < ncolor; j++ )
      ztemp = ztemp + cf[i][j] * jamp[j]; 
    matrix = matrix + real(ztemp * conj(jamp[i]))/denom[i]; 
  }

  // Store the leading color flows for choice of color
  for(i = 0; i < ncolor; i++ )
    jamp2[1][i] += real(jamp[i] * conj(jamp[i])); 

  return matrix; 
}


}  // end namespace PY8MEs_namespace

