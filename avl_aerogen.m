% AVL Aero Generation
%
% $Author:  Brian Borra $
% $Rev:     1.0         $
% $Date:    03/06/2013  $

%% Initialization
clc, clear all, %close all, format compact
% cd(['C:\Users\' getenv('username') '\Desktop\avl332'])

%% File Setup
avlFileName = 'bd.avl';                         %TODO: dir(*.avl)
% avlFileName = 'test.avl'
fileName    = regexprep(avlFileName,'.avl','');
dirName     = fileName;

if ~exist(dirName,'dir')
    mkdir(dirName)
    fprintf('%-20s %s\n','Setup:',['Directory ''' dirName ''' Made']);
else
    fprintf('%-20s %s\n','Setup:',['Directory ''' dirName ''' Exists']);    
end

%% Validate AVL File
% Assume that .avl file specified is generated and operable.
% TODO: Validate AVL File

%% Read .AVL File
input = avl_fileread(avlFileName);

%% Plot Geometry using AVL
% avl_fileplot('avl')
avl_fileplot(input.avl,'matlab')
keyboard

%% Run Setup
sweep.alpha     = -4:4:4;   %alpha 
sweep.beta      = -6:6:6;   %beta
% sweep.surf.one  = -2:2:2;   %surfaces - to be designated per surface in GUI
% sweep.surf.two  = -2:2:2;

% Search for surfaces with CONTROL 

surfNames = fieldnames(input.avl.surface);
nSurf = length(surfNames);

for iSurf = 1:nSurf
    if isfield(input.avl.surface.(surfNames{iSurf}),'CONTROL')
        CTRL = input.avl.surface.(surfNames{iSurf}).CONTROL.Name;
        [m,n] = size(CTRL);
        
        for row = 1:m
            
            temp = vertcat(CTRL{row,:}); % concatenate vertically
            if row == 2
                keyboard
            end
            for col = 1:n-1
%                 if ~isempty(temp{col,:})
                    wtf(row,col) = strcmp(temp(col,:),temp(col+1,:)) 
%                 else
%                     wtf(row,col) = 0;
%                 end
            end
        end
        
%         for iCtrl = 1:nCtrl-1
%             if strcmpi(ctrlNames{iCtrl},ctrlNames{iCtrl+1})
%                 temp.(surfNames{iSurf}).surfMatch(iCtrl)    = 1;
%                 temp.(surfNames{iSurf}).surfMatch(iCtrl+1)  = 1;
%             else
%                 temp.(surfNames{iSurf}).surfMatch(iCtrl)    = 0;
%                 temp.(surfNames{iSurf}).surfMatch(iCtrl+1)  = 0;
%             end
%         end
    end
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
fid = fopen('reset.txt', 'w');

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
fprintf(fid,' %-10s=   %.5f     %s\n','bank',       input.avl.bank,     'deg');  
fprintf(fid,' %-10s=   %.5f     %s\n','elevation',  input.avl.elevation,'deg');
fprintf(fid,' %-10s=   %.5f     %s\n','heading',    input.avl.heading,  'deg');
fprintf(fid,' %-10s=   %.5f     %s\n','Mach',       input.avl.mach,     '');
fprintf(fid,' %-10s=   %.5f     %s\n','velocity',   input.avl.velocity, [input.mass.Lunit '/' input.mass.Tunit]);
fprintf(fid,' %-10s=   %.5f     %s\n','density',    input.avl.rho,      [input.mass.Munit '/' input.mass.Tunit '^3']);
fprintf(fid,' %-10s=   %.5f     %s\n','grav.acc.',  input.avl.g,        [input.mass.Lunit '/' input.mass.Tunit '^2']);
fprintf(fid,' %-10s=   %.5f     %s\n','turn_rad.',  input.avl.mach,     input.mass.Lunit);
fprintf(fid,' %-10s=   %.5f     %s\n','load_fac.',  input.avl.mach,     '');
fprintf(fid,' %-10s=   %.5f     %s\n','X_cg',       input.avl.xref,     input.mass.Lunit);        
fprintf(fid,' %-10s=   %.5f     %s\n','Y_cg',       input.avl.yref,     input.mass.Lunit);
fprintf(fid,' %-10s=   %.5f     %s\n','Z_cg',       input.avl.zref,     input.mass.Lunit);
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

if ~isempty(dir(fullfile(dirName,'*.st')))
    delete(fullfile(dirName,'*.st'))
    fprintf('%-20s %s\n','Setup:','.ST Files Exist and Removed');
else
    fprintf('%-20s %s\n','Setup:','.ST Files Do Not Exist');    
end

%% Write AVL Command File

% Open the file with write permission
fid = fopen('command.txt', 'w');

% Load the AVL definition of the aircraft
fprintf(fid, 'LOAD %s\n', [fileName,'.avl']);

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
nS = length(surfName);

for iA = 1:nA
    
    for iB = 1:nB
        
%         % Screenshot Beta
%         fprintf(fid, '%s\n',   'G');
%         fprintf(fid, '%s\n',   'V');
%         fprintf(fid, '%s\n',   [sweep.beta(iB) ' -90']);
        
        for iS = 1:nS
            
            nD = length(sweep.surf.(['D' num2str(iS)]));

            for iD = 1:nD
                
                % Specify file name parameters
                angName  = sprintf('A_%+i B_%+i', sweep.alpha(iA), sweep.beta(iB));
                surfName = sprintf(' D%i_+0',1:nS);
                caseName = sprintf('%s %s%s', avlFileName, angName, surfName);
                
                % Load reset.txt run file to zero deflections (& other vars)
                fprintf(fid, '%s\n',   'f');
                fprintf(fid, '%s\n',   'reset.txt');
                
                % Set alpha
                fprintf(fid, 'A A %f\n',sweep.alpha(iA));
                
                % Set beta
                fprintf(fid, 'B B %f\n',sweep.beta(iB));
                
                % Acquire deflection value within surface structure
                deflValue = sweep.surf.(['D' num2str(iS)])(iD);
                
                % Set deflection
                fprintf(fid, 'D%i D%i %i\n',iS, iS, deflValue);

                % String Replace D#_#
                expr        = sprintf('D%i_\\+0', iS);
                repstr      = sprintf('D%i_%+i', iS, deflValue);
                caseName    = regexprep(caseName, expr, repstr);
                                
                % Init case
                fprintf(fid, '%s\n',   'i');

                % Run all the cases
                fprintf(fid, '%s\n',   'x');

                % Save the st data
                fprintf(fid, '%s\n',   'st');
                fprintf(fid, '%s\n', fullfile(dirName,[caseName,'.st']));
                
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
% [status,result] = dos('avl.exe < command.txt &'); %,'-echo');
evalin('base','!avl.exe < command.txt');