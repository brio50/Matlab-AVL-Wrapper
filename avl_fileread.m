function input = avl_fileread(avlFileName)

% Assumes that header is in this format
%
%      Bubble Dancer RES
%      0.0                      Mach
%      0      0      0.0        iYsym  iZsym  Zsym
%      1000.0 10.0   116.6      Sref   Cref   Bref
%      3.40   0.0    0.5        Xref   Yref   Zref
%      0.017                    CDo
%

%% Read from File

% Open file for reading
fid     = fopen(avlFileName,'r');
tline = fgetl(fid);

% Initialize Counters
line_num = 0; % file line number
eval_num = 0; % evaluated line number (excludes comments and empty spaces)
comm_num = 0;

while ischar(tline)
    
    % Step line number counter
    line_num = line_num + 1;
    
    if strncmp(tline,'!',1) || strncmp(tline,'#',1) || isempty(tline)
        
        % Avoid two comment types and empty lines
        comm_num = comm_num + 1;
        comment_line{comm_num,1} = tline;  %fprintf('COMMENT: %s\n',tline);
        
    else
        
        % Store evaluation line
        eval_num = eval_num + 1;
        eval_line{eval_num,1} = tline;

    end
    
    % Step line number in fid
    tline = fgetl(fid);
    
end

% Now that comments are sorted out from real data, close the file
fclose(fid);
clear eval_num

%% Write to Structure

% First 6 lines of .avl file is constant

% Read Title
input.avl.header.name      = strtrim(eval_line{1});

% Read Mach
temp_mach = textscan(eval_line{2},'%f');
input.avl.header.Mach = temp_mach{1};
clear temp_mach

% Read iYsym, iZsym, Zsym
temp_sym = textscan(eval_line{3},'%f %f %f');
input.avl.header.iYsym     = temp_sym{1};
input.avl.header.iZsym     = temp_sym{2};
input.avl.header.Zsym      = temp_sym{3};
clear temp_sym

% Read Sref, Cref, Bref
temp_ref = textscan(eval_line{4},'%f %f %f');
input.avl.header.Sref      = temp_ref{1};
input.avl.header.Cref      = temp_ref{2};
input.avl.header.Bref      = temp_ref{3};
clear temp_ref

% Read [X,Y,Z]ref
temp_cg = textscan(eval_line{5},'%f %f %f');
input.avl.header.Xref      = temp_cg{1};
input.avl.header.Yref      = temp_cg{2};
input.avl.header.Zref      = temp_cg{3};
clear temp_cg

% Read CDoref
temp_cDo = textscan(eval_line{6},'%f');
input.avl.header.CDoref    = temp_cDo{1};
clear temp_cDo

eval_num = 7;

