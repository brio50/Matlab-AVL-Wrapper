function avl_fileplot(input,method)

if strcmpi(method,'avl')
    %% Write AVL Command File
    
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
    
elseif strcmpi(method,'matlab')
    
figure %('Color',[0 0 0])
hold all

% Place CG Marker
XCG = input.header.Xref;
YCG = input.header.Yref;
ZCG = input.header.Zref;
plot3(XCG,YCG,ZCG,'.k','MarkerSize',20)

    surfaces = fieldnames(input.surface);
    for i = 1:length(surfaces)
        fprintf('%s\n',surfaces{i});
        for j = 1:length(input.surface.(surfaces{i}).SECTION)
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
                Z2{i}(j,k) = (X2{i}(j,k)-X1{i}(j,k))*sind(input.surface.(surfaces{i}).SECTION.Ainc(k))+ZT+Z1{i}(j,k);
                
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
            
            % Axis Properties
            view(3);
            axis equal
            xlabel('x'),ylabel('y'),zlabel('z')
            
        end
        
        % Rotate if dAinc specified
        if isfield(input.surface.(surfaces{i}),'dAinc')
            if input.surface.(surfaces{i}).dAinc ~= 0
                rotate(H{i},[0 1 0],input.surface.(surfaces{i}).dAinc)
            end
        end
        
    end
        
    ORIGIN = min(str2num(get(gca,'YTickLabel')));
    keyboard
    % Arrow Shaft
    plot3(ORIGIN+[0 5],ORIGIN+[0 0],ORIGIN+[0 0],'-r')
    plot3(ORIGIN+[0 0],ORIGIN+[0 5],ORIGIN+[0 0],'-r')
    plot3(ORIGIN+[0 0],ORIGIN+[0 0],ORIGIN+[0 5],'-r')
    
    % Arrow Head
%     plot3(5,0,0,'.r','MarkerSize',20)
%     plot3(0,5,0,'.r','MarkerSize',20)
%     plot3(0,0,5,'.r','MarkerSize',20)
    
else
    error('Unrecognized method.')
end