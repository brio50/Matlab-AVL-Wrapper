% AVL Aero Generation
%
% $Author:  Brian Borra $
% $Rev:     1.1         $
% $Date:    05/18/2014  $

%% Initialization
clc, clear all, close all, format compact

%% File Setup
avlFileName = './avl/bd.avl';                         %TODO: dir(*.avl)
[path,name,ext] = fileparts(avlFileName);

if ~exist(['./out/' name],'dir')
    mkdir(['./out/' name])
    fprintf('%-20s %s\n','Setup:',['Directory ''' ['./out/' name] ''' Made']);
else
    fprintf('%-20s %s\n','Setup:',['Directory ''' ['./out/' name] ''' Exists']);    
end

%% Validate AVL File
% Assume that .avl file specified is generated and operable.
% TODO: Validate AVL File

%% Read .AVL File
input = avl_fileread(avlFileName);

%% Plot Geometry using AVL
% avl_fileplot('avl')
avl_fileplot(input.avl,'matlab')

%% Run Setup
sweep.alpha     = -4:4:4;   %alpha 
sweep.beta      = -6:6:6;   %beta
sweep.surf      = -2:2:2;   %surfaces - to be designated per surface in GUI
% sweep.surf.two  = -2:2:2;

% Search for surfaces with CONTROL 
surfNames = fieldnames(input.avl.surface);
nSurf = length(surfNames);

cnt = 1;
for iSurf = 1:nSurf
    if isfield(input.avl.surface.(surfNames{iSurf}),'CONTROL')
        ctrlNames(cnt) = unique(input.avl.surface.(surfNames{iSurf}).CONTROL.Name);
        cnt = cnt+1;
    end
    
%     for iCtrl = 1:nCtrl-1
%         if strcmpi(ctrlNames{iCtrl},ctrlNames{iCtrl+1})
%             temp.(surfNames{iSurf}).surfMatch(iCtrl)    = 1;
%             temp.(surfNames{iSurf}).surfMatch(iCtrl+1)  = 1;
%         else
%             temp.(surfNames{iSurf}).surfMatch(iCtrl)    = 0;
%             temp.(surfNames{iSurf}).surfMatch(iCtrl+1)  = 0;
%         end
%     end
end

%% Read .RUN File

% Store additional case parameters in structure 
input.run.bank      = 0;
input.run.elevation = 0;
input.run.heading   = 0;
input.run.velocity  = 0;
input.run.rho       = 0;
input.run.g         = 1;
input.run.turn_rad  = 0;
input.run.load_fac  = 1;

%% Read .MASS File

% TODO: load mass file and ensure that mass, MOI, and POI are correct
input.mass.Lunit    = 'Lunit'; %'m', 'ft', 'in'
input.mass.Munit    = 'Munit'; %'kg', 'lb'
input.mass.Tunit    = 'Tunit'; %'s'

%% Write Reset Run File
% Space before parameter name is necessary, same with spacing for run names 

% Open the file with write permissions, flush existing content
fid = fopen('tmp/reset.txt', 'w');

fprintf(fid,' \n');
fprintf(fid,' ---------------------------------------------\n');
fprintf(fid,' Run case  1:  %s\n',  ['Reset ' avlFileName]);
fprintf(fid,' %-12s ->  %-11s =  %.5f\n',   'alpha',    'alpha',    0);
fprintf(fid,' %-12s ->  %-11s =  %.5f\n',   'beta' ,    'beta' ,    0);
fprintf(fid,' %-12s ->  %-11s =  %.5f\n',   'pb/2V',    'pb/2V',    0);
fprintf(fid,' %-12s ->  %-11s =  %.5f\n',   'qc/2V',    'qc/2V',    0);
fprintf(fid,' %-12s ->  %-11s =  %.5f\n',   'rb/2V',    'rb/2V',    0);
for iC = 1:length(ctrlNames)
    fprintf(fid,' %-12s ->  %-11s =  %.5f\n',   ctrlNames{iC},  ctrlNames{iC},  0);
end
fprintf(fid,' \n');
fprintf(fid,' %-10s=   %.5f     %s\n','alpha',      0,                  'deg');
fprintf(fid,' %-10s=   %.5f     %s\n','beta' ,      0,                  'deg');
fprintf(fid,' %-10s=   %.5f     %s\n','pb/2V',      0,                  '');
fprintf(fid,' %-10s=   %.5f     %s\n','qc/2V',      0,                  '');
fprintf(fid,' %-10s=   %.5f     %s\n','rb/2V',      0,                  '');
fprintf(fid,' %-10s=   %.5f     %s\n','CL',         0,                  '');
fprintf(fid,' %-10s=   %.5f     %s\n','CDo',        input.avl.CDoref,   '');
fprintf(fid,' %-10s=   %.5f     %s\n','bank',       input.run.bank,     'deg');  
fprintf(fid,' %-10s=   %.5f     %s\n','elevation',  input.run.elevation,'deg');
fprintf(fid,' %-10s=   %.5f     %s\n','heading',    input.run.heading,  'deg');
fprintf(fid,' %-10s=   %.5f     %s\n','Mach',       input.avl.Mach,     '');
fprintf(fid,' %-10s=   %.5f     %s\n','velocity',   input.run.velocity, [input.mass.Lunit '/' input.mass.Tunit]);
fprintf(fid,' %-10s=   %.5f     %s\n','density',    input.run.rho,      [input.mass.Munit '/' input.mass.Tunit '^3']);
fprintf(fid,' %-10s=   %.5f     %s\n','grav.acc.',  input.run.g,        [input.mass.Lunit '/' input.mass.Tunit '^2']);
fprintf(fid,' %-10s=   %.5f     %s\n','turn_rad.',  input.run.turn_rad, input.mass.Lunit);
fprintf(fid,' %-10s=   %.5f     %s\n','load_fac.',  input.run.load_fac, '');
fprintf(fid,' %-10s=   %.5f     %s\n','X_cg',       input.avl.Xref,     input.mass.Lunit);        
fprintf(fid,' %-10s=   %.5f     %s\n','Y_cg',       input.avl.Yref,     input.mass.Lunit);
fprintf(fid,' %-10s=   %.5f     %s\n','Z_cg',       input.avl.Zref,     input.mass.Lunit);
fprintf(fid,' %-10s=   %.5f     %s\n','mass',       1,                  input.mass.Munit);
fprintf(fid,' %-10s=   %.5f     %s\n','Ixx',        1,                  [input.mass.Munit '-' input.mass.Lunit '^2']);
fprintf(fid,' %-10s=   %.5f     %s\n','Iyy',        1,                  [input.mass.Munit '-' input.mass.Lunit '^2']);
fprintf(fid,' %-10s=   %.5f     %s\n','Izz',        1,                  [input.mass.Munit '-' input.mass.Lunit '^2']);
fprintf(fid,' %-10s=   %.5f     %s\n','Ixy',        0,                  [input.mass.Munit '-' input.mass.Lunit '^2']);
fprintf(fid,' %-10s=   %.5f     %s\n','Iyz',        0,                  [input.mass.Munit '-' input.mass.Lunit '^2']);
fprintf(fid,' %-10s=   %.5f     %s\n','Izx',        0,                  [input.mass.Munit '-' input.mass.Lunit '^2']);
fprintf(fid,' %-10s=   %.5f     %s\n','visc CL_a',  0,                  '');
fprintf(fid,' %-10s=   %.5f     %s\n','visc CL_u',  0,                  '');
fprintf(fid,' %-10s=   %.5f     %s\n','visc CM_a',  0,                  '');
fprintf(fid,' %-10s=   %.5f     %s\n','visc CM_u',  0,                  '');  

% Close File
fclose(fid);

%% Remove Existing Output Files
% Commands below do not consider the .st overwrite command

% TODO: use fullfile everywhere
if ~isempty(dir(fullfile(path,name,'*.st')))
    delete(fullfile(path,name,'*.st'))
    fprintf('%-20s %s\n','Setup:','.ST Files Exist and Removed');
else
    fprintf('%-20s %s\n','Setup:','.ST Files Do Not Exist');    
end

%% Write AVL Command File

% Open the file with write permission
fid = fopen('tmp/command.txt', 'w');

% Load the AVL definition of the aircraft
fprintf(fid, 'LOAD %s\n', name);

% Load mass parameters - TODO: incorporate into reset.txt!
% fprintf(fid, 'MASS %s\n', [fileName,'.mass']);
% fprintf(fid, 'MSET\n');

% Change this parameter to set which run cases to apply 
% fprintf(fid, '%i\n',   0); 

% Disable Graphics
fprintf(fid, 'PLOP\nG\n\n'); 

% Open the OPER menu
fprintf(fid, '%s\n',   'OPER');   

nA = length(sweep.alpha);
nB = length(sweep.beta);
nD = length(ctrlNames);
nS = length(sweep.surf);

for iA = 1:nA
    
    for iB = 1:nB
        
%         % Screenshot Beta
%         fprintf(fid, '%s\n',   'G');
%         fprintf(fid, '%s\n',   'V');
%         fprintf(fid, '%s\n',   [sweep.beta(iB) ' -90']);
        
        for iS = 1:nS % sweep surface
            
%             nD = length(sweep.surf.(['D' num2str(iS)]));

            for iD = 1:nD
                
                % Specify file name parameters
                angName  = sprintf('A_%+i B_%+i', sweep.alpha(iA), sweep.beta(iB));
                surfName = sprintf(' D%i_+0',1:nD);
                caseName = sprintf('%s %s%s', name, angName, surfName);
                
                % Load reset.txt run file to zero deflections (& other vars)
                fprintf(fid, '%s\n',   'f');
                fprintf(fid, '%s\n',   'reset.txt');
                
                % Set alpha
                fprintf(fid, 'A A %f\n',sweep.alpha(iA));
                
                % Set beta
                fprintf(fid, 'B B %f\n',sweep.beta(iB));
                
                % Acquire deflection value within surface structure
%                 deflValue = sweep.surf.(['D' num2str(iD)])(iD);
                
                % Set deflection
                fprintf(fid, 'D%i D%i %i\n',iD, iD, sweep.surf(iS)); %deflValue

                % String Replace D#_#
                expr        = sprintf('D%i_\\+0', iD);
                repstr      = sprintf('D%i_%+i', iD, sweep.surf(iS)); %deflValue
                caseName    = regexprep(caseName, expr, repstr);
                                
                % Init case
                fprintf(fid, '%s\n',   'i');

                % Run all the cases
                fprintf(fid, '%s\n',   'x');

                % Save the st data
                fprintf(fid, '%s\n',   'st');
                fprintf(fid, '%s\n', fullfile('..','out',name,[caseName,'.st']));
                
            end
        end
    end
end
   
% Quit Program
fprintf(fid, '\n'); 
fprintf(fid, 'Quit\n'); 

% Close File
fclose(fid);

%% Execute Run
cd avl
% [status,result] = dos('avl\avl.exe < tmp\command.txt &'); %,'-echo');
evalin('base','!avl.exe < ..\tmp\command.txt');

%% Read .ST
% TODO - scan .st file
% TODO - fix .st file names, they don't match the deflections issued