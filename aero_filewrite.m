function aero = aero_filewrite(varargin)
%AERO_FILEREAD
%   convert st file data into an aero structure/database suitable for
%   simulation look up tables
%
% 09/12/2014 - BB - Created

% Input Handling
if nargin == 0
    
    [file,path] = uigetfile({'*.mat','ST MAT-file'},'Select a .mat file that contains .st AVL output data!');
    
    if isequal(file,0)
        disp('User selected cancel.')
    else
        disp(['User selected ', fullfile(path, file)])
    end
    
    name = strrep(file,'.mat','');
    ext = '.mat';
    
    mat_file_write = 0;

elseif nargin <=3
    
    if isstruct(varargin{1})
        data = varargin{1};
    elseif exist(varargin{1},'file') == 2
        [path,name,ext] = fileparts(varargin{1});
    else
        error('Uncregonized input type or file does not exist.')
    end
    
    if nargin == 1
        mat_file_write = 0;  
    elseif nargin == 2
        mat_file_write = varargin{2};
    end
    
else
    
    error('Too many input arguments.');
    
end

% If a file was the input argument, load it!
if exist('ext','var') == 1
    load(fullfile(path,[name ext]));
    data = output;
    clear output
end

% Ensure that we're dealing with a .st mat-file
if ~isfield(data,'avl')
    error('The .mat file you''ve selected does not containt .avl data.');
else 
    if ~isfield(data.avl,'st')
        error('The .mat file you''ve selected does not containt .st data.');
    end
end

%% Determine breakpoint indeces

% Alpha
xbp_name = 'Alpha';
xbp_data = [data.avl.st.(xbp_name)];
[xbp_data_unique,~,iXbp] = unique(xbp_data,'sorted');

% Beta
ybp_name = 'Beta';
ybp_data = [data.avl.st.(ybp_name)];
[ybp_data_unique,~,iYbp] = unique(ybp_data,'sorted');

% Deflection(s)
stFieldNames = fieldnames(data.avl.st);
isAvlSurf = ~cellfun('isempty',regexp(stFieldNames,'^d\d','match'));
avlSurfNames = stFieldNames(isAvlSurf);

for iSurf = 1:length(avlSurfNames)
   
   % assumes that all file names have the same d# assigned to surf name
   % therefore data.avl.st(1) utilized for effector naming.
   effector{iSurf} = data.avl.st(1).(avlSurfNames{iSurf});
   
   % rename 'd1' to 'd1_controlName'
   zbp_name{iSurf} = [avlSurfNames{iSurf} '_' effector{iSurf}];
   for iFile = 1:length(data.avl.st)
        data.avl.st(iFile).(zbp_name{iSurf}) = data.avl.st(iFile).(effector{iSurf});
   end
   
   % remove confusing fields from set
   data.avl.st = rmfield(data.avl.st,avlSurfNames{iSurf});
   data.avl.st = rmfield(data.avl.st,effector{iSurf});
   
   zbp_data{iSurf} = [data.avl.st.(zbp_name{iSurf})];
   [zbp_data_unique{iSurf},~,iZbp{iSurf}] = unique(zbp_data{iSurf},'sorted');
end

% concatenate all surface deflections into a matrix
% zbp_data_cat = cat(1,zbp_data{:});
% 
% for iFile = 1:length(data.avl.st)
%     if all(zbp_data_cat(:,iFile) == 0)
%         data.avl.st(iFile).isSurfNeutral = 1;
%     else
%         data.avl.st(iFile).isSurfNeutral = 0;
%     end
% end

%% Assign Aerodynamic Coefficients based on breakpoint indeces

aero.date = date;

% Assign Reference Variables
isRef = ~cellfun('isempty',regexp(stFieldNames,'ref','match'));
refNames = stFieldNames(isRef);
for iRef = 1:length(refNames)
    aero.(refNames{iRef}) = data.avl.st(1).(refNames{iRef});
end

% Select Aerodynamic Coefficients
coefName = {'CLtot','CYtot','CDtot','Cltot','Cmtot','Cntot'};

% TODO: aero airplane name aero.airplaneName

% Create fields for all aero coefficient names:
% TODO: name lookup, sensible definition;
for iCoef = 1:length(coefName)
    % Stability Derivative
    aero.(coefName{iCoef}).name = [];
    aero.(coefName{iCoef}).xbp_name = xbp_name;
    aero.(coefName{iCoef}).ybp_name = ybp_name;
    aero.(coefName{iCoef}).xbp_data = xbp_data_unique;
    aero.(coefName{iCoef}).ybp_data = ybp_data_unique;
    aero.(coefName{iCoef}).size = [length(xbp_data_unique) length(ybp_data_unique)];
    aero.(coefName{iCoef}).data = NaN(aero.(coefName{iCoef}).size);
    for iSurf = 1:length(zbp_name)
        % Control Derivative
        aero.([coefName{iCoef} '_' zbp_name{iSurf}]).name = [];
        aero.([coefName{iCoef} '_' zbp_name{iSurf}]).xbp_name = xbp_name;
        aero.([coefName{iCoef} '_' zbp_name{iSurf}]).ybp_name = ybp_name;
        aero.([coefName{iCoef} '_' zbp_name{iSurf}]).zbp_name = zbp_name{iSurf};
        aero.([coefName{iCoef} '_' zbp_name{iSurf}]).xbp_data = xbp_data_unique;
        aero.([coefName{iCoef} '_' zbp_name{iSurf}]).ybp_data = ybp_data_unique;
        aero.([coefName{iCoef} '_' zbp_name{iSurf}]).zbp_data = zbp_data_unique{iSurf};
        aero.([coefName{iCoef} '_' zbp_name{iSurf}]).size = [length(xbp_data_unique) length(ybp_data_unique) length(zbp_data_unique{iSurf})];
        aero.([coefName{iCoef} '_' zbp_name{iSurf}]).data = NaN(aero.([coefName{iCoef} '_' zbp_name{iSurf}]).size);
    end
end

% Go through all aero coefficient names and fill data
for iFile = 1:length(data.avl.st)
    for iCoef = 1:length(coefName)
        %TODO: somethhing is wrong here... only need to record stab deriv
        %for neutral cases.
        iAlpha = iXbp(iFile);
        iBeta = iYbp(iFile);
        % Stability Derivatives
        aero.(coefName{iCoef}).data(iAlpha,iBeta) = data.avl.st(iFile).(coefName{iCoef});
        for iSurf = 1:length(zbp_name)
            iDefl = iZbp{iSurf}(iFile);
%             fprintf('%s = %d deg\n',zbp_name{iSurf},zbp_data_unique{iSurf}(iZbp{iSurf}(iFile)));
            % Control Derivatives
%             error('THIS IS NOT CORRECT AT THE MOMENT, NEED TO SUBTRACT NEUTRAL POSITIONS FROM THESE!')
            aero.([coefName{iCoef} '_' zbp_name{iSurf}]).data(iAlpha,iBeta,iDefl) = data.avl.st(iFile).(coefName{iCoef});
        end
        keyboard
        aero
    end
end

keyboard
