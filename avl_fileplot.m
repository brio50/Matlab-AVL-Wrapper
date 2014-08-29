function avl_fileplot(input,plot_method)

if strcmpi(plot_method,'avl')
    %% Write AVL Command File
    
    % TODO: The idea was to use AVL's geometry plot command and place
    %       its output in a GUI window, but I don't have an elegant way
    %       to do it...
    
    % Open the file with write permission
    fid = fopen('plot.txt', 'wt');
    
    % Load the AVL definition of the aircraft
    fprintf(fid, 'LOAD %s\n', [fileName,'.avl']);
    
    % Open the OPER menu
    fprintf(fid, '%s\n',   'OPER');
    
    % Plot Geometry
    fprintf(fid, '%s\n',   'G');
    
    % Front
    fprintf(fid, '%s\n',   'V');
    fprintf(fid, '%s\n',   '0 0');
    % Side
    
    % Top
    
    % Quit Program
    fprintf(fid, '\n');
    fprintf(fid, 'Quit\n');
    
    % Close File
    fclose(fid);
    
    %% Execute Run
    
    % REDIRECTION OPERATOR
    
    % [status,result] = dos('avl.exe < plot.txt &'); %,'-echo');
    evalin('base','!avl.exe < plot.txt');
    
elseif strcmpi(plot_method,'matlab')
    
figure('Color',[1 1 1])
hold all

% Place CG Marker
XCG = input.header.Xref;
YCG = input.header.Yref;
ZCG = input.header.Zref;
plot3(XCG,YCG,ZCG,'.k','MarkerSize',20);
h(1) = gca;

if isfield(input,'body')
    if isfield(input.body,'Bfile')
               
        % Get translation values
        XT = input.body.Trans(1);
        XB = input.body.Bfile_X+XT;
        
        YT = input.body.Trans(2);
        YB = input.body.Bfile_Y+YT;
        
        ZT = input.body.Trans(3);
        ZB = zeros(length(YB))+ZT;
        
        % TODO: allow even #'s of length(XB) only
        for i=1:(length(XB)/2)
            
            D(i) = abs(YB(i)) + abs(YB(end-i));
            % Diameter and Radius
            R(i) = D(i)/2;
            
            % Centerline
            CL_X(i) = XB(i);
            CL_Y(i) = YT;
            CL_Z(i) = ZT;
           
            % AVL assumed a circular fuselage cross-section
            theta = 0:pi/8:2*pi;
            X = CL_X(i) * ones(size(theta));
            Y = CL_Y(i) + R(i).*cos(theta); % 'X'
            Z = CL_Z(i) + R(i).*sin(theta); % 'Y'
            
            % Plot every other fuse x-sec to keep from bogging down plot
            if mod(i,2) == 1
                plot3(X,Y,Z,'-m')
            end
        end
        
        plot3(CL_X,CL_Y,CL_Z,'-r')
        plot3(XB,YB,ZB,'-g')

        % TODO: specify handle title to the body name
        
    else
        error('Did not detect any Body shape file. Cannot plot Body.')
    end

else
    warning('Did not detect any body within AVL file input.')
end

if isfield(input,'surface')
    surfaces = fieldnames(input.surface);
else
    keyboard
    error('Did not detect any surfaces within AVL file input.')
end

    for i = 1:length(surfaces)
        fprintf('%s\n',surfaces{i});
        for j = 1:length(input.surface.(surfaces{i}).SECTION)
            
            % If surface angle incidence is specified, capture it to be
            % applied later for Z coordinate calculation
            if isfield(input.surface.(surfaces{i}),'dAinc')
                dAinc = input.surface.(surfaces{i}).dAinc;
            else
                dAinc = 0;
            end
            
            for k = 1:length(input.surface.(surfaces{i}).SECTION.Xle)
                % AVL axes are different than aircraft axes
                % X Y Z [AC] = -X Y -Z [AVL]
                
                XT = input.surface.(surfaces{i}).Trans(1);
                XC = input.surface.(surfaces{i}).SECTION.Chord(k);
                X1{i}(j,k) = input.surface.(surfaces{i}).SECTION.Xle(k)+XT;
                X2{i}(j,k) = input.surface.(surfaces{i}).SECTION.Xle(k)+XT+XC;

                X  = [X1{i}(j,k),X2{i}(j,k)];
                
                YT = input.surface.(surfaces{i}).Trans(2);
                Y1{i}(j,k) = input.surface.(surfaces{i}).SECTION.Yle(k)+YT;
                Y2{i}(j,k) = Y1{i}(j,k);
                
                Y  = [Y1{i}(j,k),Y2{i}(j,k)];
                                
                ZT = input.surface.(surfaces{i}).Trans(3);
                Z1{i}(j,k) = input.surface.(surfaces{i}).SECTION.Zle(k)+ZT;
                ANGLE = input.surface.(surfaces{i}).SECTION.Ainc(k)+dAinc;
                Z2{i}(j,k) = (X2{i}(j,k)-X1{i}(j,k))*sind(ANGLE)+ZT+Z1{i}(j,k);
                
                Z  = [Z1{i}(j,k),Z2{i}(j,k)];
                
                %% Plot Chordwise
                H{i}(1) = plot3(X,Y,Z,'-m');
                
                % Plot if Y Duplicate specified
                if input.surface.(surfaces{i}).Ydupl == 0
                    H{i}(2) = plot3(X,-Y,Z,'-m');
                end
                
            end
            
            
            %% Plot Outer Mold Lines
            
            % Leading Edge
            H{i}(3) = plot3(X1{i},Y1{i},Z1{i},'-g');
            
            % Plot if Y Duplicate specified
            if input.surface.(surfaces{i}).Ydupl == 0
                H{i}(4) = plot3(X1{i},-Y1{i},Z1{i},'-g');
            end
            
            % Trailing Edge
            H{i}(5) = plot3(X2{i},Y2{i},Z2{i},'-g');
            
            % Plot if Y Duplicate specified
            if input.surface.(surfaces{i}).Ydupl == 0
                H{i}(6) = plot3(X2{i},-Y2{i},Z2{i},'-g');
            end
            
            %% Set Axis Properties
            view(3);
            axis equal, grid on
            xlabel('x'),ylabel('y'),zlabel('z')
            
        end
    end
    
    %% Plot X,Y,Z Arrows

    % Make new axes
    h(2) = axes('Position',[0.05 0.05 0.1 0.1]);
    hold all,  axis equal, axis off,
    linkprop(h,'View'); % syncronize views
    
    % Arrow Shaft
    plot3([0 1],[0 0],[0 0],'-r')
    plot3([0 0],[0 1],[0 0],'-r')
    plot3([0 0],[0 0],[0 1],'-r')
    
    % Labels
    text(1,0,0,' X','Color','r')
    text(0,1,0,' Y','Color','r')
    text(0,0,1,' Z','Color','r')
    
else
    error('Unrecognized plot_method.')
end