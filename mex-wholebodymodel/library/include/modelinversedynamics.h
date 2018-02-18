/*
 * Copyright (C) 2016 Robotics, Brain and Cognitive Sciences - Istituto Italiano di Tecnologia
 * Author: Martin Neururer
 * E-mail: martin.neururer@student.tuwien.ac.at / martin.neururer@gmail.com
 *
 * The development of this software was supported by the FP7 EU project
 * CoDyCo (No. 600716 ICT 2011.2.1 Cognitive Systems and Robotics (b)),
 * <http://www.codyco.eu>.
 *
 * Permission is granted to copy, distribute, and/or modify this program
 * under the terms of the GNU General Public License, version 2 or any
 * later version published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * A copy of the GNU General Public License can be found along with
 * the source library. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef MODELINVERSEDYNAMICS_H
#define MODELINVERSEDYNAMICS_H

// global includes

// library includes

// local includes
#include "modelcomponent.h"

namespace mexWBIComponent
{
  class ModelInverseDynamics : public ModelComponent
  {
    public:
       static ModelInverseDynamics *getInstance();

      /**
       * Delete the (static) instance of this component,
       * and set the instance pointer to 0.
       */
      static void deleteInstance();

      virtual bool allocateReturnSpace(int nlhs, mxArray **plhs);
      virtual bool compute(int nrhs, const mxArray **prhs);
      virtual bool computeFast(int nrhs, const mxArray **prhs);

      virtual ~ModelInverseDynamics();

    private:
      ModelInverseDynamics();
      static bool processArguments(int nrhs, const mxArray **prhs);
      static bool processFastArguments(int nrhs, const mxArray **prhs);

      static ModelInverseDynamics *modelInverseDynamics;

      // inputs:
      static double *qj;
      static double *qj_dot;
      static double *qj_ddot;
      static double *vb;
      static double *vb_dot;
      static double *g;
      // output:
      static double *tau; // joint torques
    };

}

#endif // MODELINVERSEDYNAMICS_H