while eval_num <= length(eval_line)
    
    tline = eval_line{eval_num};
    
    if strcmpi(tline,'BODY')
        
        % Read Body Name
        input.avl.body.Name = tline;
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Read Body Param
        temp_body = textscan(tline,'%f %f');
        input.avl.body.Nbody        = temp_body{1};
        input.avl.body.Bspace       = temp_body{2};
        clear temp_body
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        while ~strcmpi(strtrim(tline),'SURFACE') % until you hit a SURFACE...
            
            if strcmpi(strtrim(tline),'YDUPLICATE')
                
                eval_num = eval_num + 1;
                tline = eval_line{eval_num};
                
                % Read Ydup
                temp_ydup = textscan(tline,'%f');
                input.avl.body.Ydupl = temp_ydup{1};
                clear temp_ydup
                
            elseif strcmpi(strtrim(tline),'SCALE')
                
                eval_num = eval_num + 1;
                tline = eval_line{eval_num};
                
                % Read Scale
                temp_scale = textscan(tline,'%f %f %f');
                input.avl.body.Scale = cell2mat(temp_scale);
                clear temp_scale
                
            elseif strcmpi(strtrim(tline),'TRANSLATE')
                
                eval_num = eval_num + 1;
                tline = eval_line{eval_num};
                
                % Read d[X,Y,Z]
                temp_trans = textscan(tline,'%f %f %f');
                input.avl.body.Trans = cell2mat(temp_trans);
                clear temp_trans
                
            elseif strcmpi(strtrim(tline),'BFIL')
                
                eval_num = eval_num + 1;
                tline = eval_line{eval_num};
                
                % Read Body .dat file
                input.avl.body.Bfile = strtrim(tline);
                
                try

                    % Assumes Body .dat file is stored in ./avl fldr
                    Bfilefull = ['./avl/' input.avl.body.Bfile];
                    
                    if exist(Bfilefull,'file')==2
                        fid2 = fopen(Bfilefull);
                        C = textscan(fid2, '%f %f','HeaderLines',1);
                        fclose(fid2);
                        
                        % Read the documentation for body file specification:
                        % The # of coordinates must be even in order to
                        % calculate the diameter between each Y-upper
                        % and Y-lower value specified.
                        
                        % 1st column X values
                        input.avl.body.Bfile_X = C{1};
                        
                        % 2nd column Y-upper and Y-lower
                        input.avl.body.Bfile_Y = C{2};
                    else
                        warning('Body File Not Found! %s',Bfilefull)
                    end
                    
                catch error_avl_fileread
                    fprintf('Error, keyboard in catch statement...');
                    keyboard
                end
                
            end
            
            eval_num = eval_num + 1;
            tline = eval_line{eval_num};
            
        end % BODY loop
        
    end % HEADER loop 
    
    if strcmpi(strtrim(tline),'SURFACE')
        
        % Initialize/Reset Section Number Counter:
        sect_num = 0;
        
        % Step Forward
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Read Surface Name
        surf_name = genvarname(tline);        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Read Surface Param
        temp_surf = textscan(tline,'%f %f %f %f');
        input.avl.surface.(surf_name).Nchord = temp_surf{1};
        input.avl.surface.(surf_name).Cspace = temp_surf{2};
        if ~isempty(temp_surf{3})
            input.avl.surface.(surf_name).Nspan  = temp_surf{3};
            input.avl.surface.(surf_name).Sspace = temp_surf{4};
        else
            input.avl.surface.(surf_name).Nspan = '';
            input.avl.surface.(surf_name).Sspace = '';
        end
        clear temp_surf
        
        % Assume that YDUPLICATE is empty, may be useful for plotting
        input.avl.surface.(surf_name).Ydupl = '';
        
    elseif strcmpi(strtrim(tline),'COMPONENT')
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Read Lcomp
        temp_comp = textscan(tline,'%f');
        input.avl.surface.(surf_name).Lcomp = temp_comp{1};
        clear temp_comp
        
    elseif strcmpi(strtrim(tline),'YDUPLICATE')
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Read Ydup
        temp_ydup = textscan(tline,'%f');
        input.avl.surface.(surf_name).Ydupl = temp_ydup{1};
        clear temp_ydup
        
    elseif strcmpi(strtrim(tline),'SCALE')
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Read Scale
        temp_scale = textscan(tline,'%f %f %f');
        input.avl.surface.(surf_name).Scale = cell2mat(temp_scale);
        clear temp_scale
        
    elseif strcmpi(strtrim(tline),'TRANSLATE')
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Read d[X,Y,Z]
        temp_trans = textscan(tline,'%f %f %f');
        input.avl.surface.(surf_name).Trans = cell2mat(temp_trans);
        clear temp_trans
        
    elseif strcmpi(strtrim(tline),'ANGLE')
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Read offset added on to the Ainc values for all the defining sections in this surface
        temp_angle = textscan(tline,'%f');
        input.avl.surface.(surf_name).dAinc = temp_angle{1};
        clear temp_angle
        
    elseif strcmpi(strtrim(tline),'NOWAKE')
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Specify if surface is to NOT shed a wake
        input.avl.surface.(surf_name).NOWAKE = 'TRUE';
        
    elseif strcmpi(strtrim(tline),'NOALBE')
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Specify if fixed surface is specified
        input.avl.surface.(surf_name).NOALBE  = 'TRUE';
        
    elseif strcmpi(strtrim(tline),'NOLOAD')
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Specify if forces and moments on surface are included in final F & M calc
        input.avl.surface.(surf_name).NOLOAD  = 'TRUE';
        
    elseif strcmpi(strtrim(tline),'SECTION')
        
        % Initialize/Reset Control Number Counter:
        ctrl_num = 0;
        
        % NOTE: sect_num index used for all keywords within SECTION
        %       in order to align keyword with respective SECTION
        
        sect_num = sect_num + 1; % increment section # counter
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Assign SECTION: Xle Yle Zle Chord Ainc [ Nspan Sspace ]
        temp_sect = textscan(tline,'%f %f %f %f %f %f %f');
        input.avl.surface.(surf_name).SECTION.Xle(1,sect_num)     = temp_sect{1};
        input.avl.surface.(surf_name).SECTION.Yle(1,sect_num)     = temp_sect{2};
        input.avl.surface.(surf_name).SECTION.Zle(1,sect_num)     = temp_sect{3};
        input.avl.surface.(surf_name).SECTION.Chord(1,sect_num)   = temp_sect{4};
        input.avl.surface.(surf_name).SECTION.Ainc(1,sect_num)    = temp_sect{5};
        input.avl.surface.(surf_name).SECTION.Nspan(1,sect_num)   = temp_sect{6};
        input.avl.surface.(surf_name).SECTION.Sspan(1,sect_num)   = temp_sect{7};
        clear temp_sect
        
    elseif strcmpi(strtrim(tline),'NACA')
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Read NACA Airfoil specification
        input.avl.surface.(surf_name).SECTION.NACA(1,sect_num) = textscan(tline,'%f');
        
        % TODO: plot NACA??? 
        
    elseif strcmpi(strtrim(tline),'AIRFOIL')
        
        fprintf('TODO: Add AIRFOIL keyword detection [SURFACE: %s SECTION: %i]',surf_name, sect_num);
        
    elseif strcmpi(strtrim(tline),'AFIL')
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Read Airfoil .dat file
        input.avl.surface.(surf_name).SECTION.Afile{1,sect_num} = strtrim(tline);
        
    elseif strcmpi(strtrim(tline),'DESIGN')
        
        fprintf('TODO: Add DESIGN keyword detection [SURFACE: %s SECTION: %i]',surf_name, sect_num);
        
    elseif strcmpi(strtrim(tline),'CONTROL')
        
        ctrl_num = ctrl_num + 1;
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Assign CONTROL: Name, Gain, Xhinge, XYZhvec, SgnDup
        temp_ctrl = textscan(tline,'%s %f %f %f %f %f %f');
        input.avl.surface.(surf_name).CONTROL.Name(ctrl_num,sect_num)    = temp_ctrl{1};
        input.avl.surface.(surf_name).CONTROL.Gain(ctrl_num,sect_num)    = temp_ctrl{2};
        input.avl.surface.(surf_name).CONTROL.Xhinge(ctrl_num,sect_num)  = temp_ctrl{3};
        input.avl.surface.(surf_name).CONTROL.XYZhvec(ctrl_num,sect_num) = temp_ctrl{4};
        input.avl.surface.(surf_name).CONTROL.SgnDup(ctrl_num,sect_num)  = temp_ctrl{5};
        clear temp_ctrl
        
    elseif strcmpi(strtrim(tline),'CLAF')
        
        eval_num = eval_num + 1;
        tline = eval_line{eval_num};
        
        % Read Airfoil CL-Alpha scale factor
        temp_cla = textscan(tline,'%f');
        input.avl.surface.(surf_name).SECTION.CLaf(1,sect_num) = temp_cla{1};
        clear temp_cla
        
    end % SURFACE loop
    
    eval_num = eval_num + 1;
                
end % MAIN WHILE Loop


end % function
