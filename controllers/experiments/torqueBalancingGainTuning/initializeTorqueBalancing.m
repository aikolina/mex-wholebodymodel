%% INITIALIZETORQUEBALANCING
%
% This is the initialization script for torque balancing simulation of the robot
% iCub using Matlab.
% The user can set the parameters below to generate different simulations.
% The forward dynamics integration is available for both the robot balancing
% on one foot and two feet, and for the robot standing or moving, following
% a CoM trajectory. It is also possible to use a QP program to ensure the contact
% forces at feet are inside the friction cones. A linearization setup for both
% analysis and gains tuning purpose is available, too.
%
% Author : Gabriele Nava (gabriele.nava@iit.it)
% Genova, May 2016
%

% ------------Initialization----------------
clear
close all
clc
%% %%%%%%%%%%%%%%%%%%%%%%%%%%% BASIC SETUP %%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% Configure the simulation
CONFIG.demo_movements                        = 0;                          %either 0 or 1
CONFIG.feet_on_ground                        = [0,1];                      %either 0 or 1; [left,right]

%% QP solver and gains tuning procedure
CONFIG.use_QPsolver                          = 0;                          %either 0 or 1
CONFIG.gains_tuning                          = 1;                          %either 0 or 1

%% Visualization setup
% robot simulator
CONFIG.visualize_robot_simulator             = 1;                          %either 0 or 1
% forward dynamics integration results
CONFIG.visualize_integration_results         = 0;                          %either 0 or 1
CONFIG.visualize_joints_dynamics             = 1;                          %either 0 or 1
% linearization and gains tuning
CONFIG.visualize_gains_tuning_results        = 1;                          %either 0 or 1; available only if gains_tuning = 1

%% Integration time [s]
CONFIG.tStart                                = 0;
CONFIG.tEnd                                  = 5;
CONFIG.sim_step                              = 0.01;

%% Generate the joint references with the inverse kinematics solver
CONFIG.jointRef_with_ikin                    = 1;                          %either 0 or 1
CONFIG.visualize_ikin_results                = 0;                          %either 0 or 1
CONFIG.ikin_integration_step                 = 0.01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%% ADVANCED SETUP %%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% ONLY FOR DEVELOPERS
% tolerances for pseudoinverse and QP
CONFIG.pinv_tol           = 1e-8;
CONFIG.pinv_damp          = 5e-6;
CONFIG.reg_HessianQP      = 1e-3;

%% Verify the joint space linearization; stability analysis procedure
% run the simulation with CONFIG.linearizationDebug = 1 to verify that the
% joint space linearization is performed properly, and to check the
% controlled system's stability
CONFIG.linearizationDebug  = 1;                                            %either 0 or 1

% enter in debug mode
if CONFIG.linearizationDebug == 1
    
    CONFIG.demo_movements  = 0;
    CONFIG.use_QPsolver    = 0;
end

%% Forward dynamics integration setup
% CONFIG.integrateWithFixedStep will use a Euler forward integrator instead
% of ODE15s to integrate the forward dynamics.
CONFIG.integrateWithFixedStep = 0;                                         %either 0 or 1

% The fixed step integration needs a desingularization of system mass matrix
% to converge to a solution
if CONFIG.integrateWithFixedStep == 1
    
    CONFIG.massCorr = 0.05;
else
    CONFIG.massCorr = 0;
end

% integration options
CONFIG.options                   = odeset('RelTol',1e-6,'AbsTol',1e-6);

%% Visualization setup
% this script modifies the default MATLAB options for figures and graphics
plot_set

% this is the figure counter. It is used to automatically adapt the figure
% number in case new figures are added
CONFIG.figureCont                = 1;

%% Initialize the robot model
wbm_modelInitialise('icubGazeboSim');
CONFIG.ndof  = 25;

%% Initial joints position [deg]
leftArmInit  = [ -20  30  0  45  0]';
rightArmInit = [ -20  30  0  45  0]';
torsoInit    = [ -10   0  0]';

if       CONFIG.feet_on_ground(1) == 1 && CONFIG.feet_on_ground(2) == 1
    
    % initial conditions for balancing on two feet
    leftLegInit  = [  25.5   0.1   0  -18.5  -5.5  -0.1]';
    rightLegInit = [  25.5   0.1   0  -18.5  -5.5  -0.1]';
    
elseif   CONFIG.feet_on_ground(1) == 1 && CONFIG.feet_on_ground(2) == 0
    
    % initial conditions for the robot standing on the left foot
    leftLegInit  = [  25.5   15   0  -18.5  -5.5  -0.1]';
    rightLegInit = [  25.5    5   0  -40    -5.5  -0.1]';
    
elseif   CONFIG.feet_on_ground(1) == 0 && CONFIG.feet_on_ground(2) == 1
    
    % initial conditions for the robot standing on the right foot
    leftLegInit  = [  25.5    5   0  -40    -5.5  -0.1]';
    rightLegInit = [  25.5   15   0  -18.5  -5.5  -0.1]';
end

% joint configuration [rad]
CONFIG.qjInit = [torsoInit;leftArmInit;rightArmInit;leftLegInit;rightLegInit]*(pi/180);

%% %%%%%%%%%%%%%%%%%%%%% FORWARD DYNAMICS INTEGRATION %%%%%%%%%%%%%%%%%% %%
codyco_root  = getenv('CODYCO_SUPERBUILD_ROOT');
utility_root = [codyco_root, filesep, '/main/mexWholeBodyModel/controllers/utilitiesForTorqueBalancing'];
robot_root   = [utility_root, filesep, '/RobotFunctions'];
plots_root   = [utility_root, filesep, '/Visualization'];
ikin_root    = [utility_root, filesep, '/InverseKinematics'];
gain_root    = [utility_root, filesep, '/LinearizationAndGainTuning'];
src_root     = [codyco_root, filesep, '/main/mexWholeBodyModel/controllers/experiments/torqueBalancingGainTuning/src'];
addpath(utility_root);
addpath(robot_root);
addpath(plots_root);
addpath(ikin_root);
addpath(gain_root);
addpath(src_root);

initForwardDynamics(CONFIG);
