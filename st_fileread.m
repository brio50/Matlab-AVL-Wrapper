function output = st_fileread(varargin)
%ST_FILEREAD
%   read all of the available .st files created by aerogen.m
%
% 08/28/2014 - BB - Created

% Input Handling
if nargin == 0
    path = uigetdir(pwd,'Select the directory that houses .st files!');
    if isequal(path,0)
        disp('User selected Cancel')
    else
        disp(['User selected ', fullfile(path)])
    end
    mat_file_write = 0;
elseif nargin == 1
    path = varargin{1};
    mat_file_write = 0;
elseif nargin == 2
    path = varargin{1};
    mat_file_write = varargin{2};
end

% Make inconsistent path specification consistent
if ~strcmp(path(end),filesep)
    path = [path filesep];
end

% Collect all of the *.st file names
fileNames = cellstr(ls([path '*.st']));

for iFile = 1:length(fileNames)
    
    % Assign .st filename to struct
    output.avl.st(iFile).filename = fileNames{iFile};
    
    % Read file
    fid = fopen([path filesep fileNames{iFile}]);
    C = textscan(fid, '%s','HeaderLines',1);
    fclose(fid);
    
    % Find control surface assignments based on d# location
    isCtrl = regexp(C{:},'^d\d');
    for iLine = 1:length(isCtrl)
        if ~isempty(isCtrl{iLine})
%             ctrl.(C{:}{iLine-1}) = C{:}{iLine}; % assign as char
            output.avl.st(iFile).(C{:}{iLine}) = C{:}{iLine-1};
        end
    end    
    
    % Assign .st value to struct based on equal sign search
    isEqlSgn = zeros(size(C{:}));
    for iLine = 1:length(isEqlSgn)
        if strcmp(C{:}(iLine),'=')
            isEqlSgn(iLine) = 1;
            
            % capture variable names preceeding equal sign and 
            % ensure valid field name
            st_variable = (C{:}{iLine-1});
            st_variable = strrep(st_variable,'/','_div_');
            st_variable = strrep(st_variable,'''','_prime_');
            
            % corresponding values succeed equal sign
            st_value = str2double(C{:}{iLine+1});
            
            output.avl.st(iFile).(st_variable) = st_value;
            
        end        
    end
    
    % since all of the fields contrain the same data type, one may
    % concatenate all of the list items for that field, eg:
    % [output.avl.st.Xref]
    
end

% Write output to mat file if specified
if mat_file_write
    fprintf('Saving .mat file...\n')
    mat_file = [path 'st_data.mat'];
    save(mat_file,'output','-mat')
    fprintf('Saved %s Successfully!\n',mat_file)
end

end

