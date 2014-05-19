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

% Open file for reading
fid     = fopen(avlFileName,'r'); 
tline   = fgetl(fid);

% Initialize Counters
line_num = 1; % file line number
eval_num = 1; % evaluated line number (excludes comments and empty spaces)

while ischar(tline)      
    
    if strncmp(tline,'!',1) || strncmp(tline,'#',1) || isempty(tline)
        
        % Avoid two comment types and empty lines
        %fprintf('COMMENT: %s\n',tline);
        
        % Step 'file line #,' but don't step 'eval line #'
        line_num = line_num + 1;
        tline = fgetl(fid);
        
    else

        % Read First 6 REAL Header Lines and BODY if it exists...
        
        if eval_num == 1
            
            % Read Title
            input.avl.header.name      = strtrim(tline);
            
        elseif eval_num == 2
            
            % Read Mach
            temp_mach = textscan(tline,'%f');
            input.avl.Mach = temp_mach{1};
            clear temp_mach
            
        elseif eval_num == 3
            
            % Read iYsym, iZsym, Zsym
            temp_sym = textscan(tline,'%f %f %f');
            input.avl.iYsym     = temp_sym{1};
            input.avl.iZsym     = temp_sym{2};
            input.avl.Zsym      = temp_sym{3};
            clear temp_sym
            
        elseif eval_num == 4
            
            % Read Sref, Cref, Bref
            temp_ref = textscan(tline,'%f %f %f');
            input.avl.Sref      = temp_ref{1};
            input.avl.Cref      = temp_ref{2};
            input.avl.Bref      = temp_ref{3};
            clear temp_ref
            
        elseif eval_num == 5
            
            % Read [X,Y,Z]ref
            temp_cg = textscan(tline,'%f %f %f');
            input.avl.Xref      = temp_cg{1};
            input.avl.Yref      = temp_cg{2};
            input.avl.Zref      = temp_cg{3};
            clear temp_cg
            
        elseif eval_num == 6
            
            % Read CDoref
            temp_cDo = textscan(tline,'%f');
            input.avl.CDoref    = temp_cDo{1};
            clear temp_cDo
            
        elseif strcmpi(tline,'BODY')

            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);

            % Read Body Name
            input.avl.body.Name = tline;
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Read Body Param
            temp_body = textscan(tline,'%f %f');
            input.avl.body.Nbody        = temp_body{1};
            input.avl.body.Bspace       = temp_body{2};
            clear temp_body
            
            line_num = line_num + 1;            
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            while ~strcmpi(tline,'SURFACE') % until you hit a SURFACE...
                
                if strcmpi(tline,'YDUPLICATE')
                    
                    line_num = line_num + 1;
                    eval_num = eval_num + 1;
                    tline = fgetl(fid);
                    
                    % Read Ydup
                    temp_ydup = textscan(tline,'%f');
                    input.avl.body.Ydupl = temp_ydup{1};
                    clear temp_ydup
                    
                elseif strcmpi(tline,'SCALE')
                    
                    line_num = line_num + 1;
                    eval_num = eval_num + 1;
                    tline = fgetl(fid);
                    
                    % Read Scale
                    temp_scale = textscan(tline,'%f %f %f');
                    input.avl.body.Scale = cell2mat(temp_scale);
                    clear temp_scale
                    
                elseif strcmpi(tline,'TRANSLATE')
                    
                    line_num = line_num + 1;
                    eval_num = eval_num + 1;
                    tline = fgetl(fid);
                    
                    % Read d[X,Y,Z]
                    temp_trans = textscan(tline,'%f %f %f');
                    input.avl.body.Trans = cell2mat(temp_trans);
                    clear temp_trans
                    
                elseif strcmpi(tline,'BFIL')
                    
                    line_num = line_num + 1;
                    eval_num = eval_num + 1;
                    tline = fgetl(fid);
                    
                    % Read Body .dat file
                    input.avl.body.Bfile = strtrim(tline);
                    
                end
                
                line_num = line_num + 1;
                eval_num = eval_num + 1;
                tline = fgetl(fid);
                
            end % BODY loop
        end % HEADER loop
        
        if strcmpi(tline,'SURFACE')
            
            % Initialize/Reset Section Number Counter:
            sect_num = 0;
        
            % Step Forward
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Read Surface Name
            surf_name = genvarname(tline);
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
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
            
        elseif strcmpi(tline,'COMPONENT')
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Read Lcomp
            temp_comp = textscan(tline,'%f');
            input.avl.surface.(surf_name).Lcomp = temp_comp{1};
            clear temp_comp
            
        elseif strcmpi(tline,'YDUPLICATE')
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Read Ydup
            temp_ydup = textscan(tline,'%f');
            input.avl.surface.(surf_name).Ydupl = temp_ydup{1};
            clear temp_ydup
            
        elseif strcmpi(tline,'SCALE')
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Read Scale
            temp_scale = textscan(tline,'%f %f %f');
            input.avl.surface.(surf_name).Scale = cell2mat(temp_scale);
            clear temp_scale
            
        elseif strcmpi(tline,'TRANSLATE')
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Read d[X,Y,Z]
            temp_trans = textscan(tline,'%f %f %f');
            input.avl.surface.(surf_name).Trans = cell2mat(temp_trans);
            clear temp_trans
            
        elseif strcmpi(tline,'ANGLE')
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Read offset added on to the Ainc values for all the defining sections in this surface
            temp_angle = textscan(tline,'%f');
            input.avl.surface.(surf_name).dAinc = temp_angle{1};
            clear temp_angle
            
        elseif strcmpi(tline,'NOWAKE')
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Specify if surface is to NOT shed a wake
            input.avl.surface.(surf_name).NOWAKE = 'TRUE';
            
        elseif strcmpi(tline,'NOALBE')
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Specify if fixed surface is specified
            input.avl.surface.(surf_name).NOALBE  = 'TRUE';
            
        elseif strcmpi(tline,'NOLOAD')
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Specify if forces and moments on surface are included in final F & M calc
            input.avl.surface.(surf_name).NOLOAD  = 'TRUE';
            
        elseif strcmpi(tline,'SECTION')
            
            % Initialize/Reset Control Number Counter:
            ctrl_num = 0;
            
            % NOTE: sect_num index used for all keywords within SECTION
            %       in order to align keyword with respective SECTION
            
            sect_num = sect_num + 1; % increment section # counter
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
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
            
        elseif strcmpi(tline,'NACA')
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Read NACA Airfoil specification
            input.avl.surface.(surf_name).SECTION.NACA(1,sect_num) = textscan(tline,'%f');
            
        elseif strcmpi(tline,'AIRFOIL')
            
            fprintf('TODO: Add AIRFOIL keyword detection [SURFACE: %s SECTION: %i]',surf_name, sect_num);
            
        elseif strcmpi(tline,'AFIL')
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Read Airfoil .dat file
            input.avl.surface.(surf_name).SECTION.Afile{1,sect_num} = strtrim(tline);
            
        elseif strcmpi(tline,'DESIGN')
            
            fprintf('TODO: Add DESIGN keyword detection [SURFACE: %s SECTION: %i]',surf_name, sect_num);
            
        elseif strcmpi(tline,'CONTROL')
            
            ctrl_num = ctrl_num + 1;
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
                        
            % Assign CONTROL: Name, Gain, Xhinge, XYZhvec, SgnDup
            temp_ctrl = textscan(tline,'%s %f %f %f %f %f %f');
            input.avl.surface.(surf_name).CONTROL.Name(ctrl_num,sect_num)    = temp_ctrl{1};
            input.avl.surface.(surf_name).CONTROL.Gain(ctrl_num,sect_num)    = temp_ctrl{2};
            input.avl.surface.(surf_name).CONTROL.Xhinge(ctrl_num,sect_num)  = temp_ctrl{3};
            input.avl.surface.(surf_name).CONTROL.XYZhvec(ctrl_num,sect_num) = temp_ctrl{4};
            input.avl.surface.(surf_name).CONTROL.SgnDup(ctrl_num,sect_num)  = temp_ctrl{5};
            clear temp_ctrl
            
            input.avl.surface.(surf_name).CONTROL.Xle(ctrl_num,sect_num) = input.avl.surface.(surf_name).SECTION.Xle(1,sect_num);
            input.avl.surface.(surf_name).CONTROL.Yle(ctrl_num,sect_num) = input.avl.surface.(surf_name).SECTION.Yle(1,sect_num);
            input.avl.surface.(surf_name).CONTROL.Zle(ctrl_num,sect_num) = input.avl.surface.(surf_name).SECTION.Zle(1,sect_num);
            
        elseif strcmpi(tline,'CLAF')
            
            line_num = line_num + 1;
            eval_num = eval_num + 1;
            tline = fgetl(fid);
            
            % Read Airfoil CL-Alpha scale factor
            temp_cla = textscan(tline,'%f');
            input.avl.surface.(surf_name).SECTION.CLaf(1,sect_num) = temp_cla{1};
            clear temp_cla
            
        end % SURFACE loop  
        
        line_num = line_num + 1;
        eval_num = eval_num + 1;
        tline = fgetl(fid);
                
    end % COMMENT / EMPTY LINE loop
        
end % FILE PARSING loop
fclose(fid);
