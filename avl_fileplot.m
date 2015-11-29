function [f,h,ax,t] = avl_fileplot(input,plot_method)
%   h = figure handle for all plot elements
%   t = transform object, used to manipulate alpha and beta during run
%
f = [];
h = [];
ax = [];
t = [];

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
    
f = figure('Color',[1 1 1],'WindowStyle','docked');

%% Wrapper Axes
ax(1) = axes('Position',[0.05 0.05 0.9 0.9]);
set(ax(1),'Color','none','Xtick',[],'Ytick',[],'Xlabel',[],'Ylabel',[])
title('Airplane Name')
box on
    
%% Isometric View
ax(2) = axes('Position',[0.5 0.5 0.45 0.45]);
set(get(ax(2),'Title'),'String','Isometric','Color',[1 1 1])
hold all

t = hgtransform; 

% Place CG Marker
XCG = input.header.Xref;
YCG = input.header.Yref;
ZCG = input.header.Zref;
h(1) = plot3(XCG,YCG,ZCG,'.k','MarkerSize',20,'Parent',t);
set(h(1),'DisplayName','cg');

if isfield(input,'body')
    if isfield(input.body,'Bfile')
               
        % Get translation values
        XT = input.body.Trans(1);
        XB = input.body.Bfile_X+XT;
        
        YT = input.body.Trans(2);
        YB = input.body.Bfile_Y+YT;
        
        ZT = input.body.Trans(3);
        ZB = zeros(length(YB),1)+ZT;
        
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
                h(end+1) = plot3(X,Y,Z,'-m','Parent',t);
                set(h(end),'DisplayName',sprintf('body_station_%d',i));
            end
        end
        
        h(end+1) = plot3(CL_X,CL_Y,CL_Z,'-r','Parent',t);
        set(h(end),'DisplayName','center_line');
        h(end+1) = plot3(XB,YB,ZB,'-g','Parent',t);
        set(h(end),'DisplayName','body_line');
        
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
                h(end+1) = plot3(X,Y,Z,'-m','Parent',t);
                set(h(end),'DisplayName','wing_chord_lines')
                
                % Plot if Y Duplicate specified
                if input.surface.(surfaces{i}).Ydupl == 0
                    h(end+1) = plot3(X,-Y,Z,'-m','Parent',t);
                    set(h(end),'DisplayName','wing_chord_lines_ydup')
                end
                
            end
            
            
            %% Plot Outer Mold Lines
            
            % Leading Edge
            h(end+1) = plot3(X1{i},Y1{i},Z1{i},'-g','Parent',t);
            set(h(end),'DisplayName','wing_leading_edge')
            
            % Plot if Y Duplicate specified
            if input.surface.(surfaces{i}).Ydupl == 0
                h(end+1) = plot3(X1{i},-Y1{i},Z1{i},'-g','Parent',t);
                set(h(end),'DisplayName','wing_leading_edge_ydup')
            end
            
            % Trailing Edge
            h(end+1) = plot3(X2{i},Y2{i},Z2{i},'-g','Parent',t);
            set(h(end),'DisplayName','wing_trailing_edge')
            
            % Plot if Y Duplicate specified
            if input.surface.(surfaces{i}).Ydupl == 0
                h(end+1) = plot3(X2{i},-Y2{i},Z2{i},'-g','Parent',t);
                set(h(end),'DisplayName','wing_trailing_edge_ydup')
            end
            
            %% Set Axis Properties
            view(3);
            axis equal, grid on
            xlabel('x'),ylabel('y'),zlabel('z')
            
        end
    end
    
    %% Plot X,Y,Z Arrows

    % Make new axes
    ax(3) = axes('Position',[0.85 0.85 0.1 0.1]);
    set(get(ax(3),'Title'),'String','Body Coordinate Display','Color',[1 1 1])
    hold all, axis equal, axis off,
    linkprop([ax(2) ax(3)],'View'); % syncronize views
    
    % Arrow Shaft
    plot3([0 1],[0 0],[0 0],'-r','DisplayName','x_body')
    plot3([0 0],[0 1],[0 0],'-r','DisplayName','y_body')
    plot3([0 0],[0 0],[0 1],'-r','DisplayName','z_body')
    
    % Labels
    text(1,0,0,' X','Color','r')
    text(0,1,0,' Y','Color','r')
    text(0,0,1,' Z','Color','r')
    
    %% Top View
    ax(4) = axes('Position',[0 0.5 0.45 0.45]);
    set(get(ax(4),'Title'),'String','Top','Color',[1 1 1])
    copyobj(h,ax(4))
    axis equal, axis off
    view([0 0 1])
    
    %% Front View
    ax(5) = axes('Position',[0.5 0 0.45 0.45]);
    set(get(ax(5),'Title'),'String','Front','Color',[1 1 1])
    copyobj(h,ax(5))
    axis equal, axis off
    view([1 0 0])
    
    %% Side View
    ax(6) = axes('Position',[0 0 0.45 0.45]);
    set(get(ax(6),'Title'),'String','Side','Color',[1 1 1]);
    copyobj(h,ax(6))
    axis equal, axis off
    view([0 -1 0])
    
else
    error('Unrecognized plot_method.')
end
